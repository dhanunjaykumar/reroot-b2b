//
//  EditRegistrationViewController.swift
//  REroot
//
//  Created by Dhanunjay on 25/01/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import CoreData


class EditRegistrationViewController: UIViewController,UITextFieldDelegate,UIPopoverPresentationControllerDelegate,HidePopUp {
    

    var selectedEnquirySource : NewEnquirySources!
    var prospectDetails : REGISTRATIONS_RESULT!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var titleInfoView: UIView!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var customerNameTextField: UITextField!
    @IBOutlet var emailAddressTextField: UITextField!
    var enquirySources : [NewEnquirySources]! //[EnquirySources]
    @IBOutlet var enquirySourceTextField: UITextField!
    
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
        
        
//        buttonsView.clipsToBounds = true
//
//        buttonsView.layer.masksToBounds = false
//        buttonsView.layer.shadowColor = UIColor.lightGray.cgColor
//        buttonsView.layer.shadowOffset = CGSize(width: 0, height: -2)
//
//        buttonsView.layer.shadowOpacity = 0.4
//        buttonsView.layer.shadowRadius = 1.0
//        buttonsView.layer.shouldRasterize = true
//        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
//
//        buttonsView.layer.shouldRasterize = true
//        buttonsView.layer.rasterizationScale = UIScreen.main.scale
//        self.view.bringSubviewToFront(buttonsView)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let emailImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        emailImage.contentMode = UIView.ContentMode.center
        emailImage.image = UIImage.init(named: "prefill_icon")
        emailImage.isUserInteractionEnabled = true
        emailAddressTextField.rightView = emailImage
        emailAddressTextField.rightViewMode = .always
        emailImage.isUserInteractionEnabled = true
        emailImage.tag = 3
        let tapGuesture2 = UITapGestureRecognizer.init(target: self, action: #selector(searchPhoneNumberOrName(_:)))
        emailImage.addGestureRecognizer(tapGuesture2)
        
        let phoneNumberImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        phoneNumberImage.contentMode = UIView.ContentMode.center
        phoneNumberImage.image = UIImage.init(named: "prefill_icon")
        phoneNumberImage.isUserInteractionEnabled = true
        phoneNumberTextField.rightView = phoneNumberImage
        phoneNumberTextField.rightViewMode = .always
        
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(searchPhoneNumberOrName(_:)))
        phoneNumberImage.tag = 1
        phoneNumberImage.addGestureRecognizer(tapGuesture)
        
        let enquiryImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        enquiryImage.contentMode = UIView.ContentMode.center
        enquiryImage.image = UIImage.init(named: "downArrow")
        enquirySourceTextField.rightView = enquiryImage
        enquirySourceTextField.rightViewMode = .always
        
        enquirySourceTextField.delegate = self

        customerNameTextField.text = prospectDetails.userName
        if(prospectDetails.userEmail != nil && RRUtilities.sharedInstance.isValidEmail(emailID: prospectDetails.userEmail!)){
            emailAddressTextField.text = prospectDetails.userEmail
        }
        else{
            emailAddressTextField.text = ""
        }
        phoneNumberTextField.text = prospectDetails.userPhone
        enquirySourceTextField.text = prospectDetails.enquirySource
        
        enquirySources = RRUtilities.sharedInstance.model.getNewEnquirySources()
        
//        let entity = NSEntityDescription.entity(forEntityName: "EnquirySources", in: RRUtilities.sharedInstance.model.managedObjectContext)
//        let tempRecord = EnquirySources.init(entity: entity!, insertInto: nil)
//
//        tempRecord.id = "none"
//        tempRecord.name = "Select Source"
//
//        enquirySources.insert(tempRecord, at: 0)
        
