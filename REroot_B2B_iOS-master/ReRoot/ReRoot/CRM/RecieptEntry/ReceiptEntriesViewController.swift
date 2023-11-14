//
//  ReceiptEntriesViewController.swift
//  REroot
//
//  Created by Dhanunjay on 18/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import PKHUD
import Alamofire
import JJFloatingActionButton

class ReceiptEntriesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIPopoverPresentationControllerDelegate,HidePopUp {

    var refreshControl: UIRefreshControl?
    var isDeletePermitted : Bool = false
    
    var paymentTowardsComponentsArray : [PaymentToWards] = []

    @IBOutlet weak var serchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var tab : Int!
    var indexPathToDelete : IndexPath!
    var isProjectWise : Bool = false
    var isUserWise : Bool = false
    var isPaymentWise : Bool = false
    
    var selectedEntry : ReceiptEntriesCount!
    var selectedProjectId : String!
    
    @IBOutlet weak var paymentTowardsLabel: UILabel!
    @IBOutlet weak var unitTypeLabel: UILabel!
    @IBOutlet weak var unitTypeView: UIView!
    @IBOutlet weak var paymentModeView: UIView!
    
    var searchText : String = ""
    
    var isShowingUnitTypePopUp : Bool = false
    var isShowingPaymentModePopUp : Bool = false
//    paymentTowards
    var shouldShowReservedEntries = false
    var shluldShowBookedAndSoldUnits = false
    
    var receiptEntriesFetchedResultsController : NSFetchedResultsController<ReceiptEntry>!
    var payementToWardsFetchedResultsController : NSFetchedResultsController<PaymentTowards> = NSFetchedResultsController.init()
    
    var unitTypeFilterDataSource : [String] = []
    var paymentTowardsTypeFilterDataSource : [PaymentToWards] = []

    @IBOutlet var tableView: UITableView!
    
    var selectedReceiptEntryType : ReceiptEntry!
    var paymentToWardsArray : [PaymentToWards] = []
    
    var tempPaymentToWardsArray : [PaymentToWards] = []

    @IBOutlet var projectNameLabel: UILabel!
    @IBOutlet var entriesInfoLabel: UILabel!
    @IBOutlet var titleView: UIView!
    
    var selectedPaymentTowards : String!
    var selectedUnitType : String!
    
    // MARK: - View LIfe cycle
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
    override func viewWillDisappear(_ animated: Bool) {
        self.receiptEntriesFetchedResultsController.delegate = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    func configureView(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_RECEIPT_ENTRIES), object: nil)
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black

        self.shouldShowSearchBar(shouldShow: false)
        self.configureFloatButton()
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search Customer/Project/Unit"
        
        self.isDeletePermitted = PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.DELETE.rawValue)
        
        let all = PaymentToWards(name: "All", count: 0, amount: 0, _id: "All")
        let advancedReceipts = PaymentToWards(name: "Advance Receipts", count: 0, amount: 0, _id: "AR")

        paymentToWardsArray.append(all)
        paymentToWardsArray.append(advancedReceipts)
        
        self.projectNameLabel.text = self.selectedEntry.name
        
        tempPaymentToWardsArray.append(PaymentToWards(name: "On Booking", count: 0, amount: 0, _id: "OB"))
        tempPaymentToWardsArray.append(PaymentToWards(name: "Against Demand Note", count: 0, amount: 0, _id: "AD"))
        tempPaymentToWardsArray.append(PaymentToWards(name: "Against Debit Note", count: 0, amount: 0, _id: "AD"))
        tempPaymentToWardsArray.append(PaymentToWards(name: "Stamp Duty Charges", count: 0, amount: 0, _id: "SD"))
        tempPaymentToWardsArray.append(PaymentToWards(name: "Franking Charges", count: 0, amount: 0, _id: "FC"))
        tempPaymentToWardsArray.append(PaymentToWards(name: "Unit Asssignment Charges", count: 0, amount: 0, _id: "UC"))
        tempPaymentToWardsArray.append(PaymentToWards(name: "Cancellation Charges", count: 0, amount: 0, _id: "CC"))
        
