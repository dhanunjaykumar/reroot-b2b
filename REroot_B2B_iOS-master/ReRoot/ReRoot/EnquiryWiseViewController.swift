//
//  EnquiryWiseViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 14/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import CoreData

class EnquiryWiseViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    var searchText = ""
    var selectedIndexPath : IndexPath!
    weak var delegate:ParallaxDelegate?
    var receiptEntriesFetchedResultsController : NSFetchedResultsController<ReceiptEntriesCount>!
    var isReceiptEntry : Bool = false
    var refreshControl: UIRefreshControl?
    @IBOutlet var tableView: UITableView!
    
    var tableViewDataSource : Array<PROSPECT_DETAILS> = []
    var expiredDataSource : Array<PROSPECT_DETAILS> = []
    var currentTableViewDataSource : Array<PROSPECT_DETAILS> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        let nib = UINib(nibName: "ProspectsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "prospectCell")
        
        let nib2 = UINib(nibName: "NewProspectsTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "newProspectCell")
        
        let nib1 = UINib(nibName: "ProspectsSubTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "prospectSubCell")
        
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 60))
        
        tableView.estimatedRowHeight = 330
        tableView.rowHeight = UITableView.automaticDimension

        if(isReceiptEntry){
            self.getReceiptEntriesCount()
            RRUtilities.sharedInstance.uploadScreenEvent(screenName: "ENQUIRY_WISE_RECEIPTENTRY")
        }
        else{
            self.getProspects()
            RRUtilities.sharedInstance.uploadScreenEvent(screenName: "ENQUIRY_WISE_RECEIPTENTRY")
        }
        
        self.addRefreshControl()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.reloadData()

    }
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(getProspects), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getReceiptEntrieCountFromServer), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_RECEIPT_ENTRIES), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getProspects), name: NSNotification.Name(rawValue: NOTIFICATIONS.PROSPECT_DATE_CHANGED), object: nil)
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
        }
        else{
            self.getProspects()
        }
        
    }
    func setUpNoDataLabel(){
        let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text          = "No data available"
        noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
        noDataLabel.textColor     = UIColor.black
        noDataLabel.textAlignment = .center
        self.tableView.backgroundView  = noDataLabel
        self.tableView.separatorStyle  = .none
    }
    //MARK:- Tableview Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidMove(scrollView: scrollView)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(isReceiptEntry){
            return 1
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

//        if (self.tableViewDataSource.count > 0)
//        {
//            tableView.backgroundView = nil
//        }
//        else
//        {
//            self.setUpNoDataLabel()
//        }
//        return self.tableViewDataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(isReceiptEntry){
            if((self.receiptEntriesFetchedResultsController.fetchedObjects?.count)! > 0){
                return self.receiptEntriesFetchedResultsController.fetchedObjects!.count
            }
            else{
                self.setUpNoDataLabel()
            }
        }
        if(currentTableViewDataSource.count > 0){
            let prospect = self.currentTableViewDataSource[section]
            
            if(prospect.shouldOpen!){
                return 1
            }else{
                if (self.currentTableViewDataSource.count > 0){
                    return 1
                }
                else{
                    let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                    noDataLabel.text          = "No data available"
                    noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
                    noDataLabel.textColor     = UIColor.black
                    noDataLabel.textAlignment = .center
                    self.tableView.backgroundView  = noDataLabel
                    self.tableView.separatorStyle  = .none
                    return 0
                }
            }
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectCell",
            for: indexPath) as! ProspectsTableViewCell
        
        if(isReceiptEntry){
            
            let receiptEntry = self.receiptEntriesFetchedResultsController.object(at: indexPath)
            
            cell.leftImageView.image = UIImage.init(named: "enquiry_icon")
            cell.prospectsCountLabel.text = String(format: "%d", receiptEntry.count)
            cell.widthOfApprovalsCountLabel.constant = 42
            cell.rightImageView.isHidden = true
            cell.prospectsCountLabel.isHidden = false
            cell.titleLabel.text = receiptEntry.id
            
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
            
            let projectDetails = self.currentTableViewDataSource[indexPath.section]
            cell.prospectDetails = self.currentTableViewDataSource[indexPath.section]
            cell.selectedIndexPath = indexPath
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
                cell.projectIconImageView.image = UIImage.init(named: "enquiry_icon")
            }
            
            let enqSource = RRUtilities.sharedInstance.model.getEnqSrcNameById(id: projectDetails._id ?? "")
            
            if let dName = enqSource?.displayName{
                cell.projectNameLabel.text = dName
            }
            else{
                cell.projectNameLabel.text = projectDetails.name
            }
            
            
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

            cell.totalProspectsCountLabel.text = String(format: "Total: %d", totalLeadsCount + totalOpportunitiesCount)
            cell.schduledProspectsCountLabel.text = String(format: "Scheduled: %d", (totalLeadsCount + totalOpportunitiesCount)-(projectDetails.leads!.notInterestedCount! + projectDetails.opportunities!.notInterestedCount!))

            if(expiredProspect != nil){
                let expiredLeadsCount = (expiredProspect.leads!.callCount! + expiredProspect.leads!.offerCount! + expiredProspect.leads!.siteVisitCount! + expiredProspect.leads!.discountRequestCount! + expiredProspect.leads!.otherCount! + expiredProspect.leads!.notInterestedCount!)
                let expiredOpportunitiesCount = (expiredProspect.opportunities!.callCount! + expiredProspect.opportunities!.offerCount! + expiredProspect.opportunities!.siteVisitCount! + expiredProspect.opportunities!.discountRequestCount! + expiredProspect.opportunities!.otherCount! + expiredProspect.opportunities!.notInterestedCount!)
                cell.expiredProspectsCountLabel.text = String(format: "Expired: %d",expiredLeadsCount + expiredOpportunitiesCount)
            }
            else{
                cell.expiredProspectsCountLabel.text = "Expired: 0"
            }

            return cell
        }
        
        
