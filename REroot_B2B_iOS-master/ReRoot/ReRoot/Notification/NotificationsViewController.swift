//
//  NotificationsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 28/02/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import PKHUD
import FloatingPanel

class NotificationsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var celarAllButton: UIButton!
    @IBOutlet var priorityButton: UISwitch!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    var notificationsFetchedResultsController : NSFetchedResultsController<Notifications>!
    @IBOutlet var titleView: UIView!
    var indexPathForDeletion : IndexPath! = nil
    
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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                
        NotificationCenter.default.addObserver(self, selector: #selector(deleteNotificationOnStatusChange), name: NSNotification.Name(rawValue: NOTIFICATIONS.DELETE_NOTIFICATION), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchNotifications), name: NSNotification.Name(rawValue: "FetchNotifications"), object: nil)

        
        priorityButton.isOn = false
        
        celarAllButton.layer.cornerRadius = 16
        celarAllButton.layer.borderWidth = 0.5
        celarAllButton.layer.borderColor = UIColor.lightGray.cgColor
        
        self.fetchNotifications()
        
        let nib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "notificationCell")

        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension

        tableView.delegate = self
        tableView.dataSource = self
    }
    @objc func deleteNotificationOnStatusChange(){
        self.deleteNotification(indexPath: self.indexPathForDeletion, completion: { _ in
            // Post complete notification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)
        })
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func clearAllNotifications(_ sender: Any) {
        self.clearAllNotifications()
    }
    @IBAction func showOnlyPriorityNotifications(_ sender: Any) {
        self.fetchNotifications()
        self.tableView.reloadData()
    }
    @objc func fetchNotifications(){
        
        let request: NSFetchRequest<Notifications> = Notifications.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Notifications.created_at), ascending: false)
        request.sortDescriptors = [sort]
        
        if(priorityButton.isOn){
            let predicate = NSPredicate(format: "isPriority == %d", priorityButton.isOn)
            request.predicate = predicate
        }
        
        notificationsFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        notificationsFetchedResultsController?.delegate = self
        
        do {
            try notificationsFetchedResultsController?.performFetch()
//            let count = RRUtilities.sharedInstance.model.notificationsCount()
            if(notificationsFetchedResultsController.fetchedObjects!.count > 0){
                self.titleLabel.text = String(format: "NOTIFICATIONS (%d)", notificationsFetchedResultsController.fetchedObjects!.count)
            }
            else{
                self.titleLabel.text = String(format: "NOTIFICATIONS")
            }
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    // MARK: - Tableview Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((notificationsFetchedResultsController.fetchedObjects?.count)! > 0)
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
        return (notificationsFetchedResultsController.fetchedObjects?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : NotificationTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "notificationCell",
            for: indexPath) as! NotificationTableViewCell
        
        let notification = notificationsFetchedResultsController.object(at: indexPath)
        
        let attr1 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-Bold", size: 12), NSAttributedString.Key.foregroundColor : UIColor.hexStringToUIColor(hex: "34495e")]
        let attributedString1 = NSMutableAttributedString(string:String(format: "%@ - ", notification.type!), attributes:attr1 as [NSAttributedString.Key : Any])
        let attr2 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-Medium", size: 12), NSAttributedString.Key.foregroundColor : UIColor.hexStringToUIColor(hex: "34495e")]
        let attributedString2 = NSMutableAttributedString(string:notification.msg!, attributes:attr2 as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)

        cell.messageLabel.attributedText = attributedString1
        
        cell.prospectTypeLabel.text = notification.prospectType
        cell.dateLabel.text = RRUtilities.sharedInstance.getNotificationViewDate(dateStr: notification.created_at!)  //notification.created_at
        
        if(notification.isAccepted == 1){
            cell.typeIndicator.backgroundColor = UIColor.hexStringToUIColor(hex: "3ba21b")
        }
        else if(notification.isAccepted == 2){
            cell.typeIndicator.backgroundColor = UIColor.hexStringToUIColor(hex: "cd0a27")
        }
        else if(notification.isAccepted == 0){
            cell.typeIndicator.backgroundColor = UIColor.hexStringToUIColor(hex: "4d92df")
        }
        cell.textLabel?.font = UIFont.init(name: "Montserrat-Bold", size: 12)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notification = notificationsFetchedResultsController.object(at: indexPath)
        
        
        if(notification.type == "Prospect Call Missed" || notification.type == "Prospect Call Scheduled" || notification.type == NOTIFICATION_TYPES.PROSPECT_CALL_REMINDER.rawValue){
            if(notification.refererenceItem == nil || notification.refererenceItem?.isEmpty ?? false){
                HUD.flash(.label("Prospect doesn't exist"), delay: 1.0)
                return
            }

            print("Prospect Call Missed")
            HUD.show(.progress, onView: self.view)
            
            ServerAPIs.getProspectById(pid: notification.refererenceItem ?? "", completion: { [unowned self] result in
                HUD.hide()
                switch result {
                case .success(let result):
                    
                    //                    let resultStr = result ? "Completion Date edited succesfully" : "Faild to add Completion Date"
                    //                    HUD.flash(.label(resultStr), delay: 1.5)
                    
                    self.indexPathForDeletion = indexPath
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailsController = storyboard.instantiateViewController(withIdentifier :"cusDetailsController") as! CustomerDetailsViewController
                    detailsController.prospectDetails = result
                    detailsController.tabId = 1 //self.tabID
                    detailsController.statusID = 1
                    detailsController.isFromNotification = true
                    
                    if(result.type == "L"){
                        detailsController.viewType = VIEW_TYPE.LEADS
                        //                    detailsController.tabId = 2
                        detailsController.prospectType = .LEADS
                    }
                    else if(result.type == "O"){
                        detailsController.viewType = VIEW_TYPE.OPPORTUNITIES
                        detailsController.prospectType = .OPPORTUNITIES
                    }
                    self.navigationController?.pushViewController(detailsController, animated: true)
                    
                    break
                case .failure(let error):
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    break
                }
                
            })
            
        }
        else if(notification.type == "Site Visit Scheduled"){
            print("Site Visit Scheduled")
            
            if(notification.refererenceItem == nil || notification.refererenceItem?.isEmpty ?? false){
                HUD.flash(.label("Prospect doesn't exist"), delay: 1.0)
                return
            }

            ServerAPIs.getProspectById(pid: notification.refererenceItem ?? "", completion: { [unowned self] result in
                HUD.hide()
                switch result {
                case .success(let result):
                    
                    //                    let resultStr = result ? "Completion Date edited succesfully" : "Faild to add Completion Date"
                    //                    HUD.flash(.label(resultStr), delay: 1.5)
                    
                    self.indexPathForDeletion = indexPath
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailsController = storyboard.instantiateViewController(withIdentifier :"cusDetailsController") as! CustomerDetailsViewController
                    detailsController.prospectDetails = result
                    detailsController.tabId = 1 //self.tabID
                    detailsController.statusID = 3
                    detailsController.isFromNotification = true
                    
                    if(result.type == "L"){
                        detailsController.viewType = VIEW_TYPE.LEADS
                        //                    detailsController.tabId = 2
                        detailsController.prospectType = .LEADS
                    }
                    else if(result.type == "O"){
                        detailsController.viewType = VIEW_TYPE.OPPORTUNITIES
                        detailsController.prospectType = .OPPORTUNITIES
                    }
                    self.navigationController?.pushViewController(detailsController, animated: true)
                    
                    break
                case .failure(let error):
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    break
                }
                
            })
        }
        else if(notification.type == NOTIFICATION_TYPES.DISCOUNT_REQUEST.rawValue || notification.type == NOTIFICATION_TYPES.APPROVED_DISCOUNT_REQUEST.rawValue || notification.type == NOTIFICATION_TYPES.REJECTED_DISCOUNT_REQUEST.rawValue){
            
            print(notification)
            
        }
        else if(notification.type == NOTIFICATION_TYPES.DISCOUNT_APPROVAL.rawValue){
            
            print(notification)
            
            if(notification.refererenceItem == nil || notification.refererenceItem?.isEmpty ?? false){
                HUD.flash(.label("Approval data not available"), delay: 1.0)
                return
            }
            HUD.show(.progress, onView: self.view)
            ServerAPIs.getApprovalById(approvalId: notification.refererenceItem ?? "", completion: { result in
                HUD.hide()
                
                switch result {
                case .success(let result):
                    
                    let tempApproval = result
                    let entity = NSEntityDescription.entity(forEntityName: "Approvals", in: RRUtilities.sharedInstance.model.managedObjectContext)

                    let newApproval = NSManagedObject.init(entity: entity!, insertInto: nil) as! Approvals

                    newApproval.kind = tempApproval.reference?.kind
                    newApproval.reference_item_id = tempApproval.reference?.item?._id
                    newApproval.id = tempApproval._id
                    newApproval.status = Int16(tempApproval.status!)
                    newApproval.level = Int16(tempApproval.level!)
                    newApproval.company_group = tempApproval.company_group
                    newApproval.unit = tempApproval.unit
                    
                    newApproval.approval_type = Int16(tempApproval.approval_type!)
//                    newApproval.isIncoming = isIncoming
                    
                    newApproval.requester_id = tempApproval.requester?._id
                    newApproval.requester_email = tempApproval.requester?.email
                    newApproval.requester_userinfo_id = tempApproval.requester?.userInfo?._id
                    newApproval.requester_userinfo_name = tempApproval.requester?.userInfo?.name
                    newApproval.requester_userinfo_email = tempApproval.requester?.userInfo?.email
                    newApproval.requester_userinfo_phone = tempApproval.requester?.userInfo?.phone
                    
                    newApproval.approver_id = tempApproval.approver?._id
                    newApproval.approver_email = tempApproval.approver?.email
                    newApproval.approver_userinfo_id = tempApproval.approver?.userInfo?._id
                    newApproval.approver_userinfo_name = tempApproval.approver?.userInfo?.name
                    newApproval.approver_userinfo_email = tempApproval.approver?.userInfo?.email
                    newApproval.approver_userinfo_phone = tempApproval.approver?.userInfo?.phone
                    
                    newApproval.regInfo_id = tempApproval.reference?.item?.regInfo?._id
                    newApproval.regInfo_userName = tempApproval.reference?.item?.regInfo?.userName
                    newApproval.regInfo_userEmail = tempApproval.reference?.item?.regInfo?.userEmail
                    newApproval.regInfo_userPhone = tempApproval.reference?.item?.regInfo?.userPhone
                    newApproval.scheme = tempApproval.reference?.item?.scheme
                    
                    if tempApproval.reference?.item?.unit is String{
                        
                    }
                    else{
                        if(tempApproval.reference!.item?.unit != nil){
                            newApproval.unitIndex = Int64(tempApproval.reference?.item?.unit?.unitNo?.index ?? 0)
                            newApproval.unitDisplayName = tempApproval.reference?.item?.unit?.unitNo?.displayName
                        }
                    }
                    
                    newApproval.projectId = tempApproval.reference?.item?.unit?.project?._id
                    newApproval.projectName = tempApproval.reference?.item?.unit?.project?.name
                    
                    newApproval.towerId = tempApproval.reference?.item?.unit?.tower?._id
                    newApproval.towerName = tempApproval.reference?.item?.unit?.tower?.name
                    
                    newApproval.blockId = tempApproval.reference?.item?.unit?.block?._id
                    newApproval.blockName = tempApproval.reference?.item?.unit?.block?.name
                    newApproval.unitDescription = tempApproval.reference?.item?.unit?.description
                    newApproval.unit_type_id = tempApproval.reference?.item?.unit?.type?._id
                    newApproval.unit_type_name = tempApproval.reference?.item?.unit?.type?.name
                    
                    newApproval.customer_id = tempApproval.reference?.item?.customer?._id
                    newApproval.customer_name = tempApproval.reference?.item?.customer?.name
                    newApproval.customer_email = tempApproval.reference?.item?.customer?.email
                    //                print(String(format: "%ld", (tempApproval.reference?.item?.customer?.phone) ?? 0))
                    
                    if(tempApproval.reference?.item?.customer?.phone != nil){
                        newApproval.customer_phone = String(format: "%ld", (tempApproval.reference?.item?.customer?.phone) ?? 0)
                    }
                    
                    newApproval.updateByDate = tempApproval.updateBy?.last?.date
                    
                    newApproval.new_customer_id = tempApproval.reference?.item?.new_customer?._id
                    newApproval.new_customer_name = tempApproval.reference?.item?.new_customer?.userName
                    
                    newApproval.pdc_return_date = tempApproval.reference?.item?.pdc_return_date
                    newApproval.agreement_collected_date = tempApproval.reference?.item?.agreement_collected_date
                    newApproval.cancellation_date = tempApproval.reference?.item?.cancellation_date
                    newApproval.cancel_reason = tempApproval.reference?.item?.cancel_reason
                    
                    if(tempApproval.approvalHistory != nil){
                        var counter = 0
                        for tempHistory in tempApproval.approvalHistory!{
                            
                            let newHistoryRow = NSEntityDescription.insertNewObject(forEntityName: "ApprovalHistory", into: RRUtilities.sharedInstance.model.managedObjectContext) as! ApprovalHistory
                            
                            counter += 1
                            newHistoryRow.orderID = Int32(counter)
                            newHistoryRow.approver_id = tempApproval._id
                            newHistoryRow.approval_type = Int16(tempApproval.approval_type!)
                            newHistoryRow.level = Int16(tempHistory.level!)
                            newHistoryRow.rejectReason = tempHistory.rejectReason
                            newHistoryRow.remarks = tempHistory.remarks
                            newHistoryRow.created = tempHistory.created
                            newHistoryRow.lastModified = tempHistory.lastModified
                            newHistoryRow.status = Int64(tempHistory.status!)
                            
                            newHistoryRow.approver_id = tempHistory.approver?._id
                            newHistoryRow.approver_email = tempHistory.approver?.email
                            newHistoryRow.approver_userinfo_id = tempHistory.approver?.userInfo?._id
                            newHistoryRow.approver_userinfo_phone = tempHistory.approver?.userInfo?.phone
                            newHistoryRow.approver_userinfo_name = tempHistory.approver?.userInfo?.name
                            newHistoryRow.approver_userinfo_email = tempHistory.approver?.userInfo?.email
                            
                            newApproval.addToHistory(newHistoryRow)
                            
                        }
                    }
                    
                    
                    
                    var counter = 0
                    if(tempApproval.reference?.item?.billingsInfo != nil){
                        
                        for tempBillingInfo in (tempApproval.reference?.item?.billingsInfo)!{
                            
                            let billingInfo = NSEntityDescription.insertNewObject(forEntityName: "BillingInfo", into: RRUtilities.sharedInstance.model.managedObjectContext) as! BillingInfo
                            
                            counter += 1
                            
                            billingInfo.orderID = Int32(counter)
                            billingInfo.id = tempBillingInfo._id
                            billingInfo.approval_id = tempApproval._id
                            billingInfo.approval_type = Int16(tempApproval.approval_type!)
                            billingInfo.billingElement_id = tempBillingInfo.billingElement?._id
                            billingInfo.billingElement_name = tempBillingInfo.billingElement?.name
                            billingInfo.sub_BillingElement_name = tempBillingInfo.nbilling?.name
                            billingInfo.billingElement_type =  Int16(tempBillingInfo.billingElement!.elementType!)
                            billingInfo.billingElement_agreeValItem = Int16(tempBillingInfo.billingElement!.agreeValItem!)
                            billingInfo.discountedAmt = tempBillingInfo.discountedAmt ?? 0.0
                            billingInfo.discountedRate = tempBillingInfo.discountedRate ?? 0.0
                            billingInfo.discountedPercent = tempBillingInfo.discountedPercent ?? 0.0
                            billingInfo.discountOnRate = tempBillingInfo.discountOnRate ?? 0.0
                            billingInfo.rate = tempBillingInfo.rate ?? 0.0
//                            billingInfo.isIncoming = isIncoming
                            if(tempBillingInfo.qty != nil){
                                billingInfo.qty = tempBillingInfo.qty!
                            }
                            billingInfo.type = tempBillingInfo.type
                            
                            newApproval.addToBillingInfos(billingInfo)
                        }
                    }
                    
                    for tempUpdateBy in tempApproval.updateBy ?? []{
                        
                        let updateBy = NSEntityDescription.insertNewObject(forEntityName: "UpdateBy", into: RRUtilities.sharedInstance.model.managedObjectContext) as! UpdateBy
                        
                        updateBy.approval_id = tempApproval._id
                        updateBy.approval_type = Int16(tempApproval.approval_type!)
                        updateBy.date = tempUpdateBy.date
                        updateBy.descp = tempUpdateBy.descp
                        updateBy.src = Int32(tempUpdateBy.src!)
                        updateBy.isApproval = true
                        updateBy.id = tempUpdateBy._id
                        updateBy.user = tempUpdateBy.user
                        
                        newApproval.addToUpdateBy(updateBy)
                    }
                    
                    if(tempApproval.reference?.item?.pricingInfo != nil){
                        
                        let pricingInfo = NSEntityDescription.insertNewObject(forEntityName: "ApprovalPricingInfo", into: RRUtilities.sharedInstance.model.managedObjectContext) as! ApprovalPricingInfo
                        
                        pricingInfo.approval_id = tempApproval._id
                        pricingInfo.approval_type = Int16(tempApproval.approval_type!)
                        //                    pricingInfo.isIncoming = isIncoming
                        
                        let approvalPricingInfo = tempApproval.reference!.item!.pricingInfo!
                        pricingInfo.waiveOffCharges = approvalPricingInfo.waive_off_charges ?? 0.0
                        pricingInfo.transferChargePayableBy = approvalPricingInfo.transfer_charge_payable_by ?? 0.0
                        pricingInfo.taxPaid = approvalPricingInfo.tax_paid ?? 0.0
                        pricingInfo.taxReceived = approvalPricingInfo.tax_received ?? 0.0
                        pricingInfo.taxAmountRefund = approvalPricingInfo.tax_amount_refund ?? 0.0
                        pricingInfo.isTaxAmountRefund = approvalPricingInfo.is_tax_amount_refund ?? false
                        
                        pricingInfo.demandLetterAmount = approvalPricingInfo.demand_letter_amount ?? 0.0
                        pricingInfo.cancellationCharge = approvalPricingInfo.cancellation_charge ?? 0.0
                        pricingInfo.cancellationChargeTax = approvalPricingInfo.cancellation_charge_tax ?? 0.0
                        
                        pricingInfo.amountDue = approvalPricingInfo.amount_due ?? 0.0
                        pricingInfo.amountPayable = approvalPricingInfo.amount_payable ?? 0.0
                        pricingInfo.amountReceived = approvalPricingInfo.amount_received ?? 0.0
                        pricingInfo.assignmentCharge = approvalPricingInfo.assignment_charge ?? 0.0
                        pricingInfo.assignmentChargeDebitNoteReference = approvalPricingInfo.assignment_charge_debit_note_reference ?? ""
                        pricingInfo.assignmentChargeReceiptReference = approvalPricingInfo.assignment_charge_receipt_reference ?? ""
                        pricingInfo.assignmentChargeTax = approvalPricingInfo.assignment_charge_tax ?? 0.0
                        
                        newApproval.pricingInfo = pricingInfo
                        
                    }
                    
//                    let approvalForm = ApprovalFormViewController(nibName: "ApprovalFormViewController", bundle: nil)
//                    self.navigationController?.pushViewController(approvalForm, animated: true)
                    
                    let fpc = FloatingPanelController()
                    
                    let approvalFormViewController = ApprovalFormViewController(nibName: "ApprovalFormViewController", bundle: nil)
                    
                    approvalFormViewController.approvalType = APPROVAL_TYPES.DISCOUNT_APPROVAL
                    approvalFormViewController.selectedApproval = newApproval
                    approvalFormViewController.isFromNotification = true
                    approvalFormViewController.isIncomingApprovals = true

                    fpc.surfaceView.cornerRadius = 6.0
                    fpc.surfaceView.shadowHidden = false
                    
//                    approvalFormViewController.delegate = self
                    
                    fpc.delegate = self
                    
//                    self.selectedIndexPath = indexPath
                    
                    fpc.set(contentViewController: approvalFormViewController)
                    
                    fpc.track(scrollView: approvalFormViewController.scrollView)

                    fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
                    
                    self.present(fpc, animated: true, completion: nil)

                    
                    break
                case .failure(let error):
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    break
                }

                
                
                
            })

        }
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Mark As Read") { (rowAction, indexPath) in
            //TODO: edit the row at indexPath here
            print("Mark as read")
            //(indexPath: indexPath)
            self.deleteNotification(indexPath: indexPath, completion: { _ in
                
            })
            //delete row
        }
        editAction.backgroundColor = .blue
        return [editAction]
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            
            // remove the item from the data model
