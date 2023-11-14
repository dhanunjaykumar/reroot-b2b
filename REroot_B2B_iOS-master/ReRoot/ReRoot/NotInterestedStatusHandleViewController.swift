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
    
    var statusID : Int? = 0
    @IBOutlet var heightOfTableView: NSLayoutConstraint!
    var isFromRegistrations = false
    var prospectDetails : REGISTRATIONS_RESULT!
    @IBOutlet var remarkTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    var tableViewDataSource : [PREDIFINED] = []
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
        
        print(RRUtilities.sharedInstance.notInterestedSources.predefined!)
        
        let predefined = RRUtilities.sharedInstance.notInterestedSources.predefined
        
        tableViewDataSource = predefined!
        
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
        
        
        if(isFromRegistrations){
            
            var actionsArray : [Dictionary<String,String>] = []
            
            for tempDict in selectedStatusesDict{
                
                var action : [String : String] = [:]
                
                action["id"] = tempDict.key
                action["label"] = tempDict.value
                
                actionsArray.append(action)
                
            }
            
            var actionInfo : [String : String] = [:]
            
            if(remarkTextField.text!.count>0){
                actionInfo["comment"] = remarkTextField.text! //prospectDetails.comment
            }
            else{
                actionInfo["comment"] = ""
            }
            parameters["project"] = prospectDetails.project?._id
            parameters["regInfo"] = prospectDetails._id
            parameters["registrationDate"] = prospectDetails.registrationDate
            
            parameters["registrationStatus"] = 2 //for not interested
            
            var action : [String : String] = [:]
            action["id"] = String(format: "%d", selectedActionType)
            action["label"] = selectedActionLabel
            
            parameters["action"] = action
            parameters["actionInfo"] = actionInfo

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
            action["id"] = String(format: "%d", selectedActionType)
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
            let temper = prospectDetails.action?.id
            print(temper)
            prevLeadStatus["actionType"] = prospectDetails.action?.id //*** should pass ACTION TYPE IDDD
            prevLeadStatus["id"] = prospectDetails._id
            
            var status : [String : Any] = [:]   ////
            status["id"] = selectedLeadActionType
            status["label"] = SCHEDULE_CALL_ACTIONS_STRING.NOT_INTERESTED.rawValue
            
            prevLeadStatus["status"] = status
            
            parameters["prevLeadStatus"] = prevLeadStatus
            parameters["actionInfo"] = actionInfo
            
            if(statusID == 1){
                
            }
            else if(statusID == 2){
                
            }
            else if(statusID == 3){
                
            }
            
        }
        print(parameters)
        print(RRAPI.CHANGE_PROSPECT_STATE)
        
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
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Tablaview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectStatusTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectStatusCell",
            for: indexPath) as! ProspectStatusTableViewCell
        
        let difinedStatus = tableViewDataSource[indexPath.row]
        cell.statusTitleLabel.text = difinedStatus.name
        
        let keyString = String(format: "%d", indexPath.row + 1)
        
        if(selectedStatusesDict.keys.contains(keyString)){
            cell.statusTypeImageView.image = UIImage.init(named: "Checkbox_on")
        }
        else{
            cell.statusTypeImageView.image = UIImage.init(named: "Checkbox_off")
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        let selectedOption  = tableViewDataSource[indexPath.row]
        let selectedIndex = selectedOption.id
        
        selectedActionType = selectedOption.id
        selectedActionLabel = selectedOption.name
        
        let keyString = String(format: "%d", selectedIndex!)
        
        if(selectedStatusesDict.keys.contains(keyString))
        {
            selectedStatusesDict.removeValue(forKey: keyString)
        }
        else{
//            selectedStatusesDict.removeValue(forKey: selectedIndex)
            selectedStatusesDict[keyString] = selectedOption.name
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
        parameters["comments"] = prospectDetails.comment
        parameters["enquirySource"] = prospectDetails.enquirySource
        parameters["prevRegId"] = prospectDetails._id
        parameters["registrationDate"] = prospectDetails.registrationDate
        
        print(parameters)
        HUD.show(.progress)
        
        Alamofire.request(RRAPI.QUICK_REIGSTRATION, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
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
//                    self.hide(UIButton())
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                    
                }else{
                    
                    HUD.flash(.label(urlResult.err), delay: 1.0)
                }
                HUD.hide()
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
