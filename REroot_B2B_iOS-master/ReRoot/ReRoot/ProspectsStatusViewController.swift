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


class ProspectsStatusViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource ,RegistrationSearchDelegate {
   
    var statusID : Int?
    var selectedIndexPath : IndexPath!
    var prospectID = String()
    var isFromRegistrations : Bool = false
    @IBOutlet var heightOfTableView: NSLayoutConstraint!
    @IBOutlet var widthOfOkButton: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    var prospectStatusesArray : NSMutableOrderedSet = []
    var selectedStatus : Int = -1
    var prospectDetails : REGISTRATIONS_RESULT!
    
    @IBOutlet var buttonsView: UIView!
    @IBOutlet var okButton: UIButton!
    
    var tabID : Int!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        heightOfTableView.constant = CGFloat(prospectStatusesArray.count * 44)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
            
            prospectStatusesArray.add("Preview")
            prospectStatusesArray.add("Send")

        }
        else if(statusID == 3){ //From SiteVisits Controller
         
            prospectStatusesArray.add("Good")
            prospectStatusesArray.add("Satisfactory")
            prospectStatusesArray.add("Dissatisfied")
            prospectStatusesArray.add("Not Interested")

        }
        else if(statusID == 4){ // From Discount Request controller
            prospectStatusesArray.add("Send")
        }
        else if(statusID == 5){ //From Other Task Request controller
            
            prospectStatusesArray.add("Completed")
            prospectStatusesArray.add("On Hold")
            prospectStatusesArray.add("Not Interested")
            
        }
        else if(statusID == 6){ //From Not interested Request controller // *** Nothing to handle here for now
            
        }
        
        let nib = UINib(nibName: "ProspectStatusTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "prospectStatusCell")
        
        tableView.tableFooterView = UIView()
        widthOfOkButton.constant = 0
        okButton.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
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
            cell.statusTypeImageView.image = UIImage.init(named: "Checkbox_on")
        }
        else{
            cell.statusTypeImageView.image = UIImage.init(named: "Checkbox_off")
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        
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
        widthOfOkButton.constant = 70
        okButton.isHidden = false
        //leadsPopUp
        selectedStatus = indexPath.row
        tableView.reloadData()
        
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func hide(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okAction(_ sender: Any) {
        
        if(isFromRegistrations){  // Only two states from registratois 1. interested , 2 not interested
            
            if(selectedIndexPath.row == 0)
            {
                if(prospectDetails.project == nil)
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
                    registerController.delegate = self
                    self.present(registerController, animated: true, completion: nil)
                    return
                }
                else
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                    leadsPopUpController.prevSelectedStatus = selectedStatus
                    leadsPopUpController.prospectDetails = prospectDetails
                    leadsPopUpController.selctedScheduleCallOption = selectedStatus + 1
                    leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                    leadsPopUpController.statusID = self.statusID
                    self.present(leadsPopUpController, animated: true, completion: nil)
                    return
                    
                }
            }
            else if(selectedIndexPath.row == 1)
            {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
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
                if(prospectDetails.project == nil)
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
                    registerController.delegate = self
                    self.present(registerController, animated: true, completion: nil)
                    return
                }
                else
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                    leadsPopUpController.prevSelectedStatus = selectedStatus
                    leadsPopUpController.prospectDetails = prospectDetails
                    leadsPopUpController.selctedScheduleCallOption = selectedStatus + 1
                    leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                    leadsPopUpController.statusID = self.statusID
                    self.present(leadsPopUpController, animated: true, completion: nil)
                    return
                }
                
            }
            else{
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                notInterestedController.prospectDetails =  prospectDetails
                notInterestedController.isFromRegistrations = isFromRegistrations
                notInterestedController.selectedLeadActionType = selectedStatus + 1
                self.present(notInterestedController, animated: true, completion: nil)
                return
                
            }

        }
        else if(statusID == 2){ //From Offers Controller
            
            if(selectedIndexPath.row == 0){ // PREVIEW
                // YET TO IMPLEMENT 
            }
            else if(selectedIndexPath.row == 1) //SEND
            {
                // show send
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                leadsPopUpController.prevSelectedStatus = selectedStatus
                leadsPopUpController.prospectDetails = prospectDetails
                leadsPopUpController.selctedScheduleCallOption = selectedStatus + 1
                leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                leadsPopUpController.statusID = self.statusID
                self.present(leadsPopUpController, animated: true, completion: nil)
                return
                
            }
        }
        else if(statusID == 3){ //From SiteVisits Controller
            
            if(selectedIndexPath.row != prospectStatusesArray.count-1)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                leadsPopUpController.prevSelectedStatus = selectedStatus
                leadsPopUpController.prospectDetails = prospectDetails
                leadsPopUpController.selctedScheduleCallOption = selectedStatus + 1
                leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                leadsPopUpController.statusID = self.statusID
                self.present(leadsPopUpController, animated: true, completion: nil)
                return
            }
            else{

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedState") as! NotInterestedStatusHandleViewController
                notInterestedController.prospectDetails =  prospectDetails
                notInterestedController.isFromRegistrations = isFromRegistrations
                notInterestedController.selectedLeadActionType = selectedStatus + 1
                notInterestedController.statusID = self.statusID
                self.present(notInterestedController, animated: true, completion: nil)
                return
            }
        }
        else if(statusID == 4){ // From Discount Request controller
            
            //*** show email view (send offer controller)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let offerController = storyboard.instantiateViewController(withIdentifier :"sendOfferPopUp") as! SendOfferPopUpViewController
            offerController.selectedProspect = prospectDetails
            offerController.isFromRegistrations = isFromRegistrations
            offerController.statusID = self.statusID
            offerController.prevSelectedStatus = selectedStatus
            self.present(offerController, animated: true, completion: nil)
            
        }
        else if(statusID == 5){ //From Other Task Request controller
            
            if(selectedStatus == 0) // Complted
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                leadsPopUpController.prevSelectedStatus = selectedStatus
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
                notInterestedController.prospectDetails =  prospectDetails
                notInterestedController.isFromRegistrations = isFromRegistrations
                notInterestedController.selectedLeadActionType = selectedStatus + 1
                notInterestedController.statusID = self.statusID
                self.present(notInterestedController, animated: true, completion: nil)
                return

            }

            
        }
        else if(statusID == 6){ //From Not interested Request controller
            
        }

        
        
        
        
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
        parameters["userEmail"] = prospectDetails.userEmail
        parameters["userName"] = prospectDetails.userName
        parameters["projects"] = projectIds
        if(prospectDetails.comment != nil){
            parameters["comments"] = prospectDetails.comment
        }
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
                HUD.hide()
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                
                let urlResult = try! JSONDecoder().decode(Q_REGISTRATION_RESULT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
                    HUD.flash(.label("Registered successfull"), delay: 1.0)
//                    self.dismiss(animated: true, completion: nil)
//                    self.dismiss(animated: true, completion: nil)
                    self.hide(UIButton())
                    self.dismiss(animated: true, completion: nil) //hide project search n selection
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                }else{
                    self.hide(UIButton())
                    self.dismiss(animated: true, completion: nil) //hide project search n selection
//                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
//                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                    HUD.flash(.label(urlResult.err), delay: 1.5)
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
        parameters["_id"] = prospectDetails._id
        parameters["taskStatus"] = selectedStatus + 1
        
        print(parameters)
        HUD.show(.progress)
        
        Alamofire.request(RRAPI.API_UPDATE_TASK, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                HUD.hide()
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                
                let urlResult = try! JSONDecoder().decode(Q_REGISTRATION_RESULT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
                    HUD.flash(.label("Registered successfull"), delay: 1.0)
                    //                    self.dismiss(animated: true, completion: nil)
                    //                    self.dismiss(animated: true, completion: nil)
                    self.hide(UIButton())
                    self.dismiss(animated: true, completion: nil) //hide project search n selection
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
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
                    HUD.flash(.label(urlResult.err), delay: 1.5)
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
