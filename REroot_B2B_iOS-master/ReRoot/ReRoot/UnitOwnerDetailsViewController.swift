//
//  UnitOwnerDetailsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 03/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage
import AWSS3
import PKHUD

protocol ProspectUpdateDelegate : class {
    func didFinishProspectUpdate(updatedClient : Client,selectedCustomer : ClientList,selectedIndex : Int)
}
extension ProspectUpdateDelegate{
    func didFinishProspectUpdate(updatedClient : Client,selectedCustomer : ClientList,selectedIndex : Int){
    }
}
struct AWS_INPUTS {
    var imageName : String!
    var imageURL : URL!
    var type : AWS_TYPE!
}
struct AWS_OUTPUT {
    var imageURL : String!
    var type : AWS_TYPE!
}
enum AWS_TYPE : String{
    case client = "1"
    case pan = "2"
    case aadhar = "3"
    case handover = "4"
    case receiptEntry = "5"
}
enum POPUP_SOURCE : Int{
    case client = 1
    case pan = 2
    case aadhar = 3
}

class UnitOwnerDetailsViewController: UIViewController {

    @IBOutlet weak var heightOfUpdateButton: NSLayoutConstraint!
    @IBOutlet weak var updateButton: UIButton!
    var selectedImage : UIImage!
    var selectedImageName : String!
    
    var uploadImagesArray : [AWS_INPUTS] = []
    
    weak var delegate : ProspectUpdateDelegate?
    
    var selectedClietImageURL : URL!
    var selectedPanImageURL : URL!
    var selectedAadharImageURL : URL!
    
    var selectedClientImageTime : String!
    var selectedUnitStatus : UNIT_STATUS!
    var shouldAllowEdit : Bool!
    
    var isSoldUnit : Bool = false
    var selectedClientIndex : Int!
    var selectedClient : ClientList!
    var clientDetails : Client!
    var imagePicker: ImagePicker!
    var selectedImageViewType : Int = -1 // 1 : client pic,2 : pan card 3 : aadhar card
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleInfoView: UIView!
    @IBOutlet weak var emailIDTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var panNumberTextField: UITextField!
    @IBOutlet weak var aadharCardTextField: UITextField!
    
    @IBOutlet weak var clientPhotoImageView: UIImageView!
    @IBOutlet weak var panImageView: UIImageView!
    @IBOutlet weak var aadharImageView: UIImageView!
    var viewImageView : UIImageView!
    
    var totalNumberOfImagesToUpload : Int = 0
    var uploadedImagesCount : Int = 0
    
    @objc lazy var transferUtility = {
        AWSS3TransferUtility.default()
    }()
    @objc var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    @objc var progressBlock: AWSS3TransferUtilityProgressBlock?

    
    // MARK: - View Life cycle
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleInfoView.clipsToBounds = true
        
        titleInfoView.layer.masksToBounds = false
        titleInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        titleInfoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleInfoView.layer.shadowOpacity = 0.4
        titleInfoView.layer.shadowRadius = 1.0
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleInfoView)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        uploadImagesArray.removeAll()
        self.clientDetails = selectedClient.client
        self.configureView()
        
//        var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        print(path)
//        path.appendPathComponent("fileName")
//        print(path.appendPathComponent("fileName"))
        //file:///Users/dhanunjay/Library/Developer/CoreSimulator/Devices/9A58D269-EA40-4EFD-98E9-5A174D5F9034/data/Containers/Data/Application/2B9976B2-9CEB-426C-B404-FF78725E620A/Documents/