        print(enquirySources[0])
        
    }
    // MARK: - METHOD ACTIONS
    @objc func searchPhoneNumberOrName(_ sender: UITapGestureRecognizer){
        
        //QUICK_REGISTRATION_SEARCH
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.labeledProgress(title: "", subtitle: nil))
        
        let tag = sender.view!.tag
        
        if(tag == 1){
//            if(phoneNumberTextField.text?.count != 10){
//                HUD.flash(.label("Enter valid phone number"), delay: 0.8)
//                return
//            }
        }else if(tag == 2){
            if (customerNameTextField.text?.isEmpty)! {
                HUD.flash(.label("Enter name"), delay: 1.0)
                return
            }
        }else if(tag == 3){
            if (emailAddressTextField.text?.isEmpty)! {
                HUD.flash(.label("Enter Email ID"), delay: 1.0)
                return
            }
            guard let email = emailAddressTextField.text , RRUtilities.sharedInstance.isValidEmail(emailID: emailAddressTextField.text!) != false else{
                HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
                return
            }
        }
        
        let urlString = String(format: "%@phone&phone=%@&email&email=%@&name&name=%@", RRAPI.QUICK_REGISTRATION_SEARCH,phoneNumberTextField.text!,emailAddressTextField.text!,customerNameTextField.text!)
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()
                
                let urlResult = try! JSONDecoder().decode(SEARCH_RESULT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
                    if(urlResult.result != nil){
                        self.phoneNumberTextField.text = urlResult.result?.userPhone
                        self.emailAddressTextField.text = urlResult.result?.userEmail
                        self.customerNameTextField.text = urlResult.result?.userName
                    }
                    else{
                        
                    }
                }else{
                    
                    HUD.flash(.label(""), delay: 1.0)
                }
                
                // make tableview data
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func save(_ sender: Any) {
        
        if(phoneNumberTextField.text?.count != 10){
//            HUD.flash(.label("Enter valid phone number"), delay: 0.8)
//            return
        }
        if (customerNameTextField.text?.isEmpty)! {
            HUD.flash(.label("Enter name"), delay: 1.0)
            return
        }
        if (emailAddressTextField.text?.isEmpty)! {
            HUD.flash(.label("Enter Email ID"), delay: 1.0)
            return
        }
        guard let email = emailAddressTextField.text , RRUtilities.sharedInstance.isValidEmail(emailID: emailAddressTextField.text!) != false else{
            HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
            return
        }

        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        if(enquirySourceTextField.text == "Select Source"){
            HUD.flash(.label("Select Enquiry Source"), delay: 1.0)
            return
        }
        
        var parameters : Dictionary<String,String> = [:]
        parameters["userName"] = customerNameTextField.text
        parameters["userPhone"] = phoneNumberTextField.text
        parameters["userEmail"] = emailAddressTextField.text
        parameters["enquirySource"] = enquirySourceTextField.text
        if(selectedEnquirySource != nil){
            parameters["enquirySourceId"] = selectedEnquirySource.id
        }
        else{
            parameters["enquirySourceId"] = prospectDetails.enquirySource
        }
        parameters["currId"] = prospectDetails._id
        parameters["regInfo"] = prospectDetails.regInfo ?? prospectDetails._id
        parameters["comment"] = ""
        
        print(prospectDetails.viewType)
        parameters["viewType"] = String(format: "%d", prospectDetails.viewType ?? 1)
        parameters["src"] = 3
        print(prospectDetails.currProject)
        
        //                requestBody.put(Prospect.REG_INFO, if (viewType != 1) mProspectData?.prospectsLeads?.regInfo
//            else mProspectData?._id)
//        print(parameters)
        
        HUD.show(.progress)
        
        Alamofire.request(RRAPI.API_EDIT_REGISTRATION_BASICS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                HUD.hide()
                
                let urlResult = try! JSONDecoder().decode(QR_HISTORY_OUTPUT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                else if(urlResult.status == -1){
                    
                }
                else if(urlResult.status == 0){
                    //                    HUD.flash(.label(urlResult.err), delay: 1.0)
                }
                
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if ((textField == enquirySourceTextField) ){
            self.showSources()
            return false
        }
        
        return true
    }
    func showSources(){
        
        // Show Pop Up
        self.view.endEditing(true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .ENQUIRY_SOURCES
        vc.preferredContentSize = CGSize(width: 300, height: (self.enquirySources.count-1) * 44)
        
        if(CGFloat((self.enquirySources.count-1) * 44) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 300, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.enquiryDataSource = self.enquirySources
        
        popOver?.sourceView = enquirySourceTextField
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    //MARK: - popOver
    func didSelectProject(optionType: String, optionIndex: Int) {
        
    }
    
    func didFinishTask(optionType: String, optionIndex: Int) {
     
        enquirySourceTextField.text = optionType
        selectedEnquirySource = enquirySources[optionIndex]
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    
    func didSelectOptionForUnitsView(selectedIndex: Int) {
        
    }
    
    func shouldShowUnitsWithSelectedStatus(selectedStatus: Int) {
        
    }
    
    func showSelectedTowerFromFloatButton(selectedTower: Towers, selectedBlock: String) {
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
