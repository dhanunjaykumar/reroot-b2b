//
//  LeadsAndOpportunitiesViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 25/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class LeadsAndOpportunitiesViewController: UIViewController,UISearchBarDelegate,CAPSPageMenuDelegate {
    
    @IBOutlet var searchButton: UIButton!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var titleView: UIView!
    @IBOutlet var projectNameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    var selectedPageMenuIndex : Int = 0
    
    var callsController : CallsViewController!
    var offersController : OffersViewController!
    var siteVisitsController : SiteVisitsViewController!
    var discountsController : DiscountRequestsViewController!
    var otherTasksController : OtherTasksViewController!
    var notInterestedController : NotInterestedViewController!
    
    
    var prospectDetails : PROSPECT_DETAILS!
    
    var leadsCount : Int = 0
    var projectName : String = ""
    var isLeads : Bool = true
    
    var tabID : Int!
    var projectID : String!
    var statusID : Int?
//    var prospectDetails : REGISTRATIONS_RESULT!

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
        
        projectNameLabel.text = projectName
        
//        NotificationCenter.default.addObserver(self, selector: #selector(changeCounter), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_ON_ACTION), object: nil)

        
        
        if(isLeads)
        {
            titleLabel.text = String(format: "Leads")
        }
        else
        {
            titleLabel.text = String(format: "Opportunities")
        }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var tempLeads = prospectDetails.leads!

        if(isLeads){
             tempLeads = prospectDetails.leads!
        }else{
            tempLeads = prospectDetails.opportunities!
        }

        callsController = storyboard.instantiateViewController(withIdentifier :"callsController") as? CallsViewController
        callsController.isLeads = isLeads
        
        
        if(tempLeads.callCount! > 0)
        {
            callsController.title = String(format: "Calls(%d)", tempLeads.callCount!)
        }
        else
        {
            callsController.title = "Calls"
        }
        
        callsController.statusID = 1
        callsController.tabID = self.tabID
        callsController.projectID = self.projectID
        callsController.callsCount = tempLeads.callCount
        
        offersController = storyboard.instantiateViewController(withIdentifier :"offersController") as? OffersViewController
        offersController.isLeads = isLeads
        
        if(tempLeads.offerCount! > 0)
        {
            offersController.title = String(format: "Offers(%d)", tempLeads.offerCount!)
        }
        else
        {
            offersController.title = "Offers"
        }

//        offersController.title = "Offers"
        offersController.statusID = 2
        offersController.tabID = self.tabID
        offersController.projectID = self.projectID
        offersController.offersCount = tempLeads.offerCount
        
        siteVisitsController = storyboard.instantiateViewController(withIdentifier :"siteVisitsController") as? SiteVisitsViewController
        siteVisitsController.statusID = 3
        siteVisitsController.tabID = self.tabID
        siteVisitsController.projectID = self.projectID
        siteVisitsController.isLeads = isLeads
        
        if(tempLeads.siteVisitCount == nil)
        {
            siteVisitsController.siteVisitsCount = 0
            siteVisitsController.title = "Site Vists"
        }
        else
        {

            if(tempLeads.siteVisitCount! > 0)
            {
                siteVisitsController.title = String(format: "Site Vists(%d)", tempLeads.siteVisitCount!)
            }
            else
            {
                siteVisitsController.title = "Site Vists"
            }

            siteVisitsController.siteVisitsCount = tempLeads.siteVisitCount
        }


        discountsController = storyboard.instantiateViewController(withIdentifier :"discountController") as? DiscountRequestsViewController
        
        if(tempLeads.discountRequestCount! > 0)
        {
            discountsController.title = String(format: "Discount Requests(%d)", tempLeads.discountRequestCount!)
        }
        else
        {
            discountsController.title = "Discount Requests"
        }

        discountsController.isLeads = isLeads
        discountsController.statusID = 4
        discountsController.tabID = self.tabID
        discountsController.projectID = self.projectID
        discountsController.discountsCount = tempLeads.discountRequestCount

        otherTasksController = storyboard.instantiateViewController(withIdentifier :"otherTasksController") as? OtherTasksViewController
        
        if(tempLeads.otherCount! > 0)
        {
            otherTasksController.title = String(format: "Other Tasks(%d)", tempLeads.otherCount!)
        }
        else
        {
            otherTasksController.title = "Other Tasks"
        }

        otherTasksController.isLeads = isLeads
        otherTasksController.statusID = 5
        otherTasksController.tabID = self.tabID
        otherTasksController.projectID = self.projectID
        
        otherTasksController.otherTasksCount = tempLeads.otherCount

        notInterestedController = storyboard.instantiateViewController(withIdentifier :"notInterestedController") as? NotInterestedViewController
        notInterestedController.title = "Not Interested"
        
        if(tempLeads.notInterestedCount! > 0)
        {
            notInterestedController.title = String(format: "Not Interested(%d)", tempLeads.notInterestedCount!)
        }
        else
        {
            notInterestedController.title = "Not Interested"
        }
        notInterestedController.statusID = 6
        notInterestedController.tabID = self.tabID
        notInterestedController.projectID = self.projectID
        notInterestedController.notInteretedCount = tempLeads.notInterestedCount
        notInterestedController.isLeads = isLeads
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        controllerArray.append(callsController)
        controllerArray.append(offersController)
        controllerArray.append(siteVisitsController)
        controllerArray.append(discountsController)
        controllerArray.append(otherTasksController)
        controllerArray.append(notInterestedController)
        