//        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
//        print(fileURL)
    }
    func configureView(){
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)

        let client = selectedClient.client
        
        countryCodeTextField.text = client.phoneCode ?? "91"
        phoneNumberTextField.text = client.phone
        nameTextField.text = client.name
        emailIDTextField.text = client.email
        
        panNumberTextField.text = client.panCard ?? ""
        aadharCardTextField.text = client.aadhar ?? ""
        
        if let panUrl = client.panUrl{
//            print("panrul " +  panUrl.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            DispatchQueue.global().async {
                let url = ServerAPIs.getSingleSingedUrl(url: panUrl)
                DispatchQueue.main.async { [unowned self] in
                    self.panImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "photo"), options:[.highPriority,.refreshCached])
                }
            }

        }
        if let clientPhoto = client.photo{
//            print("client " + clientPhoto.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!)
            DispatchQueue.global().async {
                let url = ServerAPIs.getSingleSingedUrl(url: clientPhoto)
                DispatchQueue.main.async { [unowned self] in
                    self.clientPhotoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "photo"), options:[.highPriority,.refreshCached])

                }
            }
        }
        if let aadharUrl = client.aadharUrl{
//            print("aadhar " + aadharUrl.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!)
            DispatchQueue.global().async {
                let url = ServerAPIs.getSingleSingedUrl(url: aadharUrl)
                DispatchQueue.main.async { [unowned self] in
                    self.aadharImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "photo"), options:[.highPriority,.refreshCached])
                }
            }

           
        }
        
        if(selectedUnitStatus == UNIT_STATUS.BOOKED){
            self.shouldAllowEdit = true
            self.shouldEnableEditingAsPerStatus(allowEdit: true)
        }
        else{
            self.shouldAllowEdit = false
            self.shouldEnableEditingAsPerStatus(allowEdit: false)
        }
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BOOKING_FORM.rawValue, permissionType: UserRolePermissions.CREATE.rawValue) || !PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BOOKING_FORM.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
            self.updateButton.isHidden = true
            self.heightOfUpdateButton.constant = 0
            self.view.layoutIfNeeded()
        }

    }
    func shouldEnableEditingAsPerStatus(allowEdit : Bool){
        
        self.countryCodeTextField.isEnabled = allowEdit
        self.phoneNumberTextField.isEnabled = allowEdit
        self.nameTextField.isEnabled = allowEdit
        self.emailIDTextField.isEnabled = allowEdit
        self.panNumberTextField.isEnabled = allowEdit
        self.aadharCardTextField.isEnabled = allowEdit
    }

    @IBAction func updateProspect(_ sender: Any) {
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        HUD.show(.progress)
        
        if(panNumberTextField.text!.count > 0){
            self.clientDetails.panCard = panNumberTextField.text
        }
        if(aadharCardTextField.text!.count > 0){
            self.clientDetails.aadhar = aadharCardTextField.text
        }
        
        self.clientDetails.email = emailIDTextField.text
        self.clientDetails.name = nameTextField.text
        self.clientDetails.phone = phoneNumberTextField.text
        self.clientDetails.phoneCode = countryCodeTextField.text
        
        if(uploadImagesArray.count > 0){
            for awsInput in uploadImagesArray{
                self.uploadButtonAction(imageDetails: awsInput)
            }
        }
        else{
            self.updateProspectCall()
        }
    }
    func updateProspectCall(){
        
        HUD.show(.progress)
        print(self.clientDetails)

        ServerAPIs.updateProspect(clientDetails: self.clientDetails, completionHandler: { (responseObject, error) in
            if(responseObject?.status == 1){
                HUD.hide()
                RRUtilities.sharedInstance.clearImagesCache()
                self.delegate?.didFinishProspectUpdate(updatedClient: self.clientDetails, selectedCustomer: self.selectedClient, selectedIndex: self.selectedClientIndex)
                HUD.flash(.label("Updated succesfully"), delay: 2.0)
                self.dismiss(animated: true, completion: nil)
            }
            else{
                HUD.hide()
                HUD.flash(.label(responseObject?.err), delay:2.0)
            }
        })
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func imageViewClicked(_ sender: Any) {
         self.showPopUpMenu(source: 1)
    }
    @IBAction func panImageViewClick(_ sender: Any) {
         self.showPopUpMenu(source: 2)
    }
    @IBAction func aadharImageViewClick(_ sender: Any) {
        self.showPopUpMenu(source: 3)
    }
    func showPopUpMenu(source : Int){
        
        // Show Pop Up
        self.view.endEditing(true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .OWNER_IMAGES_POP_UP
        
        var imageExist = false

        let client = selectedClient.client

        if(source == POPUP_SOURCE.client.rawValue){
            if(client.photo != nil && client.photo!.count > 0){
                imageExist = true
            }
            else{
                for eachImage in uploadImagesArray{
                    if(eachImage.type == AWS_TYPE.client){
                        imageExist = true
                    }
                }
            }
        }
        else if(source == POPUP_SOURCE.pan.rawValue){
            if(client.panUrl != nil && client.panUrl!.count > 0){
                imageExist = true
            }
            else{
                for eachImage in uploadImagesArray{
                    if(eachImage.type == AWS_TYPE.pan){
                        imageExist = true
                    }
                }
            }
        }
        else if(source == POPUP_SOURCE.aadhar.rawValue){
            if(client.aadharUrl != nil && client.aadharUrl!.count > 0){
                imageExist = true
            }
            else{
                for eachImage in uploadImagesArray{
                    if(eachImage.type == AWS_TYPE.aadhar){
                        imageExist = true
                    }
                }
            }
        }
        
        var sourcesArray : [String] = []
        
        if !shouldAllowEdit {
            sourcesArray = ["View Photo"]
            self.selectedImageViewType = POPUP_SOURCE.client.rawValue
            self.viewImage()
            return
        }
        else{
            if(imageExist){
                sourcesArray = ["View Photo","Take Photo","Choose from gallery","Delete"]
            }
            else{
                sourcesArray = ["Take Photo","Choose from gallery"]
            }
        }
        
        
//        if(!imageExist){
//            sourcesArray = ["Take Photo","Choose from gallery"]
//        }
        
        vc.preferredContentSize = CGSize(width: 200, height: (sourcesArray.count-1) * 44)
        
        if(CGFloat((sourcesArray.count-1) * 44) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 200, height: (self.view.frame.size.height - 150))
        }

        if(sourcesArray.count == 1){
            vc.preferredContentSize = CGSize(width: 200, height: 1)
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.tableViewDataSourceOne = sourcesArray
        
        if(source == 1){
            popOver?.sourceView = clientPhotoImageView
        }else if(source == 2){
            popOver?.sourceView = panImageView
        }else if(source == 3){
            popOver?.sourceView = aadharImageView
        }
        selectedImageViewType = source
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    @IBAction func openDialer(_ sender: Any) {
        let client = selectedClient.client
        guard let number = URL(string: "tel://" + client.phone!) else { return }
        UIApplication.shared.open(number)
    }
    @IBAction func openWhatsapp(_ sender: Any) {
        let client = selectedClient.client
        var tempCode = ""
        if let phoneCode = client.phoneCode{
            if(phoneCode.count > 0){
                tempCode = phoneCode
            }
            else
            {
                tempCode = "91"
            }
        }
        else{
            tempCode = "91"
        }

//        let phone = tempCode + (client.phone ?? "")
        let phone  = (client.phone!.count > 10) ? client.phone! : tempCode + client.phone!
        let selectedRegistration = String(format: "%@",phone)
        guard let number = URL(string: String(format: "https://wa.me/%@?text=%@", selectedRegistration,""))else{return}
        //https://api.whatsapp.com/send?phone=
        UIApplication.shared.open(number)
    }
    @IBAction func openEmail(_ sender: Any) {
        
        let client = selectedClient.client

        if(client.email != nil){
            
            let emailer = String(format: "mailto:%@", client.email!)
            let url = URL(string: emailer)
            
            UIApplication.shared.open(url!)
        }
    }
     func uploadButtonAction(imageDetails : AWS_INPUTS) {
        
        let s3Config = RRUtilities.sharedInstance.model.getS3Config()
        
        if(s3Config == nil){
            return
        }
        
//        let accessKey = s3Config!.accessKeyId!
//        let secretKey = s3Config!.secretAccessKey!
//
//        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
//        let configuration = AWSServiceConfiguration(region:AWSRegionType.APSouth1, credentialsProvider:credentialsProvider)
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:AWSRegionType.APSouth1,
                                                                identityPoolId:"ap-south-1:dcf659d0-1fb4-4041-b392-15869ad0ae04")
        
        let configuration = AWSServiceConfiguration(region:AWSRegionType.APSouth1, credentialsProvider:credentialsProvider)

        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let S3BucketName = s3Config!.bucket!
        
//        let remoteName = RRUtilities.sharedInstance.getCurrentTimeAsString()
//        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
//        let image = selectedImage
        
//        let data = image!.jpegData(compressionQuality: 0.5)
//        do {
//            try data?.write(to: fileURL)
//        }
//        catch {}
        
//        print(imageDetails.imageURL)
//        print(imageDetails.imageName)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = imageDetails.imageURL
        uploadRequest.key = imageDetails.imageName
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .private
        uploadRequest.contentDisposition = imageDetails.type.rawValue
        
        let queueID = "com.reroot.queue" + imageDetails.type.rawValue
        
        let queue = DispatchQueue(label: queueID, qos: DispatchQoS.userInitiated)
        
        queue.async {
            
            let transferManager = AWSS3TransferManager.default()
            
            transferManager.upload(uploadRequest).continueWith { [weak self] (task) -> Any? in
                DispatchQueue.main.async {
                    print("DONE WITH UPLOAD")
                    //                self?.uploadButton.isHidden = false
                    //                self?.activityIndicator.stopAnimating()
                }
                
                if let error = task.error {
                    print("Upload failed with error: (\(error.localizedDescription))")

                     DispatchQueue.main.async {
                        if(uploadRequest.contentDisposition == "1"){
                            HUD.flash(.label("Couldn't upload client image (\(error.localizedDescription))"), delay: 1.0)
                        }
                        else if(uploadRequest.contentDisposition == "2"){
                            HUD.flash(.label("Couldn't upload PAN image (\(error.localizedDescription))"), delay: 1.0)
                        }
                        else if(uploadRequest.contentDisposition == "3"){
                            HUD.flash(.label("Couldn't upload AADHAR image (\(error.localizedDescription))"), delay: 1.0)
                        }
                    }
                }
                
                if task.result != nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    self?.uploadedImagesCount += 1
                    print(url)
                    let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                    if let absoluteString = publicURL?.absoluteString {
                        
                        DispatchQueue.main.async {
                            print("Uploaded to:\(absoluteString)")
                            if(uploadRequest.contentDisposition == "1"){
                                self?.clientDetails.photo = absoluteString

                            }
                            else if(uploadRequest.contentDisposition == "2"){
                                self?.clientDetails.panUrl = absoluteString
                            }
                            else if(uploadRequest.contentDisposition == "3"){
                                self?.clientDetails.aadharUrl = absoluteString
                            }
                            if(self?.uploadImagesArray.count == self?.uploadedImagesCount){
                                // go head and call update
                                self?.updateProspectCall()
                            }

                        }
                    }
                    else{
                        print("")
                    }
                }
                
                return nil
            }
        }
        
    }
    func removeUploadedImgeFromArrayWithType(type : AWS_TYPE){
        
        var indexer = 0
        for tempInput in uploadImagesArray{
            if(tempInput.type == type){
                uploadImagesArray.remove(at: indexer)
            }
            indexer += 1
        }
        print(uploadImagesArray)
        if(uploadImagesArray.count == 0){
            RRUtilities.sharedInstance.clearImagesCache()
        }
    }
    func uploadImage(){
        
//        let transferUtility = AWSS3TransferUtility.default()

        if(selectedImage == nil){
            return
        }
        
        let image = selectedImage!
        let imageName = selectedImageName ?? ""
        
        let keyFileName = RRUtilities.sharedInstance.getCurrentTimeAsString() + (imageName ?? "")
        
//        let tnewData = Data.init(contentsOf: "T##URL")
        
        var data: Data!
        if let tempData:Data = image.jpegData(compressionQuality: 0.5) {
            data = tempData
        }
        else if let tempData:Data = image.pngData() {
            data = tempData
        } else if let tempData:Data = image.jpegData(compressionQuality: 0.5) {
            data = tempData
        }
        
        if(data == nil || image == nil){
            print("data is ni")
        }
        
//        let expression = AWSS3TransferUtilityUploadExpression()
//        expression.progressBlock = {(task, progress) in
//            DispatchQueue.main.async(execute: {
//                // Do something e.g. Update a progress bar.
//                print("pringng progress")
//                print(progress)
//            })
//        }
//
//        completionHandler = { (task, error) -> Void in
//            DispatchQueue.main.async(execute: {
//                // Do something e.g. Alert a user for transfer completion.
//                // On failed uploads, `error` contains the error object.
//                print("COMLETIPN BLOCK ")
//                print(task)
//                print(error)
//            })
//        }
//
//        DispatchQueue.main.async {
//            AWSS3TransferUtility.default().uploadData(data,
//                                                      bucket:"buildez",
//                                                      key: "test.png",
//                                                      contentType: "image/png",
//                                                      expression: expression,
//                                                      completionHandler: self.completionHandler).continueWith {
//                                                        (task) -> AnyObject? in
//                                                        if let error = task.error {
//                                                            print("Error: \(error.localizedDescription)")
//                                                        }
//
//                                                        if let _ = task.result {
//                                                            // Do something with uploadTask.
//                                                            print(task.result as Any)
//                                                        }
//                                                        return nil;
//            }
//        }

//        DispatchQueue.main.async {
//
//            let s3BucketName = String(format: "buildez/%@/bookingform/", UserDefaults.standard.value(forKey: "groupId") as! String)
//            let expression1 = AWSS3TransferUtilityUploadExpression()
//            let transferUtility = AWSS3TransferUtility.default()
//
//            print(s3BucketName)
//
//            self.transferUtility.uploadData(data, bucket: s3BucketName, key: keyFileName, contentType: "image/png", expression: expression, completionHandler: { (task, error) in
//                if let error = error{
//                    print(error.localizedDescription)
//                    return
//                }
//                print("uploaded successfully")
//            })
//
//        }
        
        
        
        //        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        //        completionHandler = { (task, error) -> Void in
        //            DispatchQueue.main.async(execute: {
        //                // Do something e.g. Alert a user for transfer completion.
        //                // On failed uploads, `error` contains the error object.
        //                print("COMLETIPN BLOCK ")
        //                print(task)
        //                print(error)
        //            })
        //        }
        
        //        let transferUtility = AWSS3TransferUtility.default()
        
        //
        
        
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
extension UnitOwnerDetailsViewController : UIPopoverPresentationControllerDelegate,HidePopUp {
    
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func didFinishTask(optionType: String, optionIndex: Int) {
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });

        print(optionType)
        
        if(optionType == "View Photo"){
            self.viewImage()
        }
        else if(optionType == "Take Photo"){
            if(selectedImageViewType == 1){
                self.imagePicker.takePhoto(from: clientPhotoImageView)
            }
            else if(selectedImageViewType == 2){
                self.imagePicker.takePhoto(from: panImageView)
            }
            else if(selectedImageViewType == 3){
                self.imagePicker.takePhoto(from: aadharImageView)
            }
        }
        else if(optionType == "Choose from gallery"){
            if(selectedImageViewType == 1){
                self.imagePicker.takeFromPhotos(from: clientPhotoImageView)
            }
            else if(selectedImageViewType == 2){
                self.imagePicker.takeFromPhotos(from: panImageView)
            }
            else if(selectedImageViewType == 3){
                self.imagePicker.takeFromPhotos(from: aadharImageView)
            }
        }
        else if(optionType == "Delete"){
            if(selectedImageViewType == 1){
                self.clientPhotoImageView.image = UIImage(named: "photo")
                self.clientDetails.photo = ""
                self.selectedClient.client.photo = ""
                self.uploadImagesArray = self.uploadImagesArray.filter({ $0.type != AWS_TYPE.client })
            }
            else if(selectedImageViewType == 2){
                self.panImageView.image = UIImage(named: "photo")
                self.clientDetails.panUrl = ""
                self.selectedClient.client.panUrl = ""
                self.uploadImagesArray = self.uploadImagesArray.filter({ $0.type != AWS_TYPE.pan })
            }
            else if(selectedImageViewType == 3){
                self.aadharImageView.image = UIImage(named: "photo")
                self.clientDetails.aadharUrl = ""
                self.selectedClient.client.aadharUrl = ""
                self.uploadImagesArray = self.uploadImagesArray.filter({ $0.type != AWS_TYPE.aadhar })
            }
        }
    }
    func getImageURLUsingType(type : AWS_TYPE)->URL?{
        
        for tempImages in uploadImagesArray{
            if(type == tempImages.type){
                return tempImages.imageURL
            }
        }
        
        return nil
        
    }
    func viewImage(){
        
        let preview =  ImagePreviewViewController(nibName: "ImagePreviewViewController", bundle: nil)
        let client = selectedClient.client

        var imageExist : Bool = false

        if(selectedImageViewType == 1){
            
            for eachImage in uploadImagesArray{
                if(eachImage.type == AWS_TYPE.client){
                    imageExist = true
                }
            }
            if(imageExist){
                preview.image = self.clientPhotoImageView.image
            }
            else if let clientPhoto = client.photo{
                print("client " + clientPhoto.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!)
                preview.imageURL = clientPhoto
            }
            else{
                preview.image = self.clientPhotoImageView.image
                //                let url = self.getImageURLUsingType(type: AWS_TYPE.client)
                //                preview.imageURL = url
            }

        }
        else if(selectedImageViewType == 2){
            
            for eachImage in uploadImagesArray{
                if(eachImage.type == AWS_TYPE.pan){
                    imageExist = true
                }
            }
            
            if(imageExist){
                preview.image = self.panImageView.image
            }
            else if let panUrl = client.panUrl{
                preview.imageURL = panUrl
                print("panrul " +  panUrl.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            }else{
                return
            }
        }
        else if(selectedImageViewType == 3){
            for eachImage in uploadImagesArray{
                if(eachImage.type == AWS_TYPE.aadhar){
                    imageExist = true
                }
            }
            if(imageExist){
                preview.image = self.aadharImageView.image
            }
            else if let aadharUrl = client.aadharUrl{
                preview.imageURL = aadharUrl
                print("aadhar " + aadharUrl.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!)
            }else{
                return
            }
        }
        self.present(preview, animated: true, completion: nil)
    }
    func takeImageFromCamera(){
        
    }
    func takeImageFromGallery(){
        
    }
}
extension UnitOwnerDetailsViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?,imageName : String?) {
        
