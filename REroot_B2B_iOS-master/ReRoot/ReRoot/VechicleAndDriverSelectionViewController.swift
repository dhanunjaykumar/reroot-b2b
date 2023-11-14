//
//  VechicleAndDriverSelectionViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 06/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import PKHUD

protocol VechicleAndDriverDelegate: class {
    func didSelectVehicleAndDriver(driveID: String,vehicleID: String,selectedAction : Int)
}

class VechicleAndDriverSelectionViewController: UIViewController ,UITextFieldDelegate{

    var statusID : Int? = 0
    var selectedAction = 0 //Selected option should be > 0 for server
    
    weak var delegate:VechicleAndDriverDelegate?
    
    var selectedProject : Project!
    var selctedScheduleCallOption : Int!
    var prospectDetails : REGISTRATIONS_RESULT!
    var selectedDate : Date!
    var selectedProjectId : String!
    var selectedUnitId : String!
    var selectedProspect : REGISTRATIONS_RESULT!
    var isFromRegistrations = false
    
    let vehicleSelectionDropDown = DropDown()
    let driverSelectionDropDown = DropDown()
    
    @IBOutlet var driverTextField: UITextField!
    @IBOutlet var vehicleTextField: UITextField!
    
    
    var vehiclesArray : [String] = []
    var driversArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        definesPresentationContext = true
        
        driverTextField.delegate = self
        vehicleTextField.delegate = self
        
        let drivers = RRUtilities.sharedInstance.drivers
        
        for driver in drivers{
            self.driversArray.append(driver.name!)
        }
        
        let vehicles = RRUtilities.sharedInstance.vehicles
        
        for vehicle in vehicles{
            self.vehiclesArray.append(vehicle.vehicleType!)
        }
        self.setupDriversDropDown()
        self.setupVehiclesDropDown()
    }
    func setupVehiclesDropDown(){
        
        vehicleSelectionDropDown.anchorView = vehicleTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        vehicleSelectionDropDown.bottomOffset = CGPoint(x: 0, y: vehicleTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        vehicleSelectionDropDown.dataSource = self.vehiclesArray
        
        // Action triggered on selection
        vehicleSelectionDropDown.selectionAction = { [weak self] (index, item) in
            //            self?.projectNameTextField.setTitle(item, for: .normal)
            self?.vehicleTextField.text = item
        }
        
    }
    
    func setupDriversDropDown(){
        
        driverSelectionDropDown.anchorView = driverTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        driverSelectionDropDown.bottomOffset = CGPoint(x: 0, y: driverTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        driverSelectionDropDown.dataSource = self.driversArray
        
        // Action triggered on selection
        driverSelectionDropDown.selectionAction = { [weak self] (index, item) in
            //            self?.projectNameTextField.setTitle(item, for: .normal)
            self?.driverTextField.text = item
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
        
        if(textField == driverTextField){
            driverSelectionDropDown.show()
        }
        if(textField == vehicleTextField){
            vehicleSelectionDropDown.show()
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
        
        let selectedDrivers = RRUtilities.sharedInstance.drivers.filter { ($0.name! == selectedDriver) }
        
        let selectedDriverID = selectedDrivers[0]._id

        let selectedVehicle = vehicleTextField.text
        
        let selectedVehicles = RRUtilities.sharedInstance.vehicles.filter { ($0.vehicleType! == selectedVehicle) }
        
        let selectedVehicleID = selectedVehicles[0]._id
        
        
        if(isFromRegistrations){
            
            siteVisitParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            siteVisitParameters["project"] = selectedProspect.project?._id
            siteVisitParameters["registrationDate"] = selectedProspect.registrationDate
            
            if(selectedProspect.regInfo != nil){
                siteVisitParameters["regInfo"] = selectedProspect.regInfo
            }else{
                siteVisitParameters["regInfo"] = selectedProspect._id
            }
            
            var action : Dictionary<String,String> = [:]
            
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.SITE_VISTI.rawValue
            
            var actionInfo : Dictionary<String,Any> = [:]
            
            actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
            actionInfo["projects"] = [selectedProjectId]
            actionInfo["units"] = [selectedUnitId]
            actionInfo["drivers"] = selectedDriverID
            actionInfo["vehicle"] = selectedVehicleID

            siteVisitParameters["action"] = action
            siteVisitParameters["actionInfo"] = actionInfo
            
        }
        else{
            
            siteVisitParameters["registrationDate"] = selectedProspect.registrationDate
            siteVisitParameters["project"] = selectedProspect.project?._id
            siteVisitParameters["regInfo"] = selectedProspect.regInfo
            siteVisitParameters["registrationStatus"] = 1 //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            var action : Dictionary<String,String> = [:]
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.SCHEDULE_CALL.rawValue
            
            var actionInfo : Dictionary<String,Any> = [:]
            
            actionInfo["projects"] = [selectedProspect.project?._id]
            actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
            
            var prevLeadStatus : Dictionary<String,Any> = [:]
            
            if(selectedProspect.action != nil)
            {
                prevLeadStatus["actionType"] = selectedProspect.action?.id
            }
            else
            {
                prevLeadStatus["actionType"] = ACTION_TYPE.SITE_VISIT.rawValue
            }
            prevLeadStatus["id"] = selectedProspect._id ////*** should pass ACTION TYPE IDDD
            
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

            }
            else if(statusID == 2){ //Offers controller
                
                siteVisitParameters["_id"] = selectedProspect._id

                actionInfo["driver"] = selectedDriverID
                actionInfo["vehicle"] = selectedVehicleID
                
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
                
                siteVisitParameters["userEmail"] = selectedProspect.userEmail
                siteVisitParameters["userName"] = selectedProspect.userName
                siteVisitParameters["userPhone"] = selectedProspect.userPhone
                
            }
            
            prevLeadStatus["status"] = status
            
            siteVisitParameters["prevLeadStatus"] = prevLeadStatus
            siteVisitParameters["action"] = action
            siteVisitParameters["actionInfo"] = actionInfo
        }
        print(siteVisitParameters.keys)
        print(siteVisitParameters)
        
        var urlString = ""
        
        if(statusID == 1){
            urlString = RRAPI.CHANGE_PROSPECT_STATE
        }
        else if(statusID == 2){
            urlString = String(format:RRAPI.API_OFFERS_PROSPECT_CHANGE,"2")
        }
        
        Alamofire.request(urlString, method: .post, parameters: siteVisitParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                
                let urlResult = try! JSONDecoder().decode(PROSPECT_SUBMIT_RESULT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
                    HUD.flash(.label("Success"), delay: 1.0)
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                }
                else
                {
                    HUD.flash(.label(urlResult.err!.actionInfo), delay: 1.0)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
