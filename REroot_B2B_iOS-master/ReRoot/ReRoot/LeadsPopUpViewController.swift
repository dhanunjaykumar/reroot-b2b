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
import FloatingPanel

class LeadsPopUpViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,DateSelectedFromTimePicker,ProjectSelectorDelegate,VechicleAndDriverDelegate,RegistrationSearchDelegate,MOVE_TO_FULL_DELEGATE,FloatingPanelControllerDelegate {
    
//    var isRejectedDisscount = false
    var isFromNotification = false
    let fpc = FloatingPanelController()

    var selectedDateAndTime : Date!
    var selectedProspectOption : Int!
    var selectedActionType : ACTION_TYPE!
    var selectedProjectID : String!
    
    var selectedLabel : String!
    var selctedLabelIndex : Int!
    var selectedIndexPath : IndexPath!
    var emailId : String!
    var statusID : Int? //Controller type
    var tabId : Int? //View type
    var viewType : VIEW_TYPE!
    var selctedScheduleCallOption : Int! ///no response or not reachable or call complete  , not interested
    var isFromRegistrations : Bool = false
    var isFromDiscountView = false
    
    @IBOutlet var heightOfTableView: NSLayoutConstraint!
    
    var selectedReason : String!
    var selectedReasonIndex : Int!
    var intrestedStatusSelection : Int!
    var selectedDateForStatus : Date!
    
    var tableViewDataSource : NSMutableOrderedSet = []
    var selectedStatus : Int = -1
    var selectedOptions : [String] = []
    @IBOutlet var heightOfPopUpView: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    var isLeads : Bool!
    var isOpportunities : Bool!
    
    var remarkText : String!
    
//    var selectedProjectId : String!
//    var selectedRegistrationID : String!
//    var selectedProspectRegistrationDate : String!
    
    var selectedProspect : PROSPECT_DETAILS!
    
    var prevSelectedStatus = 0
    var prospectDetails : REGISTRATIONS_RESULT!
    
    var siteVisitParametersDict : Dictionary<String,Any> = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideAll), name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)

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
            }
            else if(prevSelectedStatus == 2){
                tableViewDataSource.add("Schedule Call")
                tableViewDataSource.add("Send Offer")
                tableViewDataSource.add("Schedule Site Visit")
                tableViewDataSource.add("Request for Discount")
                tableViewDataSource.add("Add New Task")
            }
            else{
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
            tableViewDataSource.add("Not Interested")
            if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                tableViewDataSource.add("Book Unit")
            }
        }
        else if(statusID == 4){ // From Discount Request controller
            
//            if(isRejectedDisscount){
                tableViewDataSource.add("Schedule Call")
                tableViewDataSource.add("Send")
                tableViewDataSource.add("Schedule Site Visit")
                tableViewDataSource.add("Request for Discount")
                tableViewDataSource.add("Add New Task")
                tableViewDataSource.add("Not interested")
            if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                tableViewDataSource.add("Book Unit")
            }

//            }
//            else{
//                tableViewDataSource.add("Schedule Call")
//                //            tableViewDataSource.add("Send Offer")
//                tableViewDataSource.add("Re-Schedule Site Visit")
//                tableViewDataSource.add("Request for Discount")
//                tableViewDataSource.add("Add New Task")
//            }
//            tableViewDataSource.add("Schedule Call")
////            tableViewDataSource.add("Send Offer")
//            tableViewDataSource.add("Re-Schedule Site Visit")
//            tableViewDataSource.add("Request for Discount")
//            tableViewDataSource.add("Add New Task")
//            if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
//                tableViewDataSource.add("Book Unit")
//            }

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
            tableViewDataSource.add("Schedule Call")
            tableViewDataSource.add("Send Offer")
            tableViewDataSource.add("Schedule Site Visit")
            tableViewDataSource.add("Request for Discount")
            tableViewDataSource.add("Add New Task")
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
            cell.statusTypeImageView.image = UIImage.init(named: "radio_on")
        }
        else{
            cell.statusTypeImageView.image = UIImage.init(named: "radio_off")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    //check for permission
        
        let selectedOption : String = tableViewDataSource[indexPath.row] as! String

        if(selectedOption == "Schedule Call" || selectedOption == "Re-Schedule Call"){
            if(!PermissionsManager.shared.calls()){
                self.showAlert()
                return
            }
        }
        
        if(selectedOption == "Send Offer"){
            if(!PermissionsManager.shared.offers()){
                self.showAlert()
                return
            }
        }

        if(selectedOption == "Schedule Site Visit" || selectedOption == "Re-Schedule Site Visit"){
            if(!PermissionsManager.shared.siteVisits()){
                self.showAlert()
                return
            }
        }
        
        if(selectedOption == "Request for Discount"){
            if(!PermissionsManager.shared.discountRequests()){
                self.showAlert()
                return
            }
        }
        
        if(selectedOption == ("Add New Task")){
            if(!PermissionsManager.shared.otherTasks()){
                self.showAlert()
                return
            }
        }
        
        if(selectedOption == ("Not Interested")){
            if(!PermissionsManager.shared.notInterested()){
                self.showAlert()
                return
            }
        }
        
        if(selectedOption == ("Book Unit")){
            if(!PermissionsManager.shared.bookUnit()){
                self.showAlert()
                return
            }
        }
        
        self.selectedIndexPath = indexPath

        
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

        self.handleOkAction(indexPath: indexPath)
        
    }
    func showAlert(){
        HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
    }
    func getDiscountDetailsOfUnit(){
        
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
        
        let tempUnits = prospectDetails.actionInfo?.units
        let counter = tempUnits?.count
        
        var unitDetails : UNITS!
        
        if(counter! > 0){
            unitDetails = (prospectDetails.actionInfo?.units![0])!
        }
        
        if(unitDetails == nil){
            HUD.flash(.label("No Unit ID to get billing info"), delay: 1.0)
            return
        }
        
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_UNIT_PRICE, unitDetails._id ?? "")
        
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
                    let urlResult = try JSONDecoder().decode(UNIT_PRICE_API_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        //                    HUD.flash(.label("Success"), delay: 1.0)
                            
//                        self.dismiss(animated: true, completion: nil)
                        
                        let discountRequestController = DiscountViewController(nibName: "DiscountViewController", bundle: nil)
                        discountRequestController.prospectDetails = self.prospectDetails
                        discountRequestController.viewType = self.viewType
                        discountRequestController.isFromRegistrations = self.isFromRegistrations
                        discountRequestController.statusID = self.statusID
                        discountRequestController.unitBillingInfo = urlResult.result
                        discountRequestController.delegate = self
                        self.showDiscountView(controller: discountRequestController)
                        //                    self.present(discountRequestController, animated: true, completion: nil)
                        
                    }
                    else
                    {
                        HUD.flash(.label(urlResult.err), delay: 1.0)
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
    //MARK: - FLOAT PANEL BEGIN
    @objc func moveFpcViewToFull() {
        fpc.move(to: .full, animated: true)
    }
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  FullScreenCustomPanelLayout(parent: self)
    }
    func showDiscountView(controller : DiscountViewController){
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
    
        fpc.delegate = self
        
        fpc.set(contentViewController: controller)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: controller.scrollView)
        
        self.present(fpc, animated: true, completion: nil)
    }

    func handleOkAction(indexPath : IndexPath){
        
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
            else if(indexPath.row == 5){
                self.showNotInterested()
            }
            else if(indexPath.row == 6){
                
            }
        }
        else if(statusID == 4){ // From Discount Request controller
            //http://192.168.1.3:3000/api/business/prospects/unitprice?unit=5b6c1ba64ae0c968fdeb644f
            
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
                self.getDiscountDetailsOfUnit()

//                self.showDiscount(forActionType: ACTION_TYPE.DISCOUNT_REQUEST)
            }
            else if(indexPath.row == 4){
                self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
            }
            else if(indexPath.row == 5){
                self.showNotInterested()
            }
            else if(indexPath.row == 6){
                self.bookUnitCheck(prospectDetails: prospectDetails)
            }

            
