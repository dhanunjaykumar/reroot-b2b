//
//  LeadsPopUpViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class LeadsPopUpViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,DateSelectedFromTimePicker,ProjectSelectorDelegate,VechicleAndDriverDelegate {
   
    var statusID : Int?
    
    var selctedScheduleCallOption : Int! ///no response or not reachable or call complete  , not interested
    var isFromRegistrations : Bool = false
    
    @IBOutlet var heightOfTableView: NSLayoutConstraint!
    
    var selectedReason : String!
    var selectedReasonIndex : Int!
    
    var selectedLabel : String!
    
    var intrestedStatusSelection : Int!
    var selectedDateForStatus : Date!
    
    var tableViewDataSource : NSMutableOrderedSet = []
    var selectedStatus : Int = -1
    var selectedOptions : [String] = []
    @IBOutlet var heightOfPopUpView: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    var isRegistration : Bool!
    var isLeads : Bool!
    var isOpportunities : Bool!
    
    var remarkText : String!
    
//    var selectedProjectId : String!
//    var selectedRegistrationID : String!
//    var selectedProspectRegistrationDate : String!
    
    var selectedProspect : PROSPECT_DETAILS!
    
    var prevSelectedStatus = -1
    var prospectDetails : REGISTRATIONS_RESULT!
    
    var siteVisitParametersDict : Dictionary<String,Any> = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: "ProspectStatusTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "prospectStatusCell")
        
        tableView.tableFooterView = UIView()

        if(statusID == 1 || statusID == nil || isFromRegistrations){  //From Calls Controller  ///tab ID is 1 for all
            
            if(prospectDetails.action?.id == nil){
                
                if(prevSelectedStatus == 0){
                    tableViewDataSource.add("Schedule Call")
                    tableViewDataSource.add("Send Offer")
                    tableViewDataSource.add("Schedule Site Visit")
                    tableViewDataSource.add("Request for Discount")
                    tableViewDataSource.add("Add New Task")
                }
            }else{
                tableViewDataSource.add("Re-Schedule Call")
                tableViewDataSource.add("Send Offer")
                tableViewDataSource.add("Schedule Site Visit")
                tableViewDataSource.add("Request for Discount")
                tableViewDataSource.add("Add New Task")
            }
        }
        else if(statusID == 2){ //From Offers Controller
            tableViewDataSource.add("Schedule Call")
            tableViewDataSource.add("Schedule Site Visit")
            tableViewDataSource.add("Request for Discount")
            tableViewDataSource.add("Add New Task")
        }
        else if(statusID == 3){ //From SiteVisits Controller
         
            tableViewDataSource.add("Schedule Call")
            tableViewDataSource.add("Send Offer")
            tableViewDataSource.add("Re-Schedule Site Visit")
            tableViewDataSource.add("Request for Discount")
            tableViewDataSource.add("Add New Task")

        }
        else if(statusID == 4){ // From Discount Request controller
            
            tableViewDataSource.add("Schedule Call")
            tableViewDataSource.add("Re-Schedule Site Visit")
            tableViewDataSource.add("Request for Discount")
            tableViewDataSource.add("Add New Task")

        }
        else if(statusID == 5){ //From Other Task Request controller
         
            tableViewDataSource.add("Schedule Call")
            tableViewDataSource.add("Send Offer")
            tableViewDataSource.add("Schedule Site Visit")
            tableViewDataSource.add("Request for Discount")
            tableViewDataSource.add("Add New Task")

        }
        else if(statusID == 6) //From Not interested Request controller
        {
            
        }

        
        tableView.dataSource = self
        tableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
