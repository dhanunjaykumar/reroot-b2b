//
//  PreSalesViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 30/08/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import Alamofire
import PKHUD
import SideMenu
import FloatingPanel

class PreSalesViewController: UIViewController,UISearchBarDelegate ,CAPSPageMenuDelegate,UICollectionViewDelegate,UICollectionViewDataSource,ParallaxDelegate ,FloatingPanelControllerDelegate{
    
    //srinivas.vunnam@irarealty.in
    //srinivas@1256
    
    @IBOutlet weak var heightOfDateView: NSLayoutConstraint!
    @IBOutlet weak var heightOfProspectCountLabel: NSLayoutConstraint!
    var startDate : Date!
    var endDate : Date!
    var isFromStartDateButton = false
    let fpc = FloatingPanelController()
    @IBOutlet weak var prospectsCountLabel: UILabel!
    @IBOutlet weak var toDateButton: UIButton!
    @IBOutlet weak var fromDateButton: UIButton!
    var oldContentOffset = CGPoint.zero
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    
    var prospectsCount : PROSPECT_COUNT_OUTPUT?
    
    @IBOutlet weak var notificationsCountLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var notificationsInfoView: UIView!
    @IBOutlet weak var pageMenuHolderView: UIView!
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    var isReceiptEntry : Bool = false
    @IBOutlet weak var collectionView: UICollectionView!
    var collectionViewDataSource : [String] = []
    var prsopectsTypeCountsDict : Dictionary<String,Int> = [:]
    var tableViewDataSource : Array<PROSPECT_DETAILS> = []

    @IBOutlet weak var reportsButton: UIButton!
    var projectsWiseController : ProjectWiseViewController!
    var salesWiseController : SalesPersonWiseViewController!
    var enquiryWiseController : EnquiryWiseViewController!
    var idleViewController : IdleViewController!
    
    @IBOutlet weak var titleLabel: UILabel!
    var pageMenu : CAPSPageMenu!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var widthOfReportsButton: NSLayoutConstraint!
    
    var selectedPageMenuIndex : Int = 0
    
    @objc func injected() {
//        configureView()
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
//        titleView.isHidden = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 1.0, animations: {
            self.pageMenu.view.frame = CGRect(x: 0.0, y:0.0, width: self.view.frame.size.width, height: self.pageMenuHolderView.frame.size.height)
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
             statusBar.backgroundColor = .white
             UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            UIApplication.shared.statusBarView?.backgroundColor =  .white //UIColor.init(red: 243/250, green: 243/250, blue: 243/250, alpha: 1)
            
        }

//        RRUtilities.sharedInstance.prospectsStartDate = "1899-12-01T00:00:00"
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar,
                                            year: 1899,
                                            month: 12,
                                            day: 01,hour: 00,minute: 00,second: 00)
        let date = calendar.date(from: dateComponents)! // 2018-10-10
