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
import DLRadioButton
import FloatingPanel
import CoreData

protocol EditRegistration : class {
    func didFinishEdit(prospect : REGISTRATIONS_RESULT)
}
extension EditRegistration {
    func didFinishEdit(prospect : REGISTRATIONS_RESULT){
        // leaving this empty
        
    }
}

class RegistrationViewController: UIViewController , UITextFieldDelegate, UIPopoverPresentationControllerDelegate,HidePopUp,RegistrationSearchDelegate,DateSelectedFromPicker,FloatingPanelControllerDelegate{
    
    var avoidCrossProjectCheck = false

    @IBOutlet weak var commissioinView: UIView!
    var commissionGroup : DispatchGroup = DispatchGroup()
    @IBOutlet weak var unitTypesView: UIView!
    @IBOutlet weak var heightOfUnitTypesView: NSLayoutConstraint!
    @IBOutlet weak var heightOfBudgetRangeView: NSLayoutConstraint!
    @IBOutlet weak var budgetRangeView: UIView!
    @IBOutlet weak var maxBudgetTextField: UITextField!
    @IBOutlet weak var minBudgetTextField: UITextField!
    var selectedUnitType : UnitTypes!
    var selectedMinBudget : CustomerBudgets!
    var selectedMaxBudget : CustomerBudgets!
    @IBOutlet weak var unitTypeTextField: UITextField!
    @IBOutlet weak var gapBetweenAlternateNExtraRegFieldsView: NSLayoutConstraint!
    @IBOutlet weak var alternatePhoneNumberView: UIView!
    @IBOutlet weak var heightOfAlternatePhoneNumberView: NSLayoutConstraint!
    @IBOutlet weak var alternatePhoneNumberTextField: UITextField!
    @IBOutlet weak var alternateCountryCodeTextField: UITextField!
    var selectedCommssion : CommissionUser!
    @IBOutlet weak var commissoinTypeLabel: UILabel!
    @IBOutlet weak var commissionTitleView: UIView!
    @IBOutlet weak var heightOfCommissionView: NSLayoutConstraint!
    @IBOutlet weak var commissionAplicableButton: UIButton!
    @IBOutlet weak var heightOfCommissionTypeView: NSLayoutConstraint!
    @IBOutlet weak var commissionTypeView: UIView!
    var viewType : VIEW_TYPE!
    @IBOutlet weak var gapBwNameAndPhone: NSLayoutConstraint!
    var prospectDetails : REGISTRATIONS_RESULT!
    @IBOutlet weak var registrationModeLabel: UILabel!
    var isEditingRegistration : Bool = false
    @IBOutlet weak var heightOfProjectSelectionView: NSLayoutConstraint!
    @IBOutlet weak var projectSelectionView: UIView!
    var selectedEnquirySource : NewEnquirySources!
    var editedProspect : REGISTRATIONS_RESULT = REGISTRATIONS_RESULT()

    var selectedLead : Int = -1
    var selectedGender : String!
    var commissionUserTypeSelection : Int = -1
    weak var delegate:EditRegistration?
    var selectedDateOfBirth : Date!
    @IBOutlet weak var extraRegFieldsView: UIView!
    @IBOutlet weak var heightOfExtraFieldsView: NSLayoutConstraint!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var industryTextField: UITextField!
    @IBOutlet weak var designationTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var showMoreButton: UIButton!
    var selectedProjects = [String]()
    var selectedProjectIds = [String]()
    @IBOutlet weak var projectTitleView: UIView!
    @IBOutlet weak var projectsLabel: UILabel!
    @IBOutlet weak var commentsTextView: KMPlaceholderTextView!

    @IBOutlet weak var saveButton: UIButton!
//    @IBOutlet weak var projectTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var enquirySourceTextField: UITextField!
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var emailAddressTextField: UITextField!
    var sourcesArray : [NewEnquirySources]!  //[EnquirySources]!
    
    @IBOutlet weak var heightOfMoreButton: NSLayoutConstraint!
    @IBOutlet weak var maleButton: DLRadioButton!
    @IBOutlet weak var femaleButton: DLRadioButton!
    @IBOutlet weak var othersButton: DLRadioButton!
    
    @IBOutlet weak var agentButton: DLRadioButton!
    @IBOutlet weak var employeeButton: DLRadioButton!
    @IBOutlet weak var customerSelfReferralButton: DLRadioButton!
    @IBOutlet weak var customerOtherReferralButton: DLRadioButton!
    @IBOutlet weak var userCommissionTypesView: UIView!
    @IBOutlet weak var heightOfUserCommissionTypesView: NSLayoutConstraint!
    
    @IBOutlet weak var sourceRectView: UIView!
    @IBOutlet weak var coldButton: UIButton!
    @IBOutlet weak var warmButton: UIButton!
    @IBOutlet weak var hotButton: UIButton!
    var countryCodesArray : NSMutableArray = []
    
    var countryCodePopOver : PopOverViewController!
    var countryCodeNavigator : UINavigationController!
    
    var employeesCommissionInfo : [CommissionUser] = []
    var customersCommissionInfo : [CommissionUser] = []
    var oldCustomersCommissionInfo : [CommissionUser] = []
    
    var commissionPopUpDataSource : [CommissionUser] = []
    
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
    override func loadView() {
        super.loadView()
    }
    func getEmployeesForcommissions(){
        commissionGroup.enter()
        ServerAPIs.getEmployeesForCommissions( completion: { [weak self] result in
            switch result {
            case .success(let result):
                guard let self = self else{
                    return
                }
                self.employeesCommissionInfo = result
                self.commissionUserSelection(self.agentButton!)
            case .failure(let error):
                print(error.localizedDescription)
            }
            self?.getCustomers()
            self?.commissionGroup.leave()
        })
    }
    func getCustomers(){
        
        commissionGroup.enter()

        ServerAPIs.getCustomers(completion: { [weak self] result in
            switch result {
            case .success(let result):
                self?.customersCommissionInfo = result
            case .failure(let error):
                print(error.localizedDescription)
            }
            self?.getOldCustomers()
            self?.commissionGroup.leave()
        })
    }
    func getOldCustomers(){
        commissionGroup.enter()
        ServerAPIs.getOldCustomers(completion: { [weak self] result in
            switch result {
            case .success(let result):
                self?.oldCustomersCommissionInfo = result
            case .failure(let error):
                print(error.localizedDescription)
            }
            self?.commissionGroup.leave()
        })
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.agentButton.isSelected = true
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
             statusBar.backgroundColor = .white
             UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            UIApplication.shared.statusBarView?.backgroundColor =  .white //UIColor.init(red: 243/250, green: 243/250, blue: 243/250, alpha: 1)
        }

//        let operationQueue = OperationQueue.current
//        operationQueue?.addOperations(<#T##ops: [Operation]##[Operation]#>, waitUntilFinished: <#T##Bool#>)
        
