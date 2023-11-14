//
//  SyncHelper.swift
//  REroot
//
//  Created by Dhanunjay on 6/27/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import Foundation
import UIKit
import AWSS3
import Alamofire
import PKHUD
import CoreData

let handoverGroup = DispatchGroup()
let missedImagesGroup = DispatchGroup()

final class SyncHelper : SingletonOne {
    
    static var shared = SyncHelper()

    private init(){
        
    }

    func uploadMissedImages(completionHandler: @escaping (Bool, Error?) -> ()){
        
        var uploadImagesFetchedResultsController : NSFetchedResultsController<MissedImages>!
        
        let request: NSFetchRequest<MissedImages> = MissedImages.fetchRequest()
        request.sortDescriptors = []

        uploadImagesFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        let fileManager = FileManager.default

        do{
            try  uploadImagesFetchedResultsController.performFetch()
            
            let missedImageObjs =  uploadImagesFetchedResultsController?.fetchedObjects ?? []
            
            for eachObj in missedImageObjs{
                
                // get item  using itemId
                let handoverItem = RRUtilities.sharedInstance.model.getHandoverItemById(itemID: eachObj.handOverItemId ?? "")
                
                if(handoverItem != nil){
                    
                    let imageDetails = AWS_INPUTS(imageName: URL.init(string: eachObj.imagePath!)?.lastPathComponent, imageURL: URL.init(string: eachObj.imagePath!), type: AWS_TYPE.handover)
                    missedImagesGroup.enter()
                    RRUtilities.sharedInstance.uploadImge(imageDetails: imageDetails, completionHandler: { (responeStr , error) in
                        if(responeStr != nil){
                            
                            handoverItem!.complaintimgUrls?.append(responeStr!)
                            
                            if(fileManager.fileExists(atPath: URL.init(string: eachObj.imagePath!)!.relativePath)){
                                try! fileManager.removeItem(at: URL.init(string: eachObj.imagePath!)!)
                            }
                        }
                        else{
                            
                        }
                        missedImagesGroup.leave()
                    })
                }
                else{
                    // delete missed image
                    RRUtilities.sharedInstance.model.managedObjectContext.delete(eachObj)
                }
            }
        }
        catch{
            
        }
        
        missedImagesGroup.notify(queue: DispatchQueue.main, execute: {
            print("Finished all requests.")
            try! RRUtilities.sharedInstance.model.managedObjectContext.save()
            completionHandler(true,nil)
        })
    }
    
