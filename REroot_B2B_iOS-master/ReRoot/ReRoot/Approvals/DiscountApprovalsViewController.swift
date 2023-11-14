//
//  DiscountApprovalsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 26/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PKHUD

class DiscountApprovalsViewController: UIViewController ,CAPSPageMenuDelegate {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleLabel: UILabel!
    var approvalType : APPROVAL_TYPES!
    @IBOutlet weak var titleView: UIView!
    
    var selectedPageMenuIndex : Int = 0
    var inComingApprovals : ApprovalsViewController!
    var outComingApprovals : ApprovalsViewController!
    var pageMenu: CAPSPageMenu!
    
    var isFromProspects : Bool = false
    var prospectUserName : String!

    // MARK: - View LIfe cycle
    @objc func injectable(){
        
    }
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
        
        self.configureView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateApprovalsCount), name: NSNotification.Name(rawValue: NOTIFICATIONS.UPDATE_DISC_APPROVALS_COUNT), object: nil)
        
        self.shouldShowSearchBar(shouldShow: false)
        self.searchBar.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(isFromProspects){
            if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.OUTGOING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
                self.getOutGoingApprovals()
            }
        }
    }
//    @objc func updateApprovalCount(_ notification: NSNotification){
//
//    }
    func shouldShowSearchBar(shouldShow : Bool){
        searchBar.isHidden = !shouldShow
        searchButton.isHidden = shouldShow
        titleLabel.isHidden = shouldShow
        
    }
    @IBAction func searchApprovals(_ sender: Any) {
        self.shouldShowSearchBar(shouldShow: true)
    }
    func configureView(){
        
        if(approvalType == APPROVAL_TYPES.DISCOUNT_APPROVAL){
            titleLabel.text = "DISCOUNT APPROVALS"
        }
        else if(approvalType == APPROVAL_TYPES.CANCEL_UNIT_APPROVAL){
            titleLabel.text = "CANCEL UNITS APPROVALS"
        }
        else if(approvalType == APPROVAL_TYPES.ASSIGN_UNIT_APPROVAL){
            titleLabel.text = "ASSIGN UNITS APPROVALS"
        }
        else if(approvalType == APPROVAL_TYPES.TRANSFER_UNIT_APPROVAL){
            titleLabel.text = "TRANSFER UNITS APPROVALS"
        }
        else if(approvalType == APPROVAL_TYPES.BOOKING_FORM_APPROVAL){
            titleLabel.text = "BOOKING FORM APPROVALS"
        }
        else if(approvalType == APPROVAL_TYPES.CREDIT_NOTES_APPROVAL){
            titleLabel.text = "CREDIT NOTE APPROVALS"
        }
        else if(approvalType == APPROVAL_TYPES.DEBIT_NOTES_APPROVAL){
            titleLabel.text = "DEBIT NOTE APPROVALS"
        }
        
        var controllerArray : [UIViewController] = []
        
        if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.INCOMING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
            
            inComingApprovals = ApprovalsViewController(nibName: "ApprovalsViewController", bundle: nil)
            inComingApprovals.isIncomingApprovals = true
            inComingApprovals.title = String(format: "INCOMING (%d)", RRUtilities.sharedInstance.model.getIncomingApprovalsByType(approvalType: self.approvalType.rawValue, isIncoming: true))
            inComingApprovals.approvalType = self.approvalType
            controllerArray.append(inComingApprovals)
        }

        if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.OUTGOING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
            
            outComingApprovals = ApprovalsViewController(nibName: "ApprovalsViewController", bundle: nil)
            outComingApprovals.isIncomingApprovals = false
            outComingApprovals.title = String(format: "OUTGOING (%d)", RRUtilities.sharedInstance.model.getIncomingApprovalsByType(approvalType: self.approvalType.rawValue, isIncoming: false))
            outComingApprovals.approvalType = self.approvalType
            outComingApprovals.isFromProspects = self.isFromProspects
            outComingApprovals.prospectUserName = self.prospectUserName
            controllerArray.append(outComingApprovals)
        }

        
        NotificationCenter.default.addObserver(self, selector: #selector(updateApprovalsCount), name: NSNotification.Name(rawValue: NOTIFICATIONS.UPDATE_PROSPECT_COUNT), object: nil)

        let font = UIFont(name: "Montserrat-Bold", size: 12.0)
        
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.hexStringToUIColor(hex: "323f4f")),
            .viewBackgroundColor(UIColor.hexStringToUIColor(hex: "323f4f")),
            .selectionIndicatorColor(UIColor.white),
            .bottomMenuHairlineColor(UIColor.white),
            .menuItemFont(font!),
            .useMenuLikeSegmentedControl(true),
            .menuHeight(50.0),
            .centerMenuItems(true),
            .menuItemSeparatorColor(UIColor.clear),
            .menuItemWidthBasedOnTitleTextWidth(true)
        ]
        
        var yValue = (titleView.frame.size.height + titleView.frame.origin.y + 2)
        
        if(RRUtilities.hasTopNotch){
            yValue = (titleView.frame.size.height + titleView.frame.origin.y + 0)
        }
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: yValue, width: self.view.frame.size.width, height: self.view.frame.size.height - yValue), pageMenuOptions: parameters)
        pageMenu.delegate = self
        
        //(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        //        self.view.addSubview(pageMenu.view)
        self.addChild(pageMenu)
        self.view.addSubview(pageMenu.view)
        
        pageMenu.didMove(toParent: self)

    }
    deinit{
        self.remove()
    }
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    @objc func updateApprovalsCount(_ notification: NSNotification){
        
        if let dict = notification.userInfo as Dictionary? {
            
            self.setCountOfControllers(dict: dict as! Dictionary<String, Int>)
        }
        
    }
    func setCountOfControllers(dict : Dictionary<String, Int>){
        
        let pType : Int = dict["pType"]!
        
        let count : Int = dict["count"]!
        
        switch pType {
        case 0:
            if(count > 0){
                pageMenu.menuItems[pType].titleLabel?.text = String(format: "INCOMING (%d)", count)
            }
            else{
                pageMenu.menuItems[pType].titleLabel?.text = "INCOMING (0)"
            }
            break
        case 1:
            if(count > 0){
                pageMenu.menuItems[pType].titleLabel!.text = String(format: "OUTGOING (%d)", count)
            }
            else{
                pageMenu.menuItems[pType].titleLabel!.text = "OUTGOING (0)"
            }
            break
        default:
            break
        }
        
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - PAGE MENU DELEGATE
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        
    }
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        
        self.selectedPageMenuIndex = index
        
        if(index == 0){
            searchBar.placeholder = "Search approvals"
        }
        else if(index == 1){
            searchBar.placeholder = "Search approvals"
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
extension DiscountApprovalsViewController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(selectedPageMenuIndex == 0){
            inComingApprovals.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 1){
            outComingApprovals.searchBar(searchBar, textDidChange: searchText)
        }
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if(selectedPageMenuIndex == 0){
            inComingApprovals.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 1){
            outComingApprovals.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        
        if(selectedPageMenuIndex == 0){
            inComingApprovals.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 1){
            outComingApprovals.searchBarCancelButtonClicked(searchBar)
        }

        searchBar.isHidden = true
        titleLabel.isHidden = false
        searchButton.isHidden = false
    }
    func hideKeyBoard()
    {
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
    }
    func getOutGoingApprovals(){
    
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Approvals")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "ApprovalHistory")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "BillingInfo")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "ApprovalPricingInfo")

        HUD.show(.progress)
        ServerAPIs.getOutGoingDiscountApprovals(completionHandler: { (responseObject, error) in
            
            DispatchQueue.main.async { [weak self] in
                HUD.hide()
                if(responseObject!){
                    self?.pageMenu.moveToPage(1)
                    self?.searchBar.text = self?.prospectUserName
                    self?.shouldShowSearchBar(shouldShow: true)
                }
                else{
                    HUD.flash(.label("Failed to fetch approvals."), delay: 1.0)
                }
            }
        })
    }

}
