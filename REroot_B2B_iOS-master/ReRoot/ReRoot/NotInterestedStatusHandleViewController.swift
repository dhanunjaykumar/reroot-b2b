//
//  NotInterestedStatusHandleViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 04/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class NotInterestedStatusHandleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,RegistrationSearchDelegate{
    
    var viewType : VIEW_TYPE!
    var statusID : Int? = 0
    @IBOutlet var heightOfTableView: NSLayoutConstraint!
    var isFromRegistrations = false
    var selctedLabelIndex : Int!
    var isFromNotification = false
    var prospectDetails : REGISTRATIONS_RESULT!
    @IBOutlet var remarkTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    var tableViewDataSource : [PREDIFINED] = []
    var tableViewDataSourceOne : [NotInterestedCause] = []
    var selectedStatusesArray : [String] = []
    var selectedStatusIDs : [Int] = []
    
    var selectedLeadActionType : Int!
    var selectedLeadActionID : String!
    
    var selectedActionType : Int!
    var selectedActionLabel : String!
    
    var selectedStatusesDict : Dictionary<String,String> = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let height = CGFloat(tableViewDataSource.count * 44) + 142
        
        if(height >= self.view.frame.size.height){
            heightOfTableView.constant = self.view.frame.size.height - (142 + 64)
        }
        else{
            heightOfTableView.constant = CGFloat(tableViewDataSource.count * 44)
        }
        tableView.superview?.layoutIfNeeded()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: "ProspectStatusTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "prospectStatusCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideAll), name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)

        tableView.tableFooterView = UIView()
        
        let passwordImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        passwordImage.image = UIImage.init(named: "remark")
        passwordImage.contentMode = UIView.ContentMode.center
        remarkTextField.leftViewMode = .always
        remarkTextField.leftView = passwordImage

//        if(prospectDetails.project == nil){ // if no project id , show projects and submit selected proj to server
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
//            registerController.delegate = self
//            self.present(registerController, animated: true, completion: nil)
//            return
//        }
//        else{ //if project is there then just submit reason to server
//
//        }
        
        
//        print(RRUtilities.sharedInstance.notInterestedSources)
        