//            if(indexPath.row == 0) //schedule call
//            {
//                self.showDatePicker(forActionType: ACTION_TYPE.SCHEDULE_CALL)
//            }
////            else if(indexPath.row == 1){ //send offer
////                self.showProjectSelectionView(forActionType: ACTION_TYPE.SEND_OFFER)
////            }
//            else if(indexPath.row == 1)
//            {
//                self.showDatePicker(forActionType: ACTION_TYPE.SITE_VISIT)
//            }
//            else if(indexPath.row == 2)
//            {
//                // request for discount **
//                self.showDiscount(forActionType: ACTION_TYPE.DISCOUNT_REQUEST)
//            }
//            else if(indexPath.row == 3) ///Add new task
//            {
//                self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
//            }
//            else if(indexPath.row == 5) ///Book unit
//            {
////                self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
////                self.bookUnitCheck(prospectDetails: prospectDetails)
//            }

            
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

    }
    // MARK: - METHODS
    func bookUnitCheck(prospectDetails : REGISTRATIONS_RESULT){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var parameters : Dictionary<String,Any> = [:]
        
        parameters["_id"] = self.prospectDetails._id
        parameters["pId"] = self.prospectDetails.prospectId
        parameters["src"] = 3
        HUD.show(.progress)
        
        AF.request(RRAPI.API_PROSPECT_BOOK_UNIT_CHECK, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let urlResult = try JSONDecoder().decode(PROSPECT_BOOK_UNIT_CHECK.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        // open booking form ***
                        //get unit from DB
                        print((urlResult.result?.unit)!)
                        self.getUnitPricing(unitID: (urlResult.result?.unit)!)
                        
                    }
                    else if(urlResult.status == 0){
                        HUD.flash(.label(urlResult.err), delay: 1.6)
                    }
                    else if(urlResult.status == -1){ // ** Logout **
                        
                        self.hide(UIButton())
                        self.dismiss(animated: true, completion: nil) //hide project search n selection
                        
                    }
                    else{
                        //                    self.hide(UIButton())
                        //                    self.dismiss(animated: true, completion: nil) //hide project search n selection
                        //                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                        //                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                        HUD.flash(.label(urlResult.err), delay: 1.5)
                    }
                    
                }                // make tableview data
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
    func getUnitPricing(unitID : String){
        
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
        
        let urlString = String(format:RRAPI.API_PREVIEW_PRICE, unitID,prospectDetails.regInfo!,"")
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
                //                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                do{
                    
                    let urlResult = try JSONDecoder().decode(BOOKING_FORM_RESULT.self, from: responseData)
                    
                    //                print(urlResult.booking)
                    if(urlResult.status == 1){
                        var unitDetsils =  RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: unitID)
                        if(unitDetsils == nil){
                            //fetch Entire project and go ahead *****
                            self.selectedProjectID = self.prospectDetails.project?._id
                            self.getSelectedProjectDetails(projectID: (self.prospectDetails.project?._id)!, completionHandler: { responseObject , error in
                                if(responseObject){
                                    unitDetsils =  RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: unitID)
                                    let bookingFormController = BookingFormViewController(nibName: "BookingFormViewController", bundle: nil)
                                    bookingFormController.selectedUnit = unitDetsils
                                    bookingFormController.bookingFormOutput = urlResult
                                    bookingFormController.selectedProspect = self.prospectDetails
                                    bookingFormController.delegate = self
                                    let navController = UINavigationController(rootViewController: bookingFormController)
                                    navController.navigationBar.isHidden = true
                                    self.present(navController, animated: true, completion: nil)
                                    return
                                }
                                else{
                                    
                                }
                            })
                            
                            //                        ServerAPIs.searchForIfscCode(ifscCode: ifscCodeTextField.text!, completionHandler: { responseObject , error in
                            //                            if(responseObject != nil){
                            //                                self.ifscCode = responseObject
                            //                                self.bankBranchLabel.text = self.ifscCode.branch
                            //                                self.bankNameLabel.text = self.ifscCode.bank
                            //                            }
                            //                            else{
                            //                                HUD.flash(.label("Couldn't find IFSC Code\nEnter valid IFSC code"), delay: 1.5)
                            //                            }
                            //                        })
                            
                            return
                        }
                        let bookingFormController = BookingFormViewController(nibName: "BookingFormViewController", bundle: nil)
                        bookingFormController.selectedUnit = unitDetsils
                        bookingFormController.bookingFormOutput = urlResult
                        bookingFormController.selectedProspect = self.prospectDetails
                        bookingFormController.delegate = self
                        let navController = UINavigationController(rootViewController: bookingFormController)
                        navController.navigationBar.isHidden = true
                        self.present(navController, animated: true, completion: nil)
                    }
                    else{
                        HUD.flash(.label("Booking form not linked"), delay: 1.0)
                        return
                    }
                    
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                HUD.hide()
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    func getSelectedProjectDetails(projectID: String,completionHandler: @escaping (Bool, Error?) -> ())->(){
        
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
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, projectID)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
                //                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(ProjectDetails.self, from: responseData)
                    
                    
                    RRUtilities.sharedInstance.model.writeBlocksToDB(projectDetails: urlResult, projectID: self.selectedProjectID)
                    RRUtilities.sharedInstance.model.writeTowersToDB(projectDetails: urlResult, projectID: self.selectedProjectID)
                    RRUtilities.sharedInstance.model.writeUnitsToDB(projectDetails: urlResult, projectID: self.selectedProjectID)
                    sleep(1)
                    HUD.hide()
                    completionHandler(true,nil)

                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(false,nil)
                }
                break;
            case .failure(let error):
                HUD.hide()
                completionHandler(false,nil)
                print(error)
            }
        }
    }
    func handleNotInterestedViewCalls(selectedOption : Int){
        
        if(selectedOption == 0)
        {
            self.showDatePicker(forActionType: ACTION_TYPE.SCHEDULE_CALL)
        }
        else if(selectedOption == 1)
        {
            self.showProjectSelectionView(forActionType: ACTION_TYPE.SEND_OFFER)
        }
        else if(selectedOption == 2)
        {
            self.showDatePicker(forActionType: ACTION_TYPE.SITE_VISIT)
        }
        else if(selectedOption == 3)
        {
            // request for discount **
            self.showDiscount(forActionType: ACTION_TYPE.DISCOUNT_REQUEST)
        }
        else if(selectedOption == 4) ///Add new task
        {
            self.showAddNewTask(forActionType: ACTION_TYPE.NEW_TASK)
        }
    }
    func showVehicleAndDriverPicker(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vehicleController = storyboard.instantiateViewController(withIdentifier :"vechiclesController") as! VechicleAndDriverSelectionViewController
        vehicleController.delegate = self
        vehicleController.viewType = self.viewType
        vehicleController.selectedAction = forActionType.rawValue
        vehicleController.isFromNotification = self.isFromNotification
        vehicleController.isFromRegistrations = isFromRegistrations
        self.present(vehicleController, animated: true, completion: nil)

    }
    func showDatePicker(forActionType : ACTION_TYPE)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let datePickerController = storyboard.instantiateViewController(withIdentifier :"prospectDatePicker") as! ProspectDatePickerViewController
        datePickerController.delegate = self
        datePickerController.emailId = self.emailId
        datePickerController.selectedProspect = prospectDetails
        datePickerController.selectedAction = forActionType.rawValue
        datePickerController.viewType = self.viewType
        datePickerController.tabId = self.tabId
        datePickerController.isFromRegistrations = isFromRegistrations
        datePickerController.statusID = self.statusID
        datePickerController.isFromNotification = self.isFromNotification
        datePickerController.selctedScheduleCallOption = self.selctedScheduleCallOption