//        print(date)
        RRUtilities.sharedInstance.prospectsSDate = date
        RRUtilities.sharedInstance.prospectsEDate = Date()
        
        RRUtilities.sharedInstance.prospectsStartDate = RRUtilities.sharedInstance.prospectDateInGMTFormat(date: date, isFromDate: true)
        RRUtilities.sharedInstance.prospectsEndDate = RRUtilities.sharedInstance.prospectDateInGMTFormat(date: Date(), isFromDate: false)
            //RRUtilities.sharedInstance.getProspectDateFormat(date: Date(),isFromDate: false)
        
        self.updateDates()
        
        let image: UIImage? = UIImage.init(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        fromDateButton.setImage(image, for: .normal)
        fromDateButton.imageView?.tintColor = UIColor.white
        
        let image1: UIImage? = UIImage.init(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        toDateButton.setImage(image1, for: .normal)
        toDateButton.imageView?.tintColor = UIColor.white

        
        if(isReceiptEntry){
            self.titleLabel.text = "RECEIPT ENTRY"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(getProspectsCount), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        projectsWiseController = storyboard.instantiateViewController(withIdentifier :"projectWise") as? ProjectWiseViewController
        projectsWiseController.title = "Projectwise"
        projectsWiseController.delegate = self
        projectsWiseController.isReceiptEntry = self.isReceiptEntry
        salesWiseController = storyboard.instantiateViewController(withIdentifier :"salesWise") as? SalesPersonWiseViewController
//        if(!isReceiptEntry){
//            salesWiseController.title = "Sales Personwise"
//        }
//        else{
            salesWiseController.title = "Userwise"
//        }
        salesWiseController.isReceiptEntry = self.isReceiptEntry
        salesWiseController.delegate = self
        enquiryWiseController = storyboard.instantiateViewController(withIdentifier :"enquiryWise") as? EnquiryWiseViewController
        if(!isReceiptEntry){
            enquiryWiseController.title = "Enquirywise"
        }
        else{
            enquiryWiseController.title = "Paymentwise"
        }
        enquiryWiseController.isReceiptEntry = self.isReceiptEntry
        enquiryWiseController.delegate = self

        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        controllerArray.append(projectsWiseController)
        controllerArray.append(salesWiseController)
        controllerArray.append(enquiryWiseController)
        
        salesWiseController.addObservers()
        enquiryWiseController.addObservers()

        
        if(!isReceiptEntry){
            
            idleViewController = IdleViewController(nibName: "IdleViewController", bundle: nil)
            idleViewController.title = "Idle"
            idleViewController.delegate = self
            controllerArray.append(idleViewController)
            idleViewController.addObservers()
        }
        
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
//        let controller : UIViewController = UIViewController(nibName: "controllerNibName", bundle: nil)
//        controller.title = "SAMPLE TITLE"
//        controllerArray.append(controller)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
//        var parameters: [CAPSPageMenuOption] = [
//            .menuItemSeparatorWidth(4.3),
//            .useMenuLikeSegmentedControl(true),
//            .menuItemSeparatorPercentageHeight(0.1),
//            .centerMenuItems(true)
//        ]
//        parameters.append(.menuItemWidthBasedOnTitleTextWidth(true))
        
        var font = UIFont(name: "Montserrat-Bold", size: 11.0)
        
        if(UIDevice.current.screenType == .iPhones_5_5s_5c_SE){
            font = UIFont(name: "Montserrat-Bold", size: 11.0)
        }
        else{
            font = UIFont(name: "Montserrat-Bold", size: 12.0)
        }
        
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.hexStringToUIColor(hex: "323f4f")),
            .viewBackgroundColor(UIColor.hexStringToUIColor(hex: "323f4f")),
            .selectionIndicatorColor(UIColor.white),
            .bottomMenuHairlineColor(UIColor.white),
            .menuItemFont(font!),
            .useMenuLikeSegmentedControl(true),
            .menuHeight(60.0),
            .centerMenuItems(true),
            .menuItemSeparatorColor(UIColor.clear),
            .menuItemWidthBasedOnTitleTextWidth(true)
        ]
        // Initialize page menu with controller array, frame, and optional parameters

//        print(RRUtilities.hasTopNotch)
//        print(titleView.frame.size.height + titleView.frame.origin.y)
//        print(titleView.frame)
        
        var yValue = (titleView.frame.size.height + titleView.frame.origin.y + 130)
        
        if(RRUtilities.hasTopNotch){
            yValue = (titleView.frame.size.height + titleView.frame.origin.y + 24 + 130)
        }
        
        if(isReceiptEntry){
            yValue = (titleView.frame.size.height + titleView.frame.origin.y)
            
            if(RRUtilities.hasTopNotch){
                yValue = (titleView.frame.size.height + titleView.frame.origin.y + 24)
            }
        }
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y:0.0, width: self.view.frame.size.width, height: self.pageMenuHolderView.frame.size.height), pageMenuOptions: parameters)
        //(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
//        self.view.addSubview(pageMenu.view)
        self.addChild(pageMenu)
//        let tempView : UIView = pageMenu.view
        self.pageMenuHolderView.addSubview(pageMenu.view)
        
//        self.view.addSubview(tempView)
        
        pageMenu.didMove(toParent: self)
        
        pageMenu.delegate = self
        