//        let pagingViewController = FixedPagingViewController(viewControllers: controllerArray)
//
//        pagingViewController.menuItemSpacing = 0
//
//        pagingViewController.delegate = self
//
//        pagingViewController.view.frame = CGRect(x: 0.0, y: titleView.frame.size.height + titleView.frame.origin.y + 20, width: self.view.frame.size.width, height: self.view.frame.size.height-(titleView.frame.size.height + titleView.frame.origin.y + 20))
//
//        // Make sure you add the PagingViewController as a child view
//        // controller and contrain it to the edges of the view.
//        addChild(pagingViewController)
//        view.addSubview(pagingViewController.view)
////        view.constrainToEdges(pagingViewController.view)
//        pagingViewController.didMove(toParent: self)
        
        
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.hexStringToUIColor(hex: "f0f7ff")),
            .viewBackgroundColor(UIColor.hexStringToUIColor(hex: "f0f7ff")),
            .selectionIndicatorColor(UIColor.hexStringToUIColor(hex: "548ed1")),
            .bottomMenuHairlineColor(UIColor.white),
            .selectedMenuItemLabelColor(UIColor.hexStringToUIColor(hex: "548ed1")),
            .unselectedMenuItemLabelColor(UIColor.hexStringToUIColor(hex: "4a4d52")),
            .menuItemFont(UIFont(name: "Montserrat-Bold", size: 13.0)!),
            .useMenuLikeSegmentedControl(false),
            .menuHeight(50.0),
            .centerMenuItems(true),
            .menuItemWidthBasedOnTitleTextWidth(true),
        ]
        var yValue = (titleView.frame.size.height + titleView.frame.origin.y + 0)
        
        if(PreSalesViewController.hasTopNotch){
            yValue = (titleView.frame.size.height + titleView.frame.origin.y + 24)
        }
        // Initialize page menu with controller array, frame, and optional parameters
        let pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: yValue, width: self.view.frame.size.width, height: self.view.frame.size.height - yValue), pageMenuOptions: parameters)
        pageMenu.delegate = self
        //(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        //        self.view.addSubview(pageMenu.view)
        self.addChild(pageMenu)
        self.view.addSubview(pageMenu.view)

        pageMenu.didMove(toParent: self)
        
        self.selectedPageMenuIndex = 0
        searchBar.delegate = self
        self.shouldHideSearchBar(shouldHide: false)
    }

    @IBAction func showSearch(_ sender: Any) {
        self.shouldHideSearchBar(shouldHide: true)
    }
    func shouldHideSearchBar(shouldHide : Bool){
        
        titleLabel.isHidden = shouldHide
        projectNameLabel.isHidden = shouldHide
        searchButton.isHidden = shouldHide
        searchBar.isHidden = !shouldHide
        searchBar.showsCancelButton = shouldHide
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - PAGE MENU DELEGATE
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        
    }
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        self.selectedPageMenuIndex = index
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        if(selectedPageMenuIndex == 0){
            callsController.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 1){
            offersController.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 2){
            siteVisitsController.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 3){
            discountsController.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 4){
            otherTasksController.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 5){
            notInterestedController.searchBar(searchBar, textDidChange: searchText)
        }

        
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        
        if(selectedPageMenuIndex == 0){
            callsController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 1){
            offersController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 2){
            siteVisitsController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 3){
            discountsController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 4){
            otherTasksController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 5){
            notInterestedController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }

        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if(selectedPageMenuIndex == 0){
            callsController.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 1){
            offersController.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 2){
            siteVisitsController.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 3){
            discountsController.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 4){
            otherTasksController.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 5){
            notInterestedController.searchBarCancelButtonClicked(searchBar)
        }
        
        self.shouldHideSearchBar(shouldHide: false)
        
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
//extension LeadsAndOpportunitiesViewController: PagingViewControllerDelegate {
//    
//    // We want the size of our paging items to equal the width of the
//    // city title. Parchment does not support self-sizing cells at
//    // the moment, so we have to handle the calculation ourself. We
//    // can access the title string by casting the paging item to a
//    // PagingTitleItem, which is the PagingItem type used by
//    // FixedPagingViewController.
//    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, widthForPagingItem pagingItem: T, isSelected: Bool) -> CGFloat? {
//        guard let item = pagingItem as? PagingIndexItem else { return 0 }
//        
//        let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.menuItemSize.height)
//        let attributes = [NSAttributedString.Key.font: pagingViewController.font]
//        
//        let rect = item.title.boundingRect(with: size,
//                                           options: .usesLineFragmentOrigin,
//                                           attributes: attributes,
//                                           context: nil)
//        
//        let width = ceil(rect.width) + insets.left + insets.right
//        
//        if isSelected {
//            return width * 1.5
//        } else {
//            return width
//        }
//    }
//}
