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
import FloatingPanel

class AddNewTaskViewController: UIViewController,DateSelectedFromTimePicker,RegistrationSearchDelegate {
    
    var isFromNotification = false
    var isFromDiscountView : Bool = false
    var selectedProjectID : String!
    var userEmailID : String!
    var viewType : VIEW_TYPE!
    var selectedLabel : String!
    var selctedLabelIndex : Int!
    var statusID : Int? = 0
    @IBOutlet var dateLabel: UILabel!
    var isFromRegistrations = false
    var selectedProspect : REGISTRATIONS_RESULT!
    var selectedAction : Int!
    var selectedDate : Date!
    var givenComment : String!

    @IBOutlet var taskDescriptionTextView: KMPlaceholderTextView!
    @IBOutlet var taskSubjectTextView: KMPlaceholderTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(hideAll), name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)

        
    }
    @objc func hideAll(){
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)

    }
    func didSelectDateAndTime(dateAndTime: Date, selectedAction: Int, comment: String) {
        print(dateAndTime)
        selectedDate = dateAndTime
        givenComment = comment
        let readableDate = RRUtilities.sharedInstance.getDateStringFromDate(date: selectedDate)
        _ = Formatter.ISO8601.string(from: dateAndTime)   // "2018-01-23T03:06:46.232Z"
        dateLabel.text = readableDate
        dateLabel.textAlignment = .center
        self.dismiss(animated: true, completion: nil)
        
    }
    func didSelectDateAndTimeAndProjectIds(dateAndTime: Date, selectedAction: Int, projectId: String, comment: String) {
            
        selectedDate = dateAndTime
        givenComment = comment
        let readableDate = RRUtilities.sharedInstance.getDateStringFromDate(date: dateAndTime)
        _ = Formatter.ISO8601.string(from: dateAndTime)   // "2018-01-23T03:06:46.232Z"
        dateLabel.text = readableDate
        dateLabel.textAlignment = .center
        self.dismiss(animated: true, completion: nil)

    }

    // MARK: - IBACTION METHODS
    @IBAction func selectTaskDate(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let datePickerController = storyboard.instantiateViewController(withIdentifier :"prospectDatePicker") as! ProspectDatePickerViewController
        datePickerController.delegate = self
        datePickerController.selectedProspect = selectedProspect
        datePickerController.selectedAction = selectedAction
//        datePickerController.isFromRegistrations = isFromRegistrations
        self.present(datePickerController, animated: true, completion: nil)

    }
    func didSelectInterestedProjects(projectNames: [String], projectIds: [String]) {
        self.selectedProjectID = projectIds[0]
        self.addNewTask(UIButton())
    }
    @IBAction func addNewTask(_ sender: Any) { //(projectID: String, unitID: String,selectedAction : Int)
        
        if(selectedProspect.project == nil && self.selectedProjectID == nil){
            //show project selection
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
            registerController.delegate = self
//            registerController.modalPresentationStyle = .overCurrentContext
//            registerController.modalTransitionStyle = .crossDissolve
            registerController.shouldShowRadioButton = true
            let fpc = FloatingPanelController()
            fpc.surfaceView.cornerRadius = 6.0
            fpc.surfaceView.shadowHidden = false
            fpc.set(contentViewController: registerController)
            fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
            fpc.track(scrollView: registerController.tableView)
            self.present(fpc, animated: true, completion: nil)
            return
        }
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
        
        /*
         SUCCESS: {
         err =     {
         "_id" = "The _id is required";
         action = "The action is required";
         project = "The project is required";
         regInfo = "The regInfo is required";
         registrationDate = "The registrationDate is required";
         salesPerson = "The salesPerson is required";
         unit = "The unit is required";
         userEmail = "The userEmail is required";
         userName = "The userName is required";
         userPhone = "The userPhone is required";
         };
         status = "-1";

 */
        
        if(taskDescriptionTextView.text.count == 0){
            HUD.flash(.label("Please add task description"), delay: 1.0)
            return
        }
        if(taskSubjectTextView.text.count == 0){
            HUD.flash(.label("Please add task subject"), delay: 1.0)
            return
        }
        if(selectedDate == nil){
            HUD.flash(.label("Please select task date"), delay: 1.0)
            return
        }
        
        addNewTaskParameters["_id"] = selectedProspect._id
        
        if(isFromRegistrations){
            
            addNewTaskParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            addNewTaskParameters["project"] = selectedProspect.project?._id ?? self.selectedProjectID
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

            
        }
        else{
            
            if(statusID == 1)
            {
                addNewTaskParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                
                addNewTaskParameters["registrationDate"] = selectedProspect.registrationDate
                addNewTaskParameters["project"] = selectedProspect.project?._id ?? self.selectedProjectID
                if(selectedProspect.regInfo != nil){
                    addNewTaskParameters["regInfo"] = selectedProspect.regInfo
                }else{
                    addNewTaskParameters["regInfo"] = selectedProspect._id
                }

                var action : Dictionary<String,String> = [:]
                
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.NEW_TASK.rawValue
                addNewTaskParameters["action"] = action
                
                var actionInfo : Dictionary<String,Any> = [:]
                
                actionInfo["taskDescription"] = taskDescriptionTextView.text
                actionInfo["taskName"] = taskSubjectTextView.text
                actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                actionInfo["comment"] = givenComment
                
                addNewTaskParameters["actionInfo"] = actionInfo

                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = self.statusID
                prevLeadStatus["id"] = selectedProspect._id //ACTION ID
                
                var status : Dictionary<String,Any> = [:]
                
                status["id"] = selectedAction
                
                if(selctedLabelIndex == 1){
                    status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NO_RESPONSE.rawValue
                }
                else if(selctedLabelIndex == 2){
                    status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NOT_REACHABLE.rawValue
                }
                else if(selctedLabelIndex == 3){
                    status["label"] = SCHEDULE_CALL_ACTIONS_STRING.CALL_COMPLETE.rawValue
                }
                else if(selctedLabelIndex == 4){
                    status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NOT_INTERESTED.rawValue
                }
                
                prevLeadStatus["status"] = status
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    addNewTaskParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    addNewTaskParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                
                var salesPerson : Dictionary<String,String> = [:]
                
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email

                addNewTaskParameters["salesPerson"] = salesPerson
                addNewTaskParameters["unit"] = selectedProspect.unit?._id

                addNewTaskParameters["userEmail"] = userEmailID ?? selectedProspect.userEmail
                addNewTaskParameters["userName"] = selectedProspect.userName
                addNewTaskParameters["userPhone"] = selectedProspect.userPhone

            }
            else if(statusID == 2)
            {
                
                addNewTaskParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                
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
                project["_id"] = selectedProspect.project?._id ?? self.selectedProjectID
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
                addNewTaskParameters["userEmail"] = userEmailID ?? selectedProspect.userEmail
                addNewTaskParameters["userName"] = selectedProspect.userName
                addNewTaskParameters["userPhone"] = selectedProspect.userPhone
                
                addNewTaskParameters["viewType"] = self.viewType.rawValue
                addNewTaskParameters["unit"] = selectedProspect.unit?._id

            }
            else if(statusID == 3){
                
                var action : Dictionary<String,String> = [:]
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.NEW_TASK.rawValue

                var actionInfo : Dictionary<String,Any> = [:]
                actionInfo["comment"] = givenComment
                actionInfo["taskDescription"] = taskDescriptionTextView.text
                actionInfo["taskName"] = taskSubjectTextView.text
                actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = self.statusID
                prevLeadStatus["id"] = selectedProspect._id //ACTION ID
                
                var status : Dictionary<String,Any> = [:]
                
                status["id"] = selctedLabelIndex
                
//                print(status)
                
                if(selctedLabelIndex == 1){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.GOOD.rawValue
                }
                else if(selctedLabelIndex == 2){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.SATISFIED.rawValue
                }
                else if(selctedLabelIndex == 3){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.DISSATISFIED.rawValue
                }
                else if(selctedLabelIndex == 4){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.NOT_VISITED.rawValue
                }
                else if(selctedLabelIndex == 5){
                    status["label"] = SITE_VISIT_ACTIONS_STRING.NOT_INTERESTED.rawValue
                }


                addNewTaskParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                addNewTaskParameters["project"] = selectedProspect.project?._id ?? self.selectedProjectID
                addNewTaskParameters["registrationDate"] = selectedProspect.registrationDate
                addNewTaskParameters["viewType"] = self.viewType.rawValue
                if(selectedProspect.regInfo != nil){
                    addNewTaskParameters["regInfo"] = selectedProspect.regInfo
                }else{
                    addNewTaskParameters["regInfo"] = selectedProspect._id
                }

                addNewTaskParameters["action"] = action

                if(self.viewType == VIEW_TYPE.LEADS){
                    addNewTaskParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    addNewTaskParameters["prevOpportunityStatus"] = prevLeadStatus
                }

                addNewTaskParameters["actionInfo"] = actionInfo
                addNewTaskParameters["salesPerson"] = salesPerson
                addNewTaskParameters["unit"] = selectedProspect.unit?._id
                
                addNewTaskParameters["userEmail"] = userEmailID ?? selectedProspect.userEmail
                addNewTaskParameters["userName"] = selectedProspect.userName
                addNewTaskParameters["userPhone"] = selectedProspect.userPhone

            }
            else if(statusID == 5){
                
                addNewTaskParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                addNewTaskParameters["project"] = selectedProspect.project?._id ?? self.selectedProjectID
                addNewTaskParameters["registrationDate"] = selectedProspect.registrationDate
                addNewTaskParameters["viewType"] = self.viewType.rawValue
                
                if(selectedProspect.regInfo != nil){
                    addNewTaskParameters["regInfo"] = selectedProspect.regInfo
                }else{
                    addNewTaskParameters["regInfo"] = selectedProspect._id
                }
                
                var salesPerson : Dictionary<String,Any> = [:]
                
                salesPerson["_id"] = selectedProspect.salesPerson?._id
                salesPerson["email"] = selectedProspect.salesPerson?.email
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = self.statusID
                prevLeadStatus["id"] = selectedProspect._id //ACTION ID
                
                var status : Dictionary<String,Any> = [:]
                
                status["id"] = selctedLabelIndex
                
                if(selctedLabelIndex == 1){
                    status["label"] = OTHER_TASK_ACTIONS_STRING.COMPLETED.rawValue
                }
                else if(selctedLabelIndex == 2){
                    status["label"] = OTHER_TASK_ACTIONS_STRING.ON_HOLD.rawValue
                }
                else if(selctedLabelIndex == 3){
                    status["label"] = OTHER_TASK_ACTIONS_STRING.NOT_INTERESTED.rawValue
                }
                
                var actionInfo : Dictionary<String,Any> = [:]
                actionInfo["comment"] = givenComment
                actionInfo["taskDescription"] = taskDescriptionTextView.text
                actionInfo["taskName"] = taskSubjectTextView.text
                actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)
                
                var action : Dictionary<String,String> = [:]
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.NEW_TASK.rawValue
                
                addNewTaskParameters["action"] = action
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    addNewTaskParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    addNewTaskParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                addNewTaskParameters["actionInfo"] = actionInfo
                addNewTaskParameters["salesPerson"] = salesPerson
                addNewTaskParameters["unit"] = selectedProspect.unit?._id
                
                addNewTaskParameters["userEmail"] = userEmailID ?? selectedProspect.userEmail
                addNewTaskParameters["userName"] = selectedProspect.userName
                addNewTaskParameters["userPhone"] = selectedProspect.userPhone

            }
            else if(statusID == 6 || statusID == 4){
             
                if(false){
                    
                    
                }
                else{
                    
//                    addNewTaskParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                    var project : Dictionary<String,String> = [:]
                    project["_id"] = selectedProspect.project?._id ?? self.selectedProjectID
                    project["name"] = selectedProspect.project?.name ?? ""
                    addNewTaskParameters["project"] = project
                    addNewTaskParameters["projects"] = [project["_id"]]
                    addNewTaskParameters["projectNames"] = [project["name"]]
                    addNewTaskParameters["registrationDate"] = selectedProspect.registrationDate
                    addNewTaskParameters["viewType"] = self.viewType.rawValue

                    if(selectedProspect.regInfo != nil){
                        addNewTaskParameters["regInfo"] = selectedProspect.regInfo
                    }else{
                        addNewTaskParameters["regInfo"] = selectedProspect._id
                    }

                    var salesPerson : Dictionary<String,Any> = [:]
                    
                    salesPerson["_id"] = selectedProspect.salesPerson?._id
                    salesPerson["email"] = selectedProspect.salesPerson?.email

                    var prevLeadStatus : Dictionary<String,Any> = [:]
                    prevLeadStatus["actionType"] = self.statusID
                    prevLeadStatus["id"] = selectedProspect._id //ACTION ID
                    var status : Dictionary<String,Int> = [:]
                    status["id"] = 1
                    
                    var actionInfo : Dictionary<String,Any> = [:]
                    actionInfo["comment"] = givenComment
                    actionInfo["taskDescription"] = taskDescriptionTextView.text
                    actionInfo["taskName"] = taskSubjectTextView.text
                    actionInfo["date"] = Formatter.ISO8601.string(from: selectedDate)

                    var action : Dictionary<String,String> = [:]
                    action["id"] = String(format: "%d", selectedAction)
                    action["label"] = ACTION_TYPE_STRING.NEW_TASK.rawValue

                    addNewTaskParameters["status"] = 0
                    
                    addNewTaskParameters["action"] = action
                    if(self.viewType == VIEW_TYPE.LEADS && !isFromDiscountView){
                        addNewTaskParameters["prevLeadStatus"] = prevLeadStatus
                    }
                    else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                        addNewTaskParameters["prevOpportunityStatus"] = prevLeadStatus
                    }
                    else if(isFromDiscountView){
                        addNewTaskParameters["prevOpportunityStatus"] = prevLeadStatus
                    }
                    addNewTaskParameters["actionInfo"] = actionInfo
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
                    addNewTaskParameters["unit"] =  unit ///selectedProspect.unit?._id
                    
                    addNewTaskParameters["viewType"] = self.viewType.rawValue
                    
                    addNewTaskParameters["enquirySource"] = selectedProspect.enquirySource
                    addNewTaskParameters["enquirySourceId"] = selectedProspect.enquirySourceId
                    
                    addNewTaskParameters["userEmail"] = userEmailID ?? selectedProspect.userEmail
                    addNewTaskParameters["userName"] = selectedProspect.userName
                    addNewTaskParameters["userPhone"] = selectedProspect.userPhone
                    
                    addNewTaskParameters["discountApplied"] = selectedProspect.discountApplied
                    addNewTaskParameters["isCommissionApplicable"] = selectedProspect.isCommissionApplicable

                }

            }
        }
        
