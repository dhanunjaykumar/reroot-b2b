//
//  ProspectsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 13/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PKHUD
import FloatingPanel

class ProspectsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,FloatingPanelControllerDelegate {
  
    var isFromUserTab = false
    var isFromProjectSelection = false
    var isFromSalesPerson = false
    var isFromEnquiry = false
    var isFromIdle = false
    
    var isFromDiscountView = false
    @IBOutlet var filterButton: UIButton!
    var statusID : Int!
    var tabID : Int!
    var noDataLabel: UILabel!
    var statusChangeView : StatusChangeView! = nil
    var selectedProspect : REGISTRATIONS_RESULT!
    var selectedProspectRow : Int = -1
    @IBOutlet var titleInfoView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    var titleString : String!
    var refreshControl: UIRefreshControl?
    let fpc = FloatingPanelController()
    
    var dateFormatter = DateFormatter()

//    var tableViewDataSource : [String] = []
    
    var tableViewDataSource : [REGISTRATIONS_RESULT] = []
    var currentTableViewDataSource : [REGISTRATIONS_RESULT] = []
    
    var projects = Set<String>()
    var salesPersons = Set<String>()
    var enquirySources = Set<String>()
    var notInterestedReasons = Set<String>()
    
    var selectedProjectsArray : [String] = []
    var selectedSalesPersonsArray : [String] = []
    var selectedStatsuArray : [String] = []
    var selectedOverDueDataArray : [String] = []
    var selectedFloorPremiums : [String] = []
    var selectedOtherPremiums : [String] = []
    var selectedMiscArray : [String] = []
    var selectedEnquirySourcesArray : [String] = []
    var selectedNotInterestedReasonsArray : [String] = []

    var isLeadsAvailable : Bool = false
    var isOpportunitiesAvailable : Bool = false

    var projectId : String? = nil

    @IBOutlet var tableView: UITableView!
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleInfoView.clipsToBounds = true
        
