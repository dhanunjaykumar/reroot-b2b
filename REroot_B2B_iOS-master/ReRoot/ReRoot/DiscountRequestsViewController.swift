//
//  DiscountRequestsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 25/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import FloatingPanel

class DiscountRequestsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FloatingPanelControllerDelegate,MOVE_TO_FULL_DELEGATE {
    
    let fpc = FloatingPanelController()
    var selectedProspectRow : Int = -1
    @IBOutlet var changeButton: UIButton!
    var viewType : VIEW_TYPE!
    var refreshControl: UIRefreshControl?
    var tableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    var currentTableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    @IBOutlet var tableView: UITableView!
    var tabID : Int!
    var statusChangeView : StatusChangeView! = nil
    var projectID : String!
    var statusID : Int?
    var discountsCount : Int!
    @IBOutlet var statusInfoView: UIView!
    @IBOutlet var heightOfStatusInfoView: NSLayoutConstraint!
    var isLeads = false
    var isLongPress : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "CommonProspectsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "commonProspect")
        
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getProspectsAsPerStatus), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popControllers), name: NSNotification.Name(rawValue: NOTIFICATIONS.POP_CONTROLLERS), object: nil)

        if(discountsCount > 0){
            self.getProspectsAsPerStatus()
        }else{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
        heightOfStatusInfoView.constant = 0
        statusInfoView.isHidden = true
        changeButton.layer.cornerRadius = 8
        self.addRefreshControl()
        
        if(isLeads){
            self.viewType = VIEW_TYPE.LEADS
        }
        else{
            self.viewType = VIEW_TYPE.OPPORTUNITIES
        }
    }
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(getProspectsAsPerStatus), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popControllers), name: NSNotification.Name(rawValue: NOTIFICATIONS.POP_CONTROLLERS), object: nil)
    }
    @objc func popControllers(){
        _ = self.hideCheckBox()
        self.dismiss(animated: true, completion: nil)
        if(isLongPress == false){
            self.navigationController?.popViewController(animated: true)
        }
        self.isLongPress = false
        _ = self.hideCheckBox()
        self.hideStatusChangeView()
    }
    func hideStatusChangeView(){
        if(self.statusChangeView != nil){
            self.statusChangeView.isHidden = true
            self.statusChangeView.removeFromSuperview()
            self.statusChangeView = nil
        }
    }
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    @objc func refreshList() {
        
        self.getProspectsAsPerStatus()
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
        
        HUD.show(.labeledProgress(title: "", subtitle: nil), onView: self.view)
        self.refreshControl?.beginRefreshing()
        //rospectleads?tab=1&id=5a64a02cc145c62d977954f0&status=4
        
//        print(tabID)
//        print(projectID)
//        print(statusID)
        if(projectID == nil)
        {
            projectID = "null"
        }
        
        var urlString = ""
        
        if(isLeads){
            urlString = String(format:RRAPI.GET_LEADS_PROSPECTS_AS_PER_ORDER,tabID,projectID,statusID ?? -1,RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate)
        }
        else{
            urlString = String(format:RRAPI.GET_OPPORTUNITIES_PROSPECTS_AS_PER_ORDER,tabID,projectID,statusID ?? -1,RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate)
        }

        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if(UserDefaults.standard.bool(forKey: "Filter by Action Date")){
            urlString.append("&filterByActionDate=1")
        }

//        print(urlString)
        
        //        if(registrationID != nil){
        //            urlString =  RRAPI.GET_QR_PROSPECT_DATA + tabID + "&id=" + registrationID
        //        }
        //        else{
        //            urlString =  RRAPI.GET_QR_PROSPECT_DATA + tabID + "&id="
        //        }
        
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
                
                do{
                    let urlResult = try JSONDecoder().decode(REGISTRATIONS.self, from: responseData)
                    //                print(urlResult)
                    
                    if(urlResult.status == -1){
                        
                    }
                    
                    self.currentTableViewDataSourceArray.removeAll()
                    self.tableViewDataSourceArray.removeAll()
                    self.refreshControl?.endRefreshing()
                    if(urlResult.result != nil){
                        self.tableViewDataSourceArray = urlResult.result!
                        self.currentTableViewDataSourceArray = self.tableViewDataSourceArray
                    }
                    var infoDict : Dictionary<String,Int> = [:]
                    infoDict["count"] = self.tableViewDataSourceArray.count
                    infoDict["pType"] = 3
                    if(self.tableViewDataSourceArray.count > 0){
                        self.title = "Discount Requests(\(self.tableViewDataSourceArray.count))"
                    }
                    else{
                        self.title = "Discount Requests"
                    }
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                    sleep(UInt32(0.10))
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.UPDATE_PROSPECT_COUNT), object: nil, userInfo: infoDict)
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
                self.refreshControl?.endRefreshing()
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
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
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
        cell.emailButton.addTarget(self, action:#selector(openWhatsapp(_:)), for: .touchUpInside)
        cell.callButton.addTarget(self, action:#selector(openDialer(_:)), for: .touchUpInside)
        cell.emailButton.tag = indexPath.row
        cell.callButton.tag = indexPath.row
        let tapGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(showStatusChangeView(_:)))
        cell.subContentView.addGestureRecognizer(tapGesture)
        cell.subContentView.tag = indexPath.row
        
        if(selectedProspectRow == -1){
            cell.widthOfCheckBox.constant = 0
            cell.checkBoxImageView.isHidden = true
        }
        else{
            cell.widthOfCheckBox.constant = 30
            cell.checkBoxImageView.isHidden = false
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
        self.tableView.reloadData()
        self.hideStatusChangeView()
        let prospect = self.currentTableViewDataSourceArray[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsController = storyboard.instantiateViewController(withIdentifier :"cusDetailsController") as! CustomerDetailsViewController
        detailsController.prospectDetails = prospect
        detailsController.isFromDiscountView = true
        detailsController.prospectType = .REGISTRATIONS
        detailsController.tabId = self.tabID
        detailsController.statusID = self.statusID
        if(isLeads){
            detailsController.viewType = VIEW_TYPE.LEADS
        }
        else{
            detailsController.viewType = VIEW_TYPE.OPPORTUNITIES
        }

        self.navigationController?.pushViewController(detailsController, animated: true)
        
    }
    func hideCheckBox()->Bool{
        if(selectedProspectRow != -1){
            selectedProspectRow = -1
            self.tableView.reloadData()
            self.hideStatusChangeView()
            return true
        }
        self.isLongPress = false
        return false
    }
    func shouldShowStatusChangeView(fromIndex : Int)->Bool{
        
        let prospectDetails  = self.currentTableViewDataSourceArray[fromIndex]
        
        if(prospectDetails.salesPerson != nil && PermissionsManager.shared.isEmployePermittedForPresales(employeeID: (prospectDetails.salesPerson?._id ?? ""))){
            return true
        }
        else{
            _ = self.hideCheckBox()
            return false
        }
    }
    @objc func showStatusChangeView(_ sender : UILongPressGestureRecognizer){
        
        
        if sender.state == .began{
            
            statusChangeView = (StatusChangeView.instanceFromNib() as! StatusChangeView)
            let tag = sender.view?.tag
            self.tableView.reloadData()
            selectedProspectRow = tag!
            if(!self.shouldShowStatusChangeView(fromIndex: tag!)){
                return
            }
            let prospectDetails  = self.currentTableViewDataSourceArray[tag!]
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
            else{
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
            
            let tapStatusGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showStatusHandler))
            let tapSalesGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showSalePersonChangeView))
            statusChangeView.statusChangeView.addGestureRecognizer(tapStatusGuesture)
            statusChangeView.salesPersonView.addGestureRecognizer(tapSalesGuesture)
            
            statusChangeView.statusChangeButton.tag = tag!

        }
        
    }
    @objc func showSalePersonChangeView(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let salesPersonChangeController = storyboard.instantiateViewController(withIdentifier :"salesPersonChange") as! SalesPersonChangeViewController
        
        if(isLeads){
            salesPersonChangeController.viewType = VIEW_TYPE.LEADS
        }
        else{
            salesPersonChangeController.viewType = VIEW_TYPE.OPPORTUNITIES
        }
        
        salesPersonChangeController.selectedProspect = self.currentTableViewDataSourceArray[selectedProspectRow]
        
        self.present(salesPersonChangeController, animated: true, completion: nil)
        
    }
    @objc func showStatusHandler(){
        
        self.isLongPress = true
        let prospectDetails  = self.currentTableViewDataSourceArray[selectedProspectRow]
        
        
        //discountRequest
        if(prospectDetails.discountApplied == 1 || prospectDetails.discountApplied == 2){ //Discount applied  or Rejected state
            
            // Show prospect as radio Button
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.tabID = self.tabID
//            statusController.viewType = self.viewType
            if(isLeads){
                statusController.viewType = VIEW_TYPE.LEADS
            }
            else{
                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
            }
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = false
            statusController.isFromDiscountView = true
            statusController.statusID = self.statusID
            
            //        self.navigationController?.pushViewController(statusController, animated: true)
            //            let tempNavigator = UINavigationController.init(rootViewController: statusController)
            
            //                if(isLeads){
            //                    statusController.viewType = VIEW_TYPE.LEADS
            //                }
            //                else{
            //                    statusController.viewType = VIEW_TYPE.OPPORTUNITIES
            //                }
            
            self.present(statusController, animated: true, completion: nil)
            return
            // show send offer
            // SendOfferPopUpViewController
        }
        else{ //not applied
//            self.getHistoryOfQuickRegistration()
            self.getDiscountDetailsOfUnit()
            return
        }
        return
        
//        if(prospectDetails.action?.id != nil){  // launch new navigation controller?
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
//            statusController.tabID = self.tabID
//            statusController.prospectDetails = prospectDetails
//            statusController.isFromRegistrations = false
//            statusController.statusID = self.statusID
//            if(isLeads){
//                statusController.viewType = VIEW_TYPE.LEADS
//            }
//            else{
//                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
//            }
//
//            //        self.navigationController?.pushViewController(statusController, animated: true)
//            self.present(statusController, animated: true, completion: nil)
//        }
//        else{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
//            statusController.tabID = self.tabID
//            statusController.prospectDetails = prospectDetails
//            statusController.isFromRegistrations = false
//            statusController.statusID = self.statusID
//            if(isLeads){
//                statusController.viewType = VIEW_TYPE.LEADS
//            }
//            else{
//                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
//            }
//
//            self.present(statusController, animated: true, completion: nil)
//        }
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
        
        let prospectDetails  = self.currentTableViewDataSourceArray[statusChangeView.statusChangeButton.tag]

        let tempUnits = prospectDetails.actionInfo?.units
        let counter = tempUnits?.count
        
        var unitDetails : UNITS!
        
        if(counter! > 0){
            unitDetails = (prospectDetails.actionInfo?.units![0])!
        }
        
        if(unitDetails == nil){
            HUD.flash(.label("Can't request discount amount of units without Unit Type"), delay: 1.0)
            return
        }
        
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_UNIT_PRICE, unitDetails._id ?? "")
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()
                
                do{
                    let urlResult = try JSONDecoder().decode(UNIT_PRICE_API_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        //                    HUD.flash(.label("Success"), delay: 1.0)
                        //                    self.dismiss(animated: true, completion: nil)
                        
                        let discountRequestController = DiscountViewController(nibName: "DiscountViewController", bundle: nil)
                        discountRequestController.prospectDetails = prospectDetails
                        discountRequestController.isFromRegistrations = false
                        discountRequestController.viewType = self.viewType
                        discountRequestController.statusID = self.statusID
                        discountRequestController.unitBillingInfo = urlResult.result
                        discountRequestController.delegate = self
                        self.showDiscountView(controller: discountRequestController)

                    }
                    else
                    {
                        HUD.flash(.label(urlResult.err), delay: 1.0)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
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
    //MARK: - FLOAT PANEL BEGIN
    @objc func moveFpcViewToFull() {
        fpc.move(to: .full, animated: true)
    }
    func showDiscountView(controller : DiscountViewController){
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.delegate = self
        
        fpc.set(contentViewController: controller)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: controller.scrollView)
        
        self.present(fpc, animated: true, completion: nil)
    }
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  CustomPanelLayout(parent: self)
    }
    //MARK: - FLOAT PANEL END
    @objc func openWhatsapp(_ sender : UIButton){
        let prospect  = self.tableViewDataSourceArray[sender.tag]
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
        let prospect  = self.tableViewDataSourceArray[sender.tag]
        
        guard let number = prospect.userPhone else { return } //URL(string: "tel://" + prospect.userPhone!)
        //        UIApplication.shared.open(number)
        
        if(isLeads){
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
                case .failure(_):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    UIApplication.shared.open(url)
                }
            })
        }
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count == 0)
        {
            currentTableViewDataSourceArray = tableViewDataSourceArray
        }
        else{
            currentTableViewDataSourceArray = tableViewDataSourceArray.filter({ (($0.userName?.localizedCaseInsensitiveContains(searchText))!) })
        }

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
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideKeyBoard"), object: nil, userInfo: nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.hideKeyBoard()
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
