//
//  ProspectsStatusViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import FloatingPanel


class ProspectsStatusViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource ,RegistrationSearchDelegate,BookUnitDelegate,ProjectSelectorDelegate,FloatingPanelControllerDelegate,MOVE_TO_FULL_DELEGATE {
    
    var isFromNotification = false
    let fpc = FloatingPanelController()
    var selectedProjectID : String!
    var selectedLabel : String!
    var selctedLabelIndex : Int!
    var statusID : Int!
    var selectedIndexPath : IndexPath!
    var prospectID = String()
    var isFromRegistrations : Bool = false
    var isFromDiscountView : Bool = false
    var isLeads : Bool = false
    var viewType : VIEW_TYPE!
    var tabId : Int!
    @IBOutlet var heightOfTableView: NSLayoutConstraint!
//    @IBOutlet var widthOfOkButton: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    var prospectStatusesArray : NSMutableOrderedSet = []
    var selectedStatus : Int = -1
    var prospectDetails : REGISTRATIONS_RESULT!
    
    @IBOutlet var buttonsView: UIView!
    @IBOutlet var okButton: UIButton!
    
    var tabID : Int = -1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        heightOfTableView.constant = CGFloat(prospectStatusesArray.count * 44)
    }
    @objc func injcted(){
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(popControllers), name: NSNotification.Name(rawValue: NOTIFICATIONS.POP_CONTROLLERS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideAll), name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)

        if(statusID == 1 || isFromRegistrations){  //From Calls Controller
            
            if(prospectDetails.action?.id == nil)
            {
                //Registration Statuses
                
                prospectStatusesArray.add("Interested")
                prospectStatusesArray.add("Not Interested")
            }
            else
            {
                // Call Status
                
                prospectStatusesArray.add("No Response")
                prospectStatusesArray.add("Not Rechable")
                prospectStatusesArray.add("Call Complete")
                prospectStatusesArray.add("Not Interested")
            }
        }
        else if(statusID == 2){ //From Offers Controller
            
//            prospectStatusesArray.add("Preview")
            prospectStatusesArray.add("Send")

        }
        else if(statusID == 3){ //From SiteVisits Controller
         
            prospectStatusesArray.add("Good")
            prospectStatusesArray.add("Satisfactory")
            prospectStatusesArray.add("Dissatisfied")
            prospectStatusesArray.add("Not Visited")
            prospectStatusesArray.add("Not Interested")
        }
        else if(statusID == 4){ // From Discount Request controller
            if(prospectDetails.discountApplied == 1 || prospectDetails.discountApplied == 2){
                prospectStatusesArray.add("Send Offer")
            }
            else{
                
//                prospectStatusesArray.add("Schedule Call")
//                prospectStatusesArray.add("Send Offer")
//                prospectStatusesArray.add("Schedule Site Visit")
                prospectStatusesArray.add("Request for Discount")
//                prospectStatusesArray.add("Add New Task")
                
            }
        }
        else if(statusID == 5){ //From Other Task Request controller
            
            prospectStatusesArray.add("Completed")
            prospectStatusesArray.add("On Hold")
            prospectStatusesArray.add("Not Interested")
            
        }
        else if(statusID == 6){ //From Not interested Request controller // *** Nothing to handle here for now
            prospectStatusesArray.add("Schedule Call")
            prospectStatusesArray.add("Send Offer")
            prospectStatusesArray.add("Schedule Site Visit")
            prospectStatusesArray.add("Request for Discount")
            prospectStatusesArray.add("Add New Task")
        }
        
        print("opportunitis")
        if(self.viewType == VIEW_TYPE.OPPORTUNITIES && statusID != 6){
            prospectStatusesArray.add("Book Unit")
        }
        
        let nib = UINib(nibName: "ProspectStatusTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "prospectStatusCell")
        
        tableView.tableFooterView = UIView()
//        widthOfOkButton.constant = 0
//        okButton.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    @objc func popControllers(){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prospectStatusesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectStatusTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectStatusCell",
            for: indexPath) as! ProspectStatusTableViewCell
        cell.statusTitleLabel.text = prospectStatusesArray[indexPath.row] as? String
        
        if(indexPath.row == selectedStatus)
        {
            cell.statusTypeImageView.image = UIImage.init(named: "radio_on")
        }
        else{
            cell.statusTypeImageView.image = UIImage.init(named: "radio_off")
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedOption : String = prospectStatusesArray[indexPath.row] as! String

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
        
        if(statusID == 1){  //From Calls Controller  ///tab ID is 1 for all
            
        }
        else if(statusID == 2){ //From Offers Controller
            
            
        }
        else if(statusID == 3){ //From SiteVisits Controller
            
        }
        else if(statusID == 4){ // From Discount Request controller
            
        }
        else if(statusID == 5){ //From Other Task Request controller
            
        }
        else if(statusID == 6){ //From Not interested Request controller
         
//            LeadsAndOpportunitiesViewController
            
//            handleNotInterestedViewCalls

//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
//            print(selectedStatus)
//            leadsPopUpController.prevSelectedStatus = selectedStatus
//            leadsPopUpController.prospectDetails = prospectDetails
//            leadsPopUpController.selctedScheduleCallOption = indexPath.row
//            leadsPopUpController.isFromRegistrations = self.isFromRegistrations
//            leadsPopUpController.tabId = self.tabID
//            leadsPopUpController.statusID = self.statusID
//            self.present(leadsPopUpController, animated: true, completion: nil)
//            return
            
        }
        
        if(isFromRegistrations)
        {
            
        }
        else
        {
            
        }
        
        if(indexPath.row == 0)  // Interested
        {
            
        }
        else //not interested
        {
            
        }
        
//        widthOfOkButton.constant = 70
//        okButton.isHidden = false
        //leadsPopUp
        self.selectedStatus = indexPath.row
        self.okAction(UIButton())
        tableView.reloadData()
        
    }
    func showAlert(){
        HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func hide(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okAction(_ sender: Any) {
        
        if(isFromRegistrations){  // Only two states from registratois 1. interested , 2 not interested
            
            if(selectedIndexPath != nil && selectedIndexPath.row == 0)
            {
//                if(prospectDetails.project == nil) // if there is not project then ask to select project
//                {
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
//                    registerController.delegate = self
////                    self.present(registerController, animated: true, completion: nil)
//                    let fpc = FloatingPanelController()
//                    fpc.surfaceView.cornerRadius = 6.0
//                    fpc.surfaceView.shadowHidden = false
//                    fpc.set(contentViewController: registerController)
//                    fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
//                    fpc.track(scrollView: registerController.tableView)
//                    self.present(fpc, animated: true, completion: nil)
//                    return
//                }
//                else
//                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                    leadsPopUpController.prevSelectedStatus = selectedStatus
                    leadsPopUpController.viewType = self.viewType
                    leadsPopUpController.isFromDiscountView = self.isFromDiscountView
                    leadsPopUpController.prospectDetails = prospectDetails
                    leadsPopUpController.selctedScheduleCallOption = selectedStatus
                    leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                    leadsPopUpController.isFromNotification = self.isFromNotification
                    leadsPopUpController.statusID = self.statusID
                    leadsPopUpController.isFromRegistrations = isFromRegistrations
                    self.present(leadsPopUpController, animated: true, completion: nil)
                    return
                    
//                }
            }
            else if(selectedIndexPath.row == 1)
            {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                notInterestedController.viewType = self.viewType
                notInterestedController.prospectDetails =  prospectDetails
                notInterestedController.isFromRegistrations = isFromRegistrations
                notInterestedController.selectedLeadActionType = selectedStatus + 1
                notInterestedController.selectedLeadActionID = "ID "
                self.present(notInterestedController, animated: true, completion: nil)
                return
                
            }
        }
        else
        {
        }
        
        if(statusID == 1){  //From Calls Controller  ///tab ID is 1 for all
            
            if(selectedIndexPath.row != prospectStatusesArray.count-1 )
            {
//                if(prospectDetails.project == nil)
//                {
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
//                    registerController.delegate = self
//                    let fpc = FloatingPanelController()
//                    fpc.surfaceView.cornerRadius = 6.0
//                    fpc.surfaceView.shadowHidden = false
//                    fpc.set(contentViewController: registerController)
//                    fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
//                    fpc.track(scrollView: registerController.tableView)
//                    self.present(fpc, animated: true, completion: nil)
//                    return
//                }
//                else
//                {
                    if(prospectStatusesArray.contains("Not Interested") && selectedIndexPath.row == 3 && viewType == VIEW_TYPE.OPPORTUNITIES){
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                        notInterestedController.viewType = self.viewType
                        notInterestedController.prospectDetails =  prospectDetails
                        notInterestedController.isFromRegistrations = isFromRegistrations
                        notInterestedController.selectedLeadActionType = selectedStatus + 1
                        self.present(notInterestedController, animated: true, completion: nil)
                        return
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                    leadsPopUpController.prevSelectedStatus = selectedStatus
                    leadsPopUpController.prospectDetails = prospectDetails
                    leadsPopUpController.isFromDiscountView = self.isFromDiscountView
                    leadsPopUpController.isFromNotification = self.isFromNotification
                    leadsPopUpController.viewType = self.viewType
                    leadsPopUpController.selctedScheduleCallOption = selectedStatus + 1
                    leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                    leadsPopUpController.statusID = self.statusID
                    self.present(leadsPopUpController, animated: true, completion: nil)
                    return
//                }
                
            }
            else{
                
                if(self.viewType == VIEW_TYPE.REGISTRATIONS){
                    
                }
                else if(self.viewType == VIEW_TYPE.LEADS){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                    notInterestedController.viewType = self.viewType
                    notInterestedController.prospectDetails =  prospectDetails
                    notInterestedController.isFromRegistrations = isFromRegistrations
                    notInterestedController.selectedLeadActionType = selectedStatus + 1
                    self.present(notInterestedController, animated: true, completion: nil)
                }
                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                 
                    if(selectedStatus == 0){
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                        notInterestedController.viewType = self.viewType
                        notInterestedController.prospectDetails =  prospectDetails
                        notInterestedController.isFromRegistrations = isFromRegistrations
                        notInterestedController.selectedLeadActionType = selectedStatus + 1
                        self.present(notInterestedController, animated: true, completion: nil)
                        return
                    }
                    else{
                        self.bookUnitCheck(prospectDetails: prospectDetails)
                    }

                }
            }

        }
        else if(statusID == 2){ //From Offers Controller
            
            if(selectedIndexPath.row == 0){ // PREVIEW
                // YET TO IMPLEMENT
                
                // show send
                
                //*** show email view (send offer controller)
                if(selectedStatus == 0){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let offerController = storyboard.instantiateViewController(withIdentifier :"sendOfferPopUp") as! SendOfferPopUpViewController
                offerController.selectedProspect = prospectDetails
                offerController.tabId = self.tabId
                offerController.isFromDiscountView = self.isFromDiscountView
                offerController.viewType = self.viewType
                offerController.isFromRegistrations = isFromRegistrations
                offerController.statusID = self.statusID
                offerController.prevSelectedStatus = selectedStatus
                self.present(offerController, animated: true, completion: nil)
                return
                }
                else{
                    self.bookUnitCheck(prospectDetails: prospectDetails)
                    return
                }

            }
            else if(selectedIndexPath.row == 1) //SEND
            {
                
                // Book unit ??
                
                if(tabID == 1){
                    
                    //book unit
                    
                    self.bookUnitCheck(prospectDetails: prospectDetails)
                    
                }
                else{
                    //*** show email view (send offer controller)
                    
                    if(isLeads == false){
                        
                    }
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let offerController = storyboard.instantiateViewController(withIdentifier :"sendOfferPopUp") as! SendOfferPopUpViewController
                    offerController.selectedProspect = prospectDetails
                    offerController.tabId = self.tabId
                    offerController.viewType = self.viewType
                    offerController.isFromRegistrations = isFromRegistrations
                    offerController.isFromDiscountView = self.isFromDiscountView
                    offerController.statusID = self.statusID
                    offerController.prevSelectedStatus = selectedStatus
                    self.present(offerController, animated: true, completion: nil)
                    return
                }
                
                // show send
                
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
//                leadsPopUpController.prevSelectedStatus = selectedStatus
//                leadsPopUpController.prospectDetails = prospectDetails
//                leadsPopUpController.selctedScheduleCallOption = selectedStatus + 1
//                leadsPopUpController.isFromRegistrations = self.isFromRegistrations
//                leadsPopUpController.statusID = self.statusID
//                self.present(leadsPopUpController, animated: true, completion: nil)
                return
                
            }
        }
        else if(statusID == 3){ //From SiteVisits Controller
            
            if(selectedIndexPath != nil && selectedIndexPath.row != prospectStatusesArray.count-1)
            {
                let optionStr : String = prospectStatusesArray.array[selectedIndexPath.row] as! String
                if(optionStr == "Not Interested" && selectedIndexPath.row == 4 && viewType == VIEW_TYPE.OPPORTUNITIES){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                    notInterestedController.viewType = self.viewType
                    notInterestedController.prospectDetails =  prospectDetails
                    notInterestedController.isFromRegistrations = isFromRegistrations
                    notInterestedController.selectedLeadActionType = selectedStatus + 1
                    self.present(notInterestedController, animated: true, completion: nil)
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                leadsPopUpController.prevSelectedStatus = selectedStatus
                leadsPopUpController.isFromDiscountView = self.isFromDiscountView
                leadsPopUpController.selectedLabel = (self.prospectStatusesArray[selectedIndexPath.row] as! String)
                leadsPopUpController.selctedLabelIndex = selectedStatus
                leadsPopUpController.prospectDetails = prospectDetails
                leadsPopUpController.viewType = self.viewType
                leadsPopUpController.isFromNotification = self.isFromNotification
                leadsPopUpController.selctedScheduleCallOption = selectedStatus + 1
                leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                leadsPopUpController.statusID = self.statusID
                self.present(leadsPopUpController, animated: true, completion: nil)
                return
            }
            else{
                if((prospectStatusesArray[selectedStatus] as? String) ?? "" == "Book Unit"){
                    self.bookUnitCheck(prospectDetails: prospectDetails)
                    return
                }
                else{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                    notInterestedController.viewType = self.viewType
                    notInterestedController.prospectDetails =  prospectDetails
                    notInterestedController.isFromRegistrations = isFromRegistrations
                    notInterestedController.selectedLeadActionType = selectedStatus + 1
                    notInterestedController.statusID = self.statusID
                    self.present(notInterestedController, animated: true, completion: nil)
                    return
                }
            }
        }
        else if(statusID == 4){ // From Discount Request controller
            
            //*** show email view (send offer controller)
            if(selectedStatus == 0){
                
                //showing project selection ??? ***
                if(prospectDetails.discountApplied == 1 || prospectDetails.discountApplied == 2){ //for applied and pending
                    if(viewType == VIEW_TYPE.LEADS){
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let offerController = storyboard.instantiateViewController(withIdentifier :"sendOfferPopUp") as! SendOfferPopUpViewController
                        offerController.selectedProspect = prospectDetails
                        offerController.tabId = self.tabId
                        offerController.viewType = self.viewType
                        offerController.isFromDiscountView = self.isFromDiscountView
                        offerController.isFromRegistrations = isFromRegistrations
                        offerController.statusID = self.statusID
                        offerController.prevSelectedStatus = selectedStatus
                        self.present(offerController, animated: true, completion: nil)
                    }
                    else{
                        //show prejectselection
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let projectSeletionController = storyboard.instantiateViewController(withIdentifier :"projectSelection") as! ProjectSelectionViewController
                        projectSeletionController.delegate = self
                        //selectedProject
                        let projectID = prospectDetails.project!._id
                        let tempProjct = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectID!)
//                        print(tempProjct)
//                        projectSeletionController.siteVisitParameters = self.siteVisitParametersDict
//                        print(projectSeletionController.siteVisitParameters)
                        projectSeletionController.prospectDetails = self.prospectDetails
                        projectSeletionController.viewType = self.viewType
                        projectSeletionController.selectedProject = tempProjct
                        projectSeletionController.selectedAction = ACTION_TYPE.SEND_OFFER.rawValue
                        projectSeletionController.isFromRegistrations = isFromRegistrations
                        projectSeletionController.modalPresentationStyle = .overCurrentContext
                        self.present(projectSeletionController, animated: true, completion: nil)
                    }
                }
                else{
                  //show discount request
                    self.getDiscountDetailsOfUnit()
                }
            }
            else{
                self.bookUnitCheck(prospectDetails: prospectDetails)
            }
            
        }
        else if(statusID == 5){ //From Other Task Request controller
            
            if(selectedStatus == 0) // Complted
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                leadsPopUpController.prevSelectedStatus = selectedStatus
                leadsPopUpController.isFromDiscountView = self.isFromDiscountView
                leadsPopUpController.viewType = self.viewType
                
                leadsPopUpController.prospectDetails = prospectDetails
                leadsPopUpController.selctedScheduleCallOption = selectedStatus + 1
                leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                leadsPopUpController.statusID = self.statusID
                self.present(leadsPopUpController, animated: true, completion: nil)
                return
            }
            else if(selectedStatus == 1) //ON Hold
            {
                // submit status to server
                    self.submitOnHoldStatusToServer()
            }
            else if(selectedStatus == 2){ // Not interested
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                notInterestedController.viewType = self.viewType
                notInterestedController.prospectDetails =  prospectDetails
                notInterestedController.isFromRegistrations = isFromRegistrations
                notInterestedController.selectedLeadActionType = selectedStatus + 1
                notInterestedController.statusID = self.statusID
                self.present(notInterestedController, animated: true, completion: nil)
                return

            }
            else{
                self.bookUnitCheck(prospectDetails: prospectDetails)
            }
            
        }
        else if(statusID == 6){ //From Not interested Request controller
         
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
//            print(selectedStatus)
//            leadsPopUpController.prevSelectedStatus = selectedStatus
//            leadsPopUpController.prospectDetails = prospectDetails
//            leadsPopUpController.selectedReasonIndex = selectedIndexPath.row
//            leadsPopUpController.selctedScheduleCallOption = selectedIndexPath.row
//            leadsPopUpController.isFromRegistrations = self.isFromRegistrations
//            leadsPopUpController.tabId = self.tabID
//            leadsPopUpController.statusID = self.statusID
//            self.present(leadsPopUpController, animated: true, completion: nil)
//            return
        }
        
    }
    func didSelectProject(projectID: String, unitID: String, selectedAction: Int, comments : String,scheme : String) { //Send offer directly with projecct selection without cab

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
            actionInfo["comment"] = comments
            
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
            sendOfferParameters["project"] = prospectDetails.project?._id
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
            actionInfo["comment"] = comments
            
            if(selectedAction == 2 || selectedAction == 4){
                let date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
                actionInfo["date"] = Formatter.ISO8601.string(from: date)
            }

            var prevLeadStatus : Dictionary<String,Any> = [:]
            prevLeadStatus["actionType"] = self.statusID
            prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
            
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
        
        sendOfferParameters["userName"] = prospectDetails.userName
        sendOfferParameters["userPhone"] = prospectDetails.userPhone
        sendOfferParameters["userEmail"] = prospectDetails.userEmail
        
//        print(sendOfferParameters)
        var urlString = ""
        if(self.viewType == VIEW_TYPE.LEADS || isFromRegistrations){
            urlString = RRAPI.CHANGE_PROSPECT_STATE
        }
        else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
            urlString = RRAPI.CHANGE_OPPORTUNITY_PROSPECT_STATE
        }
        
        sendOfferParameters["src"] = 3
        
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
                        
                        HUD.flash(.label(urlResult.err?.actionInfo ?? "Something went wrong with prospect calls"), delay: 1.0)
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
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
    }
    func didSelectInterestedProjects(projectNames: [String], projectIds: [String]) {
        
        // submit to server
        print(projectNames)
        
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
        parameters["userPhone"] = prospectDetails.userPhone
        parameters["userEmail"] =  prospectDetails.userEmail
        parameters["userName"] = prospectDetails.userName
        parameters["projects"] = projectIds
        parameters["projectNames"] = projectNames
        if(prospectDetails.comment != nil){
            parameters["comments"] = prospectDetails.comment
        }
        parameters["enquirySource"] = prospectDetails.enquirySource
        parameters["prevRegId"] = prospectDetails._id
        parameters["registrationDate"] = prospectDetails.registrationDate
        parameters["src"] = 3
//        print(parameters)
        HUD.show(.progress)
        
        AF.request(RRAPI.QUICK_REIGSTRATION, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let urlResult1 = try JSONDecoder().decode(Q_REGISTRATION_RESULT_ONE.self, from: responseData)
                    
                    if(urlResult1.status == 0){
                        HUD.flash(.label(urlResult1.err), delay: 2.0)
                        self.hide(UIButton())
                        self.dismiss(animated: true, completion: nil) //hide project search n selection
                    }
                    else{
                        let urlResult = try JSONDecoder().decode(Q_REGISTRATION_RESULT.self, from: responseData)

                        if(urlResult1.status == 1){ // success
                            HUD.flash(.label("Registered successfull"), delay: 1.0)
                            //                    self.dismiss(animated: true, completion: nil)
                            //                    self.dismiss(animated: true, completion: nil)
                            //                    self.hide(UIButton())
                            if(!self.isFromNotification){
                                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                            }
                            else{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.DELETE_NOTIFICATION), object: nil)
                            }
                            //                    self.dismiss(animated: true, completion: nil) //hide project search n selection
                        }else{
                            self.hide(UIButton())
                            self.dismiss(animated: true, completion: nil) //hide project search n selection
                            //                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                            //                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                            HUD.flash(.label(urlResult.err?.id), delay: 1.5)
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
    func submitOnHoldStatusToServer(){
        
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
        parameters["id"] = prospectDetails._id
        print(selectedStatus)
        parameters["taskStatus"] = selectedStatus + 1
        parameters["src"] = 3
        print(parameters)
        HUD.show(.progress)
        
        var urlString = ""
        if(self.viewType == VIEW_TYPE.LEADS || isFromRegistrations){
            urlString = RRAPI.API_UPDATE_TASK
        }
        else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
            urlString = RRAPI.API_UPDATE_TASK_OPPORTUNITY
        }
        
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
                    let urlResult = try JSONDecoder().decode(Q_REGISTRATION_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        HUD.flash(.label("Registered successfull"), delay: 1.0)
                        //                    self.dismiss(animated: true, completion: nil)
                        //                    self.dismiss(animated: true, completion: nil)
                        //                    self.hide(UIButton())
                        if(!self.isFromNotification){
                            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                        }
                        else{
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.DELETE_NOTIFICATION), object: nil)
                        }
                        //                    self.dismiss(animated: true, completion: nil) //hide project search n selection
                        
                    }
                    else if(urlResult.status == -1){ // ** Logout **
                        
                        self.hide(UIButton())
                        self.dismiss(animated: true, completion: nil) //hide project search n selection
                    }
                    else{
                        self.hide(UIButton())
                        self.dismiss(animated: true, completion: nil) //hide project search n selection
                        //                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                        //                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                        HUD.flash(.label(urlResult.err?.id), delay: 1.5)
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
        
        let urlString = String(format: RRAPI.API_GET_UNIT_PRICE, unitDetails._id!)
        
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
                        //                    self.dismiss(animated: true, completion: nil)
                        
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
        return  CustomPanelLayout(parent: self)
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
    //MARK: - FLOAT PANEL END
    // MARK: - BookUnitDelegate
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
