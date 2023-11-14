//
//  RegistrationViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 20/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class RegistrationViewController: UIViewController , UITextFieldDelegate, UIPopoverPresentationControllerDelegate,HidePopUp,RegistrationSearchDelegate{
   
    var selectedProjects = [String]()
    var selectedProjectIds = [String]()
    @IBOutlet var projectTitleView: UIView!
    @IBOutlet var projectsLabel: UILabel!
    @IBOutlet var commentsTextView: KMPlaceholderTextView!

    @IBOutlet var saveButton: UIButton!
//    @IBOutlet var projectTextField: UITextField!
    @IBOutlet var enquirySourceTextField: UITextField!
    @IBOutlet var customerNameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var countryCodeTextField: UITextField!
    @IBOutlet var titleView: UIView!
    @IBOutlet var emailAddressTextField: UITextField!
    var sourcesArray = [String]()
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleView.clipsToBounds = true
        
        titleView.layer.masksToBounds = false
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleView.layer.shadowOpacity = 0.4
        titleView.layer.shadowRadius = 1.0
        titleView.layer.shouldRasterize = true
        titleView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleView.layer.shouldRasterize = true
        titleView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleView)
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureView()
        
        //prefill_icon
        sourcesArray = ["Facebook (Social Media)","Twitter (Social Media)","Hoarding","TV Ads","Radio Ads"]
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
        
        emailAddressTextField.placeholder = "Email Address (Optional)"
        
//        let customerNameImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
//        customerNameImage.contentMode = UIView.ContentMode.center
//        customerNameImage.image = UIImage.init(named: "search")
//        customerNameTextField.rightView = customerNameImage
//        customerNameTextField.rightViewMode = .always
        
//        let tapGuesture1 = UITapGestureRecognizer.init(target: self, action: #selector(searchPhoneNumberOrName(_:)))
//        customerNameImage.tag = 2
//        customerNameImage.addGestureRecognizer(tapGuesture1)

        let enquiryImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        enquiryImage.contentMode = UIView.ContentMode.center
        enquiryImage.image = UIImage.init(named: "downArrow")
        enquirySourceTextField.rightView = enquiryImage
        enquirySourceTextField.rightViewMode = .always
        
        enquirySourceTextField.delegate = self
        saveButton.layer.cornerRadius = 8.0
        commentsTextView.layer.borderWidth = 1.0
        commentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentsTextView.layer.cornerRadius = 8.0
        projectsLabel.text = "Select Project"
        projectsLabel.textColor = UIColor.lightGray
        
        projectTitleView.layer.cornerRadius = 8.0
        projectTitleView.layer.borderWidth = 0.4
        projectTitleView.layer.borderColor = UIColor.lightGray.cgColor
        
        commentsTextView.layer.borderWidth = 0.4
        
    }
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
            if(phoneNumberTextField.text?.count != 10){
                HUD.flash(.label("Enter valid phone number"), delay: 0.8)
                return
            }
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
                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()

                let urlResult = try! JSONDecoder().decode(SEARCH_RESULT.self, from: responseData)

                if(urlResult.status == 1){ // success
                    self.phoneNumberTextField.text = urlResult.result?.userPhone
                    self.emailAddressTextField.text = urlResult.result?.userEmail
                    self.customerNameTextField.text = urlResult.result?.userName
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
    func showSources(){
        
        // Show Pop Up
        self.view.endEditing(true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .SOURCES
        vc.preferredContentSize = CGSize(width: 250, height: self.sourcesArray.count * 44)
        
        if(CGFloat((self.sourcesArray.count * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.tableViewDataSourceOne = self.sourcesArray
        
        popOver?.sourceView = enquirySourceTextField
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func showProjects(_ sender: Any) {
        
        self.view.endEditing(true)
        //registratoinProSearch
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
        registerController.delegate = self
        registerController.selectedProjectNamesArray = self.selectedProjects
//        self.navigationController?.pushViewController(registerController, animated: true)
        self.present(registerController, animated: true, completion: nil)
    }
    func didSelectInterestedProjects(projectNames: [String],projectIds: [String]) {
        
        print(projectNames)
        
        if(projectNames.count == 0){
            projectsLabel.textColor = UIColor.lightGray
        }else{
            projectsLabel.textColor = UIColor.black
        }
        
        var tempStr = String()
        
        selectedProjects = projectNames
        selectedProjectIds = projectIds
        
        for projectName in projectNames{
            
            if(tempStr.count > 0){
                tempStr = String(format: "%@\n%@", tempStr,projectName)
            }
            else{
             tempStr.append(contentsOf: projectName)
            }
        }
        projectsLabel.text = tempStr

        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    //MARK:- pop over delegate
    func didSelectProject(optionType: String, optionIndex: Int) {
        
    }
    func didFinishTask(optionType: String, optionIndex: Int) {
        
        print(optionType)
        enquirySourceTextField.text = optionType
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    
    func didSelectOptionForUnitsView(selectedIndex: Int) {
        
    }
    
    func shouldShowUnitsWithSelectedStatus(selectedStatus: Int) {
        
    }
    
    func showSelectedTowerFromFloatButton(selectedTower: TOWERDETAILS, selectedBlock: String) {
        
    }
    @IBAction func registerUser(_ sender: Any) {
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        if(phoneNumberTextField.text?.count == 0){
            HUD.flash(.label("Customer phone number is manditory"), delay: 0.8)
            return
        }
        if(customerNameTextField.text?.count == 0){
            HUD.flash(.label("Customer name number is manditory"), delay: 0.8)
            return
        }
        
        if(phoneNumberTextField.text?.count != 10){
            HUD.flash(.label("Enter valid phone number"), delay: 0.8)
            return
        }
        
        
        if(emailAddressTextField.text?.count != 0 && (RRUtilities.sharedInstance.isValidEmail(emailID: emailAddressTextField.text!) == false)){
            HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
            return
        }
        
        var parameters : Dictionary<String,Any> = [:]
        
        parameters["userPhone"] = phoneNumberTextField.text
        
        if(emailAddressTextField.text?.isEmpty == false){
            parameters["userEmail"] = emailAddressTextField.text
        }
        parameters["userName"] = customerNameTextField.text
        
        if(selectedProjectIds.count > 0){
            parameters["projects"] = selectedProjectIds
        }
        
        if(commentsTextView.text.count > 0){
            parameters["comments"] = commentsTextView.text
        }
        
        if(enquirySourceTextField.text!.count > 0){
            parameters["enquirySource"] = enquirySourceTextField.text
        }
        
        print(parameters)
        HUD.show(.progress)
        
        Alamofire.request(RRAPI.QUICK_REIGSTRATION, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                HUD.hide()
                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                
                let urlResult = try! JSONDecoder().decode(Q_REGISTRATION_RESULT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
                    
                    HUD.flash(.label("Registered successfull"), delay: 1.0)
                    self.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)

                }else{
                    
                    HUD.flash(.label(urlResult.err), delay: 1.0)
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
    //MARK:- TEXTField DElegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if ((textField == enquirySourceTextField) ){//|| (textField == saleDeedDateTextField) || (textField == agreementDateTextField) || (textField == possessionFinalDateTextField) || (textField == possessionDatePrelimTextField)) {
//            self.showDatePicker(textField: textField)
            self.showSources()
            return false
        }
        
        return true
        
    }
//    @objc func injected() {
//        configureView()
//    }
    func configureView() {
        // Update the user interface for the detail item.
//        titleView.backgroundColor = UIColor.red
    }

    
    @IBAction func hide(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - popOver
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