        countryCodeTextField.delegate = self
        alternateCountryCodeTextField.delegate = self
        configureView()
        self.resetLeads()
        commissionAplicableButton.tag = 1
        self.applyCommission(commissionAplicableButton!)
        
        if(!UserDefaults.standard.bool(forKey: "showCommission")){
            commissionAplicableButton.isEnabled = false
            commissionAplicableButton.setTitleColor(.lightGray, for: .normal)
            
            self.commissioinView.isHidden = true
            self.heightOfCommissionView.constant = 0
        }
        if(UserDefaults.standard.bool(forKey: "promptOTP")){
            saveButton.setTitle("Generate OTP", for: .normal)
        }

        
        //prefill_icon
        sourcesArray = RRUtilities.sharedInstance.model.getNewEnquirySources()
            //["Facebook (Social Media)","Twitter (Social Media)","Hoarding","TV Ads","Radio Ads"]
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

        let unitTypeImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        unitTypeImage.contentMode = UIView.ContentMode.center
        unitTypeImage.image = UIImage.init(named: "downArrow")
        unitTypeTextField.rightView = unitTypeImage
        unitTypeTextField.rightViewMode = .always
        unitTypeTextField.delegate = self
        
        
        let minBudImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        minBudImage.contentMode = UIView.ContentMode.center
        minBudImage.image = UIImage.init(named: "downArrow")
        minBudgetTextField.rightView = minBudImage
        minBudgetTextField.rightViewMode = .always
        minBudgetTextField.delegate = self

        let maxBudImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        maxBudImage.contentMode = UIView.ContentMode.center
        maxBudImage.image = UIImage.init(named: "downArrow")
        maxBudgetTextField.rightView = maxBudImage
        maxBudgetTextField.rightViewMode = .always
        maxBudgetTextField.delegate = self
        
        let enquiryImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        enquiryImage.contentMode = UIView.ContentMode.center
        enquiryImage.image = UIImage.init(named: "downArrow")
        enquirySourceTextField.rightView = enquiryImage
        enquirySourceTextField.rightViewMode = .always
        
        enquirySourceTextField.delegate = self
        phoneNumberTextField.delegate = self
        alternatePhoneNumberTextField.delegate = self
        saveButton.layer.cornerRadius = 8.0
        commentsTextView.layer.borderWidth = 1.0
        commentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentsTextView.layer.cornerRadius = 8.0
        projectsLabel.text = "Select Project"
        projectsLabel.textColor = UIColor.lightGray
        
        projectTitleView.layer.cornerRadius = 8.0
        projectTitleView.layer.borderWidth = 0.4
        projectTitleView.layer.borderColor = UIColor.lightGray.cgColor
        
        commissionTitleView.layer.cornerRadius = 8.0
        commissionTitleView.layer.borderWidth = 0.4
        commissionTitleView.layer.borderColor = UIColor.lightGray.cgColor
        commissoinTypeLabel.text = "Select Commission Entity"
        
        commentsTextView.layer.borderWidth = 0.4
        dateOfBirthTextField.delegate = self
        self.shouldShowMoreRegFields(shouldShow: false)
        

        agentButton.setTitleColor(UIColor.hexStringToUIColor(hex: "4a4a4a"), for: .normal)
        employeeButton.setTitleColor(UIColor.hexStringToUIColor(hex: "4a4a4a"), for: .normal)
        customerSelfReferralButton.setTitleColor(UIColor.hexStringToUIColor(hex: "4a4a4a"), for: .normal)
        customerOtherReferralButton.setTitleColor(UIColor.hexStringToUIColor(hex: "4a4a4a"), for: .normal)
        
        self.getEmployeesForcommissions()
//        self.getCustomers()
//        self.getOldCustomers()

        if(isEditingRegistration){
            self.setUpFieldsOfRegistration()
        }
        
