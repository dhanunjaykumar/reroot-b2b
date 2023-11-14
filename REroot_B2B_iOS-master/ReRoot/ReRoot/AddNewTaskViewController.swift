//
//  AddNewTaskViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class AddNewTaskViewController: UIViewController,DateSelectedFromTimePicker {
   
    var statusID : Int? = 0
    @IBOutlet var dateLabel: UILabel!
    var isFromRegistrations = false
    var selectedProspect : REGISTRATIONS_RESULT!
    var selectedAction : Int!
    var selectedDate : Date!

    @IBOutlet var taskDescriptionTextView: KMPlaceholderTextView!
    @IBOutlet var taskSubjectTextView: KMPlaceholderTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    func didSelectDateAndTime(dateAndTime: Date, selectedAction: Int) {
        print(dateAndTime)
        selectedDate = dateAndTime
        let dateString = Formatter.ISO8601.string(from: dateAndTime)   // "2018-01-23T03:06:46.232Z"
        dateLabel.text = dateString
        self.dismiss(animated: true, completion: nil)
        
    }
    // MARK: - IBACTION METHODS
    @IBAction func selectTaskDate(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let datePickerController = storyboard.instantiateViewController(withIdentifier :"prospectDatePicker") as! ProspectDatePickerViewController
        datePickerController.delegate = self
//        datePickerController.selectedProspect = selectedProspect
        datePickerController.selectedAction = selectedAction
//        datePickerController.isFromRegistrations = isFromRegistrations
        self.present(datePickerController, animated: true, completion: nil)

    }
    @IBAction func addNewTask(_ sender: Any) { //(projectID: String, unitID: String,selectedAction : Int)
        
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
        
        var addNewTaskParameters : Dictionary<String,Any> = [:]
        
        
        if(isFromRegistrations){
            
            addNewTaskParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            addNewTaskParameters["project"] = selectedProspect.project?._id
            addNewTaskParameters["registrationDate"] = selectedProspect.registrationDate
            
            if(selectedProspect.regInfo != nil){
                addNewTaskParameters["regInfo"] = selectedProspect.regInfo
            }else{
                addNewTaskParameters["regInfo"] = selectedProspect._id
            }
            
            var action : Dictionary<String,String> = [:]
            
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.NEW_TASK.rawValue
            
            var actionInfo : Dictionary<String,Any> = [:]
            actionInfo["taskDescription"] = taskDescriptionTextView.text
            actionInfo["taskName"] = taskSubjectTextView.text
            actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
            
            //            actionInfo["projects"] = [selectedProjectId]
            //            actionInfo["units"] = [selectedUnitId]
            //            actionInfo["drivers"] = selectedDriverID
            //            actionInfo["vehicle"] = selectedVehicleID
            
            
            addNewTaskParameters["action"] = action
            addNewTaskParameters["actionInfo"] = actionInfo
            
            
        }
        else{
            
            if(statusID == 1)
            {
                
            }
            else if(statusID == 2)
            {
                
                addNewTaskParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                
//                addNewTaskParameters["project"] = selectedProspect.project?._id
                addNewTaskParameters["registrationDate"] = selectedProspect.registrationDate
                
                if(selectedProspect.regInfo != nil){
                    addNewTaskParameters["regInfo"] = selectedProspect.regInfo
                }else{
                    addNewTaskParameters["regInfo"] = selectedProspect._id
                }
                
                var action : Dictionary<String,String> = [:]
                
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.NEW_TASK.rawValue
                
                var actionInfo : Dictionary<String,Any> = [:]
                
                actionInfo["taskDescription"] = taskDescriptionTextView.text
                actionInfo["taskName"] = taskSubjectTextView.text
                actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                
                
                addNewTaskParameters["action"] = action
                addNewTaskParameters["actionInfo"] = actionInfo
                
                addNewTaskParameters["_id"] = selectedProspect._id
                addNewTaskParameters["enquirySource"] = selectedProspect.enquirySource
                
                var project : Dictionary<String,String> = [:]
                project["_id"] = selectedProspect.project?._id
                project["name"] = selectedProspect.project?.name
                
                addNewTaskParameters["project"] = project
                
                var salesPerson : Dictionary<String,Any> = [:]
                
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = selectedProspect.salesPerson?.userInfo?._id
                userInfo["email"] = selectedProspect.salesPerson?.userInfo?.email
                userInfo["name"] = selectedProspect.salesPerson?.userInfo?.name
                userInfo["phone"] = selectedProspect.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo
                
                addNewTaskParameters["salesPerson"] = salesPerson
                
                var unit : Dictionary<String,String> = [:]
                
                let tempUnits = selectedProspect.actionInfo?.units
                let counter = tempUnits?.count
                
                if(counter! > 0){
                    
                    let unitDetails : UNITS = (selectedProspect.actionInfo?.units![0])!
                    
                    unit["_id"] = unitDetails._id
                    unit["block"] = unitDetails.block
                    unit["tower"] = unitDetails.tower
                    unit["description"] = unitDetails.description
                    
//                    actionInfo["units"] = [unitDetails._id]
                    
                }
                addNewTaskParameters["actionInfo"] = actionInfo
                addNewTaskParameters["unit"] = unit
                addNewTaskParameters["userEmail"] = selectedProspect.userEmail
                addNewTaskParameters["userName"] = selectedProspect.userName
                addNewTaskParameters["userPhone"] = selectedProspect.userPhone


            }
            
            //            addNewTaskParameters["registrationDate"] = prospectDetails.registrationDate
            //            addNewTaskParameters["project"] = prospectDetails.project?._id
            //            addNewTaskParameters["regInfo"] = prospectDetails.regInfo
            //            addNewTaskParameters["registrationStatus"] = 1 //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            //
            //            var action : Dictionary<String,String> = [:]
            //            action["id"] = String(format: "%d", selectedAction)
            //            action["label"] = ACTION_TYPE_STRING.SCHEDULE_CALL.rawValue
            //
            //            var actionInfo : Dictionary<String,Any> = [:]
            //            actionInfo["projects"] = [selectedProjectId]
            //            actionInfo["units"] = [selectedUnitId]
            //            actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
            //
            //            var prevLeadStatus : Dictionary<String,Any> = [:]
            //            prevLeadStatus["actionType"] = ACTION_TYPE.SITE_VISIT.rawValue
            //            prevLeadStatus["id"] = prospectDetails._id //ACTION ID
            //
            //            var status : Dictionary<String,String> = [:]
            //
            //
            //            status["id"] = String(format: "%d", selctedScheduleCallOption)
            //
            //            if(selctedScheduleCallOption == 1){
            //                status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NO_RESPONSE.rawValue
            //            }
            //            else if(selctedScheduleCallOption == 2){
            //                status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NOT_REACHABLE.rawValue
            //            }
            //            else if(selctedScheduleCallOption == 3){
            //                status["label"] = SCHEDULE_CALL_ACTIONS_STRING.CALL_COMPLETE.rawValue
            //            }
            //            else if(selctedScheduleCallOption == 4){
            //                status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NOT_INTERESTED.rawValue
            //            }
            //
            //            prevLeadStatus["status"] = status
            //
            //            addNewTaskParameters["prevLeadStatus"] = prevLeadStatus
            //            addNewTaskParameters["action"] = action
            //            addNewTaskParameters["actionInfo"] = actionInfo
        }
        
        print(addNewTaskParameters.keys)
        print(addNewTaskParameters)
        
        var urlString = ""
        
        if(statusID == 1){
            urlString = RRAPI.CHANGE_PROSPECT_STATE
        }
        else{
            urlString = String(format:RRAPI.API_OFFERS_PROSPECT_CHANGE,"2")
        }
        
        Alamofire.request(urlString, method: .post, parameters: addNewTaskParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