//        if(RRUtilities.sharedInstance.defaultBookingFormSetUp != nil){
//            paymentToWardsArray += RRUtilities.sharedInstance.defaultBookingFormSetUp!.paymentTowards!
//        }
//        if(RRUtilities.sharedInstance.customBookingFormSetUp != nil){
//
//            for eachObject in RRUtilities.sharedInstance.customBookingFormSetUp!.paymentTowards!{
//
//                let fileterd =  paymentToWardsArray.filter({$0.name == eachObject.name })
//                if(fileterd.count == 0){
//                    paymentToWardsArray.append(eachObject)
//                }
//            }
////            paymentToWardsArray += RRUtilities.sharedInstance.customBookingFormSetUp!.paymentTowards!
//        }

        unitTypeFilterDataSource = ["All","Reserved","Booked/Sold"]
        
        self.setPaymentToWardsArray(isReserved: false)
        
        let nib = UINib(nibName: "ReceiptEntryTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "receiptEntryCell")
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        selectedPaymentTowards = "All"
        selectedUnitType = "All"

        self.fetchAllReceiptEntries()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addRefreshControl()
        
    }
    func shouldShowSearchBar(shouldShow : Bool){
        
        self.searchBar.isHidden = !shouldShow
        self.serchButton.isHidden = shouldShow
        self.projectNameLabel.isHidden = shouldShow
        self.entriesInfoLabel.isHidden = shouldShow
        
        if(shouldShow){
            self.searchBar.becomeFirstResponder()
        }
        
    }
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    @objc func refreshList(){
        
        self.refreshControl?.beginRefreshing()
        self.receiptEntriesFetchedResultsController.delegate = nil
        ServerAPIs.getReceiptEntries(projectId: self.selectedProjectId, tab: self.tab, completionHandler: {(response,error) in
            DispatchQueue.main.async {
                if(response){
                    self.fetchAllReceiptEntries()
                    self.tableView.reloadData()
                }
                else{
                    
                }
                self.refreshControl?.endRefreshing()
            }
        })
        
    }
    func setPaymentToWardsArray(isReserved : Bool){
        
        if(isReserved){
            paymentTowardsTypeFilterDataSource =  paymentToWardsArray //["Advance Receipts"]
        }
        else{
            
            paymentTowardsTypeFilterDataSource = paymentToWardsArray
            paymentTowardsTypeFilterDataSource.append(contentsOf: tempPaymentToWardsArray)
            
        }

        print(paymentTowardsTypeFilterDataSource)
        
    }
    func configureFloatButton(){
        
        if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.CREATE.rawValue)){
            
            let actionButton = JJFloatingActionButton()
            actionButton.buttonColor = UIColor.hexStringToUIColor(hex: "ffce76")
            
            actionButton.addItem(title: "", image: UIImage(named: "quick_registration_icon")?.withRenderingMode(.alwaysTemplate)) { item in

                let projectSearchController = ProjectSearchViewController(nibName: "ProjectSearchViewController", bundle: nil)
                let tempNavigator = UINavigationController.init(rootViewController: projectSearchController)
                tempNavigator.navigationBar.isHidden = true
                projectSearchController.modalPresentationStyle = .fullScreen
                tempNavigator.modalPresentationStyle = .fullScreen
                self.present(tempNavigator, animated: true, completion: nil)
            }
            
            self.view.addSubview(actionButton)
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            
            if #available(iOS 11.0, *) {
                actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
            } else {
                // Fallback on earlier versions
            }
            
            if #available(iOS 11.0, *) {
                actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    // MARK: - ACTIONS
    func fetchPaymentToWardsArray(){
        
        let request: NSFetchRequest<PaymentTowards> = PaymentTowards.fetchRequest()
        
        let sort = NSSortDescriptor(key: #keyPath(PaymentTowards.name), ascending: true)
        request.sortDescriptors = [sort]

//        let fetched =  RRUtilities.sharedInstance.model.managedObjectContext.fetch(request)
        
        //try managedObjectContext.fetch(activityInfo) as! [Vehicle]


    }
    func fetchAllReceiptEntries(){
        
        let request: NSFetchRequest<ReceiptEntry> = ReceiptEntry.fetchRequest()
        
        if(self.isProjectWise){
            let sort = NSSortDescriptor(key: #keyPath(ReceiptEntry.updateByDate), ascending: false)
            request.sortDescriptors = [sort]
            
            if(shouldShowReservedEntries){
                if(selectedPaymentTowards == "All"){ //contains[cd] %@
                    if(searchText.count > 0){
                        let predicate = NSPredicate(format: "tab == %d AND receiptType == %@ AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)",tab,RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue,searchText,searchText,searchText)
                        request.predicate = predicate
                    }
                    else{
                        let predicate = NSPredicate(format: "tab == %d AND receiptType == %@",tab,RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue)
                        request.predicate = predicate
                    }
                }
                else{
                    if(searchText.count > 0){
                        let predicate = NSPredicate(format: "tab == %d AND receiptType == %@ AND paymentTowards == %@ AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)",tab,RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue,selectedPaymentTowards,searchText,searchText,searchText)
                        request.predicate = predicate
                    }
                    else{
                        let predicate = NSPredicate(format: "tab == %d AND receiptType == %@ AND paymentTowards == %@",tab,RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue,selectedPaymentTowards)
                        request.predicate = predicate
                    }
                }
            }
            else if(shluldShowBookedAndSoldUnits){
                
                if(selectedPaymentTowards == "All"){
                    
                    if(searchText.count > 0){
                        let predicate = NSPredicate(format: "tab == %d AND receiptType == %@ AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)", tab,RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue,searchText,searchText,searchText)
                        request.predicate = predicate
                    }
                    else{
                        let predicate = NSPredicate(format: "tab == %d AND receiptType == %@", tab,RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue)
                        request.predicate = predicate
                    }
                }
                else{
                    if(selectedPaymentTowards == "All"){
                        if(searchText.count > 0){
                            let predicate = NSPredicate(format: "tab == %d AND receiptType == %@ AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)", tab,RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue,searchText,searchText,searchText)
                            request.predicate = predicate
                        }
                        else{
                            let predicate = NSPredicate(format: "tab == %d AND receiptType == %@", tab,RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue)
                            request.predicate = predicate
                        }
                    }
                    else{
                        if(searchText.count > 0){
                            let predicate = NSPredicate(format: "tab == %d AND receiptType == %@ AND paymentTowards == %@ AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)", tab,RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue,selectedPaymentTowards,searchText,searchText,searchText)
                            request.predicate = predicate
                        }
                        else{
                            let predicate = NSPredicate(format: "tab == %d AND receiptType == %@ AND paymentTowards == %@", tab,RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue,selectedPaymentTowards)
                            request.predicate = predicate
                        }
                    }
                }
            }
            else{
                
                if(selectedPaymentTowards == "All"){
                    if(searchText.count > 0){
                        let predicate = NSPredicate(format: "tab == %d AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)", tab,searchText,searchText,searchText)
                        request.predicate = predicate
                    }
                    else{
                        let predicate = NSPredicate(format: "tab == %d", tab)
                        request.predicate = predicate
                    }
                }
                else{
//                    paymentTowards
                    if(searchText.count > 0){
                        let predicate = NSPredicate(format: "tab == %d AND paymentTowards == %@ AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)", tab,selectedPaymentTowards,searchText,searchText,searchText)
                        request.predicate = predicate
                    }
                    else{
                        let predicate = NSPredicate(format: "tab == %d AND paymentTowards == %@", tab,selectedPaymentTowards)
                        request.predicate = predicate
                    }
                }
            }
        }
        if(self.isUserWise){
            let sort = NSSortDescriptor(key: #keyPath(ReceiptEntry.createdBy), ascending: true)
            request.sortDescriptors = [sort]

            if(searchText.count > 0){
                let predicate = NSPredicate(format: "tab == %d AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)", tab,searchText,searchText,searchText)
                request.predicate = predicate
            }
            else{
                let predicate = NSPredicate(format: "tab == %d", tab)
                request.predicate = predicate
            }
        }
        if(self.isPaymentWise){
            let sort = NSSortDescriptor(key: #keyPath(ReceiptEntry.updateByDate), ascending: false)
            request.sortDescriptors = [sort]
//            print(tab)
            if(searchText.count > 0){
                let predicate = NSPredicate(format: "tab == %d AND (customerName contains[cd] %@ || unitDescription contains[cd] %@ || projectName contains[cd] %@)", tab,searchText,searchText,searchText)
                request.predicate = predicate
            }
            else{
                let predicate = NSPredicate(format: "tab == %d", tab)
                request.predicate = predicate
            }
        }
        
        receiptEntriesFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        receiptEntriesFetchedResultsController.delegate = self
        do {
            try receiptEntriesFetchedResultsController.performFetch()
            self.updateCount()
            self.tableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }
        self.tableView.separatorStyle = .none
        self.tableView.separatorStyle = .singleLine
    }
    func updateCount(){
        self.entriesInfoLabel.text = String(format: "ENTRIES(%d)", (self.receiptEntriesFetchedResultsController.fetchedObjects?.count)!)
    }
    @IBAction func showUnitTypeFilter(_ sender: Any) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .STATUS
        vc.isReceiptEntry = true
        let statusesArray = unitTypeFilterDataSource
        
        self.isShowingUnitTypePopUp = true
        
        vc.preferredContentSize = CGSize(width: 150, height: (statusesArray.count-1) * 44)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.up //UIPopoverArrowDirection(rawValue: 0)
        vc.tableViewDataSourceOne = statusesArray
        
        popOver?.sourceView = unitTypeView
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    @IBAction func showPaymentTowardsFilter(_ sender: Any) {
        
        
        if(RRUtilities.sharedInstance.defaultBookingFormSetUp != nil){
            paymentTowardsComponentsArray += RRUtilities.sharedInstance.defaultBookingFormSetUp!.paymentTowards!
        }
        if(RRUtilities.sharedInstance.customBookingFormSetUp != nil){
            paymentTowardsComponentsArray += RRUtilities.sharedInstance.customBookingFormSetUp!.paymentTowards!
        }
        print(paymentTowardsComponentsArray)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .PAYMENT_TOWARDS
        vc.isReceiptEntry = true
        self.isShowingPaymentModePopUp = true
        let statusesArray = paymentTowardsTypeFilterDataSource
        
        vc.preferredContentSize = CGSize(width: 250, height: (statusesArray.count-1) * 44)
        
        if(statusesArray.count == 1){
            vc.preferredContentSize = CGSize(width: 250, height: 1)
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any //UIPopoverArrowDirection(rawValue: 0)
        vc.paymentTowardsDataSource = statusesArray
        
        popOver?.sourceView = paymentModeView
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    @IBAction func back(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func search(_ sender: Any) {
        self.shouldShowSearchBar(shouldShow:true)
    }
    @objc func deleteSelectedRecieptEntry(_ sender : UIButton){
        
        let indexPath = IndexPath.init(row: sender.tag, section: 0)
        indexPathToDelete = indexPath
        let receiptEntry  = self.receiptEntriesFetchedResultsController.object(at: indexPath)
        
        //show Alert
        let projectName = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: receiptEntry.project!)?.name ?? ""
        let alertString = String(format: "Are you sure you want to permanently delete the receipt for \nUnit - %@ | %d (%@) \nAmount - %@%.2f?", projectName,receiptEntry.unitIndex,receiptEntry.unitDescription ?? "",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,receiptEntry.amount)
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let action2 = UIAlertAction(title: "YES", style: .default) { (action:UIAlertAction) in
            self.deleteEntry(receiptEntryID: receiptEntry.id!)
            print("DELETE")
        }

        let action1 = UIAlertAction(title: "NO", style: .default) { (action:UIAlertAction) in
            print("DONT DELETE")
        }
        
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: alertString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Montserrat-Medium", size: 15)!])
        
        alertController.setValue(myMutableString, forKey: "attributedTitle")

        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)

    }
    func deleteEntry(receiptEntryID : String){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress, onView: self.view)
        let urlString = String(format:RRAPI.API_DELETE_RECEIPT_ENTRY,receiptEntryID)
        print(urlString)
        
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
                
                let urlResult = try! JSONDecoder().decode(RECEIPT_ENTRIES_COUNT_OUTPUT.self, from: responseData)
                
                if(urlResult.status == -1 ){
                    HUD.flash(.label(STRINGS.Access_Forbidden_Contact_Admin), delay: 2.0)
                    return
                }
                if(urlResult.status == 1){
                    let receiptEntryToDelete = self.receiptEntriesFetchedResultsController.object(at: self.indexPathToDelete)
                    RRUtilities.sharedInstance.model.managedObjectContext.delete(receiptEntryToDelete)
                    RRUtilities.sharedInstance.model.saveContext()
                    self.fetchAllReceiptEntries()
                    self.updateCount()
                    HUD.flash(.label("Receipt Deleted"), delay: 1.0)
                }else{
                    HUD.flash(.label("Couldn't delete Receipt. Try Again!"), delay: 1.0)
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
    func setUpNoDataLabel(){
        let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text          = "No Receipt Entries"
        noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
        noDataLabel.textColor     = UIColor.black
        noDataLabel.textAlignment = .center
        tableView.backgroundView  = noDataLabel
        tableView.separatorStyle  = .none
    }
    // MARK: - TableV// MARK: - ACTIONSiew Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if((self.receiptEntriesFetchedResultsController.fetchedObjects?.count)! > 0){
            tableView.backgroundView = nil
            return self.receiptEntriesFetchedResultsController.fetchedObjects!.count
        }else{
            self.setUpNoDataLabel()
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell : ReceiptEntryTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "receiptEntryCell",
            for: indexPath) as! ReceiptEntryTableViewCell
        
        let receiptEntry  = self.receiptEntriesFetchedResultsController.object(at: indexPath)
        cell.customerNameLabel.text = receiptEntry.customerName ?? "Guest"
        let project = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: receiptEntry.project!)
        if(project != nil){
            cell.projectNameAndUnitNameLabel.text = String(format: "%@ | %d (%@)",receiptEntry.projectName ?? "",receiptEntry.unitIndex,receiptEntry.unitDescription ?? "")
        }
        else{
             cell.projectNameAndUnitNameLabel.text = receiptEntry.unitDescription ?? ""
        }
        cell.amountLabel.text = String(format: " %@ %.2f ", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,receiptEntry.amount)
        cell.dateLabel.text = RRUtilities.sharedInstance.getReceiptEntryDate(dateStr: receiptEntry.updateByDate!)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteSelectedRecieptEntry(_:)), for: .touchUpInside)
        
        cell.deleteButton.isHidden = !isDeletePermitted
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchBarCancelButtonClicked(searchBar)
        let receiptFormController = ReceiptEntryFormViewController(nibName: "ReceiptEntryFormViewController", bundle: nil)
//        print(receiptFormController.selectedReceiptEntry)
        receiptFormController.isEditingReceiptEntry = true
        receiptFormController.selectedReceiptEntry = receiptEntriesFetchedResultsController.object(at: indexPath)
        
        let tempNavigator = UINavigationController.init(rootViewController: receiptFormController)
        tempNavigator.navigationBar.isHidden = true
        self.present(tempNavigator, animated: true, completion: nil)

//        self.navigationController?.pushViewController(receiptFormController, animated: true)
    }
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
     //MARK: - HIDE POP UP
    func didSelectProject(optionType : String,optionIndex: Int){
        
        
        if(isShowingPaymentModePopUp){
            
            selectedPaymentTowards = optionType
            self.fetchAllReceiptEntries()
            paymentTowardsLabel.text = optionType
        }
        
        isShowingUnitTypePopUp = false
        isShowingPaymentModePopUp = false
        
        //        shluldShowBookedAndSoldUnits = false
        //        shouldShowReservedEntries = false
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    func didFinishTask(optionType: String, optionIndex: Int) {
        
        selectedPaymentTowards = "All"
        paymentTowardsLabel.text = selectedPaymentTowards

        if(isShowingUnitTypePopUp){
            unitTypeLabel.text = unitTypeFilterDataSource[optionIndex]
            selectedUnitType = optionType
            if(optionType == "All"){
                shouldShowReservedEntries = false
                shluldShowBookedAndSoldUnits = false
                self.setPaymentToWardsArray(isReserved: false)
                self.fetchAllReceiptEntries()
            }
            else if(optionType == "Reserved"){
                shouldShowReservedEntries = true
                shluldShowBookedAndSoldUnits = false
                self.setPaymentToWardsArray(isReserved: true)
                self.fetchAllReceiptEntries()
            }
            else if(optionType == "Booked/Sold"){
                shluldShowBookedAndSoldUnits = true
                shouldShowReservedEntries = false
                self.setPaymentToWardsArray(isReserved: false)
                self.fetchAllReceiptEntries()
            }
        }

        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });

    }
    