//        pageMenu.view.layoutIfNeeded()
//        pageMenu.view.superview?.layoutIfNeeded()
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = UIColor.hexStringToUIColor(hex: "ffce76")
        
        actionButton.addItem(title: "", image: UIImage(named: "quick_registration_icon")?.withRenderingMode(.alwaysTemplate)) { item in
            // do something
            if(self.isReceiptEntry){
                let projectSearchController = ProjectSearchViewController(nibName: "ProjectSearchViewController", bundle: nil)
//                self.present(projectSearchController, animated: true, completion: nil)
                let tempNavigator = UINavigationController.init(rootViewController: projectSearchController)
                tempNavigator.navigationBar.isHidden = true
                projectSearchController.modalPresentationStyle = .fullScreen
                tempNavigator.modalPresentationStyle = .fullScreen
                self.present(tempNavigator, animated: true, completion: nil)
            }
            else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let registerController = storyboard.instantiateViewController(withIdentifier :"registration") as! RegistrationViewController
                registerController.modalPresentationStyle = .fullScreen
                self.present(registerController, animated: true, completion: nil)
            }
        }
        
        
        if(!self.isReceiptEntry && PermissionsManager.shared.quickRegistration()){
            self.addRegistrationButton(actionButton: actionButton)
        }
        else if(self.isReceiptEntry && PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.CREATE.rawValue)){
            self.addRegistrationButton(actionButton: actionButton)
        }
        
        selectedPageMenuIndex = 0
        self.shouldShowSearchBar(shouldShow: false)
        
        searchBar.placeholder = "Search Project"
        
        self.getVehiclesFromServer()

        if(isReceiptEntry){
            heightOfCollectionView.constant = 0
            heightOfDateView.constant = 0
            heightOfProspectCountLabel.constant = 0
            topViewTopConstraint.constant = 0
        }
        else{
            self.getProspects()
//            self.getProspectDate()
            self.setUpCollectionView()
        }
        self.getProjects()
        self.getEnquirySources()
        self.getEmployess()
        self.getAPISources()
        self.getDriversFromServer()
        
        self.updateNotificationCountLabel()
        self.notificationsCountLabel.layer.masksToBounds = true
        self.notificationsCountLabel.layer.cornerRadius = 10
        
        if(!PermissionsManager.shared.dashBoardPermitted()){
            self.reportsButton.isHidden = true
            self.widthOfReportsButton.constant = 0
        }
        
        RRUtilities.sharedInstance.uploadScreenEvent(screenName: "PreSales")
        
        if(PermissionsManager.shared.isSigleTabEabled){
            if(!isReceiptEntry){
                self.backButton.setImage(UIImage.init(named: "menu"), for: .normal)
            }
            else{
                self.backButton.setImage(UIImage.init(named: "back"), for: .normal)
            }
        }
        fromDateButton.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
        toDateButton.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
        fromDateButton.tag = 0
        toDateButton.tag = 1
    }
    //MARK: - FLOAT PANEL DELEGATE BEGIN
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  HalfFloatingPanelLayout(parent: self)
    }
    @objc func showDatePicker(_ sender : UIButton){
        //Formate Date
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "datePicker") as! DatePickerViewController
        vc.shouldSetDateLimit = false