        if(!PermissionsManager.shared.quickRegistration()){
            self.saveButton.isHidden = true
        }
        

    }
    func setUpFieldsOfRegistration(){

        if(self.isEditingRegistration){
            heightOfMoreButton.constant = 0
            showMoreButton.isHidden = true
//            heightOfAlternatePhoneNumberView.constant = 0
//            alternatePhoneNumberView.isHidden = true
            gapBetweenAlternateNExtraRegFieldsView.constant = 0
//            heightOfCommissionView.constant = 0
            heightOfBudgetRangeView.constant = 0
            heightOfUnitTypesView.constant = 0
            budgetRangeView.isHidden = true
            unitTypesView.isHidden = true
        }
        heightOfProjectSelectionView.constant = 0
        projectSelectionView.isHidden = isEditingRegistration
        registrationModeLabel.text = "Edit Registration"
        gapBwNameAndPhone.constant = 8

        saveButton.setTitle("SAVE & PROCEED", for: .normal)
        customerNameTextField.text = prospectDetails.userName
        if(prospectDetails.userEmail != nil && RRUtilities.sharedInstance.isValidEmail(emailID: prospectDetails.userEmail!)){
            emailAddressTextField.text = prospectDetails.userEmail
        }
        else{
            emailAddressTextField.text = ""
        }
        countryCodeTextField.text = prospectDetails.userPhoneCode
        phoneNumberTextField.text = prospectDetails.userPhone
        enquirySourceTextField.text = prospectDetails.enquirySource
        self.resetLeads()
        if(prospectDetails.leadStatus == "Hot"){
            self.leadClassficationAction(self.hotButton!)
        }
        else if(prospectDetails.leadStatus == "Warm"){
            self.leadClassficationAction(self.warmButton!)
        }
        else if(prospectDetails.leadStatus == "Cold"){
            self.leadClassficationAction(self.coldButton!)
        }
        for enqSource in sourcesArray{
            if(prospectDetails.enquirySourceId == enqSource.id){
                selectedEnquirySource = enqSource
                enquirySourceTextField.text = enqSource.name
                break
            }
        }
        if let alternatePhoneCode = prospectDetails.alternatePhoneCode{
            self.alternateCountryCodeTextField.text = alternatePhoneCode
        }
        if let alternatePhone = prospectDetails.alternatePhone{
            self.alternatePhoneNumberTextField.text = alternatePhone
        }
                
        self.commissionGroup.notify(queue: DispatchQueue.main, execute: { [unowned self] in
            if(self.isEditingRegistration){
                
                if(self.prospectDetails.isCommissionApplicable ?? false){
                    let button = UIButton()
                    button.tag = 0
                    self.applyCommission(button)
                    
                    let selectedCommssion : CommissionEntity = (self.prospectDetails.commissionEntity ?? nil)!
                    
                    if(selectedCommssion.kind == "UserInfo"){
                        self.employeeButton.isSelected = true
                        self.commissionUserSelection(self.employeeButton!)
                    }
                    else if(selectedCommssion.kind == "Customer"){
                        self.customerSelfReferralButton.isSelected = true
                        self.commissionUserSelection(self.customerSelfReferralButton!)
                    }
                    else if(selectedCommssion.kind == "Agent"){
                        self.agentButton.isSelected = true
                        self.commissionUserSelection(self.agentButton!)
                    }
                    else if(selectedCommssion.kind == "OldCustomer"){
                        self.customerOtherReferralButton.isSelected = true
                        self.commissionUserSelection(self.customerOtherReferralButton!)
                    }
                    //            self.commissoinTypeLabel.text = selectedCommssion.t
                    let selectionOne = self.commissionPopUpDataSource.filter({ $0._id == selectedCommssion.id})
                    print(selectionOne)
                    if(selectionOne.count == 1){
                        let commission = selectionOne[0]
                        self.commissoinTypeLabel.text = String(format: "%@ (%@)", commission.name ?? "",commission.phone ?? "")
                    }
                }
            }
        })
//        print(prospectDetails)
        self.commentsTextView.text = prospectDetails.comment ?? ""
        
    }
    func shouldShowMoreRegFields(shouldShow: Bool){
        if(shouldShow){
            heightOfExtraFieldsView.constant = 580
            extraRegFieldsView.isHidden = !shouldShow
        }
        else{
            heightOfExtraFieldsView.constant = 0
            extraRegFieldsView.isHidden = !shouldShow
        }
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
            if((emailAddressTextField.text?.count)! > 0 &&  RRUtilities.sharedInstance.isValidEmail(emailID: emailAddressTextField.text!) == false){
                HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
                return
            }
        }
        
        let urlString = String(format: "%@phone&phone=%@&email&email=%@&name&name=%@", RRAPI.QUICK_REGISTRATION_SEARCH,phoneNumberTextField.text!,emailAddressTextField.text!,customerNameTextField.text!)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
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

                do{
                    let urlResult = try JSONDecoder().decode(SEARCH_RESULT.self, from: responseData)

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
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
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
        self.showEnquirySources()
        return
//        self.view.endEditing(true)
//        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
//        vc.dataSourceType = .ENQUIRY_SOURCES
//        vc.preferredContentSize = CGSize(width:  300, height: (self.sourcesArray.count - 1) * 44)
//
//        if(CGFloat((self.sourcesArray.count * 44)) > (self.view.frame.size.height - 150)){
//
//            vc.preferredContentSize = CGSize(width: 300, height: (self.view.frame.size.height - 150))
//        }
//
//        let navigationContoller = UINavigationController(rootViewController: vc)
//        navigationContoller.navigationBar.isHidden = true
//        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
//
//        let popOver =  navigationContoller.popoverPresentationController
//        popOver?.delegate = self
//        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
//        vc.enquiryDataSource = self.sourcesArray
//
//        popOver?.sourceView = enquirySourceTextField
//
//        vc.delegate = self
//
//        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    func showUnitTypes(){
        
        let entity = NSEntityDescription.entity(forEntityName: "UnitTypes", in: RRUtilities.sharedInstance.model.managedObjectContext)
        let tempUnitType = UnitTypes.init(entity: entity!, insertInto: nil)
        tempUnitType.id = nil
        tempUnitType.name = "Select Unit Type"
        var unitTypes = RRUtilities.sharedInstance.model.getUnitTypes()
        unitTypes.insert(tempUnitType, at: 0)
        self.view.endEditing(true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .UNIT_TYPES
        vc.preferredContentSize = CGSize(width:  300, height: (unitTypes.count - 1) * 44)
        if(unitTypes.count == 1){
            vc.preferredContentSize = CGSize(width:  300, height: 1)
        }

        if(CGFloat((unitTypes.count * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 300, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.unitTypes = unitTypes
        
        popOver?.sourceView = unitTypeTextField
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    func showBudgetRanges(isMin : Bool){
        
//        let entity = NSEntityDescription.entity(forEntityName: "CustomerBudgets", in: RRUtilities.sharedInstance.model.managedObjectContext)
//        let budgetRange = CustomerBudgets.init(entity: entity!, insertInto: nil)
//        budgetRange.id = nil
//        budgetRange.value = 100000
        let budgetRanges = RRUtilities.sharedInstance.model.getBudgetRanges()
//        budgetRanges.insert(budgetRange, at: 0)
        self.view.endEditing(true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .BUDGET_RANGES
        vc.preferredContentSize = CGSize(width:  300, height: (budgetRanges.count - 1) * 44)
        
        if(budgetRanges.count == 1){
            vc.preferredContentSize = CGSize(width:  300, height: 1)
        }
        
        if(CGFloat((budgetRanges.count * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 300, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.isMinBudget = isMin
        vc.budgetRanges = budgetRanges
        
        popOver?.sourceView = isMin ? minBudgetTextField : maxBudgetTextField
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    func showDatePicker(textField : UITextField){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "datePicker") as! DatePickerViewController
        vc.shouldSetDateLimit = true
        vc.preferredContentSize = CGSize(width: 250, height: 195)
        vc.selectedFieldTag = textField.tag
        vc.delegate = self
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        popOver?.sourceView = textField
        vc.delegate = self
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    @objc func showOTPScreen(){
        
        let controller = OTPViewController(nibName: "OTPViewController", bundle: nil)
        controller.preferredContentSize = CGSize(width: 300, height: 120)
        controller.delegate = self
        
        controller.phoneNumberStr = self.countryCodeTextField.text! + self.phoneNumberTextField.text!
        
        let navigationContoller = UINavigationController(rootViewController: controller)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        popOver?.sourceView = self.view
        popOver?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: 0,height: 0)

        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    @IBAction func applyCommission(_ sender: Any) {
        
        if(commissionAplicableButton.tag == 0)
        {
            commissionAplicableButton.tag = 1
            commissionAplicableButton.setImage(UIImage.init(named: "checkbox_on"), for: .normal)
            self.commissionTypeView.isHidden = false
            self.userCommissionTypesView.isHidden = false
            self.heightOfCommissionTypeView.constant = 79
            self.heightOfUserCommissionTypesView.constant = 139
            self.heightOfCommissionView.constant = 285
            self.commissionTypeView.superview?.layoutIfNeeded()
        }
        else{
            commissionAplicableButton.tag = 0
            commissionAplicableButton.setImage(UIImage.init(named: "checkbox_off"), for: .normal)
            self.commissionTypeView.isHidden = true
            self.userCommissionTypesView.isHidden = true
            self.heightOfCommissionTypeView.constant = 0
            self.heightOfUserCommissionTypesView.constant = 0
            self.heightOfCommissionView.constant = 285 - 218
        }
    }
    @IBAction func showMoreRegFields(_ sender: Any) {
        
        let yourAttributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 15.0)!]
        
        if(showMoreButton.tag == 0)
        {
            showMoreButton.tag = 1
            let attributeString = NSMutableAttributedString(string: "Show Less",attributes: yourAttributes)
            showMoreButton.setAttributedTitle(attributeString, for: .normal)
            self.shouldShowMoreRegFields(shouldShow: true)
        }
        else{
            showMoreButton.tag = 0
            let attributeString = NSMutableAttributedString(string: "Show More",attributes: yourAttributes)
            showMoreButton.setAttributedTitle(attributeString, for: .normal)
            self.shouldShowMoreRegFields(shouldShow: false)
        }
        
        maleButton.setTitleColor(UIColor.hexStringToUIColor(hex: "4a4a4a"), for: .normal)
        femaleButton.setTitleColor(UIColor.hexStringToUIColor(hex: "4a4a4a"), for: .normal)
        othersButton.setTitleColor(UIColor.hexStringToUIColor(hex: "4a4a4a"), for: .normal)

        
//        maleButton.titleLabel?.font = UIFont.init(name: "Montserrat-SemiBold", size: 15)
//        femaleButton.titleLabel?.font = UIFont.init(name: "Montserrat-SemiBold", size: 15)
//        othersButton.titleLabel?.font = UIFont.init(name: "Montserrat-SemiBold", size: 15)
        
        
        if(prospectDetails != nil){
            
            if(prospectDetails.dob != nil){
                self.dateOfBirthTextField.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: prospectDetails.dob!, dateFormat: "dd-MMM-yyyy")
            }

            if(prospectDetails.gender != nil){
                if(prospectDetails.gender == "Male"){
                    self.maleButton.isSelected = true
                }
                else if(prospectDetails.gender == "Female"){
                    self.femaleButton.isSelected = true
                }
                else if(prospectDetails.gender == "Others"){
                    self.othersButton.isSelected = true
                }
                self.selectedGender = prospectDetails.gender
            }
            companyNameTextField.text = prospectDetails.clientDetails?.companyName ?? ""
            designationTextField.text = prospectDetails.clientDetails?.designation ?? ""
            industryTextField.text = prospectDetails.clientDetails?.industry ?? ""
            locationTextField.text = prospectDetails.clientDetails?.locationOfWork ?? ""

        }
        
        

    }
    
    @IBAction func commissionUserSelection(_ sender: Any) {
        
        
        commissionUserTypeSelection = (sender as! DLRadioButton).tag
        commissionPopUpDataSource.removeAll()
        if(commissionUserTypeSelection == CommissionUserType.AGENT.rawValue){
            commissionPopUpDataSource = employeesCommissionInfo.filter( {$0.isAgent == true })
        }
        else if(commissionUserTypeSelection == CommissionUserType.TYPE_USER.rawValue){
            commissionPopUpDataSource = employeesCommissionInfo.filter( {$0.isAgent == false })
        }
        else if(commissionUserTypeSelection == CommissionUserType.TYPE_CUSTOMER.rawValue){
            commissionPopUpDataSource = customersCommissionInfo
            commissionPopUpDataSource.append(contentsOf: oldCustomersCommissionInfo)
        }
        else if(commissionUserTypeSelection == CommissionUserType.TYPE_OLD_CUSTOMER.rawValue){
            commissionPopUpDataSource = customersCommissionInfo
            commissionPopUpDataSource.append(contentsOf: oldCustomersCommissionInfo)
        }
//        commissionPopUpDataSource.insert(CommissionUser(name: "Select Commission Entity", phone: ""), at: 0)
        self.commissoinTypeLabel.text = "Select Commission Entity"
        self.selectedCommssion = nil
    }
    @objc @IBAction private func genderSelection(radioButton : DLRadioButton) {
        selectedGender = radioButton.selected()!.titleLabel!.text!
    }
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    //MARK: - FLOAT PANEL BEGIN
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return FullScreenCustomPanelLayout(parent: self)
    }
    func resetLeads()
    {
        hotButton.layer.cornerRadius = 4
        hotButton.layer.borderWidth = 1
        hotButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "34495E").cgColor
        coldButton.layer.cornerRadius = 4
        coldButton.layer.borderWidth = 1
        coldButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "34495E").cgColor
        warmButton.layer.cornerRadius = 4
        warmButton.layer.borderWidth = 1
        warmButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "34495E").cgColor
        warmButton.backgroundColor = UIColor.white
        coldButton.backgroundColor = UIColor.white
        hotButton.backgroundColor = UIColor.white
        
        hotButton.setTitleColor(UIColor.hexStringToUIColor(hex: "34495E"), for: .normal)
        warmButton.setTitleColor(UIColor.hexStringToUIColor(hex: "34495E"), for: .normal)
        coldButton.setTitleColor(UIColor.hexStringToUIColor(hex: "34495E"), for: .normal)

    }
    func resetView(){
        
        
        self.selectedProjects = []
        self.selectedProjectIds = []
        selectedEnquirySource = nil
        selectedCommssion = nil
        selectedLead = -1
        selectedGender = nil
        selectedUnitType = nil
        selectedMinBudget = nil
        selectedMaxBudget = nil
        selectedDateOfBirth = nil
        
        self.countryCodeTextField.text = ""
        self.phoneNumberTextField.text = ""
        self.customerNameTextField.text = ""
        self.emailAddressTextField.text = ""
        
        self.dateOfBirthTextField.text = ""
        
        self.companyNameTextField.text = ""
        self.designationTextField.text = ""
        self.industryTextField.text = ""
        self.locationTextField.text = ""
        
        self.alternateCountryCodeTextField.text = ""
        self.alternatePhoneNumberTextField.text = ""
        self.projectsLabel.text = "Select Project"
        self.projectsLabel.textColor = UIColor.lightGray
        self.minBudgetTextField.text = ""
        self.maxBudgetTextField.text = ""
        self.unitTypeTextField.text = ""
        
        self.resetLeads()
        
        self.commentsTextView.text = ""
        
        maleButton.isSelected = false
        femaleButton.isSelected = false
        othersButton.isSelected = false
        
        
        
    }
    @IBAction func leadClassficationAction(_ sender: Any) {
        
        let button = sender as! UIButton
        self.resetLeads()
        button.backgroundColor = UIColor.hexStringToUIColor(hex: "34495E")
        selectedLead = button.tag
        button.setTitleColor(UIColor.white, for: .normal)
        
    }
    
    @IBAction func showCommissions(_ sender: Any) {
        
//        let commissions = RRUtilities.sharedInstance.model.getCommissionsFromDB()
        self.showCommissionNewWay()
        return
//        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
//        vc.dataSourceType = .COMMISIONS
//        let counter = ((commissionPopUpDataSource.count - 1) == 0) ? 1 : (commissionPopUpDataSource.count - 1)
//        let height = self.view.frame.size.height
//
//        if(counter * 44 > Int(height - 300)){
//            vc.preferredContentSize = CGSize(width: 250, height: self.view.frame.size.height - 300)
//        }
//        else{
//            vc.preferredContentSize = CGSize(width: 250, height: counter * 44)
//        }
//
//        let navigationContoller = UINavigationController(rootViewController: vc)
//        navigationContoller.navigationBar.isHidden = true
//        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
//
//        let popOver =  navigationContoller.popoverPresentationController
//        popOver?.delegate = self
//        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
//        vc.commissionsDataSource = commissionPopUpDataSource
//        popOver?.sourceView = commissionTypeView
//
//        vc.delegate = self
//
//        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    @IBAction func showProjects(_ sender: Any) {
        
        self.view.endEditing(true)
        //registratoinProSearch
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
        registerController.delegate = self
        registerController.selectedProjectNamesArray = self.selectedProjects

        let fpc = FloatingPanelController()
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.set(contentViewController: registerController)
        
        fpc.delegate = self
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: registerController.tableView)

        self.present(fpc, animated: true, completion: nil)
        
    }
    func showEnquirySources(){
        
        if(sourcesArray.count == 0){
            HUD.flash(.label("Something went wrong. try later."), delay: 1.0)
            return
        }
        self.view.endEditing(true)
        //registratoinProSearch
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
        registerController.delegate = self
//        registerController.selectedProjectNamesArray = self.selectedProjects
        registerController.enquiryDataSource = self.sourcesArray
        registerController.isEnquirySources = true

        let fpc = FloatingPanelController()
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.set(contentViewController: registerController)
        
        fpc.delegate = self
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: registerController.tableView)
        
        
        self.present(fpc, animated: true, completion: nil)

    }
    func showCommissionNewWay(){
        if(commissionPopUpDataSource.count == 0){
            HUD.flash(.label("Something went wrong. try later."), delay: 1.0)
            return
        }

        self.view.endEditing(true)
        //registratoinProSearch
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
        registerController.delegate = self
        //        registerController.selectedProjectNamesArray = self.selectedProjects
        registerController.commissionsDataSource = self.commissionPopUpDataSource
        registerController.isCommission = true
        
        let fpc = FloatingPanelController()
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.set(contentViewController: registerController)
        
        fpc.delegate = self
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: registerController.tableView)
        
        self.present(fpc, animated: true, completion: nil)
        
    }
    //MARK: - FLOAT PANEL END
    func didSelectInterestedProjects(projectNames: [String],projectIds: [String]) {
        
//        print(projectNames)
        
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
        if(tempStr.count > 0){
            projectsLabel.text = tempStr
        }
        else{
            projectsLabel.text = "Select Project"
        }

        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    //MARK:- pop over delegate
    func didSelectDate(optionType: Date, optionIndex: Int) {
        let timeStamp = optionType.timeIntervalSince1970
//        print(timeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // This formate is input formated .
        let dateStr = dateFormatter.string(from: optionType)
        self.dateOfBirthTextField.text = dateStr
        self.selectedDateOfBirth = optionType
        
//        DispatchQueue.main.async {
//
//            if(optionIndex == 1){
//                self.dateOfBirthTextField.text = dateStr
//                let dateString = Formatter.ISO8601.string(from: Date())   // "2018-01-23T03:06:46.232Z"
//                print(dateString)
//        }
//        }
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    func didSelectProject(optionType: String, optionIndex: Int) {
        
    }
    func didFinishTask(optionType: String, optionIndex: Int) {
        
        print(optionType)
        enquirySourceTextField.text = optionType
        selectedEnquirySource = sourcesArray[optionIndex]
        self.hidePopUp()

    }
    func didSelectEnquirySource(selectedSource : String,optionIndex: Int,enqSource : NewEnquirySources)
    {
        enquirySourceTextField.text = enqSource.displayName
        selectedEnquirySource = enqSource
        self.dismiss(animated: true, completion: nil)
    }
    func didSelectMaxBudget(selectedRange: CustomerBudgets) {
        self.selectedMaxBudget = selectedRange
        self.maxBudgetTextField.text = String(format: "%d", selectedRange.value)
        self.hidePopUp()
    }
    func didSelectMinBudget(selectedRange: CustomerBudgets) {
        self.selectedMinBudget = selectedRange
        self.minBudgetTextField.text = String(format: "%d", selectedRange.value)
        self.hidePopUp()
    }
    func didSelectUnitType(selectedUnitType: UnitTypes) {
        
        self.unitTypeTextField.text = selectedUnitType.name
        self.selectedUnitType = selectedUnitType
        self.hidePopUp()
    }
    func hidePopUp(){
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
    func setUpEditedProspect(parameters : Dictionary<String,Any>){
        
        /*
         
         Customer name
         Number
         Email
         Lead classification
         enquirysource
         Comments :
         
         */
        
    }
    @objc func hideProgress(){
        
        if(self.isEditingRegistration){
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func registerUser(_ sender: UIButton) {
        
        
//        #if DEBUG
//        self.resetView()
//        return
//        #endif
        
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
            HUD.flash(.label("Customer phone number is mandatory"), delay: 0.8)
            return
        }
        if(customerNameTextField.text?.count == 0){
            HUD.flash(.label("Customer name number is mandatory"), delay: 0.8)
            return
        }
        
//        if(isEditingRegistration && emailAddressTextField.text?.count == 0){
//            HUD.flash(.label("Enter Email ID"), delay: 1.0)
//            return
//        }
        
        if(emailAddressTextField.text?.count != 0 && (RRUtilities.sharedInstance.isValidEmail(emailID: emailAddressTextField.text!) == false)){
            HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
            return
        }
        
        if(!self.isCountryCodeValid(countryCode: self.countryCodeTextField.text!,isAlterate: false)){
            HUD.flash(.label("Please enter proper country code"), delay: 1.0)
            return
        }
        
        if(countryCodeTextField.text == "91" && phoneNumberTextField.text?.count != 10){
            HUD.flash(.label("Enter valid phone number"), delay: 0.8)
            return
        }

        
        if(self.alternateCountryCodeTextField.text!.count > 0){
            if(!self.isCountryCodeValid(countryCode: self.alternateCountryCodeTextField.text!,isAlterate: true)){
                HUD.flash(.label("Please enter proper alternate country code"), delay: 1.0)
                return
            }
        }
        
        if(alternateCountryCodeTextField.text == "91" && alternatePhoneNumberTextField.text?.count != 10){
            HUD.flash(.label("Enter valid alternate phone number"), delay: 0.8)
            return
        }
        
        var parameters : Dictionary<String,Any> = [:]

        if(enquirySourceTextField.text!.count > 0){
            parameters["enquirySource"] = selectedEnquirySource.name
            if(selectedEnquirySource != nil && selectedEnquirySource.id != nil){
                parameters["enquirySourceId"] = selectedEnquirySource.id
            }
        }
        else
        {
            HUD.flash(.label("Please select Enquiry Source"), delay: 1.0)
            return
        }
        if(selectedLead != -1){
            if(selectedLead == 0){
                parameters["leadStatus"] = "Hot"
            }else if(selectedLead == 1){
                parameters["leadStatus"] = "Warm"
            }
            else if(selectedLead == 2){
                parameters["leadStatus"] = "Cold"
            }
        }
        else{
            HUD.flash(.label("Select Lead Classfication"), delay: 1.0)
           return
        }
        if(enquirySourceTextField.text == "Select Source"){
            HUD.flash(.label("Select Enquiry Source"), delay: 1.0)
            return
        }
        if(emailAddressTextField.text!.count > 0){
            if(RRUtilities.sharedInstance.isValidEmail(emailID: emailAddressTextField.text!) == false){
                HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
                return
            }
            else{
                if(emailAddressTextField.text!.count > 0){
                    parameters["userEmail"] = emailAddressTextField.text
                }
            }
        }

        
        if(!isEditingRegistration){
            
            if(sender.tag == 0){
                
                HUD.show(.progress, onView: self.view)
                if(UserDefaults.standard.bool(forKey: "promptOTP")){
                    
                    let number = self.countryCodeTextField.text! + self.phoneNumberTextField.text!
                    ServerAPIs.generateOTP(phoneNumber: number, completion: { response in
                        
                        switch response {
                        case .success(let response):
                            DispatchQueue.main.async { [self] in
                                HUD.hide()
                                // Finish otp fast and work on timelines and idle tabs
                                HUD.flash(.label("OTP has been sent"), onView: self.view, delay: 2.0, completion: nil)
                                self.perform(#selector(self.showOTPScreen), with: nil, afterDelay: 2.0)
                            }
                            print(response)
                            break
                        case .failure(_):
                            HUD.flash(.label("Failed to send OTP"), delay: 2.0)
                            break

                        }
                        
                    })
                    
                    return
                }
            }
            else if(sender.tag == 1){
                
                
                //Verified otp , continue to register
            }
            else{
                
                
            }
        }
  
        
        parameters["userPhone"] = phoneNumberTextField.text
        //Add verification
        parameters["userPhoneCode"] = countryCodeTextField.text ?? "91"
        
        parameters["userName"] = customerNameTextField.text
        
        if(selectedProjectIds.count > 0){
            parameters["projects"] = selectedProjectIds
        }
        parameters["projectNames"] = selectedProjects

        if(commentsTextView.text.count > 0){
            parameters["comment"] = commentsTextView.text
        }
        
        if(isEditingRegistration){
            parameters["comment"] = commentsTextView.text
        }
        
        
        if(dateOfBirthTextField.text!.count > 0){
            let dateString = Formatter.ISO8601.string(from: self.selectedDateOfBirth)
            parameters["dob"] = dateString
        }
    
        if(selectedGender != nil)
        {
            parameters["gender"] = selectedGender
        }
        
        var clientDetails : Dictionary<String,String> = [:]
        
        if(companyNameTextField.text!.count > 0){
            clientDetails["companyName"] = companyNameTextField.text
        }
        if(designationTextField.text!.count > 0){
            clientDetails["designation"] = designationTextField.text
        }
        if(industryTextField.text!.count > 0){
            clientDetails["industry"] = industryTextField.text
        }
        if(locationTextField.text!.count > 0){
            clientDetails["locationOfWork"] = locationTextField.text
        }
        
        if(clientDetails.keys.count > 0){
            parameters["clientDetails"] = clientDetails
        }
        
        parameters["isCommissionApplicable"] = (commissionAplicableButton.tag == 1) ? true : false
        
        if(selectedUnitType != nil){
            parameters["unitType"] = selectedUnitType.name
        }
        if(selectedMinBudget != nil){
            parameters["minBudget"] = selectedMinBudget.value
        }
        if(selectedMaxBudget != nil){
            parameters["maxBudget"] = selectedMaxBudget.value
        }
        
        if(commissionAplicableButton.tag == 1){ //!isEditingRegistration &&
            
            if(selectedCommssion == nil){
                HUD.flash(.label("Select Commission Entity"), delay: 1.5)
                return
            }
            var commissionEntry : Dictionary<String,String> = [:]
            if(selectedCommssion.type == CommissionUserType.TYPE_USER.rawValue){
                commissionEntry["kind"] = "UserInfo"
            }
            else if(selectedCommssion.type == CommissionUserType.TYPE_CUSTOMER.rawValue){
                commissionEntry["kind"] = "Customer"
            }
            else if(selectedCommssion.type == CommissionUserType.AGENT.rawValue){
                commissionEntry["kind"] = "Agent"
            }
            else if(selectedCommssion.type == CommissionUserType.TYPE_OLD_CUSTOMER.rawValue){
                commissionEntry["kind"] = "OldCustomer"
            }
            else{
                commissionEntry["kind"] = "UserInfo"
            }
            
            let isOldCustomer = self.oldCustomersCommissionInfo.filter({ $0._id == selectedCommssion._id })
            
            if(isOldCustomer.count > 0){
                commissionEntry["kind"] = "OldCustomer"
            }
            
            commissionEntry["id"] = selectedCommssion._id
            parameters["commissionEntity"] = commissionEntry
        }

        if(alternateCountryCodeTextField.text!.count > 0){
            parameters["alternatePhoneCode"] = alternateCountryCodeTextField.text
        }
        if(alternatePhoneNumberTextField.text!.count > 0){
            parameters["alternatePhone"] = alternatePhoneNumberTextField.text
        }
        
        var urlString = String()
        
        if(isEditingRegistration){
            
            editedProspect = self.prospectDetails

            editedProspect.userName = (parameters["userName"] as? String)
            editedProspect.userPhone = (parameters["userPhone"] as? String)
            editedProspect.userPhoneCode = (parameters["userPhoneCode"] as? String)
            editedProspect.alternatePhoneCode = (parameters["alternatePhoneCode"] as? String)
            editedProspect.alternatePhone = (parameters["alternatePhone"] as? String)
            if(parameters["userEmail"] != nil){
                editedProspect.userEmail = (parameters["userEmail"] as? String)
            }
            else{
//                parameters["userEmail"] = " "
            }
            editedProspect.comment = (parameters["comment"] as! String)
            
            editedProspect.enquirySource = enquirySourceTextField.text
            if(selectedEnquirySource != nil){
                editedProspect.enquirySourceId = selectedEnquirySource.id
            }
            else{
                editedProspect.enquirySourceId = prospectDetails.enquirySourceId
            }
            editedProspect.leadStatus = (parameters["leadStatus"] as! String)
            
            if(parameters["commissionEntity"] != nil){
                let tempDict : Dictionary<String,String> = parameters["commissionEntity"] as! Dictionary<String,String>
                let entity : CommissionEntity = CommissionEntity(id: tempDict["id"], kind: tempDict["kind"])
                editedProspect.commissionEntity = entity
            }
            editedProspect.isCommissionApplicable = (commissionAplicableButton.tag == 1) ? true : false
            if(emailAddressTextField.text!.count > 0){
                editedProspect.userEmail = emailAddressTextField.text!
            }
            
            parameters["currId"]  = prospectDetails._id
            parameters["regInfo"] = prospectDetails.regInfo ?? prospectDetails._id
            parameters["viewType"] = self.viewType.rawValue
            let project = prospectDetails.actionInfo?.projects?.first
            parameters["currProject"] = project?._id
            
            if(avoidCrossProjectCheck){
                urlString = RRAPI.API_EDIT_REGISTRATION_BASICS + "?avoidCrossProjectCheck=1"
            }
            else{
                urlString =  RRAPI.API_EDIT_REGISTRATION_BASICS
            }
        }
        else{
            if(avoidCrossProjectCheck){
                urlString = RRAPI.QUICK_REIGSTRATION + "?avoidCrossProjectCheck=1"
            }
            else{
                urlString = RRAPI.QUICK_REIGSTRATION
            }
        }
        parameters["src"] = 3
        parameters["avoidCrossProjectCheck"] = 1
        //alternatePhoneCode
        //alternatePhone
        //isCommissionApplicable
        //commissionConfig
        
//        print(parameters)
        HUD.show(.progress, onView: self.view)
        
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                HUD.hide()
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                
                do{
                    let urlResult1 = try JSONDecoder().decode(Q_REGISTRATION_RESULT_CHECK.self, from: responseData)
                    if(urlResult1.status == 0){
                        let urlResult = try JSONDecoder().decode(Q_REGISTRATION_RESULT_STRING_ERROR.self, from: responseData)
                        var resuelt = urlResult.err
                        
                        var isDiffProject = false

                        if(self.selectedProjects.count > 0){
                            for eachProjectName in self.selectedProjects{
                                if(resuelt?.contains(eachProjectName) ?? false){
                                    isDiffProject = true
                                }
                            }
                        }
                        if(!isDiffProject){
                            resuelt?.append(contentsOf: "\nDo you want to continue?")
                        }
                        let alertController = UIAlertController(title: NSLocalizedString("REroot", comment: ""), message: resuelt, preferredStyle: .alert)

                        if(!isDiffProject){
                            let continueAction = UIAlertAction(title: NSLocalizedString("YES", comment: ""), style: .default, handler: { action in
                                //Call Register again with
                                self.avoidCrossProjectCheck = true
                                let tempButton = UIButton()
                                tempButton.tag = 1
                                self.registerUser(tempButton)
                            })
                            alertController.addAction(continueAction)
                            let cancelAction = UIAlertAction(title: NSLocalizedString("NO", comment: ""), style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)

                        }
                        else{
                            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)

                        }
                        
                        self.present(alertController, animated: true, completion: nil)

//                        HUD.flash(.label(resuelt), delay: 2.0)
                        return
                    }
                    if(urlResult1.status == -1){
                        do{
                            guard let _ : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                                print("error trying to convert data to JSON")
                                return
                            }
                            let urlResult = try JSONDecoder().decode(Q_REGISTRATION_RESULT_STRING_ERROR.self, from: responseData)
                            if let errorStr = urlResult.err{
//                             HUD.flash(.label(errorStr), delay: 1.5)
                                
//                                var tempStr = errorStr
                                
//                                var isDiffProject = false
//
//                                if(self.selectedProjects.count > 0){
//                                    for eachProjectName in self.selectedProjects{
//                                        if(tempStr.contains(eachProjectName)){
//                                            isDiffProject = true
//                                        }
//                                    }
//                                }
//                                if(!isDiffProject){
//                                    tempStr.append(contentsOf: "\nDo you want to continue?")
//                                }
                                
                                let alertController = UIAlertController(title: NSLocalizedString("REroot", comment: ""), message: errorStr, preferredStyle: .alert)
                                
//                                if(!isDiffProject){
//                                    let continueAction = UIAlertAction(title: NSLocalizedString("YES", comment: ""), style: .default, handler: { action in
//                                        //Call Register again with
//                                        self.avoidCrossProjectCheck = true
//                                        self.registerUser(UIButton())
//                                    })
//                                    alertController.addAction(continueAction)
//                                    let cancelAction = UIAlertAction(title: NSLocalizedString("NO", comment: ""), style: .cancel, handler: nil)
//                                    alertController.addAction(cancelAction)
//
//                                }
//                                else{
                                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
                                    alertController.addAction(cancelAction)

//                                }
                                self.present(alertController, animated: true, completion: nil)

                                return
                            }
                            else{
                                
                            }
                            //                    let urlResult = try JSONDecoder().decode(Q_REGISTRATION_RESULT.self, from: responseData)
                            //                    let resuelt = urlResult.err?.userEmail
                            HUD.flash(.label("Couldn't register prospect!. Try later"), delay: 2.0)
                            return
                        }
                        catch let jsonError{
                            print("Error in parsing :" , jsonError)
                            return
                        }
                    }
                    
                    let urlResult = try JSONDecoder().decode(Q_REGISTRATION_RESULT.self, from: responseData)
                    
                    DispatchQueue.main.async {
                        
                        if(urlResult.status == 1){ // success
                            
                            if(self.isEditingRegistration){
                                
                                HUD.flash(.label("Registration updated succesfully."), delay: 1.0)
                                self.delegate?.didFinishEdit(prospect: self.editedProspect)
                                
                                self.perform(#selector(self.hideProgress), with: nil, afterDelay: 1.0)
                                return
                            }
                            else{
                                HUD.flash(.label("Registered successfully"), delay: 2.0)

                                if(UserDefaults.standard.bool(forKey: "siteVisitUser"))
                                {
                                    // Update but don't go back from here
                                    self.resetView()
                                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                                }
                                else{
                                    self.perform(#selector(self.hideProgress), with: nil, afterDelay: 2.0)
                                }
                            }
                            
                        }else{
                            
                            HUD.flash(.label(urlResult.err?.id), delay: 1.0)
                        }
                    }
                    
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
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
        if(textField == minBudgetTextField){
            self.showBudgetRanges(isMin: true)
            return false
        }
        if(textField == maxBudgetTextField){
            self.showBudgetRanges(isMin: false)
            return false
        }
        if(textField == unitTypeTextField){
            self.showUnitTypes()
            return false
        }
        if(textField == dateOfBirthTextField){
            self.showDatePicker(textField: dateOfBirthTextField)
            return false
        }
        
        return true
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if(textField == phoneNumberTextField){
            if(countryCodeTextField.text == "91"){
                return textField.text!.count < 10 || string == ""
            }
        }
        if(textField == alternatePhoneNumberTextField){
            if(alternateCountryCodeTextField.text == "91"){
                return textField.text!.count < 10 || string == ""
            }
        }

        if(textField == countryCodeTextField || textField == alternateCountryCodeTextField){
             // perfomr search and update data source
            var isDelete = false
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    isDelete = true
                }
            }
            if(isDelete){
                print(textField.text!)
                let tempStr = textField.text!.dropLast()
                if(textField == countryCodeTextField){
                    self.showCountryCodePopUp(searchString: String(tempStr),forFieldIndex: 1)
                }
                else{
                    self.showCountryCodePopUp(searchString: String(tempStr),forFieldIndex: 2)
                }
            }
            else{
                if(textField == countryCodeTextField){
                    self.showCountryCodePopUp(searchString: textField.text! + string,forFieldIndex: 1)
                }
                else{
                    self.showCountryCodePopUp(searchString: textField.text! + string,forFieldIndex: 2)
                }
            }
            if(countryCodePopOver != nil && countryCodePopOver.mTableView != nil){
                countryCodePopOver.mTableView.reloadData()
            }
        }
        
        return true
    }
//    @objc func injected() {
//        configureView()
//    }
    func didSelectCommision(selectedCommission: CommissionUser) {
        
        self.selectedCommssion = selectedCommission
        
        if(selectedCommssion.type == nil){
            selectedCommssion.type = commissionUserTypeSelection
        }
        
        self.commissoinTypeLabel.text = String(format: "%@ (%@)", selectedCommission.name ?? "",selectedCommission.phone ?? "")
        
        let tmpController :UIViewController! = self.presentedViewController;
        if(tmpController != nil){
            self.dismiss(animated: false, completion: {()->Void in
                tmpController.dismiss(animated: false, completion: nil);
            });
        }

    }
    func didSelectCommission(commission : CommissionUser)
    {
        self.selectedCommssion = commission
        
        if(selectedCommssion.type == nil){
            selectedCommssion.type = commissionUserTypeSelection
        }
        
        self.commissoinTypeLabel.text = String(format: "%@ (%@)", commission.name ?? "",commission.phone ?? "")
        self.dismiss(animated: true, completion: nil)

    }
    func didSelectCountryCode(countryCode: String, countryName: String, forFieldIndex: Int) {
        if(forFieldIndex == 1){
            let countryCode = countryCode.dropFirst()
            self.countryCodeTextField.text = String(countryCode)
            self.hideCountryCodePopUp()
        }
        else{
            let countryCode = countryCode.dropFirst()
            self.alternateCountryCodeTextField.text = String(countryCode)
            self.hideCountryCodePopUp()
        }
    }
    func hideCountryCodePopUp(){
        
        self.countryCodesArray.removeAllObjects()
        
        let tmpController :UIViewController! = self.presentedViewController;
        if(tmpController != nil){
            self.dismiss(animated: false, completion: {()->Void in
                tmpController.dismiss(animated: false, completion: nil);
            });
        }
        self.countryCodePopOver = nil
        self.countryCodeNavigator = nil
    }
    func isCountryCodeValid(countryCode : String,isAlterate : Bool)->Bool{
        
        if(countryCodesArray.count == 0){
            let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
            countryCodesArray = NSMutableArray.init(contentsOfFile: path!)!
        }
        let predicate = NSPredicate.init(format: "dial_code CONTAINS[cd] %@",countryCode)
        let fileredArray : NSArray = self.countryCodesArray.filtered(using: predicate) as NSArray
        var arrayCounter = 0
        if(fileredArray.count > 0){
            for counter in 0...fileredArray.count-1{
                let tempDict : NSDictionary = fileredArray[counter] as! NSDictionary
                let tempCode = tempDict["dial_code"] as! String
                let code = tempCode.dropFirst()
                arrayCounter = arrayCounter + 1
                if(!isAlterate && String(code) == countryCodeTextField.text!){
                    return true
                }
                else if(isAlterate && String(code) == alternateCountryCodeTextField.text!){
                        return true
                }
            }
            return false
        }
        else{
            return false
        }
    }
    func showCountryCodePopUp(searchString : String,forFieldIndex : Int){
        
        if(countryCodesArray.count == 0){
            let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
            countryCodesArray = NSMutableArray.init(contentsOfFile: path!)!
        }
        let predicate = NSPredicate.init(format: "name CONTAINS[cd] %@ || dial_code CONTAINS[cd] %@", searchString,searchString)
        print(predicate)
        let fileredArray : NSArray = self.countryCodesArray.filtered(using: predicate) as NSArray
        
        if(fileredArray.count == 0){
            //dismiss
            print("Not found")
            self.hideCountryCodePopUp()
            return
        }
        
        if(countryCodePopOver == nil){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            countryCodePopOver = (storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController)
            countryCodePopOver.dataSourceType = .COUNTRY_CODE
            countryCodePopOver.preferredContentSize = CGSize(width:  300, height: (self.countryCodesArray.count - 1) * 44)
        }

        if(CGFloat((self.countryCodesArray.count * 44)) > (self.view.frame.size.height - 150)){
            countryCodePopOver.preferredContentSize = CGSize(width: 300, height: 300)
        }
        let navigationContoller = UINavigationController(rootViewController: countryCodePopOver)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        countryCodePopOver.countryCodeDataSouce = fileredArray
        countryCodePopOver.countryCodeFieldIndex = forFieldIndex
        
        if(forFieldIndex == 1){
            popOver?.sourceView = sourceRectView
        }
        else{
            popOver?.sourceView = alternateCountryCodeTextField
        }
        
        countryCodePopOver.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)


    }
    func configureView() {
        // Update the user interface for the detail item.
//        titleView.backgroundColor = UIColor.red
    }

    
    @IBAction func hide(_ sender: Any) {
        if(isEditingRegistration){
            self.navigationController?.popViewController(animated: true)
        }
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
extension RegistrationViewController : OTPProtool{
    
    func didVerifyOtp() {
        self.hidePopUp()
        let tempButton = UIButton()
        tempButton.tag = 1
        self.registerUser(tempButton)
    }
    func didResendOtp() {
        
    }
    
}