//        print(RRUtilities.sharedInstance.notInterestedSources.predefined!)
//
//        let predefined = RRUtilities.sharedInstance.notInterestedSources.predefined
//
//        tableViewDataSource = predefined!
        
        tableViewDataSourceOne = RRUtilities.sharedInstance.model.getNotInterestedReasons()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
    }
    
    @IBAction func okAction(_ sender: Any) {
        
//        self.navigationController!.popToRootViewController(animated: true)


//        self.dismiss(animated: true, completion: nil)
//        self.dismiss(animated: true, completion: nil)
//        self.dismiss(animated: true, completion: nil)
//        return
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
          HUD.show(.progress)
        
        var parameters : [String : Any] = [:]

//        action["id"] = String(format: "%d", selectedReasonIndex)
//        action["label"] = selectedReason
        
        if(selectedStatusesDict.keys.count == 0){
            HUD.flash(.label("Select Reason"), delay: 0.8)
            return
        }
        
        if(isFromRegistrations){
            
            var actionsArray : [Dictionary<String,String>] = []
            
            for tempDict in selectedStatusesDict{
                
                var action : [String : String] = [:]
                
                action["id"] = tempDict.key
                action["label"] = tempDict.value
                
                actionsArray.append(action)
            }
            
            var actionInfo : [String : Any] = [:]
            
            if(remarkTextField.text!.count>0){
                actionInfo["comment"] = remarkTextField.text! //prospectDetails.comment
            }
            else{
                actionInfo["comment"] = ""
            }
            let date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
            actionInfo["date"] = Formatter.ISO8601.string(from: date)
            
            parameters["project"] = prospectDetails.project?._id
            parameters["regInfo"] = prospectDetails._id
            parameters["registrationDate"] = prospectDetails.registrationDate
            
            parameters["registrationStatus"] = 2 //for not interested
            
            var action : [String : String] = [:]
            action["id"] = String(format: "%d", selectedActionType)
            action["label"] = selectedActionLabel
            
            var salesPerson : Dictionary<String,String> = [:]
            salesPerson["_id"] = prospectDetails.salesPerson?._id
            salesPerson["email"] = prospectDetails.salesPerson?.email
            
            parameters["action"] = action
            parameters["actionInfo"] = actionInfo
            parameters["salesPerson"] = salesPerson

        }
        else{
            
            var actionsArray : [Dictionary<String,String>] = []
            
            for tempDict in selectedStatusesDict{
                
                var action : [String : String] = [:]
                
                action["id"] = tempDict.key
                action["label"] = tempDict.value
                
                actionsArray.append(action)
            }
            
            var action : [String : String] = [:]
            if(selectedActionType != -1){
                action["id"] = String(format: "%d", selectedActionType)
            }
            action["label"] = selectedActionLabel

            parameters["action"] = action /// action id should be selected option , actionType should be prevLeadStat And its IDDDD
            
            parameters["project"] = prospectDetails.project?._id
            
            if(prospectDetails.regInfo != nil){
                parameters["regInfo"] = prospectDetails.regInfo
            }
            else{
                parameters["regInfo"] = prospectDetails._id
            }
            parameters["registrationDate"] = prospectDetails.registrationDate
            
            parameters["registrationStatus"] = 2 //for not interested

            var actionInfo : [String : String] = [:]
            
            if(remarkTextField.text!.count>0)
            {
                actionInfo["comment"] = remarkTextField.text! //prospectDetails.comment
            }
            else
            {
                actionInfo["comment"] = ""
            }
            
            var prevLeadStatus : [String : Any] = [:]
//            let temper = prospectDetails.action?.id
//            print(temper)
            prevLeadStatus["actionType"] = statusID //prospectDetails.action?.id //*** should pass ACTION TYPE IDDD
            prevLeadStatus["id"] = prospectDetails._id
            
            var status : [String : Any] = [:]   ////
            status["id"] = selectedLeadActionType
            status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NOT_INTERESTED.rawValue
            
            prevLeadStatus["status"] = status
            
            if(self.viewType == VIEW_TYPE.LEADS){
                parameters["prevLeadStatus"] = prevLeadStatus
            }
            else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                parameters["prevOpportunityStatus"] = prevLeadStatus
            }
            parameters["actionInfo"] = actionInfo
            
            parameters["discountApplied"] = Int(prospectDetails.discountApplied!)
            
            var salesPerson : Dictionary<String,Any> = [:]
            salesPerson["_id"] = prospectDetails.salesPerson?._id
            salesPerson["email"] = prospectDetails.salesPerson?.email
            
            var userInfo : Dictionary<String,Any> = [:]
            userInfo["name"] = prospectDetails.salesPerson?.userInfo?.name
            userInfo["_id"] = prospectDetails.salesPerson?.userInfo?._id
            userInfo["email"] = prospectDetails.salesPerson?.userInfo?.email
            userInfo["phone"] = prospectDetails.salesPerson?.userInfo?.phone
            userInfo["roles"] = prospectDetails.salesPerson?.userInfo?.roles
            
            if(userInfo.keys.count > 0){
                salesPerson["userInfo"] = userInfo
            }
            
            parameters["salesPerson"] = salesPerson
            
            if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
                parameters["unit"] = prospectDetails.unit?._id
            }
            else{
                parameters["unit"] = prospectDetails.unit?._id //prospectDetails.unit ?? ""
            }
            
            if(statusID == 1){
                
            }
            else if(statusID == 2){
                
            }
            else if(statusID == 3){
                
//                var prevLeadStatus : Dictionary<String,Any> = [:]
//                prevLeadStatus["actionType"] = statusID
//                prevLeadStatus["id"] = prospectDetails._id //*** should pass ACTION TYPE IDDD
//
//                var status : Dictionary<String,String> = [:]
//
//                status["id"] = String(format: "%d", 1)
//
//                if(selctedLabelIndex == 1){
//                    status["label"] = SITE_VISIT_ACTIONS_STRING.GOOD.rawValue
//                }
//                else if(selctedLabelIndex == 2){
//                    status["label"] = SITE_VISIT_ACTIONS_STRING.SATISFIED.rawValue
//                }
//                else if(selctedLabelIndex == 3){
//                    status["label"] = SITE_VISIT_ACTIONS_STRING.DISSATISFIED.rawValue
//                }
//                else if(selctedLabelIndex == 4){
//                    status["label"] = SITE_VISIT_ACTIONS_STRING.NOT_INTERESTED.rawValue
//                }
//
//                prevLeadStatus["status"] = status
//
//                if(self.viewType == VIEW_TYPE.LEADS){
//                    parameters["prevLeadStatus"] = prevLeadStatus
//                }
//                else if(self.viewType == VIEW_TYPE.OPPORTUNITIES){
//                    parameters["prevOpportunityStatus"] = prevLeadStatus
//                }

            }
            
        }
        
        parameters["prospectId"] = prospectDetails.prospectId ?? prospectDetails.regInfo ?? ""
        if(parameters["regInfo"] != nil){
            parameters["regInfo"] = prospectDetails.regInfo ?? prospectDetails._id
        }
        parameters["userName"] = prospectDetails.userName
        if let userPhone = prospectDetails.userPhone{
            parameters["userPhone"] = userPhone
        }
        if let email = prospectDetails.userEmail{
            parameters["userEmail"] = email
        }
        
        parameters["src"] = 3

