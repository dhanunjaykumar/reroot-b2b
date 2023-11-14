//
//  ApprovalsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 20/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import FloatingPanel

class ApprovalsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,FloatingPanelControllerDelegate {
    
    var approvalType : APPROVAL_TYPES!
    var isIncomingApprovals : Bool = false
    var isDiscountApprovals : Bool = false
    var isFromProspects = false
    var prospectUserName : String!

    @IBOutlet var tableView: UITableView!    
    var searchedText : String = ""
    var selectedIndexPath : IndexPath!
    var fetchedResultsControllerApprovals:NSFetchedResultsController<Approvals> = NSFetchedResultsController.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    func configureView(){
     
        let nib = UINib(nibName: "ApprovalsTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "approvalCell")
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if(isFromProspects){
            self.searchedText = prospectUserName
        }
        self.fetchAllApprovals()
    }
    func fetchAllApprovals(){
        
        let request: NSFetchRequest<Approvals> = Approvals.fetchRequest()
        
        let sort = NSSortDescriptor(key: #keyPath(Approvals.updateByDate), ascending: false)
        request.sortDescriptors = [sort]
        
        if(searchedText.count > 0){
            let predicate = NSPredicate(format: "isIncoming == %d AND approval_type == %d AND (regInfo_userName CONTAINS[c] %@ || customer_name CONTAINS[c] %@)", self.isIncomingApprovals,self.approvalType.rawValue,self.searchedText,self.searchedText)
            request.predicate = predicate
        }
        else{
            let predicate = NSPredicate(format: "isIncoming == %d AND approval_type == %d", self.isIncomingApprovals,self.approvalType.rawValue)
            request.predicate = predicate
        }
        
        fetchedResultsControllerApprovals = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "approval_type", cacheName:nil)
//        fetchedResultsControllerApprovals.delegate = self
        
        do {
            try fetchedResultsControllerApprovals.performFetch()
            self.tableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    // MARK: - SEARCH METHODS
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchedText = searchText
        self.fetchAllApprovals()
                
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        self.searchedText = ""
        self.fetchAllApprovals()

    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchedText = ""
        self.fetchAllApprovals()

    }
    // MARK: - TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(fetchedResultsControllerApprovals.fetchedObjects?.count ?? 0 > 0){
            return fetchedResultsControllerApprovals.fetchedObjects!.count
        }
        else{
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            if(self.isIncomingApprovals){
                noDataLabel.text = "No incoming appovals avaiable"
            }
            else{
                noDataLabel.text = "No outgoing appovals avaiable"
            }
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ApprovalsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "approvalCell",
            for: indexPath) as! ApprovalsTableViewCell
        
        self.configureDiscountApprovalCell(cell: cell, indexPath: indexPath)
        
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
        
        self.dismiss(animated: true, completion: nil)
        
        let fpc = FloatingPanelController()
        
        let approvalFormViewController = ApprovalFormViewController(nibName: "ApprovalFormViewController", bundle: nil)
        
        approvalFormViewController.selectedApproval = self.fetchedResultsControllerApprovals.object(at: indexPath)
        approvalFormViewController.isIncomingApprovals = self.isIncomingApprovals
        approvalFormViewController.approvalType = self.approvalType
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        approvalFormViewController.delegate = self
        
        fpc.delegate = self
        
        self.selectedIndexPath = indexPath
        
        fpc.set(contentViewController: approvalFormViewController)
        
        fpc.track(scrollView: approvalFormViewController.scrollView)

        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        self.present(fpc, animated: true, completion: nil)
        
    }
    func configureDiscountApprovalCell(cell : ApprovalsTableViewCell,indexPath : IndexPath){
        
        
        let approval = self.fetchedResultsControllerApprovals.object(at: indexPath)
        
        cell.nameLabel.text = approval.regInfo_userName ?? approval.customer_name ?? "--"
        cell.byWhomLabel.text = String(format: "by %@", approval.requester_userinfo_name ?? "Super Admin")
        
        let unitInfoStr = String(format: "%@ | %@ | %@ | %@", (approval.unitDescription) ?? "",(approval.blockName) ?? "",(approval.towerName) ?? "",(approval.projectName) ?? "")
        cell.unitInfoLabel.text = unitInfoStr
        cell.unitInfoLabel.textColor = UIColor.hexStringToUIColor(hex: "#80000000")
        let updateBy : UpdateBy = approval.updateBy?.lastObject as! UpdateBy
        cell.timeLabel.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: updateBy.date!, dateFormat: "dd/MM/yy,hh:mm a")
        cell.timeLabel.textColor = UIColor.hexStringToUIColor(hex: "#80000000")
        
    }
    func sendApprovalCountUpdateNotification()
    {
        var infoDict : Dictionary<String,Int> = [:]
        infoDict["count"] = self.fetchedResultsControllerApprovals.fetchedObjects!.count
        if(self.isIncomingApprovals){
            infoDict["pType"] = 0
        }
        else{
            infoDict["pType"] = 1
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.UPDATE_DISC_APPROVALS_COUNT), object: nil, userInfo: infoDict)
    }
    // MARK: - Floating Panel delegate
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  CustomPanelLayout(parent: self)
    }
}
class ApprovalFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .full
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
//        case .half: return 216.0 // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
}
//extension ApprovalsViewController  : NSFetchedResultsControllerDelegate{
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
//        //        print("A. NSFetchResultController controllerWillChangeContent :)")
//        self.tableView.beginUpdates()
//    }
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//        if(controller == self.fetchedResultsControllerApprovals){
//            switch type {
//            case .insert:
//                self.tableView.reloadData()
//                break
//            case .delete:
//                self.tableView.reloadData()
//                break
//            case .update:
//                self.tableView.reloadData()
//                break
//            case .move: break
//            @unknown default:
//                fatalError()
//            }
//        }
//        //        print("B. NSFetchResultController didChange NSFetchedResultsChangeType \(type.rawValue):)")
//    }
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.endUpdates()
////        self.tableView.reloadData()
//    }
//}
extension ApprovalsViewController : ApprovalDelegate{
 
    func didApproveApproval(selectedApproval : Approvals){
        
        let approval = self.fetchedResultsControllerApprovals.object(at: selectedIndexPath)
        RRUtilities.sharedInstance.model.managedObjectContext.delete(approval)
        selectedIndexPath = nil
        RRUtilities.sharedInstance.model.saveContext()
        self.fetchAllApprovals()
        self.tableView.reloadData()
        self.sendApprovalCountUpdateNotification()
    }
    func didClickPdfView(approvalType: APPROVAL_TYPES, selectedApproval: Approvals) {
        
        if(approvalType == APPROVAL_TYPES.BOOKING_FORM_APPROVAL){
            
            self.dismiss(animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let bookingFormPreview = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
            bookingFormPreview.isBookingFormApprovalPdfView = true
            bookingFormPreview.bookingFormPdfViewURL = String(format: RRAPI.API_BOOKING_FORM_APPROVAL_PDF_VIEW, selectedApproval.reference_item_id!)
            let navController = UINavigationController(rootViewController: bookingFormPreview)
            navController.navigationBar.isHidden = true
            self.present(navController, animated: true, completion: nil)

        }

    }

}
