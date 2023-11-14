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
import CoreData

protocol ParallaxDelegate: class {
    
    func scrollViewDidMove(scrollView : UIScrollView)
    
}
class ProjectWiseViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var searchText : String = ""
    var receiptEntriesFetchedResultsController : NSFetchedResultsController<ReceiptEntriesCount>!
    var isReceiptEntry : Bool = false
    @IBOutlet var tableView: UITableView!
    weak var delegate:ParallaxDelegate?
    var tableViewDataSource : Array<PROSPECT_DETAILS> = []
    var expiredDataSource : Array<PROSPECT_DETAILS> = []
    var receiptEntryTableViewDataSource : [RECEIPT_ENTRIES] = []
    var currentTableViewDataSource : Array<PROSPECT_DETAILS> = []
    var refreshControl: UIRefreshControl?
    var selectedIndexes : [IndexPath] = []
    var selectedSections : Dictionary<Int,Bool> = [:]
    var selectedRows : [Int] = []
    var selectedIndexPath : IndexPath!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: "ProspectsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "prospectCell")
        
        let nib2 = UINib(nibName: "NewProspectsTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "newProspectCell")
        
        let nib1 = UINib(nibName: "ProspectsSubTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "prospectSubCell")
        
        tableView.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 60))
        
        tableView.estimatedRowHeight = 330
        tableView.rowHeight = UITableView.automaticDimension

        NotificationCenter.default.addObserver(self, selector: #selector(getProspects), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getReceiptEntrieCountFromServer), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_RECEIPT_ENTRIES), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getProspects), name: NSNotification.Name(rawValue: NOTIFICATIONS.PROSPECT_DATE_CHANGED), object: nil)

        if(isReceiptEntry){
            self.getReceiptEntriesCount()
            RRUtilities.sharedInstance.uploadScreenEvent(screenName: "ReceiptEntry")
        }else{
            self.getProspects()
            tableView.dataSource = self
            tableView.delegate = self
            RRUtilities.sharedInstance.uploadScreenEvent(screenName: "ProjectWise")
        }
        self.addRefreshControl()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidMove(scrollView: scrollView)
    }
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    @objc func refreshList() {
        
        if(isReceiptEntry){
            self.getReceiptEntriesCount()
        }else{
            self.getProspects()
        }
    }
    func fetchAllReceiptEntries(){
        
        let request: NSFetchRequest<ReceiptEntriesCount> = ReceiptEntriesCount.fetchRequest()
        
        let sort = NSSortDescriptor(key: #keyPath(ReceiptEntriesCount.name), ascending: true)
        request.sortDescriptors = [sort]
        
        var predicate = NSPredicate(format: "tab == %d", 1)
        
        if(searchText.count > 0){
            predicate = NSPredicate(format: "tab == %d AND name CONTAINS[c] %@", 1,searchText)
        }
        
        request.predicate = predicate

        receiptEntriesFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try receiptEntriesFetchedResultsController.performFetch()
            self.tableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    @objc func getReceiptEntrieCountFromServer(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.refreshControl?.endRefreshing()
            return
        }
        
        let urlString = String(format:RRAPI.API_GET_RECEIPT_COUNT,1,RRUtilities.sharedInstance.getServerDateStringFromDate(date: Date.init()))
        
        ServerAPIs.getReceiptEntrisCount(urlString: urlString,tab:1, completionHandler: { (response, error) in
            
            if(response){
                DispatchQueue.main.async {
                    self.fetchAllReceiptEntries()
                }
            }
        })
    }
    @objc func getReceiptEntriesCount(){
        
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
        
        self.refreshControl?.beginRefreshing()
        HUD.show(.progress, onView: self.view)
        
        let urlString = String(format:RRAPI.API_GET_RECEIPT_COUNT,1,RRUtilities.sharedInstance.getServerDateStringFromDate(date: Date.init()))
        print(urlString)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                self.refreshControl?.endRefreshing()
                                
                HUD.hide()
                do{
                    let urlResult = try JSONDecoder().decode(RECEIPT_ENTRIES_COUNT_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        return
                    }
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.model.writeReceitEntriesCount(entriesCount: urlResult.result!, tab: 1, completionHandler: {responseObject, error in
                            DispatchQueue.main.async {
                                self.tableView.dataSource = self
                                self.tableView.delegate = self
                                self.fetchAllReceiptEntries()
                            }
                        })
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
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
    @objc func getReceiptEntries(selectedProjectId : String){
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
        
        self.refreshControl?.beginRefreshing()
        HUD.show(.progress)
        let urlSting =  String(format:RRAPI.API_GET_RECEIPT_ENTRIES,1,selectedProjectId)
        print(urlSting)
        
        AF.request(urlSting, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                self.refreshControl?.endRefreshing()
                HUD.hide()

                do{
                    let urlResult = try JSONDecoder().decode(RECEIPT_ENTRIES_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        return
                    }
                    if(urlResult.status == 1){

                        RRUtilities.sharedInstance.model.writeReceiptEntries(receiptEntries: urlResult.receiptEntries!,tab: 1,completionHandler: {responseObject, error in
                            if(responseObject != nil && responseObject!){
                                DispatchQueue.main.async {
                                    print("ENTERED INTO ENTRIES VIEW **")
                                    let receiptsController = ReceiptEntriesViewController(nibName: "ReceiptEntriesViewController", bundle: nil)
                                    receiptsController.isProjectWise = true
                                    receiptsController.selectedProjectId = selectedProjectId
                                    receiptsController.selectedEntry = self.receiptEntriesFetchedResultsController.object(at: self.selectedIndexPath)
                                    receiptsController.tab = 1
                                    self.navigationController?.pushViewController(receiptsController, animated: true)
                                    return
                                }
                            }
                            else{
                                HUD.flash(.label("Something went wrong please try again"), delay: 1.0)
                            }
                        })
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
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
    @objc func getProspects(){
        
        if(RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
            return
        }
        
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
        
        self.refreshControl?.beginRefreshing()
        HUD.show(.progress)
        var urlSting = String(format: RRAPI.PROSPECTS_TAB_COUNT, "1","1",RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate) //RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate
        
        if(UserDefaults.standard.bool(forKey: "Filter by Action Date")){
            urlSting.append("&filterByActionDate=1")
        }
        print(urlSting)
        
        AF.request(urlSting, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                
                let str = String(decoding: response.data ?? Data(), as: UTF8.self)
                print(str)

                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                HUD.hide()
                // make tableview data
                do{
                    let urlResult = try JSONDecoder().decode(PROSPECTS.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        return
                    }
                    self.tableViewDataSource.removeAll()
                    self.currentTableViewDataSource.removeAll()
                    self.tableView.reloadData()
                    self.tableViewDataSource = (urlResult.result?.counts) ?? []
                    self.expiredDataSource = (urlResult.expired?.counts) ?? []
                    
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
                    
//                    print(modifiedSource)
                    var tempSource1 = modifiedSource
                    if !tempSource1.isEmpty {
                        tempSource1.remove(at: 0)
                    }
                    
                    //                tempSource1 = tempSource1.sorted(by: { UIContentSizeCategory(rawValue: $0.name!) > $1.name })
                    
//                    tempSource1 = tempSource1.sorted(by: { $0.name! < $1.name! })
                    tempSource1.sort(by: { $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? "" })

                    self.refreshControl?.endRefreshing()
                    
                    self.tableViewDataSource = tempSource1
                    if !modifiedSource.isEmpty {
                        self.tableViewDataSource.insert(modifiedSource[0], at: 0)
                    }
                    self.currentTableViewDataSource.removeAll()
                    self.currentTableViewDataSource.append(contentsOf: self.tableViewDataSource)
//                    let temper = self.currentTableViewDataSource.filter({$0._id == "" || $0._id == nil})
//                    if(temper.count > 0){
//                        print(temper)
//                    }
                    DispatchQueue.main.async {
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
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
    func setUpNoDataLabel(){
        let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text          = "No data available"
        noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
        noDataLabel.textColor     = UIColor.black
        noDataLabel.textAlignment = .center
        tableView.backgroundView  = noDataLabel
        tableView.separatorStyle  = .none
    }
    //MARK :- TABLEVIEW DELEGATE
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(isReceiptEntry){
            if((receiptEntriesFetchedResultsController.sections?.count)! > 0){
                tableView.backgroundView = nil
                return receiptEntriesFetchedResultsController.sections!.count
            }
            else{
                self.setUpNoDataLabel()
            }
            return 0
        }
        if (self.currentTableViewDataSource.count > 0)
        {
            tableView.backgroundView = nil
        }
        else
        {
            self.setUpNoDataLabel()
        }
        return self.currentTableViewDataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        let prospect = self.currentTableViewDataSource[section]
        
        if(isReceiptEntry){
            if((self.receiptEntriesFetchedResultsController.fetchedObjects?.count)! > 0){
                return (self.receiptEntriesFetchedResultsController.fetchedObjects?.count)!
            }
            return 0
        }
        
        if(selectedSections.keys.count > 0)//(prospect.shouldOpen!){
        {
            if(selectedSections[section] != nil)
            {
                if(selectedSections[section]!){
                    return 4
                }
                else{
                    return 1
                }
            }
            else{
                return 1
            }
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(isReceiptEntry){
            
            let cell : ProspectsTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "prospectCell",
                for: indexPath) as! ProspectsTableViewCell

//            let sectionInfo = self.receiptEntriesFetchedResultsController!.sections![indexPath.section]
            let receiptEntry = self.receiptEntriesFetchedResultsController.object(at: indexPath)
            
            cell.leftImageView.image = UIImage.init(named: "project_icon")
            cell.prospectsCountLabel.text = String(format: "%d", receiptEntry.count)
            cell.widthOfApprovalsCountLabel.constant = 42
            cell.rightImageView.isHidden = true
            cell.prospectsCountLabel.isHidden = false
            cell.titleLabel.text = receiptEntry.name
            
            //RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: receiptEntry.project!)?.name ?? ""
            
            cell.subContentView.layer.cornerRadius = 4
            cell.subContentView.layer.borderWidth = 2
            cell.subContentView.layer.borderColor = UIColor.clear.cgColor
            cell.subContentView.layer.shadowRadius = 4
            cell.subContentView.layer.masksToBounds = false
            cell.subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.subContentView.layer.shadowRadius = 2
            cell.subContentView.layer.shadowOpacity = 0.3

            return cell
            
        }
        else{
            let cell : NewProspectsTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "newProspectCell",
                for: indexPath) as! NewProspectsTableViewCell
            
            cell.selectedIndexPath = indexPath
            let projectDetails = self.currentTableViewDataSource[indexPath.section]
            cell.prospectDetails = projectDetails
            let expiredOne : [PROSPECT_DETAILS] = self.expiredDataSource.filter({$0._id == cell.prospectDetails._id})
            var expiredProspect : PROSPECT_DETAILS! = nil
            if(expiredOne.count == 1){
                expiredProspect = expiredOne[0]
                cell.expiredPropsectDetails = expiredOne[0]
            }
            else{
                cell.expiredPropsectDetails = nil
            }
            
            cell.delegate = self
                
            if(indexPath.section == 0){
                cell.projectIconImageView.image = UIImage.init(named: "general_icon")
            }
            else{
                cell.projectIconImageView.image = UIImage.init(named: "project_icon")
            }
            cell.projectNameLabel.text = projectDetails.name
            
            if(projectDetails.shouldOpen ?? false){
                cell.roundView2.isHidden = false
                cell.heightOfSubContentView.constant = 337
                cell.arrowImageView.image = UIImage.init(named: "upArrow")
                if #available(iOS 11.0, *) {
                    cell.roundView1.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
                } else {
                    // Fallback on earlier versions
                }
            }
            else{
                cell.arrowImageView.image = UIImage.init(named: "downArrow")
                if #available(iOS 11.0, *) {
                    cell.roundView1.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
                } else {
                    // Fallback on earlier versions
                }
                cell.roundView2.isHidden = true
                cell.heightOfSubContentView.constant = 190
            }
            
            cell.subView.layoutIfNeeded()
            
            let gesture1 = UITapGestureRecognizer.init(target: self, action: #selector(showRegistrations(_:)))
            cell.registrationsView.addGestureRecognizer(gesture1)
            cell.registrationsView.tag = indexPath.section
            
            let gesture2 = UITapGestureRecognizer.init(target: self, action: #selector(showLeads(_:)))
            cell.leadsView.addGestureRecognizer(gesture2)
            cell.leadsView.tag = indexPath.section
            
            let gesture3 = UITapGestureRecognizer.init(target: self, action: #selector(showOpportunities(_:)))
            cell.opportunitiesView.addGestureRecognizer(gesture3)
            cell.opportunitiesView.tag = indexPath.section

            
            let totalLeadsCount = (projectDetails.leads!.callCount! + projectDetails.leads!.offerCount! + projectDetails.leads!.siteVisitCount! + projectDetails.leads!.discountRequestCount! + projectDetails.leads!.otherCount! + projectDetails.leads!.notInterestedCount!)
            let totalOpportunitiesCount = (projectDetails.opportunities!.callCount! + projectDetails.opportunities!.offerCount! + projectDetails.opportunities!.siteVisitCount! + projectDetails.opportunities!.discountRequestCount! + projectDetails.opportunities!.otherCount! + projectDetails.opportunities!.notInterestedCount!)
            
            cell.leadsCountLabel.text = String(format: "%d", totalLeadsCount)
            cell.opportunitiesCountLabel.text = String(format: "%d", totalOpportunitiesCount)
            cell.registrationsCountLabel.text = String(format: "%d", projectDetails.registrationCount!)

            if(expiredProspect != nil){
                let expiredLeadsCount = (expiredProspect.leads!.callCount! + expiredProspect.leads!.offerCount! + expiredProspect.leads!.siteVisitCount! + expiredProspect.leads!.discountRequestCount! + expiredProspect.leads!.otherCount! + expiredProspect.leads!.notInterestedCount!)
                let expiredOpportunitiesCount = (expiredProspect.opportunities!.callCount! + expiredProspect.opportunities!.offerCount! + expiredProspect.opportunities!.siteVisitCount! + expiredProspect.opportunities!.discountRequestCount! + expiredProspect.opportunities!.otherCount! + expiredProspect.opportunities!.notInterestedCount!)
                cell.expiredProspectsCountLabel.text = String(format: "Expired: %d",expiredLeadsCount + expiredOpportunitiesCount)
            }
            else{
                cell.expiredProspectsCountLabel.text = "Expired: 0"
            }
            cell.schduledProspectsCountLabel.text = String(format: "Scheduled: %d", (totalLeadsCount + totalOpportunitiesCount) - (projectDetails.leads!.notInterestedCount! + projectDetails.opportunities!.notInterestedCount!))
            cell.totalProspectsCountLabel.text = String(format: "Total: %d", totalLeadsCount + totalOpportunitiesCount)
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if(isReceiptEntry){
            self.selectedIndexPath = indexPath
            let projectEntry = self.receiptEntriesFetchedResultsController.object(at: indexPath)
            self.getReceiptEntries(selectedProjectId: projectEntry.id!)
            return
        }
        
        let cell : NewProspectsTableViewCell = tableView.cellForRow(at: indexPath) as! NewProspectsTableViewCell

        cell.subView.layoutIfNeeded()
        cell.contentView.layoutIfNeeded()
        cell.contentView.reloadInputViews()
        
        var selectedProspect = self.currentTableViewDataSource[indexPath.section]
        
        if(selectedProspect.shouldOpen!){
            selectedProspect.shouldOpen = false
        }
        else{
            selectedProspect.shouldOpen = true
        }
        self.currentTableViewDataSource[indexPath.section] = selectedProspect
        tableView.reloadData()
        
        return

    }
    @objc func showRegistrations(_ sender : UIGestureRecognizer){
        
        
        let selectedProject = self.currentTableViewDataSource[sender.view!.tag]
        
        if(selectedProject.registrationCount! == 0){
            self.showNoDataAlert()
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registrationsController = storyboard.instantiateViewController(withIdentifier :"registrations") as! RegistrationsViewController
        registrationsController.viewType = VIEW_TYPE.REGISTRATIONS
        registrationsController.tabID = 1


        if(selectedProject._id == nil){
            registrationsController.registrationID = "null"
        }
        else{
            registrationsController.registrationID = selectedProject._id
        }

        registrationsController.totalNumebrOfProspects = selectedProject.registrationCount!


        self.navigationController?.pushViewController(registrationsController, animated: true)

    }
    @objc func showLeads(_ sender : UIGestureRecognizer){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leadsController = storyboard.instantiateViewController(withIdentifier :"leadsAndOpportunities") as! LeadsAndOpportunitiesViewController
        
        let selectedProject = self.currentTableViewDataSource[sender.view!.tag]
        
        leadsController.isLeads = true
        leadsController.tabID = 1
        leadsController.projectID = selectedProject._id
        
        leadsController.prospectDetails = selectedProject
        
        let tempLeads = selectedProject.leads!
        let leadsCount = tempLeads.callCount! + tempLeads.discountRequestCount! + tempLeads.notInterestedCount! + tempLeads.offerCount! + tempLeads.otherCount! + tempLeads.siteVisitCount!
        
        leadsController.leadsCount = leadsCount
        leadsController.projectName = selectedProject.name!
        
        if(leadsCount == 0){
            self.showNoDataAlert()
            return
        }
        
        self.navigationController?.pushViewController(leadsController, animated: true)
    }
    @objc func showOpportunities(_ sender : UIGestureRecognizer){
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leadsController = storyboard.instantiateViewController(withIdentifier :"leadsAndOpportunities") as! LeadsAndOpportunitiesViewController
        
        let selectedProject = self.currentTableViewDataSource[sender.view!.tag]

        leadsController.isLeads = false
         leadsController.tabID = 1
        leadsController.projectID = selectedProject._id
        
        leadsController.prospectDetails = selectedProject
        
        leadsController.isLeads = false
        
        let tempOpportunities  = selectedProject.opportunities!
        let totalOpsCount = tempOpportunities.callCount! + tempOpportunities.discountRequestCount! + tempOpportunities.notInterestedCount! + tempOpportunities.offerCount! + tempOpportunities.otherCount! + tempOpportunities.siteVisitCount!

        leadsController.leadsCount = totalOpsCount
        leadsController.projectName = selectedProject.name!
        
        if(totalOpsCount == 0){
            self.showNoDataAlert()
            return
        }
        self.navigationController?.pushViewController(leadsController, animated: true)

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
        if(isReceiptEntry){
            self.searchText = searchText
            self.fetchAllReceiptEntries()
            return
        }
        
        currentTableViewDataSource = tableViewDataSource.filter({ (($0.name?.localizedCaseInsensitiveContains(searchText))!) })
        
        if(currentTableViewDataSource.count == 0){
            if(self.tableViewDataSource.count > 0){
                currentTableViewDataSource = self.tableViewDataSource
            }
        }
        self.tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        if(isReceiptEntry){
            self.searchText = ""
            self.fetchAllReceiptEntries()
            return
        }
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
        
        if(isReceiptEntry){
            self.searchText = ""
            self.fetchAllReceiptEntries()
            return
        }

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
extension ProjectWiseViewController : ClickDelegate{
        func didSelectProspectType(indexPath : IndexPath,titleName : String,count : Int,statusID : Int){
        
        if(count == 0){
            self.showNoDataAlert()
            return
        }
        
        let prospectsController = ProspectsViewController(nibName: "ProspectsViewController", bundle:nil)
        prospectsController.statusID = statusID
        let projectDetails = self.currentTableViewDataSource[indexPath.section]
        prospectsController.titleString = titleName
        prospectsController.projectId = projectDetails._id ?? ""
        prospectsController.tabID = 1
        prospectsController.isFromProjectSelection = true
        self.navigationController?.pushViewController(prospectsController, animated: true)

    }
    
}