//        vc.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 300)
        vc.delegate = self
        vc.selectedFieldTag = sender.tag

        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        fpc.surfaceView.grabberHandleHeight = 0.0
        fpc.delegate = self
        
        fpc.set(contentViewController: vc)
        
        vc.datePickerInfoView?.backgroundColor = .white
        
        if(sender.tag == 1){
            isFromStartDateButton = false
            vc.datePickerInfoLabel.text = "Set End Date"
        }
        else{
            isFromStartDateButton = true
            vc.datePickerInfoLabel.text = "Set Start Date"
        }

        vc.datePicker.datePickerMode = .date
        vc.buttonsView.backgroundColor = .white
        vc.shouldShowTime = false
        vc.cancelButton.setTitle("CANCEL", for: .normal)
        vc.doneButton.setTitle("OK", for: .normal)

        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
            
        self.present(fpc, animated: true, completion: nil)
    }
    func addRegistrationButton(actionButton : JJFloatingActionButton){
        
        view.addSubview(actionButton)
        
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    // MARK: - COLLECTION VIEW
    func scrollViewDidMove(scrollView: UIScrollView) {
        //ScrollView's contentOffset differences with previous contentOffset
        if(isReceiptEntry){
            return
        }
        let contentOffset =  scrollView.contentOffset.y - oldContentOffset.y
        
        // Scrolls UP - we compress the top view
        if contentOffset > 0 && scrollView.contentOffset.y > 0 {
            if ( topViewTopConstraint.constant > -203 ) {
                topViewTopConstraint.constant -= contentOffset
                scrollView.contentOffset.y -= contentOffset
            }
        }
        
        // Scrolls Down - we expand the top view
        if contentOffset < 0 && scrollView.contentOffset.y < 0 {
            if (topViewTopConstraint.constant < 0) {
                if topViewTopConstraint.constant - contentOffset > 0 {
                    topViewTopConstraint.constant = 0
                } else {
                    topViewTopConstraint.constant -= contentOffset
                }
                scrollView.contentOffset.y -= contentOffset
            }
        }
        oldContentOffset = scrollView.contentOffset

    }
    @objc func getProspectsCount(){
        
        ServerAPIs.getProspectsCount(completionHandler: {responseObject , error in
            
            if(responseObject?.status == 1){
                self.prospectsCount = responseObject
                                
                let expiredCount = responseObject!.expired!.callCount + responseObject!.expired!.offerCount  + responseObject!.expired!.siteVisitCount + responseObject!.expired!.discountRequestCount + responseObject!.expired!.otherCount + responseObject!.expired!.notInterestedCount
                                
                let totalCount = responseObject!.total!.callCount + responseObject!.total!.offerCount  + responseObject!.total!.siteVisitCount + responseObject!.total!.discountRequestCount + responseObject!.total!.otherCount + responseObject!.total!.notInterestedCount

                let scheduledCount = totalCount - responseObject!.total!.notInterestedCount
                
                self.prospectsCountLabel.text = String(format: "Total: %d | Scheduled: %d | Expired: %d", totalCount,scheduledCount,expiredCount)
                
                self.collectionView.reloadData()
            }
            else{
                
            }
        })
    }
    func setUpCollectionView(){
        
        self.getProspectsCount()
        collectionView.register(UINib(nibName: "ProspectTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "prospectTypeCell")
    
        collectionViewDataSource = ["Calls","Offers","Site Visits","Discount Requests","Other Tasks","Not Interested"]
        
        let tempLayout = UICollectionViewFlowLayout.init()
        tempLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 10)
        tempLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        tempLayout.scrollDirection = .horizontal
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        //        collectionView.collectionViewLayout = tempLayout

        collectionView.reloadData()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ProspectTypeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "prospectTypeCell", for: indexPath) as! ProspectTypeCollectionViewCell
        if(prsopectsTypeCountsDict.keys.count > 0 && self.prospectsCount != nil){
            let total = self.prospectsCount!.total!
            let expired = self.prospectsCount!.expired!
            
            if(indexPath.row == 0){
                cell.prospectsCountLabel.text = String(format: "%d", (total.callCount))
                cell.scheduledProspectsCountLabel.text = String(format: "%d", expired.callCount)
                self.shouldShowCountLabel(cell: cell, count: expired.callCount)
            }
            else if(indexPath.row == 1){
                cell.prospectsCountLabel.text = String(format: "%d", (total.offerCount))
                cell.scheduledProspectsCountLabel.text = String(format: "%d", (expired.offerCount))
                self.shouldShowCountLabel(cell: cell, count: expired.offerCount)
            }
            else if(indexPath.row == 2){
                cell.prospectsCountLabel.text = String(format: "%d", (total.siteVisitCount))
                cell.scheduledProspectsCountLabel.text = String(format: "%d", expired.siteVisitCount)
                self.shouldShowCountLabel(cell: cell, count: expired.siteVisitCount)

            }
            else if(indexPath.row == 3){
                cell.prospectsCountLabel.text = String(format: "%d", (total.discountRequestCount))
                cell.scheduledProspectsCountLabel.text = String(format: "%d", expired.discountRequestCount)
                self.shouldShowCountLabel(cell: cell, count: expired.discountRequestCount)
            }
            else if(indexPath.row == 4){
                cell.prospectsCountLabel.text = String(format: "%d", (total.otherCount))
                cell.scheduledProspectsCountLabel.text = String(format: "%d", expired.otherCount)
                self.shouldShowCountLabel(cell: cell, count: expired.otherCount)
            }
            else if(indexPath.row == 5){
                cell.prospectsCountLabel.text = String(format: "%d", (total.notInterestedCount))
                cell.scheduledProspectsCountLabel.text = String(format: "%d", expired.notInterestedCount)
                self.shouldShowCountLabel(cell: cell, count: expired.notInterestedCount)
            }
        }
        cell.prospectTypeLabel.text = collectionViewDataSource[indexPath.row]
        cell.prospectImageView.image = UIImage.init(named: collectionViewDataSource[indexPath.row])
        return cell
        
    }
    func shouldShowCountLabel(cell : ProspectTypeCollectionViewCell,count : Int){
        if(count > 0){
            cell.scheduleCountInfoView.isHidden = false
        }
        else{
            cell.scheduleCountInfoView.isHidden = true
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let prospectsController = ProspectsViewController(nibName: "ProspectsViewController", bundle:nil)
        prospectsController.statusID = indexPath.row + 1
        prospectsController.titleString = self.collectionViewDataSource[indexPath.row]
            //String(format: "%@ (%d)", self.collectionViewDataSource[indexPath.row],(responseObject?.result?.count)!)
//        print(prospectsController.titleString)
        self.navigationController?.pushViewController(prospectsController, animated: true)        
    }
    // MARK: - pagemenu delegate
    func willMoveToPage(_ controller: UIViewController, index: Int){
//        print(index)
    }
    func didMoveToPage(_ controller: UIViewController, index: Int) {
//        print(index)
        self.selectedPageMenuIndex = index
        if(index == 0){
            searchBar.placeholder = "Search Project"
        }
        else if(index == 1){
            searchBar.placeholder = "Search Sales Person"
        }
        else if(index == 2){
            searchBar.placeholder = "Search Enquiry"
        }
        else if(index == 3){
            searchBar.placeholder = "Search Idle"
        }
    }
    @IBAction func showNotifications(_ sender: Any) {
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
    @IBAction func showSearchBar(_ sender: Any) {
            self.shouldShowSearchBar(shouldShow: true)
    }
    @IBAction func showReports(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if #available(iOS 11.0, *) {
            let preSalesController = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
            preSalesController.isFromReports = true
            self.navigationController?.pushViewController(preSalesController, animated: true)
//            return
//        } else {
//            // Fallback on earlier versions
//        }
    }
    func shouldShowSearchBar(shouldShow : Bool){
        
        if(shouldShow)
        {
            searchBar.becomeFirstResponder()
        }
        searchBar.isHidden = !shouldShow
        searchBar.showsCancelButton = shouldShow
        searchButton.isHidden = shouldShow
        reportsButton.isHidden = shouldShow
        notificationsInfoView.isHidden = shouldShow
        searchBar.delegate = self // ** Should search here and pass data to controller
        if(titleLabel != nil){
            titleLabel.isHidden = shouldShow
        }
    }
    func getProspectDate(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"] ?? ""
        ]
        
        HUD.show(.progress)
        var urlSting = String(format: RRAPI.PROSPECTS_TAB_COUNT_WITHOUT_DATE, "1","0")
        
        if(UserDefaults.standard.bool(forKey: "Filter by Action Date")){
            urlSting.append("&filterByActionDate=1")
        }
        
        AF.request(urlSting, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                
                let str = String(decoding: response.data ?? Data(), as: UTF8.self)
                print(str)

                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(PROSPECTS.self, from: responseData)
                                        
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                        return
                    }
                    
                    RRUtilities.sharedInstance.prospectsEndDate = urlResult.result?.endDate
                    RRUtilities.sharedInstance.prospectsEDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: (urlResult.result?.endDate!)!)

                    RRUtilities.sharedInstance.prospectsStartDate = urlResult.result?.startDate
                    RRUtilities.sharedInstance.prospectsSDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: (urlResult.result?.startDate!)!)

                    self.updateDates()
                    HUD.hide()
                    
                    self.getProspects()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.PROSPECT_DATE_CHANGED), object: nil)
                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