        if(image == nil)
        {
            return
        }
        
        let  tempImage = RRUtilities.sharedInstance.resize(image!)
        
        var tempImageName = ""
        
        if(imageName != nil){
            tempImageName = RRUtilities.sharedInstance.getCurrentTimeAsString() + "_" + imageName!
        }
        else{
            tempImageName = RRUtilities.sharedInstance.getCurrentTimeAsString()
        }
        
        self.selectedImageName = imageName
        self.selectedImage = tempImage
        if(selectedImageViewType == 1){
            
//            self.selectedClietImageURL = RRUtilities.sharedInstance.saveImage(image!, name: tempImageName)
            
            self.clientPhotoImageView.image = tempImage
            
            let clientImageUrl = AWS_INPUTS(imageName: tempImageName, imageURL: RRUtilities.sharedInstance.saveImage(tempImage, name: tempImageName), type: AWS_TYPE.client)
            uploadImagesArray.append(clientImageUrl)
        }
        else if(selectedImageViewType == 2){
//            self.selectedPanImageURL = RRUtilities.sharedInstance.saveImage(image!, name: tempImageName)
            
            let panImage = AWS_INPUTS(imageName: tempImageName, imageURL: RRUtilities.sharedInstance.saveImage(tempImage, name: tempImageName), type: AWS_TYPE.pan)
            uploadImagesArray.append(panImage)

            self.panImageView.image = tempImage
        }
        else if(selectedImageViewType == 3){
//            self.selectedPanImageURL = RRUtilities.sharedInstance.saveImage(image!, name: tempImageName)
            let aadharImage = AWS_INPUTS(imageName: tempImageName, imageURL: RRUtilities.sharedInstance.saveImage(tempImage, name: tempImageName), type: AWS_TYPE.aadhar)
            uploadImagesArray.append(aadharImage)

            self.aadharImageView.image = tempImage
        }
        self.totalNumberOfImagesToUpload = uploadImagesArray.count
    }
    
}

