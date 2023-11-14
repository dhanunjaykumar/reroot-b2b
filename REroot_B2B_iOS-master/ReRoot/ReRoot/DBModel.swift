//
//  Model.swift
//  ReRoot
//
//  Created by Dhanunjay on 13/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import CoreData

class DBModel {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    init() {
        managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    func writeAllProjectsToDB(projectsArray : [ProjectInfo]) -> Bool {
        
        self.resetProjectsEntity()
        var counter = 1
        for projDict in projectsArray{
            
//            print(projDict)
           
            let tempPro = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedObjectContext) as! Project

            tempPro.address = projDict.address;
            tempPro.far = Int64(projDict.FAR!)
            tempPro.city = projDict.city
            tempPro.company = projDict.company
            tempPro.company_group = projDict.company_group
            tempPro.id = projDict._id
            tempPro.images = projDict.images
            tempPro.imagesTemp = projDict.imagesTemp
            tempPro.incharge = projDict.incharge
            tempPro.orderId = Int64(counter)
            counter += 1
//            guard let name = projDict.landArea else{
//                return
//            }
            
//            let person = Project(context: context)
//            person.add
            
            
            if((projDict.landArea?.nsDictionary) != nil){
                tempPro.landArea = projDict.landArea?.nsDictionary
            }
            
            tempPro.name = projDict.name
            
            if((projDict.builtUpArea?.nsDictionary) != nil){
                tempPro.builtUpArea = projDict.builtUpArea?.nsDictionary
            }
            if((projDict.superBuiltUpArea?.nsDictionary) != nil){
                tempPro.superBuiltUpArea = projDict.superBuiltUpArea?.nsDictionary
            }
            tempPro.proj_code = projDict.proj_code
            tempPro.proj_type = projDict.proj_type
            tempPro.status = Int16(projDict.status!)
            tempPro.state = projDict.state
            
            
            let orderdSet : NSMutableOrderedSet = []
            if(projDict.stats?.count != nil){
                
                for tempStat in projDict.stats!{
                    if(tempStat.count == nil){
                        continue
                    }
                    let friend1 = TempObj(context: managedObjectContext)
                    friend1.count = Int64(tempStat.count!)
                    friend1.status = Int16(tempStat.status!)
                    orderdSet.add(friend1)
                    tempPro.addToProStat(friend1)

                }
                
                tempPro.setValue(orderdSet, forKey: "proStat")
//                tempPro.stats = projDict.stats as NSArray?
//                print("fdfdf \(tempPro.stats)")
            }
            else{
                print("NO STATSSS")
//                 tempPro.stats = []
//                continue
            }
            
            tempPro.segment = projDict.segment
            tempPro.short_name = projDict.short_name
            
//            if((projDict.updateBy?.count)! > 0){
//                tempPro.updateBy = projDict.updateBy as NSArray?
//            }
//            if((projDict.sanctions?.count)! > 0){
//                tempPro.sanctions = projDict.sanctions as NSArray?
//            }
//            tempPro.sanctions = projDict.sanctions.?NSDictionary
            
//            tempPro.sanctions = projDict.sanctions.nsc
//            tempPro.sanctions = projDict.sanctions.
            
//            do {
//                try managedObjectContext.save()
//                return true
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//                return false
//            }
            
        }
        
//        activityInfo.activitiesArray = activityArray as NSArray
//        activityInfo.idForUploadCheck = UUID().uuidString.lowercased()
        
        do {
            try managedObjectContext.save()
//            self.getAllProjects()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }

//        return false
    }
    func getProjectDetailsById(projectId:String) -> Project
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
//        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "id CONTAINS[c] %@", projectId)
        fetchRequest.predicate = predicate
        let projectList = try! managedObjectContext.fetch(fetchRequest)
        
        print(projectList)
        
        let project = projectList[0]
        
        return project as! Project
        
    }
    func getProjectsCount() -> Int{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func getAllProjectRecords() -> Array<Project>{
        
        let projects = NSFetchRequest<Project>(entityName: "Project")
        projects.resultType = .dictionaryResultType
        
        do {
            let projectList = try managedObjectContext.fetch(projects)
            
//            for project in projectList{
//
//                for stat in project.proStat!{
//                    print(stat)
//                }
//            }
            
            return projectList
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func resetProjectsEntity() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    func updateStatusOfSelectedUnit(selectedProjectId : String,oldStatus : Int, updatedStatus : Int){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        fetchRequest.predicate = NSPredicate(format: "id = %@",
                                             argumentArray: [selectedProjectId])
        do {
            let results = try managedObjectContext.fetch(fetchRequest) as? [Project]
            if results?.count != 0 { // Atleast one was returned
                
                // In my case, I only updated the first item in results
                
                let project = results![0]
                
                let statssss : NSMutableOrderedSet = project.value(forKey: "proStat") as! NSMutableOrderedSet
                
                for stat in statssss{
                    
                    let actualStats = stat as! TempObj
                    
                    if(Int(actualStats.status) == updatedStatus){
                        actualStats.count = actualStats.count + 1
                    }
                    if(actualStats.status == oldStatus){
                        actualStats.count = actualStats.count - 1
                    }
                }
                
                results![0].setValue(statssss, forKey: "proStat")
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        do {
            try managedObjectContext.save()
            print("Project statuses updated")
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
        
    }
    func getAllProjects() -> Array<Project>{
        
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptors = [sortDescriptor]
            activityInfo.sortDescriptors = sortDescriptors

            let fetchedActivities = try managedObjectContext.fetch(activityInfo) as! [Project]
            print("fetchedActivities \(fetchedActivities)")
            
//            for projDict in fetchedActivities{
//                print(projDict.address)
//            }
            
            for project in fetchedActivities{
                
                let statssss : NSMutableOrderedSet = project.value(forKey: "proStat") as! NSMutableOrderedSet
                print("stsaa \(String(describing: statssss))")
                
                for temperrr in statssss{
                    print(statssss)
                    let tester = temperrr as! TempObj
                    print(tester.count)
                    print(tester.status)
                }
                
//                if(statssss != nil){
//                    for temperr in statssss{
//                        print(temperr.status)
//                    }
//                }
//                for stat in statssss{
//
//                }
//
            }

            
            return fetchedActivities
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }

    }
    
}