//            animals.remove(at: indexPath.row)
            
            // delete the table view row
//            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    func deleteNotification(indexPath : IndexPath,completion: @escaping (Result<Bool, Error>) -> ()){
        
        let notification = self.notificationsFetchedResultsController.object(at: indexPath)
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var parameters : Dictionary<String,String> = [:]
        parameters["notification"] = notification.id
        parameters["src"] = "3"
        
        AF.request(RRAPI.API_MARK_NOTIFICATION_AS_READ, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                HUD.hide()
                let urlResult = try! JSONDecoder().decode(NOTIFICATIONS_OUTPUT.self, from: responseData)
                
                if(urlResult.status == -1 ){
                    RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                    return
                }
                else{
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.model.managedObjectContext.delete(notification)
                        RRUtilities.sharedInstance.model.saveContext()
                        self.fetchNotifications()
                        NotificationCenter.default.post(name: NSNotification.Name("NotificationsAction"), object: nil)
                        completion(.success(true))
                    }
                }
                
                break
            case .failure(let error):
                print(error)
                completion(.failure(error))
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
                break
            }
        }
    }
    func clearAllNotifications(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        var parameters : Dictionary<String,Any> = [:]
        parameters["src"] = 3
        AF.request(RRAPI.API_CLEAR_ALL_NOTIFICATIONS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                HUD.hide()
                let urlResult = try! JSONDecoder().decode(NOTIFICATIONS_OUTPUT.self, from: responseData)
                
                if(urlResult.status == -1 ){
                    RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                    return
                }
                else{
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.model.resetEntity(entityName: "Notifications")
                        self.fetchNotifications()
                        self.tableView.reloadData()
                        HUD.flash(.label("Cleared All Notifications"), delay: 1.0)
                        NotificationCenter.default.post(name: NSNotification.Name("NotificationsAction"), object: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension NotificationsViewController  : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /*This delegate method will be called first.As the name of this method "controllerWillChangeContent" suggets write some logic for table view to initiate insert row or delete row or update row process. After beginUpdates method the next call will be for :
         
         - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
         
         */
        print("A. NSFetchResultController controllerWillChangeContent :)")
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if(controller == self.notificationsFetchedResultsController){
            switch type {
            case .insert: break
            //                mUnitsCollectionView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
            //                mUnitsCollectionView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
                break
            case .update:
                //            let cell = mUnitsCollectionView.cellForItem(at: indexPath!) as! UnitDetailsCollectionViewCell
//                mUnitsCollectionView.reloadItems(at: [indexPath!])
                tableView.reloadRows(at: [indexPath!], with: .automatic)
                break
                //                let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
            //                configure(cell: cell, for: indexPath!)
            case .move: break
                //                tableView.deleteRows(at: [indexPath!], with: .automatic)
                //                tableView.insertRows(at: [newIndexPath!], with: .automatic)
            }
        }
        //        print("B. NSFetchResultController didChange NSFetchedResultsChangeType \(type.rawValue):)")
    }
    /*The last delegate call*/
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
extension NotificationsViewController : FloatingPanelControllerDelegate{
    // MARK: - Floating Panel delegate
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  CustomPanelLayout(parent: self)
    }
}