//        if(indexPath.section == 0){
//            cell.leftImageView.image = UIImage.init(named: "general_icon")
//        }
//        else{
//            cell.leftImageView.image = UIImage.init(named: "enquiry_icon")
//        }
//        if(indexPath.row == 0){
//
//            let projectDetails = self.self.currentTableViewDataSource[indexPath.section]
//
//            if(projectDetails.shouldOpen!){
//                cell.rightImageView.image = UIImage.init(named: "upArrow")
//            }
//            else{
//                cell.rightImageView.image = UIImage.init(named: "downArrow")
//            }
//            cell.titleLabel.text = projectDetails.name
//
//            cell.subContentView.layer.cornerRadius = 4
//            cell.subContentView.layer.borderWidth = 2
//            cell.subContentView.layer.borderColor = UIColor.clear.cgColor
//            cell.subContentView.layer.shadowRadius = 4
//            cell.subContentView.layer.masksToBounds = false
//            cell.subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
//            cell.subContentView.layer.shadowRadius = 2
//            cell.subContentView.layer.shadowOpacity = 0.3
//
//        }
//        else{
//
//            let prospectDetails = self.currentTableViewDataSource[indexPath.section]
//
//            let subCell : ProspectsSubTableViewCell = tableView.dequeueReusableCell(
//                withIdentifier: "prospectSubCell",
//                for: indexPath) as! ProspectsSubTableViewCell
//
//            if(indexPath.row == 1)
//            {
//                subCell.mImageView.image = UIImage.init(named: "registrations_icon")
//                subCell.prospectTypeLabel.text = "Registration"
//                subCell.prospectCountLabel.text = String(format: "%zd", (prospectDetails.registrationCount)!)
//            }
//            else if(indexPath.row == 2){
//                subCell.mImageView.image = UIImage.init(named: "leads_icon")
//                subCell.prospectTypeLabel.text = "Leads"
//                let tempLeads = prospectDetails.leads!
//                let leadsCount = tempLeads.callCount! + tempLeads.siteVisitCount! + tempLeads.discountRequestCount! + tempLeads.notInterestedCount! + tempLeads.offerCount! + tempLeads.otherCount!
//                subCell.prospectCountLabel.text = String(format: "%zd", leadsCount)
//            }
//            else if(indexPath.row == 3)
//            {
//                subCell.mImageView.image = UIImage.init(named: "opportunities_icon")
//                subCell.prospectTypeLabel.text = "Opportunities"
//                let tempOpportunities  = prospectDetails.opportunities!
//
//                let totalOpsCount = tempOpportunities.callCount! + tempOpportunities.siteVisitCount! + tempOpportunities.discountRequestCount! + tempOpportunities.notInterestedCount! + tempOpportunities.offerCount! + tempOpportunities.otherCount!
//
//                subCell.prospectCountLabel.text = String(format: "%zd", totalOpsCount)
//            }
//
//            return subCell
//        }
        
