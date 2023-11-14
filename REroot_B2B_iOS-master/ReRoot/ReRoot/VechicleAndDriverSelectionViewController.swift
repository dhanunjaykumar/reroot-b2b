//
//  VechicleAndDriverSelectionViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 06/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
//import DropDown
import Alamofire
import PKHUD

protocol VechicleAndDriverDelegate: class {
    func didSelectVehicleAndDriver(driveID: String?,vehicleID: String?,selectedAction : Int)
}

class VechicleAndDriverSelectionViewController: UIViewController ,UITextFieldDelegate{

    var isOwnVehicel : Bool = false
    @IBOutlet var driverInfoLabel: UILabel!
    @IBOutlet var vehicleInfoLabel: UILabel!
    var keyboardHeight: CGFloat!
    @IBOutlet var vechicleSelectoinView: UIView!
    @IBOutlet var heightOfVechileSelectionView: NSLayoutConstraint!
    var selectedDriverID : String!
    var selectedVehicelID : String!
    var comment : String!
    
    @IBOutlet var travelTypeTextField: UITextField!
    var emailId : String!
    var statusID : Int? = 0
    var selectedAction = 0 //Selected option should be > 0 for server
    var isFromNotification = false
    weak var delegate:VechicleAndDriverDelegate?
    var viewType : VIEW_TYPE!
    var tabId : Int!
    var selectedProject : Project!
    var selctedScheduleCallOption : Int!
//    var prospectDetails : REGISTRATIONS_RESULT!
    var selectedDate : Date!
    var comments : String!
    var selectedProjectId : String!
    var selectedUnitId : String!
    var selectedSchemeID : String!
    
    var selectedProspect : REGISTRATIONS_RESULT!
    var isFromRegistrations = false
    
    let vehicleSelectionDropDown = DropDown()
    let driverSelectionDropDown = DropDown()
    let transportTypeSelectionDropDown = DropDown()
    
    @IBOutlet var driverTextField: UITextField!
    @IBOutlet var vehicleTextField: UITextField!
    
    var transportTypeArray : [String]!
    
    var vehiclesArray : [Vehicle] = []
    var driversArray : [Driver] = []
    
