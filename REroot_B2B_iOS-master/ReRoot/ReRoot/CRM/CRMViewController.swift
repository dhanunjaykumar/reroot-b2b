//
//  CRMViewController.swift
//  REroot
//
//  Created by Dhanunjay on 17/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import PKHUD
import SideMenu

class CRMViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var reportsButton: UIButton!
    @IBOutlet weak var widthOfReportsButton: NSLayoutConstraint!
    var fetchedResultsControllerApprovals:NSFetchedResultsController<Approvals> = NSFetchedResultsController.init()

    var isApprovalScreen : Bool = false
    var approvalsTableViewDataSource : Dictionary<String,Any> = [:]
    var approvalsOrderedMenu : NSMutableOrderedSet = []

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationsCountLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    var tableViewDataSourceArray : Array<String> = []
    
    var inComingApproalsDataSource : [APPROVAL] = []
    var outGoingApproalsDataSource : [APPROVAL] = []
    
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
    @objc func injectable(){
        self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchAllApprovals()
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
            self.configureView()
            self.fetchAllApprovals()

        if(!PermissionsManager.shared.dashBoardPermitted()){
            self.reportsButton.isHidden = true
            self.widthOfReportsButton.constant = 0
        }
        
    }
    // MARK: - ACTIONS
    func fetchAllApprovals(){
        
        fetchedResultsControllerApprovals.delegate = nil
        
        let request: NSFetchRequest<Approvals> = Approvals.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Approvals.unitIndex), ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedResultsControllerApprovals = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "approval_type", cacheName:nil)
        fetchedResultsControllerApprovals.delegate = self
        
        do {
            try fetchedResultsControllerApprovals.performFetch()
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    func getIncomingApprovals(){
//        return
        ServerAPIs.getIncomingApprovals(completionHandler: { (responseObject, erro) in
            if(responseObject){
//                self.inComingApproalsDataSource = (responseObject?.approvals)!
                DispatchQueue.main.async {
                    self.setUpInfoLabel()
                }
            }
            else{
                
            }
        })
    }
    func getOutGoingApprovals(){
//        return
        ServerAPIs.getOutGoingDiscountApprovals(completionHandler: { (responseObject, error) in
            if(responseObject!){
                DispatchQueue.main.async {
                    self.setUpInfoLabel()
                }
            }
            else{
                
            }
        })
    }
    func setUpInfoLabel(){
        
        let totalPedingApprovals = RRUtilities.sharedInstance.model.getAllApprovalCount()
//        if(self.approvalsTableViewDataSource.keys.count > 0){
//            var cellDict : Dictionary<String,Any> = approvalsTableViewDataSource["Discounts"] as! Dictionary<String,Any>
//            cellDict["count"] = RRUtilities.sharedInstance.model.getApprovalsCountByType(approvalType: APPROVAL_TYPES.DISCOUNT_APPROVAL.rawValue)
//            approvalsTableViewDataSource["Discounts"] = cellDict
//            self.tableView.reloadData()
//        }
        infoLabel.text = String(format: "%d Pending Requests", totalPedingApprovals)
        infoLabel.font = UIFont.init(name: "Montserrat-Regular", size: 12)
        self.tableView.reloadData()
    }
    func configureView(){
        
        
        if(PermissionsManager.shared.isSigleTabEabled){
            self.backButton.setImage(UIImage.init(named: "menu"), for: .normal)
        }
        self.updateNotificationCountLabel()
        self.notificationsCountLabel.layer.masksToBounds = true
        notificationsCountLabel.layer.cornerRadius = 10
        
        
        let nib = UINib(nibName: "ProspectsTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "prospectCell")
        
        self.tableView.tableFooterView = UIView()

        if(isApprovalScreen){
            
//            approvalsOrderedMenu.add("Booking forms")
            approvalsOrderedMenu.add("Discounts")
//            approvalsOrderedMenu.add("Payment Scedule Rivision")
//            approvalsOrderedMenu.add("Debit Notes")
//            approvalsOrderedMenu.add("Credit Notes")
            approvalsOrderedMenu.add("Cancel Units")
            approvalsOrderedMenu.add("Assign Units")
            approvalsOrderedMenu.add("Transfer Units")
            approvalsOrderedMenu.add("Booking Forms")
            approvalsOrderedMenu.add("Agreement Prints")
            approvalsOrderedMenu.add("Credit Notes")
            approvalsOrderedMenu.add("Debit Notes")
            
            
            var cellDict : Dictionary<String,Any> = [:]
//            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "007aff")
//            cellDict["text"] = "BA"
//            cellDict["count"] = 0
//            approvalsTableViewDataSource["Booking forms"] = cellDict
            
            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "ff3b30")
            cellDict["text"] = "DA"
            cellDict["count"] = 0
            cellDict["type"] = APPROVAL_TYPES.DISCOUNT_APPROVAL.rawValue
            approvalsTableViewDataSource["Discounts"] = cellDict
            
//            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "4cd964")
//            cellDict["text"] = "PA"
//            cellDict["count"] = 0
//            approvalsTableViewDataSource["Payment Scedule Rivision"] = cellDict
            
            

            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "000000")
            cellDict["text"] = "CU"
            cellDict["count"] = 0
            cellDict["type"] = APPROVAL_TYPES.CANCEL_UNIT_APPROVAL.rawValue
            approvalsTableViewDataSource["Cancel Units"] = cellDict

            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "ff9500")
            cellDict["text"] = "AU"
            cellDict["count"] = 0
            cellDict["type"] = APPROVAL_TYPES.ASSIGN_UNIT_APPROVAL.rawValue
            approvalsTableViewDataSource["Assign Units"] = cellDict

            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "99991d")
            cellDict["text"] = "TU"
            cellDict["count"] = 0
            cellDict["type"] = APPROVAL_TYPES.TRANSFER_UNIT_APPROVAL.rawValue
            approvalsTableViewDataSource["Transfer Units"] = cellDict
            
            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "007aff")
            cellDict["text"] = "BA"
            cellDict["count"] = 0
            cellDict["type"] = APPROVAL_TYPES.BOOKING_FORM_APPROVAL.rawValue
            approvalsTableViewDataSource["Booking Forms"] = cellDict
            
            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "408f2b")
            cellDict["text"] = "AP"
            cellDict["count"] = 0
            cellDict["type"] = APPROVAL_TYPES.AGREEMENTS_PRINT_APPROVAL.rawValue
            approvalsTableViewDataSource["Agreement Prints"] = cellDict
            
            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "EFDD4A")
            cellDict["text"] = "CN"
            cellDict["count"] = 0
            cellDict["type"] = APPROVAL_TYPES.CREDIT_NOTES_APPROVAL.rawValue
            approvalsTableViewDataSource["Credit Notes"] = cellDict

            cellDict["bgColor"] = UIColor.hexStringToUIColor(hex: "56BDAD")
            cellDict["text"] = "DN"
            cellDict["count"] = 0
            cellDict["type"] = APPROVAL_TYPES.DEBIT_NOTES_APPROVAL.rawValue
            approvalsTableViewDataSource["Debit Notes"] = cellDict

            titleLabel.text = "APPROVALS"
            
            self.tableView.delegate = self
            self.tableView.dataSource = self

            RRUtilities.sharedInstance.model.resetEntity(entityName: "Approvals")
            RRUtilities.sharedInstance.model.resetEntity(entityName: "ApprovalHistory")
            RRUtilities.sharedInstance.model.resetEntity(entityName: "BillingInfo")
            RRUtilities.sharedInstance.model.resetEntity(entityName: "ApprovalPricingInfo")

            if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.INCOMING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
                self.getIncomingApprovals()
            }
            if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.OUTGOING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
                self.getOutGoingApprovals()
            }

        }else{

            if(PermissionsManager.shared.isManageUnitsPermitted()){
                tableViewDataSourceArray.append("Manage Units")
            }
            if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
                tableViewDataSourceArray.append("Receipt Entry")
            }
            if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.AGREEMENT_STATUS_TRACKER.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
                tableViewDataSourceArray.append("Agreement Status Tracker")
            }
            
            if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.HANDOVER_SETUP.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
                tableViewDataSourceArray.append("Unit Handover")
            }
            tableViewDataSourceArray.append("Customer Outstandings")

            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    @IBAction func back(_ sender: Any) {
        
        if(PermissionsManager.shared.isSigleTabEabled){
            self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: {
            })
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func showReports(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 11.0, *) {
            let preSalesController = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
            preSalesController.isFromReports = true
            self.navigationController?.pushViewController(preSalesController, animated: true)
            return
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func showNotifications(_ sender: Any) {
        if(RRUtilities.sharedInstance.model.notificationsCount() == 0){
            HUD.flash(.label("There are no notificatins to show"), delay: 1.0)
            self.updateNotificationCountLabel()
            return
        }
        let notificationsController = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationsController, animated: true)
    }
    @objc func updateNotificationCountLabel(){
        let count = RRUtilities.sharedInstance.model.notificationsCount()
        self.notificationsCountLabel.text = String(format: "%d",count)
        if(count > 0){
            self.notificationsCountLabel.isHidden = false
        }else{
            self.notificationsCountLabel.isHidden = true
        }
    }
    // MARK: - NETWORK CALLS
    
    // MARK: - Tableview Methosd
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isApprovalScreen){
            return approvalsOrderedMenu.count
        }
        return tableViewDataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectCell",
            for: indexPath) as! ProspectsTableViewCell
        
        if(isApprovalScreen){
            
            let key : String = approvalsOrderedMenu[indexPath.row] as! String
            let approvalDict : Dictionary<String,Any> = approvalsTableViewDataSource[key] as! Dictionary<String, Any>

            let type = approvalDict["type"] as! Int
            
            let approvalTypeCount = RRUtilities.sharedInstance.model.getApprovalsCountByType(approvalType: type)
            
            cell.titleLabel.text = key
            
            cell.leftImageView.isHidden = true
            cell.widthConstraintOfLeftImageView.constant = 0
            cell.rightImageView.isHidden = true
            cell.widthOfRightImage.constant = 0
            
            cell.widthOfBGView.constant = 60
            cell.approvalTypeBGView.isHidden = false
            cell.leadingConstraintOfTitleLabel.constant = 80
            
            cell.approvalTypeView.layer.cornerRadius = 6
            
            cell.approvalTypeLabel.text = (approvalDict["text"] as! String)
            cell.approvalTypeView.backgroundColor = (approvalDict["bgColor"] as! UIColor)
            
            cell.prospectsCountLabel.text = String(format: "%d", approvalTypeCount)
            
            cell.prospectsCountLabel.isHidden = false
            cell.widthOfApprovalsCountLabel.constant = 40
            
            cell.subContentView.bringSubviewToFront(cell.prospectsCountLabel)
            
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
        
        cell.widthOfRightImage.constant = 0
        cell.rightImageView.isHidden = true
        cell.heightOfSubContentView.constant = 55
        cell.heightOfLeftImageView.constant = 55
        cell.bottomOfSubContentView.constant = 12
        cell.approvalTypeView.isHidden = true
        cell.prospectsCountLabel.isHidden = true
        cell.widthOfApprovalsCountLabel.constant = 0

        cell.titleLabel.text = tableViewDataSourceArray[indexPath.row]
        cell.leftImageView.image = UIImage.init(named: tableViewDataSourceArray[indexPath.row])
        
        cell.titleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 14)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(isApprovalScreen){
            
            //show discount approvals
            
            let key : String = approvalsOrderedMenu[indexPath.row] as! String
            let approvalDict : Dictionary<String,Any> = approvalsTableViewDataSource[key] as! Dictionary<String, Any>
            let type = approvalDict["type"] as! Int
            
            let count = RRUtilities.sharedInstance.model.getApprovalsCountByType(approvalType: type)
            
            if(count > 0){
                let discountApprovalsController = DiscountApprovalsViewController(nibName: "DiscountApprovalsViewController", bundle: nil)
                
                let key : String = approvalsOrderedMenu[indexPath.row] as! String
                let approvalDict : Dictionary<String,Any> = approvalsTableViewDataSource[key] as! Dictionary<String, Any>
                let type = approvalDict["type"] as! Int
                discountApprovalsController.approvalType = APPROVAL_TYPES(rawValue: type)
                
                self.navigationController?.pushViewController(discountApprovalsController, animated: true)
            }
            else{
                if(type == APPROVAL_TYPES.DISCOUNT_APPROVAL.rawValue){
                    HUD.flash(.label("There are no discount approvals"), delay: 1.0)
                }
                else if(type == APPROVAL_TYPES.CANCEL_UNIT_APPROVAL.rawValue){
                    HUD.flash(.label("There are no cancel approvals"), delay: 1.0)
                }
                else if(type == APPROVAL_TYPES.ASSIGN_UNIT_APPROVAL.rawValue){
                    HUD.flash(.label("There are no assign approvals"), delay: 1.0)
                }
                else if(type == APPROVAL_TYPES.TRANSFER_UNIT_APPROVAL.rawValue){
                    HUD.flash(.label("There are no transfer approvals"), delay: 1.0)
                }
                else if(type == APPROVAL_TYPES.BOOKING_FORM_APPROVAL.rawValue){
                    HUD.flash(.label("There are no booking form approvals"), delay: 1.0)
                }
                else if(type == APPROVAL_TYPES.CREDIT_NOTES_APPROVAL.rawValue){
                    HUD.flash(.label("There are no credit note approvals"), delay: 1.0)
                }
                else if(type == APPROVAL_TYPES.DEBIT_NOTES_APPROVAL.rawValue){
                    HUD.flash(.label("There are no debit note approvals"), delay: 1.0)
                }
            }
            return
        }
        
        let selectedRowText = tableViewDataSourceArray[indexPath.row]
        
        if(selectedRowText == "Manage Units"){
            
            let agreeStatusTrackController = AgreementsViewController(nibName: "AgreementsViewController", bundle: nil)
            agreeStatusTrackController.isFromCrm = true
            agreeStatusTrackController.isFromManageUnits = true
            self.navigationController?.pushViewController(agreeStatusTrackController, animated: true)
            
//            let manageUnitsController = ManageUnitsViewController(nibName: "ManageUnitsViewController", bundle: nil)
//            self.navigationController?.pushViewController(manageUnitsController, animated: true)
        }
        else if(selectedRowText == "Receipt Entry"){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let preSalesController = storyboard.instantiateViewController(withIdentifier :"preSales") as! PreSalesViewController
            preSalesController.isReceiptEntry = true
            self.navigationController?.pushViewController(preSalesController, animated: true)
        }
        else if(selectedRowText == "Agreement Status Tracker"){
            
            let agreeStatusTrackController = AgreementsViewController(nibName: "AgreementsViewController", bundle: nil)
            agreeStatusTrackController.isFromCrm = true
            self.navigationController?.pushViewController(agreeStatusTrackController, animated: true)

        }
        else if(selectedRowText == "Unit Handover"){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let handOverController = storyboard.instantiateViewController(withIdentifier :"HO") as! UnitHandoverViewController

//            let unitHandover = UnitHandoverViewController(nibName: "UnitHandoverViewController", bundle: nil)
            self.navigationController?.pushViewController(handOverController, animated: true)
        }
        else if(selectedRowText == "Customer Outstandings"){
            
            let outs = OutstandingsViewController(nibName: "OutstandingsViewController", bundle: nil)
            self.navigationController?.pushViewController(outs, animated: true)

            
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

extension CRMViewController  : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //        print("A. NSFetchResultController controllerWillChangeContent :)")
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if(controller == self.fetchedResultsControllerApprovals){
            switch type {
            case .insert: break
            //                mUnitsCollectionView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete: break
            //                mUnitsCollectionView.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
                //            let cell = mUnitsCollectionView.cellForItem(at: indexPath!) as! UnitDetailsCollectionViewCell
//                mUnitsCollectionView.reloadItems(at: [indexPath!])
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        if(controller == self.fetchedResultsControllerBlocks){
//            self.mTableView.endUpdates()
//        }
//        if(controller == self.fetchedResultsControllerUnits){
//            self.mUnitsCollectionView.reloadData()
//        }
        
        self.setUpInfoLabel()
    }
}