//        heightOfTableView.constant = tableView.contentSize.height
//        heightOfPopUpView.constant = heightOfTableView.constant + 100
        
        if(heightOfPopUpView.constant >= self.view.frame.size.height - 50){
           heightOfPopUpView.constant = self.view.frame.size.height - 100
            heightOfTableView.constant = CGFloat(tableViewDataSource.count * 44)
        }
        else{
            heightOfPopUpView.constant = CGFloat(tableViewDataSource.count * 44 + 100)
            heightOfTableView.constant = CGFloat(tableViewDataSource.count * 44)
        }
        
    }
    // MARK: - Tableview Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectStatusTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectStatusCell",
            for: indexPath) as! ProspectStatusTableViewCell
        
        cell.statusTitleLabel.text = tableViewDataSource[indexPath.row] as? String
        
        if(indexPath.row == selectedStatus){
            cell.statusTypeImageView.image = UIImage.init(named: "Checkbox_on")
        }
        else{
            cell.statusTypeImageView.image = UIImage.init(named: "Checkbox_off")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if(statusID == 1 || isFromRegistrations){  //From Calls Controller  ///tab ID is 1 for all
            
            intrestedStatusSelection = indexPath.row + 1
            //show date picker
            if(indexPath.row == 0)
            {
                self.showDatePicker(forActionType: ACTION_TYPE.SCHEDULE_CALL)
            }
            else if(indexPath.row == 1)
            {
                self.showProjectSelectionView(forActionType: ACTION_TYPE.SEND_OFFER)
            }
            else if(indexPath.row == 2)
            {
                self.showDatePicker(forActionType: ACTION_TYPE.SITE_VISIT)
            }
            else if(indexPath.row == 3)
            {
                // request for discount **
                self.showDiscount(forActionType: ACTION_TYPE.DISCOUNT_REQUEST)
            }
            else if(indexPath.row == 4) ///Add new task
            {
                self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
            }
        }
        else if(statusID == 2){ //From Offers Controller
            
            if(indexPath.row == 0) //schedule call
            {
                self.showDatePicker(forActionType: ACTION_TYPE.SCHEDULE_CALL)
            }
            else if(indexPath.row == 1){ //site visit
                self.showDatePicker(forActionType: ACTION_TYPE.SITE_VISIT)
            }
            else if(indexPath.row == 2) //discount request
            {
                self.showDiscount(forActionType: ACTION_TYPE.DISCOUNT_REQUEST)
            }
            else if(indexPath.row == 3){ // ADD NEw task
                self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
            }
        }
        else if(statusID == 3){ //From SiteVisits Controller
            
            if(indexPath.row == 0) //schedule call
            {
                self.showDatePicker(forActionType: ACTION_TYPE.SCHEDULE_CALL)
            }
            else if(indexPath.row == 1){
                self.showProjectSelectionView(forActionType: ACTION_TYPE.SEND_OFFER)
            }
            else if(indexPath.row == 2){
                self.showDatePicker(forActionType: ACTION_TYPE.SITE_VISIT)
            }
            else if(indexPath.row == 3){
                self.showDiscount(forActionType: ACTION_TYPE.DISCOUNT_REQUEST)
            }
            else if(indexPath.row == 4){
                self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
            }
        }
        else if(statusID == 4){ // From Discount Request controller
            //http://192.168.1.3:3000/api/business/prospects/unitprice?unit=5b6c1ba64ae0c968fdeb644f
            
            if(indexPath.row == 0) //schedule call
            {
                self.showDatePicker(forActionType: ACTION_TYPE.SCHEDULE_CALL)
            }
            else if(indexPath.row == 2)
            {
                self.showDatePicker(forActionType: ACTION_TYPE.SITE_VISIT)
            }
            else if(indexPath.row == 3)
            {
                // request for discount **
                self.showDiscount(forActionType: ACTION_TYPE.DISCOUNT_REQUEST)
            }
            else if(indexPath.row == 4) ///Add new task
            {
                self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
            }
            
        }
        else if(statusID == 5){ //From Other Task Request controller
            
            intrestedStatusSelection = indexPath.row + 1
            //show date picker
            if(indexPath.row == 0)
            {
                self.showDatePicker(forActionType: ACTION_TYPE.SCHEDULE_CALL)
            }
            else if(indexPath.row == 1)
            {
                self.showProjectSelectionView(forActionType: ACTION_TYPE.SEND_OFFER)
            }
            else if(indexPath.row == 2)
            {
                self.showDatePicker(forActionType: ACTION_TYPE.SITE_VISIT)
            }
            else if(indexPath.row == 3)
            {
                // request for discount **
                self.showDiscount(forActionType: ACTION_TYPE.DISCOUNT_REQUEST)
            }
            else if(indexPath.row == 4) ///Add new task
            {
                self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
            }

            
        }
        else if(statusID == 6){ //From Not interested Request controller
            
        }

        
        
        let selectedOption : String = tableViewDataSource[indexPath.row] as! String
//        selectedReason = selectedOption
//        selectedReasonIndex = indexPath.row + 1
//        print("selectedReasonIndex")
//        print(selectedReasonIndex)
        
        if(selectedOptions.contains(selectedOption)){
            
            selectedOptions = selectedOptions.filter{ $0 != selectedOption }
        }
        else{
            selectedOptions.append(selectedOption)
        }
        
        selectedStatus = indexPath.row
        tableView.reloadData()
    }
    // MARK: - METHODS
    func showVehicleAndDriverPicker(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vehicleController = storyboard.instantiateViewController(withIdentifier :"vechiclesController") as! VechicleAndDriverSelectionViewController
        vehicleController.delegate = self
        vehicleController.selectedAction = forActionType.rawValue
        vehicleController.isFromRegistrations = isFromRegistrations
        self.present(vehicleController, animated: true, completion: nil)

    }
    func showDatePicker(forActionType : ACTION_TYPE)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let datePickerController = storyboard.instantiateViewController(withIdentifier :"prospectDatePicker") as! ProspectDatePickerViewController
        datePickerController.delegate = self
        datePickerController.selectedProspect = prospectDetails
        datePickerController.selectedAction = forActionType.rawValue
        datePickerController.isFromRegistrations = isFromRegistrations
        datePickerController.statusID = self.statusID
        datePickerController.selctedScheduleCallOption = self.selctedScheduleCallOption
        self.present(datePickerController, animated: true, completion: nil)
    }
    func showProjectSelectionView(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let projectSeletionController = storyboard.instantiateViewController(withIdentifier :"projectSelection") as! ProjectSelectionViewController
        projectSeletionController.delegate = self
        //selectedProject
        let projectID = prospectDetails.project!._id
        let tempProjct = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectID!)
        print(tempProjct)
        projectSeletionController.selectedProject = tempProjct
        projectSeletionController.selectedAction = forActionType.rawValue
        projectSeletionController.isFromRegistrations = isFromRegistrations
        self.present(projectSeletionController, animated: true, completion: nil)
    }
    func showDiscount(forActionType : ACTION_TYPE){
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let projectSeletionController = storyboard.instantiateViewController(withIdentifier :"projectSelection") as! ProjectSelectionViewController
////        projectSeletionController.delegate = self
////        //selectedProject
////        let projectID = prospectDetails.project!._id
////        let tempProjct = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectID!)
////        print(tempProjct)
////        projectSeletionController.selectedProject = tempProjct
////        projectSeletionController.selectedAction = forActionType.rawValue
////        projectSeletionController.isFromRegistrations = isFromRegistrations
//        self.present(projectSeletionController, animated: true, completion: nil)
        
        if(statusID == 1 || isFromRegistrations){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let projectSeletionController = storyboard.instantiateViewController(withIdentifier :"projectSelection") as! ProjectSelectionViewController
            projectSeletionController.delegate = self
            //selectedProject
            let projectID = prospectDetails.project!._id
            let tempProjct = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectID!)
            print(tempProjct)
            projectSeletionController.selectedProject = tempProjct
            projectSeletionController.selectedAction = forActionType.rawValue
            projectSeletionController.isFromRegistrations = isFromRegistrations
            self.present(projectSeletionController, animated: true, completion: nil)

        }
        else if(statusID == 2){
            self.discountRequest(selectedAction: forActionType.rawValue, selectedProjectId: "", selectedUnitId: "") //You will get project n unit details from peospect
            
        }
    }
    func showAddNewTask(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addNewTaskController = storyboard.instantiateViewController(withIdentifier :"addNewTask") as! AddNewTaskViewController
        addNewTaskController.selectedAction = forActionType.rawValue
        addNewTaskController.selectedProspect = prospectDetails
        addNewTaskController.isFromRegistrations = self.isFromRegistrations
        addNewTaskController.statusID = self.statusID
        self.present(addNewTaskController, animated: true, completion: nil)
        
    }
    func submitStatus(){
        
        return // show next views
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        
        var parameters : [String : Any] = [:]

        let action : [String : String] = [:]
//        action["id"] = String(format: "%d", selectedReasonIndex)
//        action["label"] = selectedReason
        
        var actionInfo : [String : String] = [:]
        
        actionInfo["comment"] = "prospect test" //prospectDetails.comment

        if(prevSelectedStatus == 0){
            actionInfo["comment"] = "prospect test" //prospectDetails.comment
        }else{
            
            //
            if(intrestedStatusSelection == 0){
            
                actionInfo["comment"] = "prospect test"
                //prospectDatePicker
//
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let datePickerController = storyboard.instantiateViewController(withIdentifier :"prospectDatePicker") as! ProspectDatePickerViewController
//
//                self.present(datePickerController, animated: true, completion: nil)
                
            }
            else if(intrestedStatusSelection == 1)
            {
                
            }
            else if(intrestedStatusSelection == 2)
            {
                
            }
            else if(intrestedStatusSelection == 3)
            {
                
            }
            else if(intrestedStatusSelection == 4)
            {
                
            }
        }
        
        parameters["project"] = prospectDetails.project?._id
        parameters["regInfo"] = prospectDetails._id
        parameters["registrationDate"] = prospectDetails.registrationDate
        
        parameters["registrationStatus"] = String(format: "%d", prevSelectedStatus + 1)
        
        parameters["action"] = action
        parameters["actionInfo"] = actionInfo
        
        print(parameters)
        
        Alamofire.request(RRAPI.CHANGE_PROSPECT_STATE, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)

                }else{
                    
                    HUD.flash(.label("Try Again!"), delay: 1.0)
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
    @IBAction func hide(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okAction(_ sender: Any) {
        
        self.submitStatus() // Yet to handle the with action wise *** 
    }
    //MARK : VEHICLE DELEGATE
    func didSelectVehicleAndDriver(driveID: String, vehicleID: String,selectedAction: Int) {
        
        var actionInfo : Dictionary<String,Any> = siteVisitParametersDict["actionInfo"] as! Dictionary<String, Any>
        actionInfo["driver"] = driveID
        actionInfo["vehicle"] = vehicleID
        siteVisitParametersDict["actionInfo"] = actionInfo
        
        // call site visite URL ***
//        self.siteVisit(selectedAction: selectedAction)
        
    }
    // MARK: - DATEPICKER Delegate
    func didSelectDateAndTime(dateAndTime: Date, selectedAction: Int) {
        
        if(selectedAction == ACTION_TYPE.SCHEDULE_CALL.rawValue){  //Schdule call
            self.scheduleCall(dateAndTime: dateAndTime, selectedAction: selectedAction)
        }
        else if(selectedAction == ACTION_TYPE.SEND_OFFER.rawValue){
            //sumit to server
            
        }
        else if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue){ //Date selected for site visit
            self.dismiss(animated: false, completion: nil)
            var actionInfo : Dictionary<String,Any> = [:]
            let dateString = Formatter.ISO8601.string(from: dateAndTime)   // "2018-01-23T03:06:46.232Z"
            actionInfo["date"] = dateString
            siteVisitParametersDict["actionInfo"] = actionInfo
            self.showProjectSelectionView(forActionType: ACTION_TYPE.SITE_VISIT)
        }
    }
    // MARK: - SEND OFFER FOR OFFER CONTROLLER
    func sendOffer(){
        
    }
    // MARK: - SCHEDULE CALL
    func scheduleCall(dateAndTime : Date,selectedAction : Int){
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var scheduleCallParameters : Dictionary<String,Any> = [:]

        if(isFromRegistrations){
            
            scheduleCallParameters["registrationDate"] = prospectDetails.registrationDate
            scheduleCallParameters["project"] = prospectDetails.project?._id
            
            if(prospectDetails.regInfo == nil){
                scheduleCallParameters["regInfo"] = prospectDetails._id
            }
            else{
                scheduleCallParameters["regInfo"] = prospectDetails.regInfo
            }
            scheduleCallParameters["registrationStatus"] = 1 // 1 : interested , 2 not intersted

            var action : Dictionary<String,String> = [:]
            
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.SCHEDULE_CALL.rawValue

            var actionInfo : Dictionary<String,String> = [:]
            let dateString = Formatter.ISO8601.string(from: dateAndTime)   // "2018-01-23T03:06:46.232Z"
            print(dateString)
            actionInfo["date"] = dateString

            scheduleCallParameters["action"] = action
            scheduleCallParameters["actionInfo"] = actionInfo

        }
        else{
            
            
            scheduleCallParameters["registrationDate"] = prospectDetails.registrationDate
            scheduleCallParameters["project"] = prospectDetails.project?._id
            
            if(prospectDetails.regInfo != nil){
                scheduleCallParameters["regInfo"] = prospectDetails.regInfo
            }
            else{
                scheduleCallParameters["regInfo"] = prospectDetails._id
            }
            
            scheduleCallParameters["registrationStatus"] = 1 // 1 : interested , 2 not intersted
            
            var action : Dictionary<String,String> = [:]
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.SCHEDULE_CALL.rawValue

            var actionInfo : Dictionary<String,String> = [:]
            let dateString = Formatter.ISO8601.string(from: dateAndTime)   // "2018-01-23T03:06:46.232Z"
            actionInfo["date"] = dateString

            scheduleCallParameters["action"] = action
            scheduleCallParameters["actionInfo"] = actionInfo

            
            if(statusID == 1 ){ //From calls controller
                
                print(dateString)
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = prospectDetails.action?.id
                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
                
                var status : Dictionary<String,String> = [:]
                
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
                
                scheduleCallParameters["prevLeadStatus"] = prevLeadStatus

            }
            else if(statusID == 2){ //From Offers Controller
                
                scheduleCallParameters["enquirySource"] = prospectDetails.enquirySource
                
                var project : Dictionary<String,String> = [:]
                project["_id"] = prospectDetails.project?._id
                project["name"] = prospectDetails.project?.name
                
                scheduleCallParameters["project"] = project
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
                userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
                userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
                userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo
                
                var unit : Dictionary<String,String> = [:]
                
                let tempUnits = prospectDetails.actionInfo?.units
                let counter = tempUnits?.count
                
                if(counter! > 0){
                    let unitDetails : UNITS = (prospectDetails.actionInfo?.units![0])!
                    
                    unit["_id"] = unitDetails._id
                    unit["block"] = unitDetails.block
                    unit["tower"] = unitDetails.tower
                    unit["description"] = unitDetails.description
                }
                else
                {
                    
                }
                
                scheduleCallParameters["salesPerson"] = salesPerson
                
                scheduleCallParameters["unit"] = unit
                
                scheduleCallParameters["userEmail"] = prospectDetails.userEmail
                scheduleCallParameters["userName"] = prospectDetails.userName
                scheduleCallParameters["userPhone"] = prospectDetails.userPhone
                
                scheduleCallParameters["_id"] = prospectDetails._id
                
//                scheduleCallParameters["status"] = prospectDetails.status // ** recheck
            }
            else if(statusID == 3){
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = prospectDetails.action?.id
                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
                
                var status : Dictionary<String,String> = [:]
                
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
                    status["label"] = SITE_VISIT_ACTIONS_STRING.NOT_INTERESTED.rawValue
                }
                
                prevLeadStatus["status"] = status
                
                scheduleCallParameters["prevLeadStatus"] = prevLeadStatus
            }
            else if(statusID == 4)
            {
             
                scheduleCallParameters["comment"] = prospectDetails.comment
                scheduleCallParameters["enquirySource"] = prospectDetails.enquirySource
                
                var project : Dictionary<String,String> = [:]
                project["_id"] = prospectDetails.project?._id
                project["name"] = prospectDetails.project?.name
                
                scheduleCallParameters["project"] = project
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
                userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
                userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
                userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo

                var unit : Dictionary<String,String> = [:]
                
                let tempUnits = prospectDetails.actionInfo?.units
                let counter = tempUnits?.count
                
                if(counter! > 0){
                    let unitDetails : UNITS = (prospectDetails.actionInfo?.units![0])!
                    
                    unit["_id"] = unitDetails._id
                    unit["block"] = unitDetails.block
                    unit["tower"] = unitDetails.tower
                    unit["description"] = unitDetails.description
                }
                else
                {
                    
                }
                
                scheduleCallParameters["salesPerson"] = salesPerson
                
                scheduleCallParameters["unit"] = unit
                
                scheduleCallParameters["userEmail"] = prospectDetails.userEmail
                scheduleCallParameters["userName"] = prospectDetails.userName
                scheduleCallParameters["userPhone"] = prospectDetails.userPhone
                
                scheduleCallParameters["_id"] = prospectDetails._id


                //http://172.16.20.236:3000/api/business/prospects/sendoffer?view=2
            }
                
        }
        
        HUD.show(.progress)

        print(scheduleCallParameters.keys)
        print(scheduleCallParameters)
        var urlString = ""
        
        if(statusID == 1 || isFromRegistrations || statusID == 3)
        {
            urlString = RRAPI.CHANGE_PROSPECT_STATE
        }
        else if(statusID == 2 || statusID == 4)
        {
            urlString = String(format:RRAPI.API_OFFERS_PROSPECT_CHANGE,"2")
        }
        
        Alamofire.request(urlString, method: .post, parameters: scheduleCallParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                    
                }else{
                    
                    HUD.flash(.label("Try Again!"), delay: 1.0)
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
    // MARK: - PROJECTselection Delegate
    func didSelectProject(projectID: String, unitID: String,selectedAction : Int) {
        
        if(selectedAction == ACTION_TYPE.SEND_OFFER.rawValue){
            self.sendOffer(projectID: projectID, unitID: unitID, selectedAction: selectedAction)
        }
        else if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue){
            
            siteVisitParametersDict["projects"] = [projectID]
            siteVisitParametersDict["units"] = [unitID]
//            self.dismiss(animated: false, completion: nil)
            //show Vehicel SElection view :
//            self.showVehicleAndDriverPicker(forActionType: ACTION_TYPE.SITE_VISIT)
            
        }
        else if(selectedAction == ACTION_TYPE.DISCOUNT_REQUEST.rawValue){
            
            self.discountRequest(selectedAction: selectedAction, selectedProjectId: projectID, selectedUnitId: unitID)
            
        }
        else if(selectedAction == ACTION_TYPE.NEW_TASK.rawValue){
            
        }
        
    }
    // MARK: - DISCOUNT REQUEST
    func discountRequest(selectedAction : Int,selectedProjectId : String,selectedUnitId : String){
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        var discountRequestParameters : Dictionary<String,Any> = [:]
        
        if(isFromRegistrations)
        {
            discountRequestParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            discountRequestParameters["project"] = prospectDetails.project?._id
            
            discountRequestParameters["registrationDate"] = prospectDetails.registrationDate  //reg date
            
            if(prospectDetails.regInfo != nil){
                discountRequestParameters["regInfo"] = prospectDetails.regInfo
            }else{
                discountRequestParameters["regInfo"] = prospectDetails._id
            }

            var actionInfo : Dictionary<String,Any> = [:]
            
            actionInfo["projects"] = [selectedProjectId]
            actionInfo["units"] = [selectedUnitId]
            
            var action : Dictionary<String,String> = [:]
            
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue
            
            discountRequestParameters["action"] = action
            discountRequestParameters["actionInfo"] = actionInfo
            
        }
        else{
            
            if(statusID == 1)
            {
                discountRequestParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                
                discountRequestParameters["project"] = prospectDetails.project?._id
                
                discountRequestParameters["registrationDate"] = prospectDetails.registrationDate  //reg date
                
                if(prospectDetails.regInfo != nil){
                    discountRequestParameters["regInfo"] = prospectDetails.regInfo
                }else{
                    discountRequestParameters["regInfo"] = prospectDetails._id
                }
                
                var actionInfo : Dictionary<String,Any> = [:]
                
                actionInfo["projects"] = [selectedProjectId]
                actionInfo["units"] = [selectedUnitId]
                
                var action : Dictionary<String,String> = [:]
                
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue
                
                discountRequestParameters["action"] = action
                discountRequestParameters["actionInfo"] = actionInfo
                
//                prevLeadStatus
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                
                prevLeadStatus["actionType"] = prospectDetails.action?.id  //Existing status before url call
                prevLeadStatus["id"] = prospectDetails._id
                
                var status : Dictionary<String,String> = [:]
                
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
                
                discountRequestParameters["prevLeadStatus"] = prevLeadStatus


            }
            else if(statusID == 2)
            {
                
                discountRequestParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                
                discountRequestParameters["project"] = prospectDetails.project?._id
                
                discountRequestParameters["registrationDate"] = prospectDetails.registrationDate  //reg date
                
                if(prospectDetails.regInfo != nil){
                    discountRequestParameters["regInfo"] = prospectDetails.regInfo
                }else{
                    discountRequestParameters["regInfo"] = prospectDetails._id
                }
                
                var actionInfo : Dictionary<String,Any> = [:]
                
                actionInfo["projects"] = [prospectDetails.project?._id]
                
//                actionInfo["units"] = [selectedUnitId]
                
                var action : Dictionary<String,String> = [:]
                
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue
                
                discountRequestParameters["action"] = action
                discountRequestParameters["actionInfo"] = actionInfo
                
                discountRequestParameters["_id"] = prospectDetails._id
                discountRequestParameters["comment"] = prospectDetails.comment
                discountRequestParameters["enquirySource"] = prospectDetails.enquirySource
                
                var project : Dictionary<String,String> = [:]
                project["_id"] = prospectDetails.project?._id
                project["name"] = prospectDetails.project?.name
                
                discountRequestParameters["project"] = project
                
                var salesPerson : Dictionary<String,Any> = [:]
                
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
                userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
                userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
                userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo
                
                discountRequestParameters["salesPerson"] = salesPerson
                
                var unit : Dictionary<String,String> = [:]
                
                let tempUnits = prospectDetails.actionInfo?.units
                let counter = tempUnits?.count
                
                if(counter! > 0){
                    
                    let unitDetails : UNITS = (prospectDetails.actionInfo?.units![0])!
                    
                    unit["_id"] = unitDetails._id
                    unit["block"] = unitDetails.block
                    unit["tower"] = unitDetails.tower
                    unit["description"] = unitDetails.description
                    
                    actionInfo["units"] = [unitDetails._id]
                    
                }
                discountRequestParameters["actionInfo"] = actionInfo
                discountRequestParameters["unit"] = unit
                discountRequestParameters["userEmail"] = prospectDetails.userEmail
                discountRequestParameters["userName"] = prospectDetails.userName
                discountRequestParameters["userPhone"] = prospectDetails.userPhone

            }
            
            
        }
        print(discountRequestParameters.keys)
        print(discountRequestParameters)
        
        var urlString = ""
        
        if(statusID == 1 || isFromRegistrations){
            urlString = RRAPI.CHANGE_PROSPECT_STATE
        }
        else if(statusID == 2){
             urlString = String(format:RRAPI.API_OFFERS_PROSPECT_CHANGE,"2")
        }

        Alamofire.request(urlString, method: .post, parameters: discountRequestParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    
                }else{
                    
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
    // MARK: - SITE VISIT
//    func siteVisit(selectedAction : Int){
//
//        let headers : HTTPHeaders = [
//            "User-Agent" : "RErootMobile",
//            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
//        ]
//
//        if(prospectDetails.regInfo != nil){
//            siteVisitParametersDict["regInfo"] = prospectDetails.regInfo
//        }else{
//            siteVisitParametersDict["regInfo"] = prospectDetails._id
//        }
//
//        siteVisitParametersDict["project"] = prospectDetails.project?._id
//        siteVisitParametersDict["registrationDate"] = prospectDetails.registrationDate
//        siteVisitParametersDict["registrationStatus"] = 1// 1 : interested , 2 : not interested
//
//        if(isFromRegistrations){
//
//        }
//        else{
//
//        }
//
//        Alamofire.request(RRAPI.CHANGE_PROSPECT_STATE, method: .post, parameters: siteVisitParametersDict, encoding: JSONEncoding.default, headers: headers).responseJSON{
//            response in
//            switch response.result {
//            case .success( _):
//                print(response)
//                guard let responseData = response.data else {
//                    print("Error: did not receive data")
//                    return
//                }
//                //SEARCH_RESULT
//                HUD.hide()
//
//                let urlResult = try! JSONDecoder().decode(PROSPECT_SUBMIT_RESULT.self, from: responseData)
//
//                if(urlResult.status == 1){ // success
//                    HUD.flash(.label("Success"), delay: 1.0)
//                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_CALLS), object: nil)
//                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
//                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
//
//                }else{
//
//                    HUD.flash(.label(urlResult.err!.actionInfo), delay: 1.0)
//                }
//
//                // make tableview data
//                break
//            case .failure(let error):
//                print(error)
//                HUD.hide()
//                break
//            }
//        }
//
//    }
    // MARK: - SEND OFFER
    func sendOffer(projectID: String, unitID: String,selectedAction : Int){
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        
        var sendOfferParameters : Dictionary<String,Any> = [:]
        
        if(isFromRegistrations){
            
            sendOfferParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            sendOfferParameters["project"] = prospectDetails.project?._id
            sendOfferParameters["registrationDate"] = prospectDetails.registrationDate
            if(prospectDetails.regInfo != nil){
                sendOfferParameters["regInfo"] = prospectDetails.regInfo
            }else{
                sendOfferParameters["regInfo"] = prospectDetails._id
            }
            
            var action : Dictionary<String,String> = [:]
            
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.SEND_OFFER.rawValue
            
            var actionInfo : Dictionary<String,Any> = [:]
            actionInfo["projects"] = [projectID]
            actionInfo["units"] = [unitID]
            
            sendOfferParameters["action"] = action
            sendOfferParameters["actionInfo"] = actionInfo
            
        }
        else{
            
            sendOfferParameters["registrationDate"] = prospectDetails.registrationDate
            sendOfferParameters["project"] = prospectDetails.project?._id
            sendOfferParameters["regInfo"] = prospectDetails.regInfo
            sendOfferParameters["registrationStatus"] = 1 //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            var action : Dictionary<String,String> = [:]
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.SCHEDULE_CALL.rawValue
            
            var actionInfo : Dictionary<String,Any> = [:]
            actionInfo["projects"] = [projectID]
            actionInfo["units"] = [unitID]
            
            var prevLeadStatus : Dictionary<String,Any> = [:]
            prevLeadStatus["actionType"] = prospectDetails.action?.id
            prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
            
            var status : Dictionary<String,String> = [:]
            
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
            
            sendOfferParameters["prevLeadStatus"] = prevLeadStatus
            sendOfferParameters["action"] = action
            sendOfferParameters["actionInfo"] = actionInfo
            
        }
        
        print(sendOfferParameters)
        
        Alamofire.request(RRAPI.CHANGE_PROSPECT_STATE, method: .post, parameters: sendOfferParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                    
                }else{
                    
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