    // MARK:- Controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
//        transportTypeSelectionDropDown.direction = .top
//        transportTypeSelectionDropDown.topOffset = CGPoint(x: 0, y: keyboardHeight)
//
//        vehicleSelectionDropDown.direction = .top
//        vehicleSelectionDropDown.topOffset = CGPoint(x: 0, y: keyboardHeight)
//
//        driverSelectionDropDown.direction = .top
//        driverSelectionDropDown.topOffset = CGPoint(x: 0, y: keyboardHeight)
        
    }
    @objc func injected(){
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        definesPresentationContext = true
        NotificationCenter.default.addObserver(self, selector: #selector(hideAll), name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)

        driverTextField.delegate = self
        vehicleTextField.delegate = self
        travelTypeTextField.delegate = self
        
        transportTypeArray = ["Own","Company"]
        
        print(selectedProject)
        print(selectedProspect)
        
        self.driversArray = RRUtilities.sharedInstance.model.getAllDrivers()
        self.vehiclesArray = RRUtilities.sharedInstance.model.getAllVehicles()

        vehicleSelectionDropDown.showingVehicles = true
        driverSelectionDropDown.showingDrivers = true
        transportTypeSelectionDropDown.showingTrasportType = true
        
        heightOfVechileSelectionView.constant = 0
        vechicleSelectoinView.isHidden = true
        travelTypeTextField.rightView = UIImageView.init(image: UIImage.init(named: "downArrow"))
        travelTypeTextField.rightViewMode = .always
        self.isOwnVehicel = true
        self.setupDriversDropDown()
        self.setupVehiclesDropDown()
        self.setupTransportDropDown()
        
    }
    func setupTransportDropDown(){
        
        transportTypeSelectionDropDown.anchorView = travelTypeTextField
        transportTypeSelectionDropDown.topOffset = CGPoint(x: 0, y: travelTypeTextField.bounds.height)
        transportTypeSelectionDropDown.dataSource = self.transportTypeArray

        transportTypeSelectionDropDown.selectionAction = { [weak self] (index, item) in
            self?.travelTypeTextField.text = item as? String
            
            if(index == 0){
                self?.isOwnVehicel = true
                self?.heightOfVechileSelectionView.constant = 0
                self?.vechicleSelectoinView.isHidden = true
            }
            else{
                self?.isOwnVehicel = false
                self?.heightOfVechileSelectionView.constant = 200
                self?.vechicleSelectoinView.isHidden = false
            }
        }
    }
    func setupVehiclesDropDown(){
        
        if(self.vehiclesArray.count == 0){
            HUD.flash(.label("There are no vehicle!"), delay: 1.0)
            return
        }
        
        vehicleSelectionDropDown.anchorView = vehicleTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        vehicleSelectionDropDown.topOffset = CGPoint(x: 0, y: vehicleInfoLabel.bounds.height)
        vehicleSelectionDropDown.direction = .top
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        vehicleSelectionDropDown.dataSource = self.vehiclesArray
        
        // Action triggered on selection
        vehicleSelectionDropDown.selectionAction = { [weak self] (index, item) in
            let vehicle : Vehicle = item as! Vehicle
            self?.vehicleTextField.text = vehicle.plateNo
            self?.selectedVehicelID = vehicle.id
        }
    }
    
    func setupDriversDropDown(){
        
        driverSelectionDropDown.anchorView = driverTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        driverSelectionDropDown.topOffset = CGPoint(x: 0, y: driverInfoLabel.bounds.height)
        driverSelectionDropDown.direction = .top
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        driverSelectionDropDown.dataSource = self.driversArray
        
        // Action triggered on selection
        driverSelectionDropDown.selectionAction = { [weak self] (index, item) in
            let driver : Driver = item as! Driver
            self?.driverTextField.text = driver.name
            self?.selectedDriverID = driver.id
        }
    }
    @IBAction func okAction(_ sender: Any) {
        
//        self.delegate?.didSelectVehicleAndDriver(driveID: driverTextField.text!, vehicleID: vehicleTextField.text!, selectedAction: selectedAction)

        self.siteVisit()
        
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if(textField == travelTypeTextField){
            transportTypeSelectionDropDown.show()
        }
        if(textField == driverTextField){
            driverSelectionDropDown.show()
            driverSelectionDropDown.topOffset = CGPoint(x: 0, y: driverInfoLabel.bounds.height)
            print(driverTextField.bounds,driverTextField.frame)
//            return true
        }
        if(textField == vehicleTextField){
            vehicleSelectionDropDown.show()
        }
        
        return false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let searchStr = textField.text! + string
        if(textField == driverTextField){
            
            self.driversArray = RRUtilities.sharedInstance.model.getAllDrivers()
            self.driversArray = self.driversArray.filter({ ($0.name!.localizedCaseInsensitiveContains(searchStr)) })
            
            if(self.driversArray.count == 0){
                HUD.flash(.label("No Driver with name \(searchStr)"), delay: 1.0)
            }
            else{
                self.setupDriversDropDown()
                driverSelectionDropDown.show()
            }
            
        }
        return true
    }
    // MARK: - SITE VISIT CALLL
    
    func siteVisit(){ //(projectID: String, unitID: String,selectedAction : Int)
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var siteVisitParameters : Dictionary<String,Any> = [:]
        
        let selectedDriver = driverTextField.text
        let selectedVehicle = vehicleTextField.text

//        if(!self.isOwnVehicel && selectedVehicle!.count <= 0){
//            HUD.flash(.label("Select Vechicle"), delay: 1.0)
//            return
//        }
//
//        if(!self.isOwnVehicel && selectedDriver!.count <= 0){
//            HUD.flash(.label("Select Driver"), delay: 1.0)
//            return
//        }
        
        let selectedDriverID = self.selectedDriverID
        
        let selectedVehicleID = selectedVehicelID
        
        if(isFromRegistrations){
            
            siteVisitParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            siteVisitParameters["project"] = self.selectedProspect.project?._id
            siteVisitParameters["registrationDate"] = self.selectedProspect.registrationDate
            
            if(selectedProspect.regInfo != nil){
                siteVisitParameters["regInfo"] = selectedProspect.regInfo
            }else{
                siteVisitParameters["regInfo"] = selectedProspect._id
            }
            
            var action : Dictionary<String,String> = [:]
            
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.SITE_VISTI.rawValue
            
            var actionInfo : Dictionary<String,Any> = [:]
            print(siteVisitParameters["date"])
            print(Formatter.ISO8601.string(from: selectedDate))
            actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
            actionInfo["projects"] = [selectedProjectId]
            actionInfo["comment"] = comment
            actionInfo["units"] = [selectedUnitId]
            if(!self.isOwnVehicel && selectedDriverID != nil && selectedVehicleID != nil){
                actionInfo["driver"] = selectedDriverID
                actionInfo["vehicle"] = selectedVehicleID
            }
            
            siteVisitParameters["action"] = action
            siteVisitParameters["actionInfo"] = actionInfo
            
            var salesPerson : Dictionary<String,Any> = [:]
            salesPerson["_id"] = selectedProspect.salesPerson?._id
            salesPerson["email"] = selectedProspect.salesPerson?.email
            
            var userInfo : Dictionary<String,String> = [:]
            userInfo["_id"] = selectedProspect.salesPerson?.userInfo?._id
            userInfo["email"] = selectedProspect.salesPerson?.userInfo?.email
            userInfo["name"] = selectedProspect.salesPerson?.userInfo?.name
            userInfo["phone"] = selectedProspect.salesPerson?.userInfo?.phone
            
            salesPerson["userInfo"] = userInfo
            
            siteVisitParameters["salesPerson"] = salesPerson
            
        }
        else{
            
            siteVisitParameters["registrationDate"] = selectedProspect.registrationDate
            siteVisitParameters["project"] =  selectedProjectId ?? selectedProspect.project?._id
            siteVisitParameters["regInfo"] = selectedProspect.regInfo
            siteVisitParameters["registrationStatus"] = 1 //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            siteVisitParameters["unit"] = selectedProspect.unit?._id
            
            var action : Dictionary<String,String> = [:]
            action["id"] = String(format: "%d", selectedAction)
            if(selectedAction == 1){
                action["label"] = ACTION_TYPE_STRING.SCHEDULE_CALL.rawValue
            }
            else if(selectedAction == 2){
                action["label"] = ACTION_TYPE_STRING.SEND_OFFER.rawValue
            }
            else if(selectedAction == 3){
                action["label"] = ACTION_TYPE_STRING.SITE_VISTI.rawValue
            }
            else if(selectedAction == 4){
                action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue
            }
            else if(selectedAction == 5){
                action["label"] = ACTION_TYPE_STRING.NEW_TASK.rawValue
            }
            
            
            var actionInfo : Dictionary<String,Any> = [:]
            
            actionInfo["projects"] = selectedProjectId ?? [selectedProspect.project?._id]
            actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
            actionInfo["comment"] = comment
            if(selectedAction == 2 || selectedAction == 4){
                let date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
                actionInfo["date"] = Formatter.ISO8601.string(from: date)
            }

            var prevLeadStatus : Dictionary<String,Any> = [:]
            
//            if(selectedProspect.action != nil)
//            {
//                prevLeadStatus["actionType"] = selectedProspect.action?.id
//            }
//            else
//            {
                prevLeadStatus["actionType"] = self.statusID //ACTION_TYPE.SITE_VISIT.rawValue
//            }
            prevLeadStatus["id"] = selectedProspect._id ////*** should pass ACTION TYPE IDDD
            
            siteVisitParameters["viewType"] = self.viewType.rawValue
            
            var status : Dictionary<String,String> = [:]
            
            // *** status must be the first selected option inside leads or opppts :
            
            if(statusID == 1){ //From calls controller
                
                status["id"] = String(format: "%d", selctedScheduleCallOption)
                
                if(selctedScheduleCallOption == 1){
                    status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NO_RESPONSE.rawValue
                }
                else if(selctedScheduleCallOption == 2){
                    status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NOT_REACHABLE.rawValue
                }
                else if(selctedScheduleCallOption == 3){
                    status["label"] = SCHEDULE_CALL_ACTIONS_STRING.CALL_COMPLETE.rawValue
                }
                else if(selctedScheduleCallOption == 4){
                    status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NOT_INTERESTED.rawValue
                }
                
                prevLeadStatus["status"] = status
                
                actionInfo["projects"] = [selectedProjectId]
                actionInfo["units"] = [selectedUnitId]
                if(!self.isOwnVehicel && selectedVehicleID != nil && selectedDriverID != nil){
                    actionInfo["vehicle"] = selectedVehicleID
                    actionInfo["driver"] = selectedDriverID
                }
                actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                actionInfo["comment"] = comment
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email
                
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    siteVisitParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    siteVisitParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                

                siteVisitParameters["action"] = action
                if(selectedProspect.salesPerson?._id != nil){
                    siteVisitParameters["salesPerson"] = salesPerson
                }
                siteVisitParameters["unit"] = selectedUnitId
                siteVisitParameters["actionInfo"] = actionInfo
                siteVisitParameters["unit"] = selectedProspect.unit?._id
            }
            else if(statusID == 2){ //Offers controller
                
                siteVisitParameters["_id"] = selectedProspect._id

                if(!self.isOwnVehicel && selectedVehicleID != nil && selectedDriverID != nil){
                    actionInfo["vehicle"] = selectedVehicleID
                    actionInfo["driver"] = selectedDriverID
                }
                actionInfo["comment"] = comment

                siteVisitParameters["enquirySource"]  = selectedProspect.enquirySource
                
                var project : Dictionary<String,String> = [:]
                project["_id"] = selectedProspect.project?._id
                project["name"] = selectedProspect.project?.name
                
                siteVisitParameters["project"] = project
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = selectedProspect.salesPerson?.userInfo?._id
                userInfo["email"] = selectedProspect.salesPerson?.userInfo?.email
                userInfo["name"] = selectedProspect.salesPerson?.userInfo?.name
                userInfo["phone"] = selectedProspect.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo
                
                siteVisitParameters["salesPerson"] = salesPerson
                
                var unit : Dictionary<String,String> = [:]
                
                let tempUnits = selectedProspect.actionInfo?.units
                let counter = tempUnits?.count
                
                if(counter! > 0){
                    
                    let unitDetails : UNITS = (selectedProspect.actionInfo?.units![0])!
                    
                    unit["_id"] = unitDetails._id
                    unit["block"] = unitDetails.block
                    unit["tower"] = unitDetails.tower
                    unit["description"] = unitDetails.description
                    
                    actionInfo["units"] = [unitDetails._id]

                }
                else
                {
                    
                }
                
                siteVisitParameters["unit"] = unit
                
                siteVisitParameters["userEmail"] = self.emailId ?? selectedProspect.userEmail
                siteVisitParameters["userName"] = selectedProspect.userName
                siteVisitParameters["userPhone"] = selectedProspect.userPhone
                
                prevLeadStatus["status"] = status
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    siteVisitParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    siteVisitParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                siteVisitParameters["action"] = action
                siteVisitParameters["actionInfo"] = actionInfo

                
            }
            else if(statusID == 3){
                
                status["id"] = String(format: "%d", selctedScheduleCallOption)
                
                if(selctedScheduleCallOption == 1){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.GOOD.rawValue
                }
                else if(selctedScheduleCallOption == 2){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.SATISFIED.rawValue
                }
                else if(selctedScheduleCallOption == 3){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.DISSATISFIED.rawValue
                }
                else if(selctedScheduleCallOption == 4){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.NOT_VISITED.rawValue
                }
                else if(selctedScheduleCallOption == 5){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.NOT_INTERESTED.rawValue
                }

                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email
                
                prevLeadStatus["status"] = status
                
//                actionInfo["comment"] = ""
                if(!self.isOwnVehicel && selectedVehicleID != nil && selectedDriverID != nil){
                    actionInfo["vehicle"] = selectedVehicleID
                    actionInfo["driver"] = selectedDriverID
                }
                actionInfo["projects"] = [selectedProjectId]
                actionInfo["units"] = [selectedUnitId]
                actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                actionInfo["comment"] = comment
                
                siteVisitParameters["salesPerson"] = salesPerson
                if(self.viewType == VIEW_TYPE.LEADS){
                    siteVisitParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    siteVisitParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                siteVisitParameters["action"] = action
                siteVisitParameters["actionInfo"] = actionInfo

            }
            else if(statusID == 4){
                
                    var action : Dictionary<String,String> = [:]
                    
                    action["id"] = String(format: "%d", selectedAction)
                    action["label"] = ACTION_TYPE_STRING.SITE_VISTI.rawValue
                    
                    var actionInfo : Dictionary<String,Any> = [:]

                    actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                    actionInfo["projects"] = [selectedProjectId]
                    actionInfo["units"] = [selectedUnitId]
                    if(!self.isOwnVehicel && selectedVehicleID != nil && selectedDriverID != nil){
                        actionInfo["vehicle"] = selectedVehicleID
                        actionInfo["driver"] = selectedDriverID
                    }
                    actionInfo["comment"] = comment
                    
                    var prevLeadStatus : Dictionary<String,Any> = [:]
                    prevLeadStatus["actionType"] = self.statusID
                    prevLeadStatus["id"] = selectedProspect._id
                    
                    status["id"] = String(format: "%d", selctedScheduleCallOption)
                    
                    if(selctedScheduleCallOption == 1){
                        status["label"] = OTHER_TASK_ACTIONS_STRING.COMPLETED.rawValue
                    }
                    else if(selctedScheduleCallOption == 2){
                        status["label"] = OTHER_TASK_ACTIONS_STRING.ON_HOLD.rawValue
                    }
                    else if(selctedScheduleCallOption == 3){
                        status["label"] = OTHER_TASK_ACTIONS_STRING.NOT_INTERESTED.rawValue
                    }
                    
                    prevLeadStatus["status"] = status
                    var salesPerson : Dictionary<String,Any> = [:]
                    salesPerson["_id"] = selectedProspect.salesPerson?._id
                    salesPerson["email"] = selectedProspect.salesPerson?.email
                    
                    siteVisitParameters["salesPerson"] = salesPerson
                    siteVisitParameters["action"] = action
                    siteVisitParameters["actionInfo"] = actionInfo
                    if(self.viewType == VIEW_TYPE.LEADS){
                        siteVisitParameters["prevLeadStatus"] = prevLeadStatus
                    }
                    else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                        siteVisitParameters["prevOpportunityStatus"] = prevLeadStatus
                    }

                    siteVisitParameters["prospectId"] = selectedProspect.prospectId
                    siteVisitParameters["unit"] = selectedProspect.unit?._id

                
            }
            else if(statusID == 5){
                
                var action : Dictionary<String,String> = [:]
                
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.SITE_VISTI.rawValue
                
                var actionInfo : Dictionary<String,Any> = [:]

                actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                actionInfo["projects"] = [selectedProjectId]
                actionInfo["units"] = [selectedUnitId]
                if(!self.isOwnVehicel && selectedVehicleID != nil && selectedDriverID != nil){
                    actionInfo["vehicle"] = selectedVehicleID
                    actionInfo["driver"] = selectedDriverID
                }
                actionInfo["comment"] = comment
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = self.statusID
                prevLeadStatus["id"] = selectedProspect._id
                
                status["id"] = String(format: "%d", selctedScheduleCallOption)
                
                if(selctedScheduleCallOption == 1){
                    status["label"] = OTHER_TASK_ACTIONS_STRING.COMPLETED.rawValue
                }
                else if(selctedScheduleCallOption == 2){
                    status["label"] = OTHER_TASK_ACTIONS_STRING.ON_HOLD.rawValue
                }
                else if(selctedScheduleCallOption == 3){
                    status["label"] = OTHER_TASK_ACTIONS_STRING.NOT_INTERESTED.rawValue
                }
                
                prevLeadStatus["status"] = status
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email
                
                siteVisitParameters["salesPerson"] = salesPerson
                siteVisitParameters["action"] = action
                siteVisitParameters["actionInfo"] = actionInfo
                if(self.viewType == VIEW_TYPE.LEADS){
                    siteVisitParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    siteVisitParameters["prevOpportunityStatus"] = prevLeadStatus
                }

                siteVisitParameters["prospectId"] = selectedProspect.prospectId
                siteVisitParameters["unit"] = selectedProspect.unit?._id
                
            }
            else if(statusID == 6){
             
                
                action["id"] = String(format: "%d", selectedAction)
                
                if(selectedAction == 3){
                    action["label"] = ACTION_TYPE_STRING.SITE_VISTI.rawValue
                }
                
                var actionInfo : Dictionary<String,Any> = [:]
//                print(siteVisitParameters["date"])
//                print(Formatter.ISO8601.string(from: selectedDate))
                actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                actionInfo["projects"] = [selectedProjectId]
                actionInfo["units"] = [selectedUnitId]
                actionInfo["comment"] = comment
                if(!self.isOwnVehicel && selectedVehicleID != nil && selectedDriverID != nil){
                    actionInfo["vehicle"] = selectedVehicleID
                    actionInfo["driver"] = selectedDriverID
                }
                

                var action : Dictionary<String,String> = [:]
                
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.SITE_VISTI.rawValue

                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email

                var prevLeadStatus : Dictionary<String,Any> = [:]

//                if(selectedProspect.action != nil)
//                {
//                    prevLeadStatus["actionType"] = selectedProspect.action?.id
//                }
//                else
//                {
                    prevLeadStatus["actionType"] = self.statusID //ACTION_TYPE.SITE_VISIT.rawValue
//                }
                
                prevLeadStatus["id"] = selectedProspect._id ////*** should pass ACTION TYPE IDDD

                var status : Dictionary<String,Any> = [:]
                status["id"] = 1
                
                prevLeadStatus["status"] = status
                
                siteVisitParameters["salesPerson"] = salesPerson
                siteVisitParameters["action"] = action
                siteVisitParameters["actionInfo"] = actionInfo
                if(self.viewType == VIEW_TYPE.LEADS){
                    siteVisitParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    siteVisitParameters["prevOpportunityStatus"] = prevLeadStatus
                }
            }
        }
        if(self.selectedSchemeID != nil){
            siteVisitParameters["scheme"] = self.selectedSchemeID
        }
        
        siteVisitParameters["prospectId"] = selectedProspect.prospectId
        siteVisitParameters["userName"] = selectedProspect.userName
        siteVisitParameters["userPhone"] = selectedProspect.userPhone
        siteVisitParameters["userEmail"] = emailId ?? selectedProspect.userEmail
        siteVisitParameters["src"] = 3
//        print(siteVisitParameters.keys)
//        print(siteVisitParameters)
        
        var urlString = ""
        print(statusID)
        if(statusID == 0 || isFromRegistrations || statusID == 1 || statusID == 3 || statusID == 5 || statusID == 6 || statusID == 4){
            
            if(self.viewType == VIEW_TYPE.LEADS || isFromRegistrations){
                urlString = RRAPI.CHANGE_PROSPECT_STATE
            }
            else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                urlString = RRAPI.CHANGE_OPPORTUNITY_PROSPECT_STATE
            }
        }
        else if(statusID == 2){
            urlString = String(format:RRAPI.API_OFFERS_PROSPECT_CHANGE,self.viewType.rawValue)
        }
        
        HUD.show(.progress)
        
        AF.request(urlString, method: .post, parameters: siteVisitParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let urlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        HUD.flash(.label("Success"), delay: 1.0)
                        if(!self.isFromNotification){
                            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                        }
                        else{
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.DELETE_NOTIFICATION), object: nil)
                        }
                        //                    self.dismiss(animated: true, completion: nil)
                    }
                    else
                    {
                        HUD.flash(.label(urlResult.err!.actionInfo?.description ?? "Falid! Try Again"), delay: 1.0)
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
    @objc func hideAll(){
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
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
