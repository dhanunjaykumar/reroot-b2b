//
//  CustomerDetailsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 25/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class CustomerDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var isFromLeads : Bool = false
    var statusID : Int?
    var tabId : Int!
    var isFromRegistrations : Bool = false
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var emailLabel: UILabel!
    var orderedKeyDetails : NSMutableOrderedSet = []
    @IBOutlet var emailView: UIView!
    @IBOutlet var heightConstraintOfEmailView: NSLayoutConstraint!
    @IBOutlet var emailInfoLabel: UILabel!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    var prospectType : PROSPECTS_TYPES!
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var currentStatusLabel: UILabel!
    @IBOutlet var titleView: UIView!
    @IBOutlet var tableView: UITableView!
    var prospectDetails : REGISTRATIONS_RESULT!
    
    var isFromNotInterested : Bool = false
    
    var prospectsDataSourceDict: Dictionary<String,String> = [:]
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleView.clipsToBounds = true
        
        titleView.layer.masksToBounds = false
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleView.layer.shadowOpacity = 0.4
        titleView.layer.shadowRadius = 1.0
        titleView.layer.shouldRasterize = true
        titleView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleView.layer.shouldRasterize = true
        titleView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleView)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: "CustomerDetailsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cusDetailsCell")
        
        tableView.tableFooterView = UIView()
        
        print(prospectDetails)
        print(prospectType)
        
        if(prospectDetails.userEmail == nil)
        {
            emailView.isHidden = true
            heightConstraintOfEmailView.constant = 0
        }
        else{
            emailLabel.text = prospectDetails.userEmail
            emailView.isHidden = false
            heightConstraintOfEmailView.constant = 53
        }
        
        nameLabel.text = prospectDetails.userName
        phoneNumberLabel.text = prospectDetails.userPhone
        
        if(prospectDetails.salesPerson?.email != nil)
        {
            prospectsDataSourceDict["SALES PERSON"] = prospectDetails.salesPerson?.email
            orderedKeyDetails.add("SALES PERSON")
        }
        if(prospectDetails.enquirySource != nil)
        {
            prospectsDataSourceDict["ENQUIRY SOURCE"] = prospectDetails.enquirySource
            orderedKeyDetails.add("ENQUIRY SOURCE")
        }
        
        if(prospectDetails.project?.name != nil){
            prospectsDataSourceDict["INTERESTED IN"] = prospectDetails.project?.name
            orderedKeyDetails.add("INTERESTED IN")
        }
        if(prospectDetails.comment != nil)
        {
            prospectsDataSourceDict["COMMENTS"] = prospectDetails.comment
            orderedKeyDetails.add("COMMENTS")
        }
//        if(prospectDetails.action?.label != nil){
//            prospectsDataSourceDict["ACTION"] = prospectDetails.action?.label
//            orderedKeyDetails.add("ACTION")
//        }
//        else{
//            prospectsDataSourceDict["ACTION"] = "None"
//            orderedKeyDetails.add("ACTION")
//        }
        
        print(prospectDetails)
        
        if(prospectDetails.action != nil){
            currentStatusLabel.text = prospectDetails.action?.label
        }
        else{
            currentStatusLabel.text = "None"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        changeButton.layer.cornerRadius = 8
        
        if(isFromNotInterested){
            changeButton.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(popControllers), name: NSNotification.Name(rawValue: NOTIFICATIONS.POP_CONTROLLERS), object: nil)

    }
    @objc func popControllers(){
//        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        self.navigationController!.popViewController(animated: true)
    }
    // MARK: - Tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prospectsDataSourceDict.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CustomerDetailsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cusDetailsCell",
            for: indexPath) as! CustomerDetailsTableViewCell
        