//        self.navigationController?.present(datePickerController, animated: true, completion: nil)
        self.present(datePickerController, animated: true, completion: nil)
    }
    func showProjectSelectionView(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let projectSeletionController = storyboard.instantiateViewController(withIdentifier :"projectSelection") as! ProjectSelectionViewController
        projectSeletionController.delegate = self
        //selectedProject
        let projectID = prospectDetails.project?._id
        if(projectID != nil){
            let tempProjct = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectID!)
            projectSeletionController.selectedProject = tempProjct
//            print(tempProjct)
        }
        projectSeletionController.siteVisitParameters = self.siteVisitParametersDict
        print(projectSeletionController.siteVisitParameters)
        projectSeletionController.prospectDetails = self.prospectDetails
        projectSeletionController.viewType = self.viewType
        projectSeletionController.selectedAction = forActionType.rawValue
        projectSeletionController.selectedDate = siteVisitParametersDict["tempDate"] as? Date
        projectSeletionController.isFromRegistrations = isFromRegistrations
        projectSeletionController.isFromNotification = self.isFromNotification
        projectSeletionController.modalPresentationStyle = .overCurrentContext
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
        
        if(statusID == 1 || statusID == 6 || statusID == 3 || statusID == 5 || isFromRegistrations){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let projectSeletionController = storyboard.instantiateViewController(withIdentifier :"projectSelection") as! ProjectSelectionViewController
            projectSeletionController.delegate = self
            //selectedProject
            if(prospectDetails.project != nil){
                let projectID = prospectDetails.project!._id
                let tempProjct = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectID!)
//                print(tempProjct)
                projectSeletionController.selectedProject = tempProjct
            }
            projectSeletionController.prospectDetails = self.prospectDetails
            projectSeletionController.selectedAction = forActionType.rawValue
            projectSeletionController.viewType = self.viewType
            projectSeletionController.isFromRegistrations = isFromRegistrations
            projectSeletionController.modalPresentationStyle = .overCurrentContext
            projectSeletionController.isFromNotification = self.isFromNotification
            self.present(projectSeletionController, animated: true, completion: nil)

        }
        else if(statusID == 2 || statusID == 4){
            self.discountRequest(selectedAction: forActionType.rawValue, selectedProjectId: "", selectedUnitId: "", comment: "", scheme: "") //You will get project n unit details from peospect
            
        }
    }
    func showAddNewTask(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addNewTaskController = storyboard.instantiateViewController(withIdentifier :"addNewTask") as! AddNewTaskViewController
        addNewTaskController.selectedAction = forActionType.rawValue
        addNewTaskController.userEmailID = self.emailId
        addNewTaskController.isFromDiscountView = self.isFromDiscountView
        addNewTaskController.viewType = self.viewType
        addNewTaskController.selectedProspect = prospectDetails
        addNewTaskController.isFromRegistrations = self.isFromRegistrations
        addNewTaskController.statusID = self.statusID
        addNewTaskController.isFromNotification = self.isFromNotification
        self.present(addNewTaskController, animated: true, completion: nil)
        
    }
    func showNotInterested(){
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
        notInterestedController.viewType = self.viewType
        notInterestedController.prospectDetails =  prospectDetails
        notInterestedController.isFromRegistrations = isFromRegistrations
        notInterestedController.selectedLeadActionType = selectedStatus + 1
        notInterestedController.statusID = self.statusID
        notInterestedController.selctedLabelIndex =  selctedLabelIndex
        notInterestedController.isFromNotification = self.isFromNotification
        self.present(notInterestedController, animated: true, completion: nil)
        return
    }
    func submitStatus(){
        
        HUD.flash(.label("Didn't handle OK actioin ?"), delay: 1.0)
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
        
        parameters["prospectId"] = prospectDetails.prospectId
        parameters["src"] = 3
        
        parameters["userName"] = prospectDetails.userName
        parameters["userPhone"] = prospectDetails.userPhone
        parameters["userEmail"] = self.emailId ?? prospectDetails.userEmail
        parameters["src"] = 3
//        print(parameters)
        
        var urlString = ""
        
        if(self.viewType == VIEW_TYPE.LEADS || isFromRegistrations){
            urlString = RRAPI.CHANGE_PROSPECT_STATE
        }
        else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
            urlString = RRAPI.CHANGE_OPPORTUNITY_PROSPECT_STATE
        }
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let tempUrlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT_ERROR_CHECK.self, from: responseData)
                    
                    if(tempUrlResult.status == 0){
                        do{
                            guard let tempResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                                print("error trying to convert data to JSON")
                                return
                            }
                            let str = tempResult["err"] as? String
                            HUD.flash(.label(str!), delay: 1.0)
                        }
                        catch let jsonError{
                            print("Error in parsing :" , jsonError)
                            return
                        }
                    }
                    
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
                        
                    }else{
                        
                        HUD.flash(.label("Try Again!"), delay: 1.0)
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
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func hide(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okAction(_ sender: Any) {
        if(self.selectedIndexPath == nil){
            HUD.flash(.label("Please select an option"), delay: 1.0)
            return
        }
        self.handleOkAction(indexPath: self.selectedIndexPath)
//        self.submitStatus() // Yet to handle the with action wise ***
    }
    func didSelectInterestedProjects(projectNames: [String], projectIds: [String]) {

        if(self.selectedProspectOption == ACTION_TYPE.SCHEDULE_CALL.rawValue){  //Schdule call
            self.scheduleCall(dateAndTime: self.selectedDateAndTime, selectedAction: self.selectedProspectOption,comment : "")
        }
    }
    //MARK : VEHICLE DELEGATE
    func didSelectVehicleAndDriver(driveID: String?, vehicleID: String?,selectedAction: Int) {
        
        var actionInfo : Dictionary<String,Any> = siteVisitParametersDict["actionInfo"] as! Dictionary<String, Any>
        if(driveID != nil && vehicleID != nil){
            actionInfo["driver"] = driveID
            actionInfo["vehicle"] = vehicleID
            siteVisitParametersDict["actionInfo"] = actionInfo
        }
        
        // call site visite URL ***
//        self.siteVisit(selectedAction: selectedAction)
        
    }
    // MARK: - DATEPICKER Delegate
    func didSelectDateAndTimeAndProjectIds(dateAndTime: Date, selectedAction: Int, projectId: String,comment : String) {
        
        if(selectedAction == ACTION_TYPE.SCHEDULE_CALL.rawValue){  //Schdule call
            self.selectedProjectID = projectId
            self.scheduleCall(dateAndTime: dateAndTime, selectedAction: selectedAction,comment : comment)
        }

    }
    func didSelectDateAndTime(dateAndTime: Date, selectedAction: Int,comment : String) {
        
        self.selectedDateAndTime = dateAndTime
        self.selectedProspectOption = selectedAction
        
//        if(prospectDetails.project == nil){
//            //show projects to assign
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
//            registerController.delegate = self
////            registerController.modalPresentationStyle = .overCurrentContext
////            registerController.modalTransitionStyle = .crossDissolve
//            let fpc = FloatingPanelController()
//            fpc.surfaceView.cornerRadius = 6.0
//            fpc.surfaceView.shadowHidden = false
//            fpc.set(contentViewController: registerController)
//            fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
//            fpc.track(scrollView: registerController.tableView)
//            self.present(fpc, animated: true, completion: nil)
//            return
//        }
        
        if(selectedAction == ACTION_TYPE.SCHEDULE_CALL.rawValue){  //Schdule call
            self.scheduleCall(dateAndTime: dateAndTime, selectedAction: selectedAction, comment: comment)
        }
        else if(selectedAction == ACTION_TYPE.SEND_OFFER.rawValue){
            //sumit to server
            
        }
        else if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue){ //Date selected for site visit
            self.dismiss(animated: false, completion: nil)
            var actionInfo : Dictionary<String,Any> = [:]
            let dateString = Formatter.ISO8601.string(from: dateAndTime)   // "2018-01-23T03:06:46.232Z"
            actionInfo["date"] = dateString
            actionInfo["comment"] = comment
            siteVisitParametersDict["actionInfo"] = actionInfo
            siteVisitParametersDict["tempDate"] = dateAndTime
            self.showProjectSelectionView(forActionType: ACTION_TYPE.SITE_VISIT)
        }
    }
    // MARK: - SEND OFFER FOR OFFER CONTROLLER
    func sendOffer(){
        
    }
    // MARK: - SCHEDULE CALL
    func scheduleCall(dateAndTime : Date,selectedAction : Int,comment : String){
        
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
            actionInfo["comment"] = comment

            scheduleCallParameters["action"] = action
            scheduleCallParameters["actionInfo"] = actionInfo
            
            var salesPerson : Dictionary<String,Any> = [:]
            salesPerson["_id"] = prospectDetails.salesPerson?._id
            salesPerson["email"] = prospectDetails.salesPerson?.email
            
            var userInfo : Dictionary<String,String> = [:]
            userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
            userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
            userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
            userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
            
            salesPerson["userInfo"] = userInfo
            
            scheduleCallParameters["salesPerson"] = salesPerson


        }
        else{
            
            if(viewType == VIEW_TYPE.LEADS){
                
            }
            else if(viewType == VIEW_TYPE.OPPORTUNITIES){
                
            }
            
            scheduleCallParameters["registrationDate"] = prospectDetails.registrationDate
            scheduleCallParameters["project"] = prospectDetails.project?._id ?? self.selectedProjectID
            
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
            
            actionInfo["comment"] = comment // ***** NEWLY ADDED

            scheduleCallParameters["action"] = action
            scheduleCallParameters["actionInfo"] = actionInfo

            scheduleCallParameters["viewType"] = self.viewType.rawValue
            
            if(statusID == 1 ){ //From calls controller
                
                print(dateString)
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = statusID
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
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    scheduleCallParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    scheduleCallParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                scheduleCallParameters["unit"] = prospectDetails.unit?._id
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
                userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
                userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
                userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo
                
                scheduleCallParameters["salesPerson"] = salesPerson

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
                
                
                scheduleCallParameters["userEmail"] = emailId ?? prospectDetails.userEmail
                scheduleCallParameters["userName"] = prospectDetails.userName
                scheduleCallParameters["userPhone"] = prospectDetails.userPhone
                
                scheduleCallParameters["_id"] = prospectDetails._id

                if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    scheduleCallParameters["unit"] =  prospectDetails.unit?._id
                }
                else{
                    scheduleCallParameters["unit"] = unit
                }

                
//                scheduleCallParameters["status"] = prospectDetails.status // ** recheck
            }
            else if(statusID == 3){ //from site visits
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = statusID
                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
                
                var status : Dictionary<String,String> = [:]
                
                status["id"] = String(format: "%d", selctedScheduleCallOption)
                
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
                prevLeadStatus["status"] = status
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    scheduleCallParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    scheduleCallParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                scheduleCallParameters["unit"] = prospectDetails.unit?._id
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
                userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
                userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
                userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo
                
                scheduleCallParameters["salesPerson"] = salesPerson

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
                
                scheduleCallParameters["userEmail"] = emailId ?? prospectDetails.userEmail
                scheduleCallParameters["userName"] = prospectDetails.userName
                scheduleCallParameters["userPhone"] = prospectDetails.userPhone
                
                scheduleCallParameters["_id"] = prospectDetails._id
                scheduleCallParameters["unit"] = prospectDetails.unit?._id

                //http://172.16.20.236:3000/api/business/prospects/sendoffer?view=2
            }
            else if(statusID == 5){
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = statusID
                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
                
                var status : Dictionary<String,String> = [:]
                
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
                scheduleCallParameters["unit"] = prospectDetails.unit?._id
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    scheduleCallParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    scheduleCallParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
                userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
                userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
                userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo
                
                scheduleCallParameters["salesPerson"] = salesPerson


            }
            else if(statusID == 6){
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                
                prevLeadStatus["actionType"] = self.statusID
                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
                
                var status : Dictionary<String,Int> = [:]
                status["id"] = 1
                
                prevLeadStatus["status"] = status
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    scheduleCallParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    scheduleCallParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                scheduleCallParameters["unit"] = prospectDetails.unit?._id
                
//                var salesPerson : Dictionary<String,String> = [:]
//                
//                salesPerson["_id"] = prospectDetails.salesPerson?._id
//                salesPerson["email"] = prospectDetails.salesPerson?.email
//
//                scheduleCallParameters["salesPerson"] = salesPerson

                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                var userInfo : Dictionary<String,String> = [:]
                userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
                userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
                userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
                userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
                
                salesPerson["userInfo"] = userInfo
                
                scheduleCallParameters["salesPerson"] = salesPerson

//                print(scheduleCallParameters)
            }
                
        }
        
        HUD.show(.progress)

        scheduleCallParameters["prospectId"] = prospectDetails.prospectId
        scheduleCallParameters["userName"] = prospectDetails.userName
        scheduleCallParameters["userPhone"] = prospectDetails.userPhone
        scheduleCallParameters["userEmail"] = self.emailId ?? prospectDetails.userEmail
        scheduleCallParameters["src"] = 3