//    func didSelectOptionForUnitsView(selectedIndex: Int) {
//
//    }
//
//    func shouldShowUnitsWithSelectedStatus(selectedStatus: Int) {
//
//    }
//
//    func showSelectedTowerFromFloatButton(selectedTower: Towers, selectedBlock: String) {
//
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
extension ReceiptEntriesViewController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText
        if(searchText.isEmpty){
            self.searchBar.resignFirstResponder()
            self.searchBar.endEditing(true)
            self.view.endEditing(true)
            self.fetchAllReceiptEntries()
            self.tableView.reloadData()
            return
        }

        self.fetchAllReceiptEntries()
        self.tableView.reloadData()

//        var predicate: NSPredicate?
//        if searchText.count > 0 {
//            predicate = NSPredicate(format: "(customerName contains[cd] %@)", searchText)
//        } else {
//            predicate = nil
//        }

//        self.receiptEntriesFetchedResultsController.fetchRequest.predicate = predicate
//
//        do {
//            try receiptEntriesFetchedResultsController!.performFetch()
//            self.tableView.reloadData()
//        } catch let err {
//            print(err)
//        }
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //        print(selectedScope)
        self.searchText = ""
        self.fetchAllReceiptEntries()
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        self.searchText = ""
        self.shouldShowSearchBar(shouldShow: false)
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
        
        self.fetchAllReceiptEntries()
        self.tableView.reloadData()

        // Hide the cancel button
        //        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