//                self.refreshControl?.endRefreshing()
//                self.tableView.reloadData()
                HUD.hide()
                break
            }
        }
    }
    @objc func getProspects(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"] ?? ""
        ]
        
        HUD.show(.progress)
        var urlSting = String(format: RRAPI.PROSPECTS_TAB_COUNT, "1","0",RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate)
        
        if(UserDefaults.standard.bool(forKey: "Filter by Action Date")){
            urlSting.append("&filterByActionDate=1")
        }
        
        AF.request(urlSting, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                
//                let str = String(decoding: response.data ?? Data(), as: UTF8.self)
//                print(str)

                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(PROSPECTS.self, from: responseData)
                                        
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                        return
                    }
                    
                    RRUtilities.sharedInstance.prospectsEndDate = urlResult.result?.endDate
                    RRUtilities.sharedInstance.prospectsEDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: (urlResult.result?.endDate!)!)

                    RRUtilities.sharedInstance.prospectsStartDate = urlResult.result?.startDate
                    RRUtilities.sharedInstance.prospectsSDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: (urlResult.result?.startDate!)!)

                    self.tableViewDataSource = (urlResult.result?.counts)!
                                        
                    var callsCount = 0
                    var offersCount = 0
                    var siteVisitsCount = 0
                    var discountReqCount = 0
                    var otherTaskCount = 0
                    var notInterestedCount = 0
                    
                    for tempProspect in self.tableViewDataSource{
                        callsCount = callsCount + (tempProspect.leads?.callCount)! + (tempProspect.opportunities?.callCount)!
                        offersCount = offersCount + (tempProspect.leads?.offerCount)! + (tempProspect.opportunities?.offerCount)!
                        siteVisitsCount = offersCount + (tempProspect.leads?.siteVisitCount)! + (tempProspect.opportunities?.siteVisitCount)!
                        discountReqCount = offersCount + (tempProspect.leads?.discountRequestCount)! + (tempProspect.opportunities?.discountRequestCount)!
                        otherTaskCount = offersCount + (tempProspect.leads?.otherCount)! + (tempProspect.opportunities?.otherCount)!
                        notInterestedCount = offersCount + (tempProspect.leads?.notInterestedCount)! + (tempProspect.opportunities?.notInterestedCount)!
                    }
                    //["Calls","Offers","Site Visits","Discount Requests","Other Tasks","Not Interested"]
                    
                    self.prsopectsTypeCountsDict["Calls"] = callsCount
                    self.prsopectsTypeCountsDict["Offers"] = offersCount
                    self.prsopectsTypeCountsDict["Site Visits"] = siteVisitsCount
                    self.prsopectsTypeCountsDict["Discount Requests"] = discountReqCount
                    self.prsopectsTypeCountsDict["Other Tasks"] = otherTaskCount
                    self.prsopectsTypeCountsDict["Not Interested"] = notInterestedCount
                    
                    
                    self.collectionView.reloadData()
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
                HUD.flash(.label(error.localizedDescription))