//        print(addNewTaskParameters.keys)
//        print(addNewTaskParameters)
        
        addNewTaskParameters["prospectId"] = selectedProspect.prospectId
        
        addNewTaskParameters["userName"] = selectedProspect.userName
        addNewTaskParameters["userPhone"] = selectedProspect.userPhone
        addNewTaskParameters["userEmail"] = userEmailID ?? selectedProspect.userEmail
        addNewTaskParameters["src"] = 3
        var urlString = ""
        
        if(statusID == 1 || isFromRegistrations || statusID == 3 || statusID == 6 || statusID == 5){
            if(self.viewType == VIEW_TYPE.LEADS || isFromRegistrations){
                urlString = RRAPI.CHANGE_PROSPECT_STATE
            }
            else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                urlString = RRAPI.CHANGE_OPPORTUNITY_PROSPECT_STATE
            }
        }
//        else if(self.isFromDiscountView && statusID == 4){
//            urlString = String(format: RRAPI.API_OFFERS_PROSPECT_CHANGE, self.viewType.rawValue)
//        }
        else{
            urlString = String(format:RRAPI.API_OFFERS_PROSPECT_CHANGE,self.viewType.rawValue)
        }
        
        HUD.show(.progress)
        
        AF.request(urlString, method: .post, parameters: addNewTaskParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let urlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT_ONE.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        HUD.flash(.label(urlResult.msg), delay: 1.0)
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
                    else if(urlResult.status == -1){
                        if(urlResult.err == nil){
                            let urlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT.self, from: responseData)
                            HUD.flash(.label(urlResult.err!.actionInfo), delay: 1.0)
                        }
                        else{
                            HUD.flash(.label(urlResult.err), delay: 1.0)
                        }
                    }
                    else{
                        let urlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT.self, from: responseData)
                        HUD.flash(.label(urlResult.err!.actionInfo), delay: 1.0)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
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