//        print(parameters)
        print(RRAPI.CHANGE_PROSPECT_STATE)
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
                print(response)
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
                        
                        if(urlResult.status == -1){
                            HUD.flash(.label(urlResult.err?.unit ?? "Try Again!"), delay: 1.0)

                        }
                        else{
                            HUD.flash(.label("Try Again!"), delay: 1.0)
                        }
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
    @objc func hideAll(){
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Tablaview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewDataSourceOne.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectStatusTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectStatusCell",
            for: indexPath) as! ProspectStatusTableViewCell
        
        let reason = tableViewDataSourceOne[indexPath.row]
        cell.statusTitleLabel.text = reason.name
        
//        let keyString = String(format: "%d", indexPath.row + 1)
        
        if(selectedStatusesDict.keys.contains(reason.id!)){
            cell.statusTypeImageView.image = UIImage.init(named: "checkbox_on")
        }
        else{
            cell.statusTypeImageView.image = UIImage.init(named: "checkbox_off")
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
//        let selectedOption  = tableViewDataSource[indexPath.row]
//        let selectedIndex = selectedOption.id
        
        let reason = tableViewDataSourceOne[indexPath.row]

        selectedActionType = -1 //reason.id!
        selectedActionLabel = reason.name!
        
//        let keyString = String(format: "%d", selectedIndex!)
        
        if(selectedStatusesDict.keys.contains(reason.id!))
        {
            selectedStatusesDict.removeValue(forKey: reason.id!)
        }
        else{
//            selectedStatusesDict.removeValue(forKey: selectedIndex)
            selectedStatusesDict[reason.id!] = reason.name
        }
        
//        if(selectedStatusesArray.contains(selectedOption))
//        {
//            selectedStatusIDs = selectedStatusIDs.filter{ $0 != selectedIndex }
//            selectedStatusesArray = selectedStatusesArray.filter{ $0 != selectedOption }
//        }
//        else{
//            selectedStatusesArray.append(selectedOption)
//            selectedStatusIDs.append(selectedIndex)
//        }

        tableView.reloadData()
        
    }
    // MARK: - PRJECT SEARCH DELEGATE
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
        parameters["userEmail"] = prospectDetails.userEmail
        parameters["userName"] = prospectDetails.userName
        parameters["projects"] = projectIds
        parameters["projectNames"] = projectNames
        parameters["comments"] = prospectDetails.comment
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
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                
                do{
                    let urlResult = try JSONDecoder().decode(Q_REGISTRATION_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        HUD.flash(.label("Registered successfull"), delay: 1.0)
                        //                    self.hide(UIButton())
                        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                        self.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                        
                    }else{
                        
                        HUD.flash(.label(urlResult.err?.id), delay: 1.0)
                    }
                    HUD.hide()
                }
                catch let error{
                    HUD.hide()
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