//        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(isReceiptEntry){
            let salesEntry = self.receiptEntriesFetchedResultsController.object(at: indexPath)
            self.selectedIndexPath = indexPath
            self.getReceiptEntries(selectedProjectId: salesEntry.id!)
            return
        }

        var selectedProspect = self.currentTableViewDataSource[indexPath.section]
        
        if(selectedProspect.shouldOpen!){
            selectedProspect.shouldOpen = false
        }
        else{
            selectedProspect.shouldOpen = true
        }
        self.currentTableViewDataSource[indexPath.section] = selectedProspect
        self.tableView.reloadData()
        return
        
        if(indexPath.row == 1){
            
            // take actions
            //RegistrationsViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let registrationsController = storyboard.instantiateViewController(withIdentifier :"registrations") as! RegistrationsViewController
            registrationsController.tabID = 3
            if(selectedProspect._id == nil){
                registrationsController.registrationID = "null"
            }else{
                registrationsController.registrationID = selectedProspect._id
            }
            registrationsController.totalNumebrOfProspects = selectedProspect.registrationCount!
            self.navigationController?.pushViewController(registrationsController, animated: true)
            
        }
        else if(indexPath.row == 2){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let leadsController = storyboard.instantiateViewController(withIdentifier :"leadsAndOpportunities") as! LeadsAndOpportunitiesViewController
            leadsController.isLeads = true
            leadsController.tabID = 3
            leadsController.projectID = selectedProspect._id
            
            leadsController.prospectDetails = selectedProspect
            self.navigationController?.pushViewController(leadsController, animated: true)
            
        }
        else if(indexPath.row == 3){  // opportunities
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let leadsController = storyboard.instantiateViewController(withIdentifier :"leadsAndOpportunities") as! LeadsAndOpportunitiesViewController
            
            leadsController.isLeads = false
            leadsController.tabID = 3
            leadsController.projectID = selectedProspect._id
            
            leadsController.prospectDetails = selectedProspect
            
            
            let tempOpportunities  = selectedProspect.opportunities!
            let totalOpsCount = tempOpportunities.callCount! + tempOpportunities.discountRequestCount! + tempOpportunities.notInterestedCount! + tempOpportunities.offerCount! + tempOpportunities.otherCount! + tempOpportunities.siteVisitCount!
            
            leadsController.leadsCount = totalOpsCount
            leadsController.projectName = selectedProspect.name!
            
            if(totalOpsCount == 0){
                self.showNoDataAlert()
                return
            }
            self.navigationController?.pushViewController(leadsController, animated: true)
        }
        else{
            self.currentTableViewDataSource[indexPath.section] = selectedProspect
            self.tableView.reloadData()
        }
    }
    @objc func showRegistrations(_ sender : UIGestureRecognizer){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registrationsController = storyboard.instantiateViewController(withIdentifier :"registrations") as! RegistrationsViewController
        registrationsController.viewType = VIEW_TYPE.REGISTRATIONS
        registrationsController.tabID = 3

        let selectedProject = self.currentTableViewDataSource[sender.view!.tag]

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
        leadsController.tabID = 3
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
         leadsController.tabID = 3
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
    func fetchAllReceiptEntries(){
        
        let request: NSFetchRequest<ReceiptEntriesCount> = ReceiptEntriesCount.fetchRequest()
        
        let sort = NSSortDescriptor(key: #keyPath(ReceiptEntriesCount.id), ascending: true)
        request.sortDescriptors = [sort]
        
        var predicate = NSPredicate(format: "tab == %d", 3)
        
        if(searchText.count > 0){
            predicate = NSPredicate(format: "id CONTAINS[c] %@",searchText)
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
        
        let urlString = String(format:RRAPI.API_GET_RECEIPT_COUNT,3,RRUtilities.sharedInstance.getServerDateStringFromDate(date: Date.init()))
        
        ServerAPIs.getReceiptEntrisCount(urlString: urlString,tab:3, completionHandler: { (response, error) in
            
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
        HUD.show(.progress)
        
        let urlString = String(format:RRAPI.API_GET_RECEIPT_COUNT,3,RRUtilities.sharedInstance.getServerDateStringFromDate(date: Date.init()))
//        print(urlString)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)

                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    self.refreshControl?.endRefreshing()
                    
                    let urlResult = try JSONDecoder().decode(RECEIPT_ENTRIES_COUNT_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        return
                    }
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.model.writeReceitEntriesCount(entriesCount: urlResult.result!, tab: 3, completionHandler: {responseObject, error in
                            DispatchQueue.main.async {
                                self.tableView.dataSource = self
                                self.tableView.delegate = self
                                self.fetchAllReceiptEntries()
                            }
                        })
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
        let urlSting =  String(format:RRAPI.API_GET_RECEIPT_ENTRIES,3,selectedProjectId)
//        print(urlSting)
        
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

                do{
                    let urlResult = try JSONDecoder().decode(RECEIPT_ENTRIES_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        return
                    }
                    if(urlResult.status == 1){
                        HUD.hide()
                        
                        RRUtilities.sharedInstance.model.writeReceiptEntries(receiptEntries: urlResult.receiptEntries!,tab: 3,completionHandler: {responseObject, error in
                            if(responseObject!){
                                DispatchQueue.main.async {
                                    let receiptsController = ReceiptEntriesViewController(nibName: "ReceiptEntriesViewController", bundle: nil)
                                    receiptsController.isPaymentWise = true
                                    receiptsController.tab = 3
                                    receiptsController.selectedProjectId = selectedProjectId
                                    receiptsController.selectedEntry = self.receiptEntriesFetchedResultsController.object(at: self.selectedIndexPath)
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
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                    self.tableView.reloadData()
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
        var urlSting =  String(format: RRAPI.PROSPECTS_TAB_COUNT, "3","1",RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate)
        if(UserDefaults.standard.bool(forKey: "Filter by Action Date")){
            urlSting.append("&filterByActionDate=1")
        }
//        print(urlSting)
        AF.request(urlSting, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
//                let str = String(decoding: response.data ?? Data(), as: UTF8.self)
//                print(str)
//
                
                do{
                    let urlResult = try JSONDecoder().decode(PROSPECTS.self, from: responseData)
                    print(urlSting)
                    self.tableViewDataSource = (urlResult.result?.counts)!
                    self.expiredDataSource = (urlResult.expired?.counts)!
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
                    
//                    tempSource1 = tempSource1.sorted(by: { $0.name ?? "" < $1.name ?? "" })
                    tempSource1.sort(by: { $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? "" })

                    self.tableViewDataSource = tempSource1
                    if !modifiedSource.isEmpty {
                        self.tableViewDataSource.insert(modifiedSource[0], at: 0)
                    }
                    self.refreshControl?.endRefreshing()
                    self.currentTableViewDataSource = self.tableViewDataSource
                    //                self.tableViewDataSource = modifiedSource
                    //                self.tableViewDataSource.insert(modifiedSource[0], at: 0)
                    self.tableView?.delegate = self
                    self.tableView?.dataSource = self
                    self.tableView?.reloadData()
                    HUD.hide()
                    
                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                    self.refreshControl?.endRefreshing()
                    self.tableView?.reloadData()
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
                self.refreshControl?.endRefreshing()
                self.tableView?.reloadData()
                break
            }
        }
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

//        currentTableViewDataSource = tableViewDataSource.filter({PROSPECT_DETAILS -> Bool in
//            switch searchBar.selectedScopeButtonIndex {
//            case -1 : fallthrough
//            case 0 :
//                if(searchText.isEmpty) {return true}
//                return PROSPECT_DETAILS.name!.lowercased().contains(searchText.lowercased())
//            default:
//                return false
//            }
//        })
//        if(currentTableViewDataSource.count == 0){
//            currentTableViewDataSource.append(self.tableViewDataSource[0])
//        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension EnquiryWiseViewController : ClickDelegate{
    func didSelectProspectType(indexPath : IndexPath,titleName : String,count : Int,statusID : Int) {

        if(count == 0){
            self.showNoDataAlert()
            return
        }

        let prospectsController = ProspectsViewController(nibName: "ProspectsViewController", bundle:nil)
        prospectsController.statusID = statusID
        let projectDetails = self.currentTableViewDataSource[indexPath.section]
        prospectsController.projectId = projectDetails._id ?? ""
        prospectsController.titleString =  titleName
        prospectsController.tabID = 3
        prospectsController.isFromEnquiry = true
        self.navigationController?.pushViewController(prospectsController, animated: true)
    }
}
