//
//  SiteVisitsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 25/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class SiteVisitsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var selectedProspectRow : Int = -1
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var statusInfoView: UIView!
    var refreshControl: UIRefreshControl?
    @IBOutlet var heightOfStatusInfoView: NSLayoutConstraint!
    var tableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    var currentTableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    var statusChangeView : StatusChangeView! = nil
    @IBOutlet var tableView: UITableView!
    var tabID : Int!
    var projectID : String!
    var statusID : Int?
    var siteVisitsCount : Int!
    var isLeads = false
    var isLongPress : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "CallsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "calls")
        
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getProspectsAsPerStatus), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popControllers), name: NSNotification.Name(rawValue: NOTIFICATIONS.POP_CONTROLLERS), object: nil)

        
        if(siteVisitsCount > 0){
            self.getProspectsAsPerStatus()
        }else{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
        
        heightOfStatusInfoView.constant = 0
        statusInfoView.isHidden = true
        changeButton.layer.cornerRadius = 8
        self.getProspectsAsPerStatus()
        self.addRefreshControl()
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
        let chck = self.hideCheckBox()
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
        
//        print(urlString)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                HUD.hide()
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
                        var tempArray = urlResult.result!
                        if(tempArray.count > 0){
                            tempArray.sort(by: { $0.actionInfo!.date ?? "" < $1.actionInfo!.date ?? ""})
                            self.tableViewDataSourceArray = tempArray
                            self.currentTableViewDataSourceArray = self.tableViewDataSourceArray
                        }
                    }
                    var infoDict : Dictionary<String,Int> = [:]
                    infoDict["count"] = self.tableViewDataSourceArray.count
                    infoDict["pType"] = 2
                    if(self.tableViewDataSourceArray.count > 0){
                        self.title = "Site Visits(\(self.tableViewDataSourceArray.count))"
                    }
                    else{
                        self.title = "Site Visits"
                    }
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                    sleep(UInt32(0.10))
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.UPDATE_PROSPECT_COUNT), object: nil, userInfo: infoDict)
                }
                catch let error{
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

        let cell : CallsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "calls",
            for: indexPath) as! CallsTableViewCell
        
        let prospect : REGISTRATIONS_RESULT = self.currentTableViewDataSourceArray[indexPath.row]
        cell.nameLabel.text = prospect.userName
        if(prospect.actionInfo != nil && prospect.actionInfo!.date != nil){
//            print(prospect.actionInfo!.date!)
            cell.dateLabel.text = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: prospect.actionInfo!.date!)
            if(RRUtilities.sharedInstance.isCurrentDayOrFutureDay(dateString: prospect.actionInfo!.date!)){
                cell.dateLabel.textColor = UIColor.blue
            }
            else{
                cell.dateLabel.textColor = UIColor.red
            }
        }
        else{
            cell.dateLabel.text = "No Date"
        }
        let tapGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(showStatusChangeView(_:)))
        cell.subView.addGestureRecognizer(tapGesture)
        cell.subView.tag = indexPath.row
        
        cell.whatsappButton.addTarget(self, action:#selector(openWhatsapp(_:)), for: .touchUpInside)
        cell.callButton.addTarget(self, action:#selector(openDialer(_:)), for: .touchUpInside)
        cell.whatsappButton.tag = indexPath.row
        cell.callButton.tag = indexPath.row

        if(selectedProspectRow != -1){
            cell.checkBoxImageView.isHidden = false
            cell.widthOfCheckBoxImage.constant = 30
        }
        else{
            cell.checkBoxImageView.isHidden = true
            cell.widthOfCheckBoxImage.constant = 0
        }
        
        if(selectedProspectRow == indexPath.row){
            cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
        }
        else{
            cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
        }

//        let prospect = self.currentTableViewDataSourceArray[indexPath.row]
//        cell.nameLabel.text = prospect.userName
//        cell.emailButton.addTarget(self, action:#selector(openWhatsapp(_:)), for: .touchUpInside)
//        cell.callButton.addTarget(self, action:#selector(openDialer(_:)), for: .touchUpInside)
//        cell.emailButton.tag = indexPath.row
//        cell.callButton.tag = indexPath.row
//        let tapGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(showStatusChangeView(_:)))
//        cell.subContentView.addGestureRecognizer(tapGesture)
//        cell.subContentView.tag = indexPath.row
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hideStatusChangeView()
        if(selectedProspectRow != -1){
            selectedProspectRow = indexPath.row
            self.tableView.reloadData()
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsController = storyboard.instantiateViewController(withIdentifier :"cusDetailsController") as! CustomerDetailsViewController
        let prospect = self.currentTableViewDataSourceArray[indexPath.row]
        detailsController.prospectDetails = prospect
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
            selectedProspectRow = tag!
            if(!self.shouldShowStatusChangeView(fromIndex: tag!)){
                return
            }
            self.tableView.reloadData()
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
        
        if(prospectDetails.action?.id != nil){  // launch new navigation controller?
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = false
            statusController.statusID = self.statusID
            statusController.tabID = self.tabID

            if(isLeads){
                statusController.viewType = VIEW_TYPE.LEADS
            }
            else{
                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
            }

            //        self.navigationController?.pushViewController(statusController, animated: true)
            self.present(statusController, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.tabID = self.tabID
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = false
            statusController.statusID = self.statusID
            if(isLeads){
                statusController.viewType = VIEW_TYPE.LEADS
            }
            else{
                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
            }

            self.present(statusController, animated: true, completion: nil)
        }
    }

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
                case .failure( _):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    UIApplication.shared.open(url)                }
            })
        }

    }

    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
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
//        print(selectedScope)
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