        titleInfoView.layer.masksToBounds = false
        titleInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        titleInfoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleInfoView.layer.shadowOpacity = 0.4
        titleInfoView.layer.shadowRadius = 1.0
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleInfoView)
        //        titleInfoView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black

        NotificationCenter.default.addObserver(self, selector: #selector(popMe), name: NSNotification.Name(rawValue: "popFromProspects"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getProspects), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popControllers), name: NSNotification.Name(rawValue: NOTIFICATIONS.POP_CONTROLLERS), object: nil)

        titleLabel.text = String(format: "%@", titleString)
        
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let nib = UINib(nibName: "ProspectTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "commonPropspectCell")
        
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        searchBar.delegate = self
    
        self.getProspects()

        self.addRefreshControl()

        
    }
    @objc func getProspects(){
        
        self.refreshControl?.beginRefreshing()
        ServerAPIs.getProspectAccordingToStatus(status:statusID,tabId: self.tabID, projectID: self.projectId, completionHandler: { [unowned self] (responseObject, error) in
            if(responseObject?.status == 1){
                DispatchQueue.main.async {
                    
                    
                    self.tableViewDataSource = (responseObject?.result)!
                    var tempArray = self.tableViewDataSource
//                    tempArray.sort(by: { $0.type < $1.actionInfo?.pdate ?? "" })
                    
                    if(self.projectId?.count == 0){
                        tempArray = self.tableViewDataSource
                        tempArray = self.tableViewDataSource.filter( { $0.project?._id == "" || $0.project?._id == nil } )
                    }
                    else{
                        if(self.isFromProjectSelection){
                            tempArray = tempArray.filter( { $0.project?._id == self.projectId } )
                        }
                        else if(self.isFromSalesPerson){
                            tempArray = tempArray.filter( { $0.salesPerson?._id == self.projectId } )
                        }
                        else if(self.isFromEnquiry){
                            tempArray = tempArray.filter( { $0.enquirySource == self.projectId } )
                        }
                        else if(self.isFromIdle){
                            tempArray = tempArray.filter( { $0.salesPerson?._id == self.projectId } )
                        }
                    }
                                        
                    tempArray.sort(by: { $0.type ?? "" < $1.type ?? "" })
                    var leadsArray = tempArray.filter({ $0.type == "L" })
                    var oppsArray = tempArray.filter({ $0.type == "O" })
//                    tempArray.sort(by: { $0.actionInfo?.date ?? "" < $1.actionInfo?.date ?? "" })
                    leadsArray.sort(by: { $0.actionInfo?.date ?? "" < $1.actionInfo?.date ?? "" })
                    oppsArray.sort(by: { $0.actionInfo?.date ?? "" < $1.actionInfo?.date ?? "" })

                    tempArray.removeAll()
                    if(leadsArray.count > 0){
                        self.isLeadsAvailable = true
                    }
                    if(oppsArray.count > 0){
                        self.isOpportunitiesAvailable = true
                    }
                    tempArray.append(contentsOf: leadsArray)
                    tempArray.append(contentsOf: oppsArray)
                        
                    self.tableViewDataSource = tempArray
                    self.currentTableViewDataSource = self.tableViewDataSource
                    
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                    self.setProspectsCount()
                    self.setUpFiltersDataSource()
                }
            }
            else{
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                self.setProspectsCount()
            }
            self.refreshControl?.endRefreshing()
        })
    }
    func setUpFiltersDataSource(){
        
        salesPersons.insert("Super Admin")
        var counter = 0
        for tempProspect in self.tableViewDataSource{
            counter += 1
            if(tempProspect.project?.name != nil){
                projects.insert(tempProspect.project!.name!)
            }
            if(tempProspect.salesPerson?.userInfo?.name != nil){
                salesPersons.insert((tempProspect.salesPerson!.userInfo?.name)!)
            }
            if(tempProspect.enquirySource != nil){
                enquirySources.insert(tempProspect.enquirySource!)
            }
            if(self.statusID == 6 && tempProspect.action?.label != nil){
                self.notInterestedReasons.insert(tempProspect.action?.label ?? "")
            }
            
            
//            else{
//                print("No Sales person mean super admin")
//            }
        }
        print(counter)
        print(salesPersons)
        print(notInterestedReasons)
        print("")
    }
    func setProspectsCount()
    {
        titleLabel.text = String(format: "%@ (%d)", titleString,self.currentTableViewDataSource.count)
    }
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    @objc func refreshList() {
//        self.getProspectsAsPerStatus()
//        self.resetFilters()
        self.getProspects()
    }
    @objc func showStatusChangeView(_ sender : UILongPressGestureRecognizer){

        if sender.state == .began {
            
            self.statusChangeView = (StatusChangeView.instanceFromNib() as! StatusChangeView)
            let tag = sender.view?.tag
            
            selectedProspectRow = tag!
            
            let prospectDetails  = self.currentTableViewDataSource[tag!]
            self.view.addSubview(self.statusChangeView)
            self.statusChangeView.alpha = 0.0
            let attributedString = NSAttributedString(
                string:"Change",
                attributes:[
                    NSAttributedString.Key.font :UIFont.init(name: "Montserrat-Medium", size: 14) as Any,
                    NSAttributedString.Key.foregroundColor : UIColor.hexStringToUIColor(hex: "358ED7"),
                    NSAttributedString.Key.underlineStyle:1.0
                ])
            
            statusChangeView.statusChangeButton.setAttributedTitle(attributedString, for: .normal)
            statusChangeView.salesPersonChangeButton.setAttributedTitle(attributedString, for: .normal)
            
            if(tabID != 2){
                statusChangeView.HLineView.isHidden = true
                statusChangeView.salesPersonView.isHidden = true
                statusChangeView.salesPersonViewHeight.constant = 0
                statusChangeView.frame = CGRect(x: 0, y: self.view.frame.height - 70, width: self.view.frame.size.width, height: 50)
            }
            else{ //Sales person wise
                statusChangeView.frame = CGRect(x: 0, y: self.view.frame.height - 120, width: self.view.frame.size.width, height: 101)
                
                statusChangeView.salesPersonChangeButton.addTarget(self, action:#selector(showSalePersonChangeView), for: .touchUpInside)
                statusChangeView.salesPersonChangeButton.tag = tag!
                
                if(prospectDetails.salesPerson?.userInfo?.name != nil){
                    statusChangeView.salesPersonNameLabel.text = prospectDetails.salesPerson?.userInfo?.name
                }
                else{
                    statusChangeView.salesPersonNameLabel.text = "Super Admin"
                }
            }
            statusChangeView.subContentView.layer.cornerRadius = 8
            
            UIView.animate(withDuration: 1.0, animations: {
                self.statusChangeView.alpha = 1.0
            })
            
            if(prospectDetails.action != nil){
                statusChangeView.currentStatusLabel.text = prospectDetails.action?.label
            }
            else{
                statusChangeView.currentStatusLabel.text = "None"
            }
            
            statusChangeView.statusChangeButton.addTarget(self, action:#selector(showStatusHandler), for: .touchUpInside)
            statusChangeView.statusChangeButton.titleLabel!.font = UIFont(name: "Montserrat-Regular", size: 18)
            statusChangeView.salesPersonChangeButton.titleLabel!.font = UIFont(name: "Montserrat-Regular", size: 18)
            statusChangeView.statusChangeButton.tag = tag!
            statusChangeView.salesPersonChangeButton.tag = tag!
            
            let tapStatusGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showStatusHandler))
            let tapSalesGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showSalePersonChangeView))
            statusChangeView.statusChangeView.addGestureRecognizer(tapStatusGuesture)
            statusChangeView.salesPersonView.addGestureRecognizer(tapSalesGuesture)
            self.selectedProspect = prospectDetails
            self.tableView.reloadData()

            
        }
    }
    @objc func showSalePersonChangeView(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let salesPersonChangeController = storyboard.instantiateViewController(withIdentifier :"salesPersonChange") as! SalesPersonChangeViewController
        
        if(selectedProspect.type == "L"){
            salesPersonChangeController.viewType = VIEW_TYPE.LEADS
        }
        else{
            salesPersonChangeController.viewType = VIEW_TYPE.OPPORTUNITIES
        }
        
        salesPersonChangeController.selectedProspect = self.currentTableViewDataSource[selectedProspectRow]
        
        self.present(salesPersonChangeController, animated: true, completion: nil)
        
    }
    @objc func showStatusHandler(){
        
        let prospectDetails  = self.currentTableViewDataSource[selectedProspectRow]
        
        if(self.statusID == 6){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
            //            print(selectedStatus)
            //            leadsPopUpController.prevSelectedStatus = selectedStatus
            leadsPopUpController.prospectDetails = prospectDetails
            leadsPopUpController.selectedReasonIndex = selectedProspectRow
            leadsPopUpController.selctedScheduleCallOption = selectedProspectRow
            leadsPopUpController.isFromRegistrations = false
            leadsPopUpController.isFromDiscountView = self.isFromDiscountView
            leadsPopUpController.tabId = self.tabID
            leadsPopUpController.statusID = self.statusID
            if((selectedProspect.type == "L")){
                leadsPopUpController.viewType = VIEW_TYPE.LEADS
            }
            else{
                leadsPopUpController.viewType = VIEW_TYPE.OPPORTUNITIES
            }
            self.present(leadsPopUpController, animated: true, completion: nil)
            return

        }
        
        if(prospectDetails.action?.id != nil){  // launch new navigation controller?
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = false
            statusController.statusID = self.statusID
            if(selectedProspect.type == "L"){
                statusController.viewType = VIEW_TYPE.LEADS
                statusController.tabID = 2
            }
            else{
                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
                statusController.tabID = 3
            }
            //        self.navigationController?.pushViewController(statusController, animated: true)
            self.present(statusController, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = false
            statusController.statusID = self.statusID
            
            if(selectedProspect.type == "L"){
                statusController.viewType = VIEW_TYPE.LEADS
                statusController.tabID = 2
            }
            else{
                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
                statusController.tabID = 3
            }
            self.present(statusController, animated: true, completion: nil)
        }
    }
    // MARK: -  METHOds
    @objc func popMe(){
        self.navigationController?.popViewController(animated: false)
    }
    @objc func popControllers(){
        DispatchQueue.main.async {
//            self.navigationController?.popViewController(animated: false)
            self.dismiss(animated: true, completion: nil)
//            self.navigationController?.popViewController(animated: true)
            self.hideStatusChangeView()
            self.selectedProspectRow = -1
            self.tableView.reloadData()
        }
    }
    func hideStatusChangeView(){
        if(self.statusChangeView != nil){
            self.statusChangeView.isHidden = true
            self.statusChangeView.removeFromSuperview()
            self.statusChangeView = nil
        }
    }
    @objc func openWhatsapp(_ sender : UIButton){
        let prospect  = self.currentTableViewDataSource[sender.tag]
        var tempCode = ""
        if let phoneCode = prospect.userPhoneCode{
            if(phoneCode.count > 0){
                tempCode = phoneCode
            }
            else
            {
                tempCode = "91"
            }
        }
        else{
            tempCode = "91"
        }
        let phone  = (prospect.userPhone!.count > 10) ? prospect.userPhone! : tempCode + prospect.userPhone!
        guard let number = URL(string: String(format: "https://wa.me/%@?text=%@", phone,""))else{return}
        UIApplication.shared.open(number)
    }
    @objc func openDialer(_ sender : UIButton){
        
        let prospect  = self.currentTableViewDataSource[sender.tag]
        guard let number = prospect.userPhone else { return } //URL(string: "tel://" + prospect.userPhone!)

        if(prospect.viewType == 1){
            ServerAPIs.prospectCall(viewType:VIEW_TYPE.REGISTRATIONS.rawValue , prospectId: prospect._id!, custNumber: number, exeNumber: prospect.salesPerson?.phone ?? "",completion: { result in
                switch result {
                case .success(let result):
                    HUD.flash(.label(result.msg), delay: 2.0)
                case .failure( _):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    UIApplication.shared.open(url)
                }
            })
        }
        else if(prospect.viewType == 2){
            ServerAPIs.prospectCall(viewType:VIEW_TYPE.LEADS.rawValue , prospectId: prospect._id!, custNumber: number, exeNumber: prospect.salesPerson?.phone ?? "",completion: { result in
                switch result {
                case .success(let result):
                    HUD.flash(.label(result.msg), delay: 2.0)
                case .failure( _):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    UIApplication.shared.open(url)
                }
            })
        }
        else{
            ServerAPIs.prospectCall(viewType:VIEW_TYPE.OPPORTUNITIES.rawValue , prospectId: prospect._id! , custNumber: number, exeNumber: prospect.salesPerson?.phone ?? "",completion: { result in
                switch result {
                case .success(let result):
                    HUD.flash(.label(result.msg), delay: 2.0)
                case .failure( _):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    UIApplication.shared.open(url)
                }
            })
        }

    }

    // MARK: -  Tableview METHODS
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(currentTableViewDataSource.count > 0){
            tableView.backgroundView = nil
        }
        else{
            noDataLabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            noDataLabel.text          = "No data available. Pull to refresh"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return  currentTableViewDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectTableViewCell = tableView.dequeueReusableCell(withIdentifier: "commonPropspectCell", for: indexPath) as! ProspectTableViewCell
        let prospect = self.currentTableViewDataSource[indexPath.row]
        cell.nameLabel.text = prospect.userName
        
//        print(prospect.salesPerson?.userInfo?.name)
        
        cell.projectNameLabel.text = prospect.project?.name
        cell.salesPersonAndTimeLabel.text = prospect.salesPerson?.userInfo?.name ?? "Super Admin"

        if(prospect.actionInfo != nil && prospect.actionInfo!.date != nil){
        
            cell.heightOfDateLabel.constant = 15
            
            cell.dateLabel.text = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: prospect.actionInfo!.date!)
//                RRUtilities.sharedInstance.getDateWithDateFormat(dateStr: prospect.actionInfo!.date!, dateFormat: "MMM, hh:mm a")
//            let date1 =

            let date = dateFormatter.date(from: prospect.actionInfo!.date!)
            
            if(date!.timeIntervalSinceNow.sign == .minus){
                cell.dateLabel.textColor = UIColor.red
            }
            else{
                cell.dateLabel.textColor = UIColor.hexStringToUIColor(hex: "0053A3")
            }

//            if(prospect.salesPerson?.name != nil){
//                cell.salesPersonAndTimeLabel.text = String(format: "%@ \n %@", (prospect.salesPerson?.name ?? ""),)
//            }
//            else{
//                cell.salesPersonAndTimeLabel.text = String(format: "%@ \n %@", (prospect.salesPerson?.email)!,RRUtilities.sharedInstance.getDateWithDateFormat(dateStr: prospect.actionInfo!.date!, dateFormat: "MMM, hh:mm a"))
//            }
        }
        else{
            cell.heightOfDateLabel.constant = 0
        }
        cell.whatsappButton.addTarget(self, action:#selector(openWhatsapp(_:)), for: .touchUpInside)
        cell.callButton.addTarget(self, action:#selector(openDialer(_:)), for: .touchUpInside)
        cell.whatsappButton.tag = indexPath.row
        cell.callButton.tag = indexPath.row
        
        if(prospect.type == "L"){
            cell.prospectTypeLabel.text = "L"
            cell.prospectTypeLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "fa6400")
        }
        else{
            cell.prospectTypeLabel.text = "O"
            cell.prospectTypeLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "44d7b6")
        }
        
        let tapGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(showStatusChangeView(_:)))
        cell.subContentView.addGestureRecognizer(tapGesture)
        cell.subContentView.tag = indexPath.row
        
        if(selectedProspectRow != -1){
            cell.checkBoxImageView.isHidden = false
            cell.widthOfImageView.constant = 30
        }
        else{
            cell.checkBoxImageView.isHidden = true
            cell.widthOfImageView.constant = 0
        }
        
        if(selectedProspectRow == indexPath.row){
            cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
        }
        else{
            cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(selectedProspectRow != -1){
            selectedProspectRow = indexPath.row
            self.tableView.reloadData()
            return
        }
        
        let prospect = self.currentTableViewDataSource[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsController = storyboard.instantiateViewController(withIdentifier :"cusDetailsController") as! CustomerDetailsViewController
        detailsController.prospectDetails = prospect
        detailsController.prospectType = .LEADS
        if(isFromUserTab){
            detailsController.tabId = self.tabID
            detailsController.isFromUserTab = isFromUserTab
        }
        detailsController.statusID = self.statusID  //indexPath.row + 1
        if(statusID == 4){
            detailsController.isFromDiscountView = true
        }
        detailsController.isFromRegistrations = false
        detailsController.isFromSummaryView = true
        
        if(prospect.type == "L"){
            detailsController.viewType = VIEW_TYPE.LEADS
            detailsController.tabId = 2
        }
        else if(prospect.type == "O"){
            detailsController.viewType = VIEW_TYPE.OPPORTUNITIES
            detailsController.tabId = 3
        }
        self.navigationController?.pushViewController(detailsController, animated: true)
    }
    // MARK: - ACTIONS
    @IBAction func back(_ sender: Any) {
        if(selectedProspectRow != -1){
            selectedProspectRow = -1
            self.tableView.reloadData()
            self.hideStatusChangeView()
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func showFilters(_ sender: Any) {
     
        let filterController = FiltersViewController(nibName: "FiltersViewController", bundle: nil)
//        infoController.selectedProject = project
        
        filterController.projectsArray = Array(self.projects)
        filterController.salesPersonsArray = Array(self.salesPersons)
        filterController.enquirySources = Array(self.enquirySources.sorted())
        filterController.notInterestedReasons = Array(self.notInterestedReasons.sorted())
        
        filterController.isLeadsAvailable = self.isLeadsAvailable
        filterController.isOpportunitiesAvailable = self.isOpportunitiesAvailable
        
        filterController.selectedOverDueDataArray.append(contentsOf: self.selectedOverDueDataArray)
        filterController.selectedProjectsArray.append(contentsOf: self.selectedProjectsArray)
        filterController.selectedStatsuArray.append(contentsOf: self.selectedStatsuArray)
        filterController.selectedSalesPersonsArray.append(contentsOf: self.selectedSalesPersonsArray)
        filterController.selectedMiscArray.append(contentsOf: self.selectedMiscArray)
        filterController.selectedOtherPremiumsArray.append(contentsOf: self.selectedOtherPremiums)
        filterController.selectedFloorWisePremiumsArray.append(contentsOf: self.selectedFloorPremiums)
        filterController.selectedEnquirySourcesArray = self.selectedEnquirySourcesArray.sorted()
        filterController.selectedNotInterestedReasonsArray = self.selectedNotInterestedReasonsArray.sorted()
        
        filterController.delegate = self
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.delegate = self
        
        fpc.set(contentViewController: filterController)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        
        self.present(fpc, animated: true, completion: nil)
        fpc.track(scrollView: filterController.tableView)


    }
    //MARK: - FLOATING PANEL DELGATE
    @objc func moveFpcViewToFull() {
        fpc.move(to: .full, animated: true)
    }
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  CustomPanelLayout(parent: self)
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        currentTableViewDataSource = tableViewDataSource.filter({REGISTRATIONS_RESULT -> Bool in
            switch searchBar.selectedScopeButtonIndex {
            case 0 :
                if(searchText.isEmpty) {return true}
                return REGISTRATIONS_RESULT.userName!.lowercased().contains(searchText.lowercased())
            default:
                return false
            }
        })
        self.setProspectsCount()
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
        self.setProspectsCount()
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
        //        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        self.hideKeyBoard()
        self.currentTableViewDataSource = self.tableViewDataSource
        self.tableView.reloadData()
        self.setProspectsCount()
    }
    @objc func hideKeyBoard()
    {
        self.view.endEditing(true)
    }
    func resetFilters() {
        self.selectedOverDueDataArray.removeAll()
        self.selectedStatsuArray.removeAll()
        self.selectedSalesPersonsArray.removeAll()
        self.selectedProjectsArray.removeAll()
        self.selectedFloorPremiums.removeAll()
        self.selectedOtherPremiums.removeAll()
        self.selectedMiscArray.removeAll()
        self.selectedEnquirySourcesArray.removeAll()
        self.selectedNotInterestedReasonsArray.removeAll()
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
extension ProspectsViewController : FilterDelegate{    
    
    func didFinishFilterSelection(selectedProjecsArray: [String], selectedSalesPersonsArray: [String], selectedStatsuArray: [String], selectedOverDueDataArray: [String], selectedFloorPremiums: [String], selectedOtherPremiums: [String], selectedMiscArray: [String], shouldDismis: Bool,selectedEnquirySources : [String],selectedNotInterestedReasons : [String]){
        
//        didFinishFilterSelection(selectedProjecsArray : [String],selectedSalesPersonsArray : [String],selectedStatsuArray : [String],selectedOverDueDataArray : [String],selectedFloorPremiums : [String],selectedOtherPremiums : [String],selectedMiscArray : [String],shouldDismis : Bool,selectedEnquirySources : [String],selectedNotInterestedReasons : [String])
        
//        projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
        self.resetFilters()
        
        if(selectedSalesPersonsArray.count > 0 || selectedProjecsArray.count > 0 || selectedStatsuArray.count > 0 || selectedOverDueDataArray.count > 0){
            self.filterButton.setImage(UIImage.init(named: "filter1"), for: .normal)
        }
        else{
            self.filterButton.setImage(UIImage.init(named: "filter"), for: .normal)
        }
        
        self.selectedSalesPersonsArray.append(contentsOf: selectedSalesPersonsArray)
        self.selectedProjectsArray.append(contentsOf: selectedProjecsArray)
        self.selectedStatsuArray.append(contentsOf: selectedStatsuArray)
        self.selectedOverDueDataArray.append(contentsOf: selectedOverDueDataArray)
        self.selectedFloorPremiums.append(contentsOf: selectedFloorPremiums)
        self.selectedOtherPremiums.append(contentsOf: selectedOtherPremiums)
        self.selectedMiscArray.append(contentsOf: selectedMiscArray)
        self.selectedEnquirySourcesArray.append(contentsOf: selectedEnquirySources)
        self.selectedNotInterestedReasonsArray.append(contentsOf: selectedNotInterestedReasons)
        
        
        currentTableViewDataSource.removeAll()
        var projectsDataSource : [REGISTRATIONS_RESULT] = []
        
        if(selectedProjecsArray.count == 0){
            projectsDataSource = tableViewDataSource
        }
        
        for projectName in selectedProjecsArray{
            projectsDataSource.append(contentsOf: tableViewDataSource.filter({ (($0.project?.name ?? "").localizedCaseInsensitiveContains(projectName)) }))
        }
        
        var salesPersonDataSource : [REGISTRATIONS_RESULT] = []
        
        if(selectedSalesPersonsArray.count == 0){
            salesPersonDataSource = projectsDataSource
        }

        for salesPersonName in selectedSalesPersonsArray{
            if(salesPersonName == "Super Admin"){
                salesPersonDataSource.append(contentsOf: projectsDataSource.filter({ ($0.salesPerson?.userInfo?.name == nil) }))
            }else{
                salesPersonDataSource.append(contentsOf: projectsDataSource.filter({ (($0.salesPerson?.userInfo?.name ?? "").localizedCaseInsensitiveContains(salesPersonName)) }))
            }
        }
        
        var prospectStatusTypeArray : [REGISTRATIONS_RESULT] = []
        
        if(selectedStatsuArray.count == 0){
            prospectStatusTypeArray = salesPersonDataSource
        }
        
        for status in selectedStatsuArray{
            if(status == "Leads"){
                prospectStatusTypeArray.append(contentsOf: salesPersonDataSource.filter({ ($0.type!.localizedCaseInsensitiveContains("L")) }))
            }
            if(status == "Opportunities"){
                prospectStatusTypeArray.append(contentsOf: salesPersonDataSource.filter({ ($0.type!.localizedCaseInsensitiveContains("O")) }))
            }
        }
        
        var overDueDateArray : [REGISTRATIONS_RESULT] = []
        
        if(selectedOverDueDataArray.count != 0){
            
            for tempProspect in prospectStatusTypeArray{
                if(tempProspect.actionInfo != nil && tempProspect.actionInfo!.date != nil){
                    let date = dateFormatter.date(from: tempProspect.actionInfo!.date!)
                    if(date!.timeIntervalSinceNow.sign == .minus){
                        overDueDateArray.append(tempProspect)
                    }
                }
            }
        }
        else{
            overDueDateArray = prospectStatusTypeArray
        }
        
        var enquirySourceArray : [REGISTRATIONS_RESULT] = []
        
        if(selectedEnquirySources.count > 0){
            
            for enquiryName in selectedEnquirySources{
//                enquirySourceArray.append(contentsOf: overDueDateArray.filter({ (($0.enquirySource?.lowercased() ?? "").localizedCaseInsensitiveContains(enquiryName.lowercased())) }))
                
                enquirySourceArray.append(contentsOf: overDueDateArray.filter( {  $0.enquirySource?.lowercased() ?? "" == enquiryName.lowercased() } ))
            }
        }
        else{
            enquirySourceArray = overDueDateArray
        }

        var notInterestedReasons : [REGISTRATIONS_RESULT] = []
        
        if(selectedNotInterestedReasons.count > 0){
            
            for reason in selectedNotInterestedReasons{
                if(reason == "General"){
                    notInterestedReasons.append(contentsOf: enquirySourceArray.filter({ $0.action?.label == nil }))
                }
                else{
//                notInterestedReasons.append(contentsOf: enquirySourceArray.filter({ (($0.action?.label ?? "").localizedCaseInsensitiveContains(reason)) }))
                
                    notInterestedReasons.append(contentsOf: enquirySourceArray.filter({ $0.action?.label?.lowercased() ?? "" == reason.lowercased() }))
                }
            }
        }
        else{
            notInterestedReasons = enquirySourceArray
        }
        
        self.currentTableViewDataSource = notInterestedReasons
        
        self.setProspectsCount()
        self.tableView.reloadData()
        if(self.currentTableViewDataSource.count > 1){
            self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        else{
            if(noDataLabel == nil){
                
                noDataLabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
                noDataLabel.text          = "No data available. Pull to refresh"
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
                self.noDataLabel.text = "No data available for applied filters"
                self.tableView.reloadData()
            }
            else{
                self.noDataLabel.text = "No data available for applied filters"
                self.tableView.reloadData()
            }

        }
        if(shouldDismis){
            self.dismiss(animated: true, completion: nil)
        }
        
    }

}