//        print(scheduleCallParameters.keys)
//        print(scheduleCallParameters)
        var urlString = ""
        
        if(statusID == 1 || isFromRegistrations || statusID == 3 || statusID == 5 || statusID == 6)
        {
            if(self.viewType == VIEW_TYPE.LEADS || isFromRegistrations){
                urlString = RRAPI.CHANGE_PROSPECT_STATE
            }
            else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                urlString = RRAPI.CHANGE_OPPORTUNITY_PROSPECT_STATE
            }
        }
        else if(statusID == 2 || statusID == 4)
        {
            urlString = String(format:RRAPI.API_OFFERS_PROSPECT_CHANGE,self.viewType.rawValue) //viewTYpe should pass??
        }
        
        AF.request(urlString, method: .post, parameters: scheduleCallParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let tempUrlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT_ERROR_CHECK.self, from: responseData)
                    
                    if(tempUrlResult.status == 0){
                        do{
                            guard let tempResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                                print("error trying to convert data to JSON")
                                return
                            }
                            let str = tempResult["err"] as? String
                            HUD.flash(.label(str ?? "Failed to schedule call try again!"), delay: 1.0)
                        }
                        catch let jsonError{
                            print("Error in parsing :" , jsonError)
                            return
                        }
                    }
                    
                    let urlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        HUD.flash(.label("Successfully updated."), delay: 2.0)
                        self.perform(#selector(self.updateThings), with: nil, afterDelay: 2.0)
                        
                        //                    self.dismiss(animated: true, completion: nil)
                        
                    }else{
                        if(tempUrlResult.err?.unit != nil){
                            HUD.flash(.label(tempUrlResult.err!.unit), delay: 1.0)
                        }else{
                            HUD.flash(.label("Try Again!"), delay: 1.0)
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
    @objc func updateThings(){
        if(!self.isFromNotification){
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.DELETE_NOTIFICATION), object: nil)
        }

    }
    @objc func hideAll(){
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
    }
    // MARK: - PROJECTselection Delegate
    func didSelectProject(projectID: String, unitID: String,selectedAction : Int, comments : String,scheme : String) {
        
        if(selectedAction == ACTION_TYPE.SEND_OFFER.rawValue){
            self.sendOffer(projectID: projectID, unitID: unitID, selectedAction: selectedAction, comment : comments,scheme: scheme)
        }
        else if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue){
            
            siteVisitParametersDict["projects"] = [projectID]
            siteVisitParametersDict["units"] = [unitID]
            siteVisitParametersDict["scheme"] = scheme
            
            var salesPerson : Dictionary<String,Any> = [:]
            salesPerson["_id"] = prospectDetails.salesPerson?._id
            salesPerson["email"] = prospectDetails.salesPerson?.email
            
            var userInfo : Dictionary<String,String> = [:]
            userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
            userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
            userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
            userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
            
            salesPerson["userInfo"] = userInfo
            
            siteVisitParametersDict["salesPerson"] = salesPerson

//            self.dismiss(animated: false, completion: nil)
            //show Vehicel SElection view :
//            self.showVehicleAndDriverPicker(forActionType: ACTION_TYPE.SITE_VISIT)
            
        }
        else if(selectedAction == ACTION_TYPE.DISCOUNT_REQUEST.rawValue){
            
            self.discountRequest(selectedAction: selectedAction, selectedProjectId: projectID, selectedUnitId: unitID, comment : comments, scheme: scheme)
        }
        else if(selectedAction == ACTION_TYPE.NEW_TASK.rawValue){
            
        }
        
    }
    // MARK: - DISCOUNT REQUEST
    func discountRequest(selectedAction : Int,selectedProjectId : String,selectedUnitId : String, comment : String,scheme : String){
        
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
            
            discountRequestParameters["project"] =  selectedProjectId//prospectDetails.project?._id
            
            discountRequestParameters["registrationDate"] = prospectDetails.registrationDate  //reg date
            
            if(prospectDetails.regInfo != nil){
                discountRequestParameters["regInfo"] = prospectDetails.regInfo
            }else{
                discountRequestParameters["regInfo"] = prospectDetails._id
            }

            var actionInfo : Dictionary<String,Any> = [:]
            
            actionInfo["projects"] = [selectedProjectId]
            actionInfo["units"] = [selectedUnitId]
            actionInfo["comment"] = comment
            
            var action : Dictionary<String,String> = [:]
            
            action["id"] = String(format: "%d", selectedAction)
            action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue
            
            discountRequestParameters["action"] = action
            discountRequestParameters["actionInfo"] = actionInfo
            discountRequestParameters["viewType"] = self.viewType.rawValue
            
            
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
                actionInfo["comment"] = comment
                
                var action : Dictionary<String,String> = [:]
                
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue
                
                discountRequestParameters["action"] = action
                discountRequestParameters["actionInfo"] = actionInfo
                
//                prevLeadStatus
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                
                prevLeadStatus["actionType"] = self.statusID  //Existing status before url call
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
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    discountRequestParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    discountRequestParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                discountRequestParameters["viewType"] = self.viewType.rawValue
                discountRequestParameters["unit"] =  selectedUnitId
                
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
                actionInfo["comment"] = comment
                
                if(selectedUnitId.count > 0){
                    actionInfo["units"] = [selectedUnitId]
                }
                
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
                discountRequestParameters["userEmail"] = emailId ?? prospectDetails.userEmail
                discountRequestParameters["userName"] = prospectDetails.userName
                discountRequestParameters["userPhone"] = prospectDetails.userPhone
                discountRequestParameters["viewType"] = self.viewType.rawValue
                if(viewType == VIEW_TYPE.LEADS){
                    discountRequestParameters["unit"] = unit
                }else{
                    discountRequestParameters["unit"] = selectedUnitId.count > 0 ? selectedUnitId : prospectDetails.unit?._id
                }
                
            }
            else if(statusID == 3){
                
                var action : Dictionary<String,String> = [:]
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue

                var actionInfo : Dictionary<String,Any> = [:]
                actionInfo["projects"] = [selectedProjectId] //[prospectDetails.project?._id]
                actionInfo["units"] = [selectedUnitId]
                actionInfo["comment"] = comment
                let date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
                actionInfo["date"] = Formatter.ISO8601.string(from: date)
                
                discountRequestParameters["action"] = action
                discountRequestParameters["actionInfo"] = actionInfo
                
                discountRequestParameters["project"] = selectedProjectId
                
                discountRequestParameters["registrationDate"] = prospectDetails.registrationDate  //reg date
                
                if(prospectDetails.regInfo != nil){
                    discountRequestParameters["regInfo"] = prospectDetails.regInfo
                }else{
                    discountRequestParameters["regInfo"] = prospectDetails._id
                }
                discountRequestParameters["registrationStatus"] = 1

                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                discountRequestParameters["salesPerson"] = salesPerson
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = statusID
                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
                
                var status : Dictionary<String,String> = [:]
                
                status["id"] = String(format: "%d", selctedScheduleCallOption)
                
                print(selctedScheduleCallOption)
                print(selctedLabelIndex)
                
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

                prevLeadStatus["status"] = status
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    discountRequestParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    discountRequestParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                discountRequestParameters["unit"] = selectedUnitId.count > 0 ? selectedUnitId : prospectDetails.unit?._id
                
            }
            else if(statusID == 4){
                
                var salesPerson : Dictionary<String,Any> = [:]
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email

                var action : Dictionary<String,String> = [:]
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue
                
                var projectDict : Dictionary<String,String> = [:]
                projectDict["_id"] = prospectDetails.project?._id
                projectDict["name"] = prospectDetails.project?.name

                var actionInfo : Dictionary<String,Any> = [:]
                actionInfo["projects"] = [prospectDetails.project?._id]
                actionInfo["comment"] = comment
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

                discountRequestParameters["project"] = projectDict
                
                
                discountRequestParameters["status"] = 0
                
                discountRequestParameters["_id"] = prospectDetails._id
                discountRequestParameters["action"] = action
//                print(prospectDetails.discountApplied)
                discountRequestParameters["discountApplied"] = Int(prospectDetails.discountApplied!)
                discountRequestParameters["comment"] = prospectDetails.comment
                discountRequestParameters["enquirySource"] = prospectDetails.enquirySource
                
                discountRequestParameters["userEmail"] = emailId ?? prospectDetails.userEmail
                discountRequestParameters["userName"] = prospectDetails.userName
                discountRequestParameters["userPhone"] = prospectDetails.userPhone
                discountRequestParameters["viewType"] = self.viewType.rawValue

                discountRequestParameters["salesPerson"] = salesPerson
                
                discountRequestParameters["registrationDate"] = prospectDetails.registrationDate  //reg date
                
                if(prospectDetails.regInfo != nil){
                    discountRequestParameters["regInfo"] = prospectDetails.regInfo
                }else{
                    discountRequestParameters["regInfo"] = prospectDetails._id
                }

                print(discountRequestParameters)
                if(viewType == VIEW_TYPE.LEADS){
                    discountRequestParameters["unit"] = unit
                }
                else{
                    discountRequestParameters["unit"] = selectedUnitId.count > 0 ? selectedUnitId : prospectDetails.unit?._id
                }
                

            }
            else if(statusID == 5){
                
                var action : Dictionary<String,String> = [:]
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue

                var actionInfo : Dictionary<String,Any> = [:]
                actionInfo["projects"] = [selectedProjectId]
                actionInfo["units"] = [selectedUnitId]
                actionInfo["comment"] = comment
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = statusID
                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
                
                var status : Dictionary<String,String> = [:]
                
                status["id"] = String(format: "%d", selctedScheduleCallOption)
                
                print(selctedScheduleCallOption)
                print(selctedLabelIndex)
                
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
                
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email

                
                discountRequestParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                if(selectedProjectId.count > 0){
                    discountRequestParameters["project"] = selectedProjectId
                }
                else{
                    discountRequestParameters["project"] = prospectDetails.project?._id
                }
                discountRequestParameters["registrationDate"] = prospectDetails.registrationDate  //reg date
                if(prospectDetails.regInfo != nil){
                    discountRequestParameters["regInfo"] = prospectDetails.regInfo
                }else{
                    discountRequestParameters["regInfo"] = prospectDetails._id
                }

                if(self.viewType == VIEW_TYPE.LEADS){
                    discountRequestParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    discountRequestParameters["prevOpportunityStatus"] = prevLeadStatus
                }
                discountRequestParameters["salesPerson"] = salesPerson
                discountRequestParameters["action"] = action
                discountRequestParameters["actionInfo"] = actionInfo
                discountRequestParameters["unit"] = selectedUnitId.count > 0 ? selectedUnitId : prospectDetails.unit?._id
            }
            else if(statusID == 6){
                
                discountRequestParameters["registrationStatus"] = 1  //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
                if(selectedProjectId.count > 0){
                    discountRequestParameters["project"] = selectedProjectId
                }
                else{
                    discountRequestParameters["project"] = prospectDetails.project?._id
                }
                discountRequestParameters["registrationDate"] = prospectDetails.registrationDate  //reg date
                if(prospectDetails.regInfo != nil){
                    discountRequestParameters["regInfo"] = prospectDetails.regInfo
                }else{
                    discountRequestParameters["regInfo"] = prospectDetails._id
                }

                var action : Dictionary<String,String> = [:]
                action["id"] = String(format: "%d", selectedAction)
                action["label"] = ACTION_TYPE_STRING.DISCOUNT_REQUEST.rawValue
                
                var actionInfo : Dictionary<String,Any> = [:]
                
                actionInfo["projects"] = [selectedProjectId]
                actionInfo["units"] = [selectedUnitId]
                actionInfo["comment"] = comment
                
                var salesPerson : Dictionary<String,Any> = [:]
                
                salesPerson["_id"] = prospectDetails.salesPerson?._id
                salesPerson["email"] = prospectDetails.salesPerson?.email
                
                var prevLeadStatus : Dictionary<String,Any> = [:]
                prevLeadStatus["actionType"] = statusID
                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
                var status : Dictionary<String,Int> = [:]
                status["id"] = 1
                prevLeadStatus["status"] = status
                
                if(self.viewType == VIEW_TYPE.LEADS){
                    discountRequestParameters["prevLeadStatus"] = prevLeadStatus
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                    discountRequestParameters["prevOpportunityStatus"] = prevLeadStatus
                }

                discountRequestParameters["salesPerson"] = salesPerson
                discountRequestParameters["action"] = action
                discountRequestParameters["actionInfo"] = actionInfo
                discountRequestParameters["unit"] = selectedUnitId.count > 0 ? selectedUnitId : prospectDetails.unit?._id
            }
        }
        discountRequestParameters["prospectId"] = prospectDetails.prospectId
        if(scheme.count > 0){
            discountRequestParameters["scheme"] = scheme
        }
        discountRequestParameters["userName"] = prospectDetails.userName
        discountRequestParameters["userPhone"] = prospectDetails.userPhone
        discountRequestParameters["userEmail"] = emailId ?? prospectDetails.userEmail
        discountRequestParameters["src"] = 3
        print(discountRequestParameters.keys)
        print(discountRequestParameters)
        
        var urlString = ""
        
        if(statusID == 1 || isFromRegistrations || statusID == 6 || statusID == 3 || statusID == 5 || isFromRegistrations){
            if(self.viewType == VIEW_TYPE.LEADS || isFromRegistrations){
                urlString = RRAPI.CHANGE_PROSPECT_STATE
            }
            else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                urlString = RRAPI.CHANGE_OPPORTUNITY_PROSPECT_STATE
            }
        }
        else if(statusID == 2 || statusID == 4){
             urlString = String(format:RRAPI.API_OFFERS_PROSPECT_CHANGE,self.viewType.rawValue)
        }
        HUD.show(.progress)

        AF.request(urlString, method: .post, parameters: discountRequestParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let tempUrlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT_ERROR_CHECK.self, from: responseData)
                    
                    if(tempUrlResult.status == 0){
                        do{
                            guard let tempResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                                print("error trying to convert data to JSON")
                                return
                            }
                            var str = tempResult["err"] as? String
                            if(str == nil){
                                str = tempResult["msg"] as? String
                            }
                            HUD.flash(.label(str ?? "ProspectLeads validation failed"), delay: 1.0)
                        }
                        catch let jsonError{
                            print("Error in parsing :" , jsonError)
                            return
                        }
                    }
                    else{
                        
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
                        }else{
                            
                            HUD.flash(.label(urlResult.err!.actionInfo), delay: 1.0)
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
//        AF.request(RRAPI.CHANGE_PROSPECT_STATE, method: .post, parameters: siteVisitParametersDict, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
//                let urlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT.self, from: responseData)
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
    func sendOffer(projectID: String, unitID: String,selectedAction : Int, comment : String,scheme : String){ //Send offer directly with projecct selection without cab
        
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
            actionInfo["comment"] = comment
            let date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
            actionInfo["date"] = Formatter.ISO8601.string(from: date)
            
            sendOfferParameters["action"] = action
            sendOfferParameters["actionInfo"] = actionInfo
            
            
            var salesPerson : Dictionary<String,Any> = [:]
            salesPerson["_id"] = prospectDetails.salesPerson?._id
            salesPerson["email"] = prospectDetails.salesPerson?.email
            
            var userInfo : Dictionary<String,String> = [:]
            userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
            userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
            userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
            userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
            
            salesPerson["userInfo"] = userInfo
            
            sendOfferParameters["salesPerson"] = salesPerson

            
        }
        else{
            
            sendOfferParameters["registrationDate"] = prospectDetails.registrationDate
            sendOfferParameters["project"] = projectID
            sendOfferParameters["regInfo"] = prospectDetails.regInfo ?? prospectDetails._id
            sendOfferParameters["registrationStatus"] = 1 //{type: Number, require: true}, // 1 - Interested, 2 - Not Interested
            
            var salesPersonDict : Dictionary<String,String> = [:]
            salesPersonDict["_id"] = prospectDetails.salesPerson?._id
            salesPersonDict["email"] = prospectDetails.salesPerson?.email
            
            sendOfferParameters["salesPerson"] = salesPersonDict
            
            var action : Dictionary<String,String> = [:]
            action["id"] = String(format: "%d", selectedAction)
            
            if(selectedAction == 1){
                    action["label"] = ACTION_TYPE_STRING.SCHEDULE_CALL.rawValue
            }
            else if(selectedAction == 2){
                var status : Dictionary<String,Int> = [:]
                status["id"] = 1
                sendOfferParameters["status"] = status
                
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
            actionInfo["projects"] = [projectID]
            actionInfo["units"] = [unitID]
            actionInfo["comment"] = comment
            if(selectedAction == 2 || selectedAction == 4){
                let date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
                actionInfo["date"] = Formatter.ISO8601.string(from: date)
            }

            var prevLeadStatus : Dictionary<String,Any> = [:]
            prevLeadStatus["actionType"] = self.statusID
            prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
            
            var status : Dictionary<String,String> = [:]
            
            if(selctedScheduleCallOption != nil){
                
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
            }

            if(self.viewType == VIEW_TYPE.LEADS){
                sendOfferParameters["prevLeadStatus"] = prevLeadStatus
            }
            else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                sendOfferParameters["prevOpportunityStatus"] = prevLeadStatus
            }

            sendOfferParameters["action"] = action
            sendOfferParameters["actionInfo"] = actionInfo
            sendOfferParameters["unit"] = unitID
            
            var salesPerson : Dictionary<String,Any> = [:]
            salesPerson["_id"] = prospectDetails.salesPerson?._id
            salesPerson["email"] = prospectDetails.salesPerson?.email
            
            var userInfo : Dictionary<String,String> = [:]
            userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
            userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
            userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
            userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
            
            salesPerson["userInfo"] = userInfo
            
            sendOfferParameters["salesPerson"] = salesPerson

        }
        sendOfferParameters["prospectId"] = prospectDetails.prospectId
        if(scheme.count > 0){
                sendOfferParameters["scheme"] = scheme
        }
        sendOfferParameters["userName"] = prospectDetails.userName
        sendOfferParameters["userPhone"] = prospectDetails.userPhone
        sendOfferParameters["userEmail"] = emailId ?? prospectDetails.userEmail
        sendOfferParameters["src"] = 3
        print(sendOfferParameters)
        var urlString = ""
        if(self.viewType == VIEW_TYPE.LEADS || isFromRegistrations){
            urlString = RRAPI.CHANGE_PROSPECT_STATE
        }
        else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
            urlString = RRAPI.CHANGE_OPPORTUNITY_PROSPECT_STATE
        }
        
        AF.request(urlString, method: .post, parameters: sendOfferParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let tempUrlResult = try JSONDecoder().decode(PROSPECT_SUBMIT_RESULT_ERROR_CHECK.self, from: responseData)
                    
                    if(tempUrlResult.status == 0){
                        do{
                            guard let tempResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                                print("error trying to convert data to JSON")
                                return
                            }
                            let str = tempResult["err"] as? String
                            HUD.flash(.label(str ?? "Couldn't send offer. Validation failed."), delay: 1.0)
                        }
                        catch let jsonError{
                            print("Error in parsing :" , jsonError)
                            return
                        }
                    }
                    
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
                    }else{
                        
                        HUD.flash(.label(urlResult.err!.actionInfo), delay: 1.0)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension LeadsPopUpViewController : BookUnitDelegate{
    
        func didFinishBookUnit(clientId: String, bookedUnit: Units, selectedIndexPath: IndexPath) {
            
            print("booking finished ??")
            if(!self.isFromNotification){
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
            }
            else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.DELETE_NOTIFICATION), object: nil)
            }
    //        self.dismiss(animated: true, completion: nil) //hide project search n selection

        }

}