//        searchBar.isHidden = true
//        titleLabel.isHidden = false
//        searchButton.isHidden = false
//        reportsButton.isHidden = false
//        notificationsView.isHidden = false
//        self.hideKeyBoard()
//        self.fetchAllProjects()
//        mTableView.reloadData()
    }

}
extension ReceiptEntriesViewController  : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if(controller == self.receiptEntriesFetchedResultsController){
            self.tableView.beginUpdates()
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if(controller == self.receiptEntriesFetchedResultsController){
            switch type {
            case .insert:
                break
            case .delete:
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                self.tableView.reloadData()
                break
            case .update:
                break
            case .move: break
            }
        }
        //        print("B. NSFetchResultController didChange NSFetchedResultsChangeType \(type.rawValue):)")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if(controller == self.receiptEntriesFetchedResultsController){
            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
    }
}
extension ReceiptEntriesViewController : UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRows = self.tableView.visibleCells
        let lastCell = visibleRows.last
        if(lastCell != nil){
            let indexpath = self.tableView.indexPath(for: lastCell!)
            
            if(indexpath!.row == self.receiptEntriesFetchedResultsController.fetchedObjects!.count - 1){
                self.tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 60))
            }else{
                self.tableView.tableFooterView = UIView()
            }
        }
    }
}