//                self.refreshControl?.endRefreshing()
//                self.tableView.reloadData()
                HUD.hide()
                break
            }
        }
    }
    func getEmployess(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)

//        print(RRAPI.GET_EMPLOYEES)
        
        AF.request(RRAPI.GET_EMPLOYEES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                
                do{
                    let urlResult = try JSONDecoder().decode(EMPLOYEES.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                        HUD.hide()
                        return
                    }
                    else{
                    
                        let isWritten = RRUtilities.sharedInstance.model.writeEmployeeDataToDB(employees: urlResult.users!)
                        if(isWritten){
                            print("Saved VEHICLES TO DB")
                        }
                        else{
                            print("FAILED TO WRITE VEHICLES To DB")
                        }
                    }
                    HUD.hide()
                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                }
                // make tableview data
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
                break
            }
        }
    }
    func getEnquirySources(){
//        API_ENQUIRY_SOURCES
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        if(RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            return
        }

        AF.request(RRAPI.API_ENQUIRY_SOURCES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                
                do{
                    let urlResult = try JSONDecoder().decode(ENQUIRY_SOURCES_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == -1){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                        HUD.hide()
                        return
                    }
                    
                    if(urlResult.status == 1 && (urlResult.enquirySources?.count)! > 0){
                            RRUtilities.sharedInstance.model.writeEnquirySourcesToDB(enquirySources: urlResult.enquirySources!)
                    }
                    
                    
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
                HUD.flash(.label(error.localizedDescription))
                break
            }
        }
        
    }
    func getAPISources(){
        //API_SOURCE_STATUS_DATA
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        if(RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            return
        }
        
//        print(RRAPI.API_SOURCE_STATUS_DATA)
        
        HUD.show(.progress)
        
        AF.request(RRAPI.API_SOURCE_STATUS_DATA, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                do{
                    let urlResult = try JSONDecoder().decode(API_SOURCE_RESULT.self, from: responseData)
                    let ss : [STATUS_SOURCES] = urlResult.ss ?? []
                    
                    if(urlResult.status == -1){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                        HUD.hide()
                        return
                    }
                    
                    RRUtilities.sharedInstance.model.resetAllEnquirySources()  // *** RESET
                    
                    let sources =  ss[0]
                    let predifinedSources = sources.predefined
                    
//                    for tempSource in predifinedSources!{
//
//                        if((tempSource.sub != nil) && (tempSource.sub?.count)! > 0)
//                        {
//                            for tempSub in tempSource.sub!{
//                                let name = String(format: "%@ (%@)", tempSub.name!,tempSource.name!)
//                                _ = RRUtilities.sharedInstance.model.writeAllEnquirySources(name: name, id: tempSource._id!, shouldReset: false)
//                            }
//                        }
//                        else{
//                            _ = RRUtilities.sharedInstance.model.writeAllEnquirySources(name: tempSource.name!, id: tempSource._id!, shouldReset: false)
//                        }
//                    }
                    
                    let css : [CUSTOMER_STATUS_SOURCES] = urlResult.css ?? []
                    
                    RRUtilities.sharedInstance.model.writeNotInterestedReasonsToDB(css: css)
                    
//                    for cSource in css{
//
//                        for data in cSource.data!{
//
//                            if((data.sub != nil) && (data.sub?.count)! > 0)
//                            {
//                                for tempSub in data.sub!{
//                                    let name = String(format: "%@ (%@)", tempSub.name!,data.name!)
//                                    _ = RRUtiliti.es.sharedInstance.model.writeAllEnquirySources(name: name, id: data._id!, shouldReset: false)
//                                }
//                            }
//                            else{
//                                _ = RRUtilities.sharedInstance.model.writeAllEnquirySources(name: data.name!, id: data._id!, shouldReset: false)
//                            }
//                        }
//                    }
                    
                    for tempSource in ss{
                        if(tempSource.label  == "Not Interested Status"){
                            RRUtilities.sharedInstance.notInterestedSources = tempSource
                            break
                        }
                    }
                    
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                        return
                    }
                    else{
                        //                    RRUtilities.sharedInstance.vehicles = urlResult.vehicles!
                    }
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
                HUD.flash(.label(error.localizedDescription))
                break
            }
        }
    }
    @IBAction func getProjects() {
        
        
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        //        print("cookie is \(String(describing: RRUtilities.sharedInstance.keychain["Cookie"]))")
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
//        HUD.show(.labeledProgress(title: "", subtitle: nil))
        
        AF.request(RRAPI.PROJECTS_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                //                print(response)
                
                do{
//                    print(response)
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(projectsResult.self, from: responseData)
                    
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        _ = RRUtilities.sharedInstance.model.writeAllProjectsToDB(projectsArray: urlResult.projects!)
                        return
                    }
                    else if(urlResult.status == -1){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                        HUD.hide()
                        return
                    }
                    
                    guard let projectsResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    
                    let status = projectsResult["status"] as! Int
                    
                    if(status == -1){ //Authentication Issue
                        
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        HUD.hide()
                        return
                    }
                    else{
                        
                        HUD.hide()
                    }
                }
                catch let parseError as NSError {
                    print("JSON Error \(parseError.localizedDescription)")
                }
                
                break;
            case .failure(let error):
                HUD.hide()
                self.navigationController?.popToRootViewController(animated: true)
                print(error)
            }
        }
    }
    
    func getVehiclesFromServer(){
        
        if(RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            return
        }
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress)
        
        AF.request(RRAPI.GET_VEHICLES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(VEHICLE_RESULT.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        return
                    }
                    else{
                        //                    RRUtilities.sharedInstance.vehicles = urlResult.vehicles!
                        
                        let isWritten = RRUtilities.sharedInstance.model.writeAllVehiclesToDB(vehicles: urlResult.vehicles!)
                        
                        if(isWritten){
                            print("Saved VEHICLES TO DB")
                        }
                        else{
                            print("FAILED TO WRITE VEHICLES To DB")
                        }
                        
                    }
                    
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
                HUD.flash(.label(error.localizedDescription))
                break
            }
        }
    }
    func getDriversFromServer(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress)
        
        AF.request(RRAPI.GET_DRIVERS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(DRIVER_RESULT.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        return
                    }
                    else{
                        //                    RRUtilities.sharedInstance.drivers = urlResult.drivers!
                        let isWritten = RRUtilities.sharedInstance.model.writeAllDriversToDB(drivers: urlResult.drivers!)
                        
                        if(isWritten){
                            print("Saved DRIVERS TO DB")
                        }
                        else{
                            print("FAILED TO WRITE DRIVERS To DB")
                        }
                    }
                    
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
                HUD.flash(.label(error.localizedDescription))
                break
            }
        }
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
    @IBAction func back(_ sender: Any) {
        
        if(PermissionsManager.shared.isSigleTabEabled && !isReceiptEntry){
            self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: {
            })
            return
        }
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        if(selectedPageMenuIndex == 0){
            projectsWiseController.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 1){
            salesWiseController.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 2){
            enquiryWiseController.searchBar(searchBar, textDidChange: searchText)
        }
        else if(selectedPageMenuIndex == 3){
            idleViewController.searchBar(searchBar, textDidChange: searchText)
        }

    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        
        if(selectedPageMenuIndex == 0){
            projectsWiseController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 1){
            salesWiseController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 2){
            enquiryWiseController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }
        else if(selectedPageMenuIndex == 3){
            idleViewController.searchBar(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
        }

    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if(selectedPageMenuIndex == 0){
            projectsWiseController.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 1){
            salesWiseController.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 2){
            enquiryWiseController.searchBarCancelButtonClicked(searchBar)
        }
        else if(selectedPageMenuIndex == 3){
            idleViewController.searchBarCancelButtonClicked(searchBar)
        }

        self.shouldShowSearchBar(shouldShow: false)
        self.view.endEditing(true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIScrollView {
    fileprivate func applyMagicInsets(navigationController: UINavigationController) {
        let navBarHeight = navigationController.isNavigationBarHidden ? 0 : navigationController.navigationBar.frame.height
        let toolbarHeight = navigationController.isToolbarHidden ? 0 : navigationController.toolbar.frame.height
        let absolutePosition = self.superview?.convert(self.frame, to: nil) ?? .zero
        let statusBarHeight: CGFloat = absolutePosition.origin.y <= 0 ? UIApplication.shared.statusBarFrame.height : 0
        let topOffset = navBarHeight + statusBarHeight
        self.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: toolbarHeight, right: 0)
        self.contentOffset = CGPoint(x: self.contentOffset.x, y: -topOffset)
    }
}

extension UIView {
    fileprivate func relevantScrollView() -> UIScrollView? {
        if let sv = self as? UIScrollView {
            return sv
        } else {
            return self.subviews.first?.relevantScrollView()
        }
    }
}
extension PreSalesViewController : DateSelectedFromPicker{
    
    func didSelectDate(optionType: Date, optionIndex: Int) {
                
        if(optionIndex == -1){
            self.dismiss(animated: true, completion: nil)
            return
        }
                
        if(self.isFromStartDateButton){
            RRUtilities.sharedInstance.prospectsSDate = optionType
//            let dateStr = RRUtilities.sharedInstance.getProspectDateFormat(date: optionType,isFromDate: true)
            let dateStr = RRUtilities.sharedInstance.prospectDateInGMTFormat(date: optionType, isFromDate: true)
            RRUtilities.sharedInstance.prospectsStartDate = dateStr
        }
        else{
             RRUtilities.sharedInstance.prospectsEDate = optionType
            let dateStr = RRUtilities.sharedInstance.prospectDateInGMTFormat(date: optionType, isFromDate: false)
                //RRUtilities.sharedInstance.getProspectDateFormat(date: optionType,isFromDate: false)
            RRUtilities.sharedInstance.prospectsEndDate = dateStr
        }
        self.updateDates()
        self.getProspects()
        self.getProspectsCount()
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.PROSPECT_DATE_CHANGED), object: nil)
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
