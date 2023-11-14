//
//  SalesPersonChangeViewController.swift
//  REroot
//
//  Created by Dhanunjay on 29/01/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class SalesPersonChangeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var isFromNotification = false
    @IBOutlet var heightOfTabelViewConstraint: NSLayoutConstraint!
    @IBOutlet var commentsTextView: KMPlaceholderTextView!
    @IBOutlet var remarksTextView: KMPlaceholderTextView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var remarksView: UIView!
    var tableViewDataSourceArray : [Employee]!
    var selectedEmployeeIndex : Int = -1
    var selectedProspect : REGISTRATIONS_RESULT!
    var viewType : VIEW_TYPE!
    
    @objc func injected() {
        configureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nib = UINib(nibName: "ProspectStatusTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "prospectStatusCell")
        
        tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(hideAll), name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)

        configureView()
        self.getAllEmployeeDetails()

        // Do any additional setup after loading the view.
    }
    func getAllEmployeeDetails(){
        
        if(selectedProspect.salesPerson!.userInfo != nil){
            
            let employeeArray =  RRUtilities.sharedInstance.model.getEmployeesByExcludingEmployee(salesPersonName: selectedProspect.salesPerson!.userInfo!.name!)
            
            self.tableViewDataSourceArray = employeeArray
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
        else{
            
            let employeeArray =  RRUtilities.sharedInstance.model.getAllEmployees() // ** SALES PERSONS
            
            self.tableViewDataSourceArray = employeeArray
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
        
        heightOfTabelViewConstraint.constant = CGFloat(self.tableViewDataSourceArray.count * 44)
    }
    func configureView(){
        
        remarksView.layer.cornerRadius = 8.0
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ok(_ sender: Any) {
        
        if(selectedEmployeeIndex == -1){
            
            return
        }
        
        let selectedSalesPerson = self.tableViewDataSourceArray[selectedEmployeeIndex]
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var parametersDict : Dictionary<String,Any> = [:]
        
//        if(viewType == VIEW_TYPE.REGISTRATIONS){
//        }
//        else{
//            parametersDict["prospects"] = [selectedSalesPerson.regInfo]
//        }
        
        if let prospectId = selectedProspect._id{
            parametersDict["prospects"] = [prospectId]
        }
        if let name = selectedProspect.userName{
            parametersDict["prospectNames"] = [name]
        }

        
//        requestBody.put("prospects", idArray)
//        requestBody.put("prospectNames", nameArray)
//        requestBody.put("salesPerson", pLeads.assignedSalesPerson?._id)
//        requestBody.put("salesPersonName", pLeads.assignedSalesPerson?.name)
//        requestBody.put("viewType", viewType)
//        requestBody.put("comment", pLeads.actionInfo?.comment)
//        requestBody.put("oldSalesPerson", mProspectList[0].salesPerson?._id)
//        requestBody.put("oldSalesPersonName", mProspectList[0].salesPerson?.userInfo?.name)

        parametersDict["prospectPhone"] = selectedProspect.userPhone
        parametersDict["salesPerson"] = selectedSalesPerson.empId
        parametersDict["salesPersonName"] = selectedSalesPerson.name
        parametersDict["viewType"] = self.viewType.rawValue
        parametersDict["comment"] = commentsTextView.text
        parametersDict["oldSalesPerson"] = selectedProspect.salesPerson?._id
        parametersDict["oldSalesPersonName"] = selectedProspect.salesPerson?.userInfo?.name ?? selectedProspect.salesPerson?.email
        parametersDict["userId"] = selectedSalesPerson.empId
        
        if(selectedProspect.actionInfo?.projects?.count ?? 0 > 0){
            var projNames : [String] = []
            for eachProject in selectedProspect.actionInfo!.projects!{
                projNames.append(eachProject.name ?? "")
            }
            parametersDict["projectNames"] = projNames
        }
        parametersDict["src"] = 3
//        selectedProspect.actionInfo?.units
        if let project = self.selectedProspect.currProject{
            parametersDict["projectNames"] = [project]
        }
        //userId - assigned sales person _id, projectNames - JSONarray

        print(parametersDict)
        
        HUD.show(.progress)

        AF.request(RRAPI.API_ASSIGN_SALES_PERSON, method: .post, parameters: parametersDict, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(ASSIGN_SALES_PERSON_OUTPUT.self, from: responseData)
                HUD.hide()

                if(urlResult.status == -1 )
                {
                    HUD.flash(.label("Please select Sales Person"), delay: 1.0)
                }
                else{
                    HUD.flash(.label("Successfully changed sales person"), delay: 2.0)
                    DispatchQueue.main.async {
                        self.perform(#selector(self.updateThings), with: nil, afterDelay: 2.0)
                    }
//                    self.dismiss(animated: true, completion: nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
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

    // MARK: - Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewDataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectStatusTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectStatusCell",
            for: indexPath) as! ProspectStatusTableViewCell

        let employee = self.tableViewDataSourceArray[indexPath.row]
        
        print(employee.name)
        print(employee.id)
        print("\n")
        
        cell.statusTitleLabel.text = employee.name
        
        if(indexPath.row == selectedEmployeeIndex){
            cell.statusTypeImageView.image = UIImage.init(named: "radio_on")
        }
        else{
            cell.statusTypeImageView.image = UIImage.init(named: "radio_off")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedEmployeeIndex = indexPath.row
        
        tableView.reloadData()
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