//        let prospect = self.tableViewDataSourceArray[indexPath.row]
//        cell.nameLabel.text = "prospect.userName"
        
        let key = orderedKeyDetails[indexPath.row] as! String
        cell.headingLabel.text = key
        cell.contentLabel.text = prospectsDataSourceDict[key]
        return cell
    }
    // MARK: - ACTIONS
    @IBAction func showStatusHandler(_ sender: Any) {
        
        print(prospectDetails)
        
        if(statusID == 4)  ///discount view
        {
            //discountRequest
            if(prospectDetails.discountApplied == 1){ //Discount applied
                
                // Show prospect as radio Button
            
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
                statusController.tabID = self.tabId
                statusController.prospectDetails = prospectDetails
                statusController.isFromRegistrations = self.isFromRegistrations
                statusController.statusID = self.statusID
                //        self.navigationController?.pushViewController(statusController, animated: true)
                //            let tempNavigator = UINavigationController.init(rootViewController: statusController)
                
                self.present(statusController, animated: true, completion: nil)
                return
                // show send offer
                // SendOfferPopUpViewController
            }
            else{ //not applied
                
                self.getDiscountDetailsOfUnit()
                return
            }
        }
        
        if(prospectDetails.action?.id != nil){  // launch new navigation controller?
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.tabID = self.tabId
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = self.isFromRegistrations
            statusController.statusID = self.statusID
            //        self.navigationController?.pushViewController(statusController, animated: true)
            self.present(statusController, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.tabID = self.tabId
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = self.isFromRegistrations
            statusController.statusID = self.statusID
            //        self.navigationController?.pushViewController(statusController, animated: true)
            
//            let tempNavigator = UINavigationController.init(rootViewController: statusController)

            self.present(statusController, animated: true, completion: nil)
        }
    }
    @IBAction func close(_ sender: Any) {
        
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        
        if(prospectDetails.userEmail != nil){
            
            let emailer = String(format: "mailto:%@", prospectDetails.userEmail!)
            let url = URL(string: emailer)
            
            UIApplication.shared.open(url!)
        }
    }
    @IBAction func call(_ sender: Any) {
        
        guard let number = URL(string: "tel://" + prospectDetails.userPhone!) else { return }
        UIApplication.shared.open(number)
    }
    // MARK: -
    func getHistoryOfQuickRegistration(){
//        String(format:RRAPI.PROJECT_DETAILS, projecct.id!)
        
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
        
        HUD.show(.progress)
        
        Alamofire.request(RRAPI.API_GET_QR_HISTORY, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                
                let urlResult = try! JSONDecoder().decode(UNIT_PRICE_API_RESULT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
                    //                    HUD.flash(.label("Success"), delay: 1.0)
                    //                    self.dismiss(animated: true, completion: nil)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let discountRequestController = storyboard.instantiateViewController(withIdentifier :"discountRequest") as! DiscountRequestViewController
                    discountRequestController.selectedProspect = self.prospectDetails
                    discountRequestController.isFromRegistrations = self.isFromRegistrations
                    discountRequestController.statusID = self.statusID
                    discountRequestController.unitBillingInfo = urlResult.result
                    self.present(discountRequestController, animated: true, completion: nil)
                    
                }
                else
                {
                    HUD.flash(.label(urlResult.err), delay: 1.0)
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
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                
                let urlResult = try! JSONDecoder().decode(UNIT_PRICE_API_RESULT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
//                    HUD.flash(.label("Success"), delay: 1.0)
//                    self.dismiss(animated: true, completion: nil)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let discountRequestController = storyboard.instantiateViewController(withIdentifier :"discountRequest") as! DiscountRequestViewController
                    discountRequestController.selectedProspect = self.prospectDetails
                    discountRequestController.isFromRegistrations = self.isFromRegistrations
                    discountRequestController.statusID = self.statusID
                    discountRequestController.unitBillingInfo = urlResult.result
                    self.present(discountRequestController, animated: true, completion: nil)

                }
                else
                {
                    HUD.flash(.label(urlResult.err), delay: 1.0)
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
