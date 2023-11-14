//
//  NotInterestedViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 25/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class NotInterestedViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var changeButton: UIButton!
    var tableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    var currentTableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    @IBOutlet var tableView: UITableView!
    var tabID : Int!
    var projectID : String!
    var statusID : Int?
    var notInteretedCount : Int!
    @IBOutlet var statusInfoView: UIView!
    @IBOutlet var heightOfStatusInfoView: NSLayoutConstraint!
    var isLeads = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "CommonProspectsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "commonProspect")
        
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getProspectsAsPerStatus), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        
        if(notInteretedCount > 0){
            self.getProspectsAsPerStatus()
        }else{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
        heightOfStatusInfoView.constant = 0
        statusInfoView.isHidden = true
        changeButton.layer.cornerRadius = 8
        
        changeButton.isHidden = true
        
    }
    @objc func getProspectsAsPerStatus(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress)
        
        //rospectleads?tab=1&id=5a64a02cc145c62d977954f0&status=4
        
        print(tabID)
        print(projectID)
        print(statusID)
        if(projectID == nil)
        {
            projectID = "null"
        }
        
        var urlString = ""
        
        if(isLeads){
            urlString = String(format:RRAPI.GET_LEADS_PROSPECTS_AS_PER_ORDER,tabID,projectID,statusID ?? -1)
        }
        else{
            urlString = String(format:RRAPI.GET_OPPORTUNITIES_PROSPECTS_AS_PER_ORDER,tabID,projectID,statusID ?? -1)
        }

        
        print(urlString)
        
        //        if(registrationID != nil){
        //            urlString =  RRAPI.GET_QR_PROSPECT_DATA + tabID + "&id=" + registrationID
        //        }
        //        else{
        //            urlString =  RRAPI.GET_QR_PROSPECT_DATA + tabID + "&id="
        //        }
        
        print(urlString)
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(REGISTRATIONS.self, from: responseData)
                print(urlResult)
                
                if(urlResult.status == -1){
                    
                }
                
                self.currentTableViewDataSourceArray.removeAll()
                self.tableViewDataSourceArray.removeAll()
                
                if(urlResult.result != nil){
                    self.tableViewDataSourceArray = urlResult.result!
                    self.currentTableViewDataSourceArray = self.tableViewDataSourceArray
                }
                
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                HUD.hide()
                
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    
    // MARK: - Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.currentTableViewDataSourceArray.count > 0)
        {
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return self.currentTableViewDataSourceArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CommonProspectsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "commonProspect",
            for: indexPath) as! CommonProspectsTableViewCell
        
        let prospect = self.currentTableViewDataSourceArray[indexPath.row]
        cell.nameLabel.text = prospect.userName
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        //show customer details
        
       let prospect = self.currentTableViewDataSourceArray[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsController = storyboard.instantiateViewController(withIdentifier :"cusDetailsController") as! CustomerDetailsViewController
        detailsController.prospectDetails = prospect
        detailsController.isFromNotInterested = true
        detailsController.prospectType = .LEADS
        self.navigationController?.pushViewController(detailsController, animated: true)
        
    }

    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        currentTableViewDataSourceArray = tableViewDataSourceArray.filter({REGISTRATIONS_RESULT -> Bool in
            switch searchBar.selectedScopeButtonIndex {
            case 0 :
                if(searchText.isEmpty) {return true}
                return REGISTRATIONS_RESULT.userName!.lowercased().contains(searchText.lowercased())
            default:
                return false
            }
        })
        
        self.tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        switch selectedScope {
        case 0:
            currentTableViewDataSourceArray = tableViewDataSourceArray
        default:
            break
        }
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
        //        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        searchBar.isHidden = true
        self.hideKeyBoard()
        self.currentTableViewDataSourceArray = self.tableViewDataSourceArray
        self.tableView.reloadData()
    }
    func hideKeyBoard()
    {
        self.view.endEditing(true)
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
