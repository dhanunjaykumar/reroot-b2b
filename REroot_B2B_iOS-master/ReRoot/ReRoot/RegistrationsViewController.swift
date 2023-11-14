//
//  RegistrationsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 24/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class RegistrationsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var toDateButton: UIButton!
    @IBOutlet weak var fromDateButton: UIButton!
    var selectedProspectRow : Int = -1
    var tabID : Int!
    var viewType : VIEW_TYPE!
    var statusChangeView : StatusChangeView! = nil
    var totalNumebrOfProspects : Int!
    @IBOutlet var searchButton: UIButton!
    var tableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    var currentTableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleView: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var titleLabel: UILabel!
    var registrationID : String!
    var refreshControl: UIRefreshControl?
//    var statusID : Int!
    
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
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black

        let nib = UINib(nibName: "CommonProspectsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "commonProspect")
        
        tableView.tableFooterView = UIView()
        
        searchBar.isHidden = true
        titleLabel.text = String(format: "REGISTRATIONS (%d)", totalNumebrOfProspects)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getRegistrations), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popControllers), name: NSNotification.Name(rawValue: NOTIFICATIONS.POP_CONTROLLERS), object: nil)
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
        searchBar.delegate = self
        self.addRefreshControl()
        
        self.updateDates()
        
        let image: UIImage? = UIImage.init(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        fromDateButton.setImage(image, for: .normal)
        fromDateButton.imageView?.tintColor = UIColor.white
        
        let image1: UIImage? = UIImage.init(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        toDateButton.setImage(image1, for: .normal)
        toDateButton.imageView?.tintColor = UIColor.white

        self.getRegistrations()

    }
    func updateDates(){
        
        let date = RRUtilities.sharedInstance.getProspectDateStringFromSelectedDate(selectedDate: RRUtilities.sharedInstance.prospectsSDate)
            
            //RRUtilities.sharedInstance.getProspectDateStringFromServerDate(dateStr: RRUtilities.sharedInstance.prospectsStartDate)
        if(RRUtilities.sharedInstance.isProspectToday(date: RRUtilities.sharedInstance.prospectsSDate)){
            self.fromDateButton.setTitle("Today", for: .normal)
        }
        else{
            self.fromDateButton.setTitle(date, for: .normal)
        }
        let toDate = RRUtilities.sharedInstance.getProspectDateStringFromSelectedDate(selectedDate: RRUtilities.sharedInstance.prospectsEDate)
            //RRUtilities.sharedInstance.getProspectDateStringFromServerDate(dateStr: RRUtilities.sharedInstance.prospectsEndDate)

        if(RRUtilities.sharedInstance.isProspectToday(date:  RRUtilities.sharedInstance.prospectsEDate)){
            self.toDateButton.setTitle("Today", for: .normal)
        }
        else{
            self.toDateButton.setTitle(toDate, for: .normal)
        }
    }

    @objc func popControllers(){
        DispatchQueue.main.async {
            self.hideCheckBox()
            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
    func hideCheckBox(){
        selectedProspectRow = -1
        self.tableView.reloadData()
        self.hideStatusChangeView()
    }
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    @objc func refreshList() {
        
        self.getRegistrations()
        
    }
    @objc func getRegistrations(){
        
        self.tableViewDataSourceArray.removeAll()
//        tableView.reloadData()

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
        
        HUD.show(.progress, onView: self.view)
        
        var urlString = ""
        
        if(registrationID != nil){
            
            urlString =  String(format: "%@%d&id=%@&startDate=%@&endDate=%@", RRAPI.GET_QR_PROSPECT_DATA,tabID,registrationID,RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate)
            //RRAPI.GET_QR_PROSPECT_DATA + tabID + "&id=" + registrationID
        }
        else{
            urlString =  RRAPI.GET_QR_PROSPECT_DATA + String(tabID) + "&id=" + String(format: "&startDate=%@&endDate=%@", RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate)
        }
//        print(urlString)
        if(UserDefaults.standard.bool(forKey: "Filter by Action Date")){
            urlString.append("&filterByActionDate=1")
        }
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                HUD.hide()
                
                do{
                    let urlResult = try JSONDecoder().decode(REGISTRATIONS.self, from: responseData)
                    //                print(urlResult)
                    
//                    let temper = urlResult.result?.filter( { $0.enquirySource?.lowercased().contains("xire prop")} )
//
//                    print(temper?.count)
                    
                    self.refreshControl?.endRefreshing()
                    if(urlResult.result != nil){
                        self.tableViewDataSourceArray = urlResult.result!
                        self.currentTableViewDataSourceArray = urlResult.result!
                        self.titleLabel.text = String(format: "REGISTRATIONS (%d)", self.tableViewDataSourceArray.count)
                    }
                    
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    self.refreshControl?.endRefreshing()
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }


                break
            case .failure(let error):
                print(error)
                HUD.hide()
                self.refreshControl?.endRefreshing()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                break
            }
        }
    }
    
    //MARK:- TABLEVIEW DELEGATE
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
//            noDataLabel.backgroundColor = UIColor.red
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return self.currentTableViewDataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CommonProspectsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "commonProspect",
            for: indexPath) as! CommonProspectsTableViewCell

        let registrationData = self.currentTableViewDataSourceArray[indexPath.row]
        
        cell.nameLabel.text = registrationData.userName
        
        cell.emailButton.tag = indexPath.row
        cell.callButton.tag = indexPath.row
        cell.emailButton.addTarget(self, action:#selector(openWhatsapp(_:)), for: .touchUpInside)
//        cell.emailButton.addTarget(self, action:#selector(openEmail(_:)), for: .touchUpInside)
        cell.callButton.addTarget(self, action:#selector(openDialer(_:)), for: .touchUpInside)
        
        let tapGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(showStatusChangeView(_:)))
        cell.subContentView.addGestureRecognizer(tapGesture)
        cell.subContentView.tag = indexPath.row
        
        if(selectedProspectRow != -1){
            cell.checkBoxImageView.isHidden = false
            cell.widthOfCheckBox.constant = 30
        }
        else{
            cell.checkBoxImageView.isHidden = true
            cell.widthOfCheckBox.constant = 0
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

        let selectedRegistration  = self.currentTableViewDataSourceArray[indexPath.row]
        
        print(selectedRegistration)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsController = storyboard.instantiateViewController(withIdentifier :"cusDetailsController") as! CustomerDetailsViewController
        detailsController.prospectDetails = selectedRegistration
        detailsController.prospectType = .REGISTRATIONS
        detailsController.viewType = self.viewType
        detailsController.isFromRegistrations = true
        detailsController.statusID = selectedRegistration.status
        detailsController.tabId = self.tabID
        detailsController.viewType = self.viewType

        
        
        
//        let tempNavigator = UINavigationController.init(rootViewController: detailsController)
        self.navigationController?.pushViewController(detailsController, animated: true)
//        self.present(tempNavigator, animated: true, completion: {
//        })

//        self.navigationController?.pushViewController(detailsController, animated: true)

        
    }
    @objc func showStatusChangeView(_ sender : UILongPressGestureRecognizer){
        
        
        if(sender.state == .began){
            
            statusChangeView = (StatusChangeView.instanceFromNib() as! StatusChangeView)
            let tag = sender.view?.tag
            selectedProspectRow = tag!
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
            
            if(tabID == 1 || tabID == 3){
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

        }
        

    }
    @objc func showSalePersonChangeView(){
        
        
        //        let salesPersonChangeController = SalesPersonChangeViewController(nibName: "SalesPersonChangeViewController", bundle: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let salesPersonChangeController = storyboard.instantiateViewController(withIdentifier :"salesPersonChange") as! SalesPersonChangeViewController
        
        salesPersonChangeController.selectedProspect = self.currentTableViewDataSourceArray[statusChangeView.salesPersonChangeButton.tag]
        salesPersonChangeController.viewType = VIEW_TYPE.REGISTRATIONS
        //        print(statusController)
        
        self.present(salesPersonChangeController, animated: true, completion: nil)
        //        self.present(salesPersonChangeController, animated: true, completion: nil)
        //        self.navigationController?.pushViewController(salesPersonChangeController, animated: true)
        
        
    }
    @objc func showStatusHandler(){
        
        let prospectDetails  = self.currentTableViewDataSourceArray[statusChangeView.statusChangeButton.tag]
        
        if(prospectDetails.action?.id != nil){  // launch new navigation controller?
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.tabID = self.tabID
            statusController.viewType = self.viewType
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = true
//            statusController.statusID = self.statusID
//            if(isLeads){
//                statusController.viewType = VIEW_TYPE.LEADS
//            }
//            else{
//                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
//            }
            //        self.navigationController?.pushViewController(statusController, animated: true)
            self.present(statusController, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.tabID = self.tabID
            statusController.viewType = self.viewType
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = true
//            statusController.statusID = self.statusID
//            if(isLeads){
//                statusController.viewType = VIEW_TYPE.LEADS
//            }
//            else{
//                statusController.viewType = VIEW_TYPE.OPPORTUNITIES
//            }
            self.present(statusController, animated: true, completion: nil)
        }
    }

    @objc func openEmail(_ sender: UIButton){
        
        let selectedRegistration  = self.currentTableViewDataSourceArray[sender.tag]
        
        if(selectedRegistration.userEmail != nil){
            
            let emailer = String(format: "mailto:%@", selectedRegistration.userEmail!)
            let url = URL(string: emailer)
            
            UIApplication.shared.open(url!)
        }
    }
    @objc func openWhatsapp(_ sender : UIButton){
        
        let selectedRegistration  = self.currentTableViewDataSourceArray[sender.tag]
        var tempCode = ""
        if let phoneCode = selectedRegistration.userPhoneCode{
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
        let phone  = (selectedRegistration.userPhone!.count > 10) ? selectedRegistration.userPhone! : tempCode + selectedRegistration.userPhone!
        guard let number = URL(string: String(format: "https://wa.me/%@?text=%@", phone,""))else{return}
        UIApplication.shared.open(number)
    }
    @objc func openDialer(_ sender: UIButton){
        let selectedRegistration  = self.currentTableViewDataSourceArray[sender.tag]
        
        guard let number = selectedRegistration.userPhone else { return } // URL(string: "tel://" + selectedRegistration.userPhone!)
//        UIApplication.shared.open(number)

            ServerAPIs.prospectCall(viewType:VIEW_TYPE.REGISTRATIONS.rawValue , prospectId: selectedRegistration._id!, custNumber: number, exeNumber: selectedRegistration.salesPerson?.phone ?? "",completion: { result in
                switch result {
                case .success(let result):
                    HUD.flash(.label(result.msg), delay: 2.0)
                case .failure( _):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    UIApplication.shared.open(url)
                }
            })

    }

    @IBAction func showSearchBar(_ sender: Any) {
        searchBar.isHidden = false
        self.titleLabel.isHidden = true
        searchButton.isHidden = true
    }
    
    @IBAction func back(_ sender: Any) {
        if(selectedProspectRow != -1){
            self.hideCheckBox()
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    func hideStatusChangeView(){
        if(self.statusChangeView != nil){
            self.statusChangeView.isHidden = true
            self.statusChangeView.removeFromSuperview()
            self.statusChangeView = nil
        }
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        currentTableViewDataSourceArray = tableViewDataSourceArray.filter( { ($0.userPhone!.contains(searchText) || $0.userName!.contains(searchText)) } )
        
//        currentTableViewDataSourceArray = tableViewDataSourceArray.filter({REGISTRATIONS_RESULT -> Bool in
//            switch searchBar.selectedScopeButtonIndex {
//            case -1:
//                if(searchText.isEmpty) {return true}
//                return REGISTRATIONS_RESULT.userName!.lowercased().contains(searchText.lowercased())
//            case 0 :
//                if(searchText.isEmpty) {return true}
//                return REGISTRATIONS_RESULT.userName!.lowercased().contains(searchText.lowercased())
//            default:
//                return false
//            }
//        })
        
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
        titleLabel.isHidden = false
        searchButton.isHidden = false
        self.hideKeyBoard()
        self.currentTableViewDataSourceArray = self.tableViewDataSourceArray
        self.tableView.reloadData()
    }
    func hideKeyBoard()
    {
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
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
