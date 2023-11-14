//
//  ProjectWiseViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 14/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import Reachability
import PKHUD


class ProjectWiseViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var tableViewDataSource : Array<PROSPECT_DETAILS> = []
    var currentTableViewDataSource : Array<PROSPECT_DETAILS> = []
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: "ProspectsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "prospectCell")
        
        let nib1 = UINib(nibName: "ProspectsSubTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "prospectSubCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(getProspects), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)

        tableView.dataSource = self
        tableView.delegate = self

        self.getProspects()
        self.addRefreshControl()
        
        
    }
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    @objc func refreshList() {
        
        self.getProspects()

    }

    @objc func getProspects(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.refreshControl?.endRefreshing()
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress)
        let urlSting =  RRAPI.PROSPECTS_TAB_COUNT + "1"
        
        Alamofire.request(urlSting, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(PROSPECTS.self, from: responseData)
                
                if(urlResult.status == -1 ){
                    RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                    return
                }
                
                self.tableViewDataSource = (urlResult.result?.counts)!
                
//                let tempSource : [PROSPECT_DETAILS] = self.tableViewDataSource
                
                var modifiedSource : [PROSPECT_DETAILS] = []
                
                var counter = 0
                
                for tempProspect in self.tableViewDataSource{
                    counter = counter + 1
                    var newProspect = tempProspect
                    newProspect.shouldOpen = false
                    modifiedSource.append(newProspect)
                    if(tempProspect.name == "General"){
                        modifiedSource.swapAt(0, counter-1)
                    }
                }
                
                print(modifiedSource)
                var tempSource1 = modifiedSource
                tempSource1.remove(at: 0)
                
//                tempSource1 = tempSource1.sorted(by: { UIContentSizeCategory(rawValue: $0.name!) > $1.name })
                
                tempSource1 = tempSource1.sorted(by: { $0.name! < $1.name! })
                
                self.refreshControl?.endRefreshing()

                self.tableViewDataSource = tempSource1
                self.tableViewDataSource.insert(modifiedSource[0], at: 0)
                self.currentTableViewDataSource.removeAll()
                self.currentTableViewDataSource.append(contentsOf: self.tableViewDataSource)
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                HUD.hide()
                // make tableview data
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                HUD.hide()
                break
            }
        }
    }
    //MARK :- TABLEVIEW DELEGATE
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if (self.currentTableViewDataSource.count > 0)
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
        return self.currentTableViewDataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let prospect = self.currentTableViewDataSource[section]
        
        if(prospect.shouldOpen!){
            return 4
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectCell",
            for: indexPath) as! ProspectsTableViewCell

        if(indexPath.section == 0){
            cell.leftImageView.image = UIImage.init(named: "general_icon")
        }
        else{
            cell.leftImageView.image = UIImage.init(named: "project_icon")
        }
        if(indexPath.row == 0){

            let projectDetails = self.currentTableViewDataSource[indexPath.section]
            
            if(projectDetails.shouldOpen!){
                cell.rightImageView.image = UIImage.init(named: "upArrow")
            }
            else{
                cell.rightImageView.image = UIImage.init(named: "downArrow")
            }
            cell.titleLabel.text = projectDetails.name
            
            cell.subContentView.layer.cornerRadius = 4
            cell.subContentView.layer.borderWidth = 2
            cell.subContentView.layer.borderColor = UIColor.clear.cgColor
            cell.subContentView.layer.shadowRadius = 4
            cell.subContentView.layer.masksToBounds = false
            cell.subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.subContentView.layer.shadowRadius = 2
            cell.subContentView.layer.shadowOpacity = 0.3

        }
        else{
            
            let prospectDetails = self.currentTableViewDataSource[indexPath.section]

            let subCell : ProspectsSubTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "prospectSubCell",
                for: indexPath) as! ProspectsSubTableViewCell

            if(indexPath.row == 1)
            {
                subCell.mImageView.image = UIImage.init(named: "registrations_icon")
                subCell.prospectTypeLabel.text = "Registration"
                subCell.prospectCountLabel.text = String(format: "%zd", (prospectDetails.registrationCount)!)
            }
            else if(indexPath.row == 2){
                subCell.mImageView.image = UIImage.init(named: "leads_icon")
                subCell.prospectTypeLabel.text = "Leads"
                let tempLeads = prospectDetails.leads!
                let leadsCount = tempLeads.callCount! + tempLeads.discountRequestCount! + tempLeads.notInterestedCount! + tempLeads.offerCount! + tempLeads.otherCount! + tempLeads.siteVisitCount!
                subCell.prospectCountLabel.text = String(format: "%zd", leadsCount)
            }
            else if(indexPath.row == 3)
            {
                subCell.mImageView.image = UIImage.init(named: "opportunities_icon")
                subCell.prospectTypeLabel.text = "Oppurtunities"
                let tempOpportunities  = prospectDetails.opportunities!
                let totalOpsCount = tempOpportunities.callCount! + tempOpportunities.discountRequestCount! + tempOpportunities.notInterestedCount! + tempOpportunities.offerCount! + tempOpportunities.otherCount! + tempOpportunities.siteVisitCount!

                subCell.prospectCountLabel.text = String(format: "%zd", totalOpsCount)
            }
            
            return subCell
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectedProspect = self.currentTableViewDataSource[indexPath.section]
        
        if(selectedProspect.shouldOpen!){
            selectedProspect.shouldOpen = false
        }
        else{
            selectedProspect.shouldOpen = true
        }
        
        if(indexPath.row == 0){
            self.currentTableViewDataSource[indexPath.section] = selectedProspect
            self.tableView.reloadData()
        }
        else if(indexPath.row == 1){
            
            //RegistrationsViewController
            let prospectDetails = self.currentTableViewDataSource[indexPath.section]

            if(prospectDetails.registrationCount! == 0){
                self.showNoDataAlert()
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let registrationsController = storyboard.instantiateViewController(withIdentifier :"registrations") as! RegistrationsViewController
            registrationsController.tabID = "1"
            
            if(selectedProspect._id == nil){
                registrationsController.registrationID = "null"
            }
            else{
                registrationsController.registrationID = selectedProspect._id
            }

            registrationsController.totalNumebrOfProspects = prospectDetails.registrationCount!
            
            
            self.navigationController?.pushViewController(registrationsController, animated: true)
        }
        else if(indexPath.row == 2){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let leadsController = storyboard.instantiateViewController(withIdentifier :"leadsAndOpportunities") as! LeadsAndOpportunitiesViewController
            leadsController.isLeads = true
            leadsController.tabID = 1
            leadsController.projectID = selectedProspect._id
            
            leadsController.prospectDetails = selectedProspect
            
//            let tempOpportunities  = selectedProspect.opportunities!
//            let totalOpsCount = tempOpportunities.callCount! + tempOpportunities.discountRequestCount! + tempOpportunities.notInterestedCount! + tempOpportunities.offerCount! + tempOpportunities.otherCount!
            

            let tempLeads = selectedProspect.leads!
            let leadsCount = tempLeads.callCount! + tempLeads.discountRequestCount! + tempLeads.notInterestedCount! + tempLeads.offerCount! + tempLeads.otherCount! + tempLeads.siteVisitCount!

            leadsController.leadsCount = leadsCount
            leadsController.projectName = selectedProspect.name!
            
            if(leadsCount == 0){
                self.showNoDataAlert()
                return
            }
            
            self.navigationController?.pushViewController(leadsController, animated: true)

        }
        else if(indexPath.row == 3){  // opportunities
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let leadsController = storyboard.instantiateViewController(withIdentifier :"leadsAndOpportunities") as! LeadsAndOpportunitiesViewController
            leadsController.isLeads = false
             leadsController.tabID = 1
            leadsController.projectID = selectedProspect._id
            
            leadsController.prospectDetails = selectedProspect

            leadsController.isLeads = false
            
            let tempOpportunities  = selectedProspect.opportunities!
            let totalOpsCount = tempOpportunities.callCount! + tempOpportunities.discountRequestCount! + tempOpportunities.notInterestedCount! + tempOpportunities.offerCount! + tempOpportunities.otherCount! + tempOpportunities.siteVisitCount!

//            let tempLeads = selectedProspect.leads!
//            let leadsCount = tempLeads.callCount! + tempLeads.discountRequestCount! + tempLeads.notInterestedCount! + tempLeads.offerCount! + tempLeads.otherCount!
            leadsController.leadsCount = totalOpsCount
            leadsController.projectName = selectedProspect.name!
            
            if(totalOpsCount == 0){
                self.showNoDataAlert()
                return
            }
            self.navigationController?.pushViewController(leadsController, animated: true)
        }
    }
    
    func showNoDataAlert(){
        
        let alertController = UIAlertController(title: "Empty", message: "No data avaiable", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            print("You've pressed default");
        }
        alertController.addAction(action1)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        currentTableViewDataSource = tableViewDataSource.filter({PROSPECT_DETAILS -> Bool in
            switch searchBar.selectedScopeButtonIndex {
            case 0 :
                if(searchText.isEmpty) {return true}
                return PROSPECT_DETAILS.name!.lowercased().contains(searchText.lowercased())
            default:
                return false
            }
        })
        if(currentTableViewDataSource.count == 0){
            currentTableViewDataSource.append(self.tableViewDataSource[0])
        }
        self.tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        switch selectedScope {
        case 0:
            currentTableViewDataSource = tableViewDataSource
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
        self.currentTableViewDataSource = self.tableViewDataSource
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
