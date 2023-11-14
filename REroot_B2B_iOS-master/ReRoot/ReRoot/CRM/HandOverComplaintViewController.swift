//
//  HandOverComplaintViewController.swift
//  REroot
//
//  Created by Dhanunjay on 28/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import AWSS3
import PKHUD
import AWSCore


protocol ImageDelegate : class {
    func showHandOverItemImges(imagesArray : [String])
}
extension ImageDelegate{
    func showHandOverItemImges(imagesArray : [String]){
    }
}

class HandOverComplaintViewController: UIViewController {

    var imagesArray : [String] = []
    var offlineImagesArray : [String] = []
    var buttonIndex : Int!
    @IBOutlet weak var imagesButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var contentView: UIView!
    var imagePicker: ImagePicker!
    var selectedHandOverItem : TowerHandOverItems!
    weak var delegate : ImageDelegate?
    weak var delegate1 : ProspectUpdateDelegate?

    @objc lazy var transferUtility = {
        AWSS3TransferUtility.default()
    }()
    @objc var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    @objc var progressBlock: AWSS3TransferUtilityProgressBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    func configureView(){
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        if((selectedHandOverItem.complaintimgUrls != nil && selectedHandOverItem.complaintimgUrls!.count > 0) || (selectedHandOverItem.offlineImges != nil && selectedHandOverItem.offlineImges!.count > 0)){
            self.shouldShowImagesButton(shouldShow: true)
        }
        else{
            self.shouldShowImagesButton(shouldShow: false)
        }

        locationTextView.layer.cornerRadius = 4
        descriptionTextView.layer.cornerRadius = 4
        locationTextView.layer.borderWidth = 1
        locationTextView.layer.borderColor = UIColor.hexStringToUIColor(hex: "d4d4d4").cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.hexStringToUIColor(hex: "d4d4d4").cgColor
        
        chooseButton.backgroundColor = UIColor.hexStringToUIColor(hex: "4a4a4a")
        takePictureButton.backgroundColor = UIColor.hexStringToUIColor(hex: "4a4a4a")
        chooseButton.layer.cornerRadius = 8
        takePictureButton.layer.cornerRadius = 8
        chooseButton.setTitleColor(.white, for: .normal)
        takePictureButton.setTitleColor(.white, for: .normal)
        contentView.layer.cornerRadius = 8
        
        descriptionTextView.text = self.selectedHandOverItem.complaintDesc
        locationTextView.text = self.selectedHandOverItem.complaintlocation
        
        if(self.selectedHandOverItem.complaintimgUrls!.count > 0){
            self.shouldShowImagesButton(shouldShow: true)
        }
        self.imagesArray = self.selectedHandOverItem.complaintimgUrls!
    }
    func updateHandOverItem(){
        
        let childContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = RRUtilities.sharedInstance.model.managedObjectContext
        
        let childEntry = childContext.object(
            with: selectedHandOverItem!.objectID) as? TowerHandOverItems
        
        childEntry?.complaintDesc = "testing"
        
        childContext.perform {
            do {
                try childContext.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            RRUtilities.sharedInstance.model.saveContext()
            NotificationCenter.default.post(name: NSNotification.Name("FecthHandOverItems"), object: nil)
        }
    }
    func shouldShowImagesButton(shouldShow : Bool){
        self.imagesButton.isHidden = !shouldShow
    }
    @IBAction func openCamera(_ sender: Any) {
        self.imagePicker.takePhoto(from: takePictureButton)
    }
    @IBAction func hideKeyBoard(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func chooseFromGallery(_ sender: Any) {
         self.imagePicker.takeFromPhotos(from: chooseButton)
    }
    @IBAction func saveComplaint(_ sender: Any) {
        
        //Decide whether handover item should be checked or unchecke
        
        //Update item state ***
        
        // Update description , lcoation images array and save to DB
        
        if(buttonIndex == 1){
         
            if(self.selectedHandOverItem.handOverStatus == HAND_OVER_ITEM_STATE.STATUS_COMPLETED.rawValue){
                self.selectedHandOverItem.handOverStatus = Int32(HAND_OVER_ITEM_STATE.STATUS_INCOMPLETE.rawValue)
            }
            else if(self.selectedHandOverItem.handOverStatus == HAND_OVER_ITEM_STATE.STATUS_INCOMPLETE.rawValue){
                self.selectedHandOverItem.handOverStatus = Int32(HAND_OVER_ITEM_STATE.STATUS_COMPLETED.rawValue)
            }
        }
        else{
            self.selectedHandOverItem.handOverStatus = Int32(HAND_OVER_ITEM_STATE.STATUS_INCOMPLETE.rawValue)
        }
        
        let childContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = RRUtilities.sharedInstance.model.managedObjectContext
        
        let childEntry = childContext.object(
            with: selectedHandOverItem!.objectID) as? TowerHandOverItems
        
        childEntry?.complaintDesc = self.descriptionTextView.text
        childEntry?.complaintlocation = self.locationTextView.text
        childEntry?.complaintimgUrls = self.imagesArray
        if(childEntry?.offlineImges != nil){
            childEntry?.offlineImges?.append(contentsOf: self.offlineImagesArray)
        }
        else{
            childEntry?.offlineImges = self.offlineImagesArray
        }
        childEntry?.hasOfflineImages = (self.offlineImagesArray.count > 0) ? true : false
        
        childContext.perform {
            do {
                try childContext.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            RRUtilities.sharedInstance.model.saveContext()
            NotificationCenter.default.post(name: NSNotification.Name("FecthHandOverItems"), object: nil)
        }

        var infoDict : Dictionary<String,Int> = [:]
        infoDict["isSave"] = 1
        infoDict["buttonIndex"] = buttonIndex
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.UPDATE_HO_ITEM_STATE), object: nil, userInfo: infoDict)
        
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func close(_ sender: Any) {
        
        for imagePath in self.offlineImagesArray{
            let path = URL.init(string: imagePath)!.relativePath
            if(FileManager.default.fileExists(atPath: path)){
               try! FileManager.default.removeItem(atPath: path)
            }
        }
        
        var infoDict : Dictionary<String,Int> = [:]
        infoDict["isSave"] = 0
        infoDict["buttonIndex"] = buttonIndex
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.UPDATE_HO_CLOSE_COMPLAINT), object: nil, userInfo: infoDict)

        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func showImages(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let floorPlanController = storyboard.instantiateViewController(withIdentifier :"floorPlan") as! FloorPlanViewController
        floorPlanController.planType = PLAN_TYPE.HAND_OVER_ITEM
        floorPlanController.handOverImages = self.imagesArray
        floorPlanController.selectedHandOverItem = self.selectedHandOverItem
        floorPlanController.delegate = self
        if(selectedHandOverItem.offlineImges != nil){
            floorPlanController.handOverImages.append(contentsOf: selectedHandOverItem.offlineImges!)
        }
        floorPlanController.handOverImages.append(contentsOf: self.offlineImagesArray)
        let tempNavigator = UINavigationController.init(rootViewController: floorPlanController)
        tempNavigator.navigationBar.isHidden = true
        self.present(tempNavigator, animated: true, completion: {
            //perhaps we'll do something here later
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension HandOverComplaintViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?,imageName : String?) {
        
        if(image == nil)
        {
            return
        }
        
        let resizedImge = RRUtilities.sharedInstance.resize(image!)

        var tempImageName = ""

        if(imageName != nil){
            tempImageName = RRUtilities.sharedInstance.getCurrentTimeAsString() + "_" + imageName!
        }
        else{
            tempImageName = RRUtilities.sharedInstance.getCurrentTimeAsString()
        }

        // if internet is there store the URL directly to item in DB , if not create folder with item id and store imgaes , n check for images while uploading  , if image is there  upload to S3 and update the image in db and do final upload of all items
        
//        print(resizedImge)
        
        let savedImagePath = RRUtilities.sharedInstance.saveImageToDocumentsFolder(image!, name: tempImageName,folderNameId: "HO")
        
        self.offlineImagesArray.append(savedImagePath!.absoluteString)
        
        if(self.imagesButton.isHidden){
            self.shouldShowImagesButton(shouldShow: true)
        }
    }
    
}
extension HandOverComplaintViewController : FloorPlanDelegate{
    
    func deleteSelectedimage(imageUrl: String, selectedItemID: String) {
            print(imageUrl)
            print(selectedItemID)
        
        var offlineImages : Array<String>  = []
        var onlineImages : Array<String> = []
        
        if(selectedHandOverItem.offlineImges != nil && (selectedHandOverItem.offlineImges?.contains(imageUrl))!){
                print("FOuND1 2")
            offlineImages = selectedHandOverItem.offlineImges!.filter({ $0 != imageUrl })
            
        }
        else{
            offlineImages = selectedHandOverItem.offlineImges ?? []
        }
        
        if(selectedHandOverItem.complaintimgUrls != nil && (selectedHandOverItem.complaintimgUrls?.contains(imageUrl))!){
            print("FOuND1 ")
            onlineImages = selectedHandOverItem.complaintimgUrls!.filter({$0 != imageUrl})
        }
        else{
            onlineImages = selectedHandOverItem.complaintimgUrls!
        }
        
        let childContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = RRUtilities.sharedInstance.model.managedObjectContext
        
        let childEntry = childContext.object(
            with: selectedHandOverItem!.objectID) as? TowerHandOverItems
        
        childEntry?.offlineImges = offlineImages
        childEntry?.complaintimgUrls = onlineImages
        
        childEntry?.hasOfflineImages = (offlineImages.count > 0) ? true : false

        
        childContext.perform {
            do {
                try childContext.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            RRUtilities.sharedInstance.model.saveContext()
            NotificationCenter.default.post(name: NSNotification.Name("FecthHandOverItems"), object: nil)
        }
        
        var infoDict : Dictionary<String,Int> = [:]
        infoDict["isSave"] = 1
        infoDict["buttonIndex"] = buttonIndex
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.UPDATE_HO_ITEM_STATE), object: nil, userInfo: infoDict)

    }
}