     func uploadHandoverData(completionHandler: @escaping (Bool, Error?) -> ()){
        DispatchQueue.global().async {
            self.uploadMissedImages(completionHandler: { (response,error) in
                self.uploadHandoverItems(completionHandler: { (response,error) in
                    completionHandler(true,nil)
                })
            })
        }
    }
    func uploadHandoverItems(completionHandler: @escaping (Bool, Error?) -> ()){
        
        var uploadUnitsFetchedResultsController : NSFetchedResultsController<SoldUnits>!
        var fetchedResultsControllerHandOverItems : NSFetchedResultsController<TowerHandOverItems>!
        
        //fetch all units with diryt state upload them and make dirty to clean
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let request: NSFetchRequest<SoldUnits> = SoldUnits.fetchRequest()
        
        let predicate = NSPredicate(format: "syncDirty == %d",SYNC_STATE.SYNC_DIRTY.rawValue)
        
        request.predicate = predicate
        
        request.sortDescriptors = []
        
        let fileManager = FileManager.default
        
        uploadUnitsFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try uploadUnitsFetchedResultsController?.performFetch()
            
            let fetchedUnits : [SoldUnits] = uploadUnitsFetchedResultsController.fetchedObjects ?? []
            
            if(fetchedUnits.count == 0){
                completionHandler(true,nil)
                return
            }
            
            for eachUnit in fetchedUnits{
                
                // fetch items related to Untis and upload each item images and sycn to DB
                
                let request: NSFetchRequest<TowerHandOverItems> = TowerHandOverItems.fetchRequest()
                let predicate = NSPredicate(format: "unit CONTAINS[c] %@ AND hasOfflineImages == %d",eachUnit.id!,true)
                request.predicate = predicate
                request.sortDescriptors = []
                
                fetchedResultsControllerHandOverItems = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
                
                do {
                    try fetchedResultsControllerHandOverItems.performFetch()
                    
                    let unitHandOverItems : [TowerHandOverItems] = fetchedResultsControllerHandOverItems.fetchedObjects ?? []
                    if(unitHandOverItems.count == 0){
                        //                        self.uploadHandOverUnitsWithoutImageChanges(shouldPostNotification: shouldPostNotification,isFromHomeView: isFromHomeView)
                    }
                    else{
                        var uploadImagesCount = 0
                        for eachItem in unitHandOverItems{
                            
                            if(eachItem.offlineImges != nil && eachItem.offlineImges!.count > 0){
                                //Upload all images
                                uploadImagesCount += eachItem.offlineImges!.count
                                // upload image and remove local path  n image  and add it to complainimages
                                let imagesArray : [String] = eachItem.offlineImges!
                                for imageUrl in imagesArray{
                                    
                                    // get image
                                    let imageDetails = AWS_INPUTS(imageName: URL.init(string: imageUrl)?.lastPathComponent, imageURL: URL.init(string: imageUrl), type: AWS_TYPE.handover)
                                    handoverGroup.enter()
                                    RRUtilities.sharedInstance.uploadImge(imageDetails: imageDetails, completionHandler: { (responeStr , error) in
                                        if(responeStr != nil){
                                            
                                            eachItem.complaintimgUrls?.append(responeStr!)
                                            
                                            eachItem.offlineImges = eachItem.offlineImges?.filter{ $0 != imageUrl }
                                            
                                            if(fileManager.fileExists(atPath: URL.init(string: imageUrl)!.relativePath)){
                                                try! fileManager.removeItem(at: URL.init(string: imageUrl)!)
                                            }
                                            //save
                                            if(eachItem.offlineImges!.count == 0){
                                                //change
                                                eachUnit.didUploadAllImages = true
                                            }
                                            try! RRUtilities.sharedInstance.model.managedObjectContext.save()
                                            handoverGroup.leave()
                                        }
                                        else{
                                            //append this to DB as failed to upload , and try next time ***
                                            eachItem.offlineImges = eachItem.offlineImges?.filter{ $0 != imageUrl }
                                            
                                            let missedImages = NSEntityDescription.insertNewObject(forEntityName: "MissedImages", into: RRUtilities.sharedInstance.model.managedObjectContext) as! MissedImages
                                            missedImages.unitID = eachUnit.id
                                            missedImages.handOverItemId = eachItem.id
                                            missedImages.imagePath = imageUrl
                                            
                                            if(eachItem.offlineImges!.count == 0){
                                                //change
                                                eachUnit.didUploadAllImages = true
                                                //call one funtion to check saved imags count same then upload all units  ** and refresh data?
                                            }
                                            
                                            try! RRUtilities.sharedInstance.model.managedObjectContext.save()
                                            handoverGroup.leave()
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
                catch {
                    fatalError("Error in fetching records")
                }
            }
            handoverGroup.notify(queue: DispatchQueue.main, execute: {
                print("Finished all requests.")
                //                completionHandler(true,nil)
                self.syncUnisWithServer(completionHandler: {(response,error) in
                    if(response){
                        completionHandler(true,nil)
                    }
                    else{
                        completionHandler(false,nil)
                    }
                })
            })
            
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    func syncUnisWithServer(completionHandler: @escaping (Bool, Error?) -> ()){
        
        var dirtyCountUnitsFetchedResultsController : NSFetchedResultsController<SoldUnits>!

        let request: NSFetchRequest<SoldUnits> = SoldUnits.fetchRequest()
        
        let predicate = NSPredicate(format: "syncDirty == %d",SYNC_STATE.SYNC_DIRTY.rawValue)
        request.predicate = predicate
        request.sortDescriptors = []
        dirtyCountUnitsFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        try! dirtyCountUnitsFetchedResultsController.performFetch()
        
        ServerAPIs.syncOfflineHandoverUnits(units: dirtyCountUnitsFetchedResultsController.fetchedObjects!, completionHandler: {(responseObject,error) in
            
            if(responseObject?.status == 1){
                
                for eachObj in dirtyCountUnitsFetchedResultsController.fetchedObjects!{
                    eachObj.syncDirty = Int16(SYNC_STATE.SYNC_CLEAN.rawValue)
                }
                try! RRUtilities.sharedInstance.model.managedObjectContext.save()
                completionHandler(true,nil)
            }
            else{
                completionHandler(false,nil)
            }
        })
    }
    
}
