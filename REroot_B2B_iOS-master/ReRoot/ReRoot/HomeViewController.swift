//
//  HomeViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import SideMenu
import PKHUD
import CoreData
import Alamofire
import AWSCore
import AWSS3


class HomeViewController: UIViewController {

    var permissionInfoLabel : UILabel!
    @IBOutlet weak var widthOfReportsButton: NSLayoutConstraint!
    @IBOutlet weak var notificationsCountLabel: UILabel!
    @IBOutlet weak var reportsButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var presalesButton: UIView!
    @IBOutlet weak var salesButton: UIView!
    @IBOutlet weak var crmButton: UIView!
    @IBOutlet weak var approvalsButton: UIView!

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
        
//        titleView.layer.shadowPath = UIBezierPath(roundedRect: titleView.bounds, cornerRadius: 10).cgPath
        titleView.layer.shouldRasterize = true
        titleView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        redrawButton(view: presalesButton)
        redrawButton(view: salesButton)
        redrawButton(view: crmButton)
        redrawButton(view: approvalsButton)
    }
    
    func redrawButton(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.updateNotificationCountLabel()
    }
    func getDocumentsDirectory() -> URL { // returns your application folder
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        print("doc url " + docUrl.description)
//        let dataPath = docUrl.appendingPathComponent("Test")
//        let fileExist = FileManager.default.fileExists(atPath: dataPath.path)
//        print(fileExist)
//        if(!fileExist){
//            try! FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: true, attributes: nil)
//        }
//        let signedUrl = URL(string:AWSService().getPreSignedURL(S3DownloadKeyName: "demo_key"),
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(showLeftMenu(_:)), name: NSNotification.Name(rawValue: NOTIFICATIONS.SHOW_LEFT_MENU), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen), name: NSNotification.Name(rawValue: NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUpHomeScreen), name: NSNotification.Name("HomeScreenSetUp"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(callNotificationURL), name: NSNotification.Name("NotificationsCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSetUpDetails), name: NSNotification.Name("SetUpCall"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationCountLabel), name: NSNotification.Name("NotificationsAction"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(getHandoverUnits), name: NSNotification.Name("FetchHandOverUnitsFromHome"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploadOnNetworkNotification), name: NSNotification.Name(NOTIFICATIONS.UPLOAD_HANDOVER_DATA), object: nil)

        self.setupSideMenu()
        
        self.updateNotificationCountLabel()
        
        permissionInfoLabel = UILabel.init()
        permissionInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        permissionInfoLabel.text = "Oops! You are not authorised to use any feature.\nPlease contact administrator."
        permissionInfoLabel.numberOfLines = 0
        permissionInfoLabel.lineBreakMode = .byWordWrapping
        permissionInfoLabel.textAlignment = .center
        permissionInfoLabel.font = UIFont.init(name: "Montserrat-Medium", size: 15)
        self.view.addSubview(permissionInfoLabel)
        permissionInfoLabel.isHidden = true
        
        let xConstraint = NSLayoutConstraint.init(item: permissionInfoLabel!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 1.0)
        let yConstraint = NSLayoutConstraint.init(item: permissionInfoLabel!, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 1.0)

        self.view.addConstraint(xConstraint)
        self.view.addConstraint(yConstraint)
        
        if UserDefaults.standard.value(forKey: "Cookie") == nil
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier :"LoginView") as! LoginViewController
//            self.navigationController?.present(loginController, animated: true, completion: nil)
            
//            let tempNavigator = UINavigationController.init(rootViewController: loginController)
            self.navigationController?.present(loginController, animated: true, completion: {
                //perhaps we'll do something here later
            })
            return
        }
//        self.setUpHomeScreen() // ON login Handle
        if(!PermissionsManager.shared.dashBoardPermitted()){
            self.reportsButton.isHidden = true
        }
        else{
            self.reportsButton.isHidden = false
        }
        
        RRUtilities.sharedInstance.uploadScreenEvent(screenName: "HOME SCREEN")
    }
    func setUpUI(){
        /*
         fun isCRMPermitted(): Boolean {
             return checkForPermission(Permission.AGREEMENT_STATUS_TRACKER, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.RECEIPT_ENTRY, UserRolePermission.VIEW) ||
                     isManageUnitsPermitted() || isHandoverPermitted()
         }

         fun isManageUnitsPermitted(): Boolean {
             return checkForPermission(Permission.BLOCK_RELEASE_UNIT, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.RESERVE_UNIT, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.CANCEL_TRANSFER_UNIT, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.ASSIGN_UNIT, UserRolePermission.VIEW)
         }

         fun isHandoverPermitted(): Boolean {
             return checkForPermission(Permission.HANDOVER_REVIEW, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.INTERNAL_REVIEW, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.INTERNAL_SNAGS, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.CUSTOMER_REVIEW, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.CUSTOMER_SNAGS, UserRolePermission.VIEW) ||
                     checkForPermission(Permission.FINAL_POSSESSION, UserRolePermission.VIEW)
         }
         */
    
        if(!PermissionsManager.shared.isSuperUser()){
            var enabledCounter = 0
            presalesButton.isHidden = !PermissionsManager.shared.isPresalesPermitted()
            salesButton.isHidden = !PermissionsManager.shared.isSalesPermitted()
            crmButton.isHidden = !PermissionsManager.shared.isCRMPermitted()
            approvalsButton.isHidden = !PermissionsManager.shared.isApprovalsPermitted()
                        
            if(!presalesButton.isHidden){
                enabledCounter += 1
            }
            if(!salesButton.isHidden){
                enabledCounter += 1
            }
            if(!crmButton.isHidden){
                enabledCounter += 1
            }
            if(!approvalsButton.isHidden){
                enabledCounter += 1
            }
            
            PermissionsManager.shared.isSigleTabEabled = (enabledCounter == 1) ? true : false
            
            if(enabledCounter == 1 && !presalesButton.isHidden){
                let tapper = UITapGestureRecognizer()
                tapper.numberOfTapsRequired = -1
                self.presalesTapListener(tapper)
            }
            if(enabledCounter == 1 && !salesButton.isHidden){
                self.salesTapListener(UITapGestureRecognizer())
            }
            if(enabledCounter == 1 && !crmButton.isHidden){
                self.crmTapListener(UITapGestureRecognizer())
            }
            if(enabledCounter == 1 && !approvalsButton.isHidden){
                self.approvalsTapListener(UITapGestureRecognizer())
            }
        }
        else{
            PermissionsManager.shared.isSigleTabEabled = false
            presalesButton.isHidden = false
            salesButton.isHidden = false
            crmButton.isHidden = false
            approvalsButton.isHidden = false
        }
        if(!PermissionsManager.shared.dashBoardPermitted()){
            self.reportsButton.isHidden = true
        }
        else{
            self.reportsButton.isHidden = false
        }
        if(presalesButton.isHidden && salesButton.isHidden && crmButton.isHidden && approvalsButton.isHidden){
            permissionInfoLabel.isHidden = false
        }
        else{
            permissionInfoLabel.isHidden = true
        }
    }
    @objc func setUpHomeScreen(){
        
        if(UserDefaults.standard.value(forKey: "Cookie") == nil){
            return
        }
        
        HUD.show(.progress, onView: self.view)
        
        self.setUpUI()

//        RRUtilities.sharedInstance.model.uploadOfflineHandOverData(shouldPostNotification: true,isFromHomeView: true)
        
        SyncHelper.shared.uploadHandoverData(completionHandler: {(response,error) in
            self.getHandoverUnits()
            HUD.hide()
        })
        
        ServerAPIs.getProjectList(completionHandler: { (response , error) in
        })
        
        ServerAPIs.getS3Config()
        ServerAPIs.getCommisionsInfo()
        ServerAPIs.getSchemes()
        ServerAPIs.getGenerals(completion: { result in
            
        })
        
    }
    @objc func uploadOnNetworkNotification(){
//        RRUtilities.sharedInstance.model.uploadOfflineHandOverData(shouldPostNotification: true,isFromHomeView: true)
        SyncHelper.shared.uploadHandoverData(completionHandler: {(response,error) in
        })
    }
    @objc func getHandoverUnits(){
        ServerAPIs.getSoldUnitsForCompanyGroup(completionHandler: { (responseObejct , error) in
            if(responseObejct?.status == 1){
                RRUtilities.sharedInstance.model.writeSoldUnitsToDB(soldUnits: responseObejct!.units!, completionHandler: { (response,error) in
                    if(response){
                        NotificationCenter.default.post(name: NSNotification.Name("UpdateUIOnNetowrkBack"), object: nil)
                    }
                    else{
                    }
                })
            }
            else{
                
            }
        })
    }
    fileprivate func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.default.menuPresentMode = .menuSlideIn

        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
//        SideMenuManager.default.menuAddPanGestureToPresent(toView:self.view)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        SideMenuManager.default.menuFadeStatusBar = false
    }
    @objc func showLoginScreen() {
        
        DispatchQueue.main.async {
            if(self.children.count > 0){
                let viewControllers:[UIViewController] = self.children
                for viewContoller in viewControllers{
                    viewContoller.willMove(toParent: nil)
                    viewContoller.view.removeFromSuperview()
                    viewContoller.removeFromParent()
                }
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier :"LoginView") as! LoginViewController
            self.navigationController?.present(loginController, animated: true, completion: {
                //perhaps we'll do something here later
            })
        }
    }
    @objc func getSetUpDetails(){
        if(UserDefaults.standard.value(forKey: "Cookie") == nil) ||  RRUtilities.sharedInstance.keychain["Cookie"] == nil{
            return
        }
        ServerAPIs.getCustomSetUpDetails()
        ServerAPIs.getDefaultSetup()
    }
    @objc func callNotificationURL(){
        if(UserDefaults.standard.value(forKey: "Cookie") == nil || RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            return
        }
        self.getNotifications()
    }
    @IBAction func showNotifications(_ sender: Any) {
        
        
        
//        #if DEBUG
//
////        let tempCtrl = QuickLookViewController(nibName: "QuickLookViewController", bundle: nil)
////
//////        let ctrl = QuickLookCollectionViewController(nibName: "QuickLookCollectionViewController", bundle: nil)
//////        let navigCtrl = UINavigationController.init(rootViewController: ctrl)
////        self.navigationController?.pushViewController(tempCtrl, animated: true)
//
////        let path = self.getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
////        let url = URL(string: path)!
////        print(path)
////        print(url)
////        UIApplication.shared.open(url)
//        return
//        #endif
        
//        let s3Config = RRUtilities.sharedInstance.model.getS3Config()
//
//        if(s3Config == nil || s3Config?.accessKeyId == nil)
//        {
//            return
//        }
//        let accessKey = s3Config!.accessKeyId!
//        let secretKey = s3Config!.secretAccessKey!
//
//        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
//        let configuration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
////
//        AWSServiceManager.default().defaultServiceConfiguration = configuration


//        AWSS3PreSignedURLBuilder.register(with:configuration!, forKey: accessKey)
//        let presignedURLBuilder = AWSS3PreSignedURLBuilder.s3PreSignedURLBuilder(forKey: "APSouth1S3PreSignedURLBuilder")

//        #if DEBUG

        
        //"Reroot/receipts/ree-p1-p1b1-p1b1t1-7-1_1601177329362920.pdf"
        
//        [8:33 am, 30/09/2020] prasanth appq: https://s3-ap-south-1.amazonaws.com/buildez/ABC+Developers/bookingform/12155_Screenshot20200929at11.34.18PM.png
//        [8:34 am, 30/09/2020] prasanth appq: https://s3-ap-south-1.amazonaws.com/buildez/ABC+Developers/bookingform/38840_hh.png
        
//        https://s3-ap-south-1.amazonaws.com/rerootwla/5f807c80ac27900f119f6d8c/button/GeFvQkBbSLaMdpKXF1Zv_bigstock-Aerial-View-Of-Blue-Lakes-And--227291596imagejpeg.jpg
        
        //"5f579e00b2f34e16a1b44581/button/Screenshot 2020-09-22 at 2image/png.40"
        
//        let signedUrl = AWSService().getPreSignedURL(S3DownloadKeyName: "5f807c80ac27900f119f6d8c/button/GeFvQkBbSLaMdpKXF1Zv_bigstock-Aerial-View-Of-Blue-Lakes-And--227291596imagejpeg.jpg")
//        print(signedUrl)
//
////        let data = try! Data.init(contentsOf: URL.init(string: signedUrl)!)
////        let str = String(decoding: data, as: UTF8.self)
////        print(str)
//
////        let imag = UIImage.init(coder: Data.init(contentsOf: URL.init(string: signedUrl)!)!)!
//
//        let dataaa = try! Data.init(contentsOf: URL.init(string: signedUrl)!)
//
//        let imag = UIImage.init(data: dataaa)
//
//        print(imag)
//
//        if #available(iOS 11.0, *) {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let preSalesController = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
//            preSalesController.previewOfferUrlString = signedUrl
//            preSalesController.isPreViewOffer = true
//            self.navigationController?.pushViewController(preSalesController, animated: true)
//            return
//        }

//        #endif
//
//
//
//        return;
        if(RRUtilities.sharedInstance.model.notificationsCount() == 0){
            HUD.flash(.label("There are no notificatins to show"), delay: 1.0)
            self.updateNotificationCountLabel()
            return
        }
        self.updateNotificationCountLabel()
        let notificationsController = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationsController, animated: true)
        
    }
    @IBAction func showLeftMenu(_ sender: Any) {
        
        self.navigationController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: {
        })
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
    @objc func updateNotificationCountLabel(){
        let count = RRUtilities.sharedInstance.model.notificationsCount()
        self.notificationsCountLabel.text = String(format: "%d",count)
        
        self.notificationsCountLabel.layer.masksToBounds = true
        self.notificationsCountLabel.layer.cornerRadius = 10

        if(count > 0){
            self.notificationsCountLabel.isHidden = false
        }else{
            self.notificationsCountLabel.isHidden = true
        }
    }
    
    @IBAction func presalesTapListener(_ sender: UITapGestureRecognizer) {
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let preSalesController = storyboard.instantiateViewController(withIdentifier :"preSales") as! PreSalesViewController
        
        if(PermissionsManager.shared.isSigleTabEabled){
            
//            let new = UINavigationController(rootViewController: preSalesController)                               // 1
//            new.navigationBar.isHidden = true
//            addChild(new)                    // 2
//            new.view.frame = view.bounds                   // 3
//            self.view.addSubview(new.view)                      // 4
//            new.didMove(toParent: self)      // 5
//            self.titleView.isHidden = true
            
//            current.willMove(toParent: nil)  // 6
//            current.view.removeFromSuperview()          // 7
//            current.removeFromParent()       // 8
//            current = new                                  // 9

            let tempNavigator = UINavigationController.init(rootViewController: preSalesController)
            tempNavigator.navigationBar.isHidden = true
            UIApplication.shared.keyWindow?.rootViewController = tempNavigator
            return
        }

        self.navigationController?.pushViewController(preSalesController, animated: true)
    }
    
    @IBAction func salesTapListener(_ sender: Any) {
        
        if(self.projectsExist()){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier :"Projects") as! ProjectsViewController
            if(PermissionsManager.shared.isSigleTabEabled){
                let tempNavigator = UINavigationController.init(rootViewController: loginController)
                tempNavigator.navigationBar.isHidden = true
                UIApplication.shared.keyWindow?.rootViewController = tempNavigator
                return
            }
            self.navigationController?.pushViewController(loginController, animated: true)
        }
        else{
            if !RRUtilities.sharedInstance.getNetworkStatus()
            {
                HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginController = storyboard.instantiateViewController(withIdentifier :"Projects") as! ProjectsViewController
            if(PermissionsManager.shared.isSigleTabEabled){
                let tempNavigator = UINavigationController.init(rootViewController: loginController)
                tempNavigator.navigationBar.isHidden = true
                UIApplication.shared.keyWindow?.rootViewController = tempNavigator
                return
            }
            self.navigationController?.pushViewController(loginController, animated: true)
        }
    }
    
    @IBAction func crmTapListener(_ sender: Any) {
        
        let crmController = CRMViewController(nibName: "CRMViewController", bundle: nil)
        
        if(PermissionsManager.shared.isSigleTabEabled){
        
            let tempNavigator = UINavigationController.init(rootViewController: crmController)
            tempNavigator.navigationBar.isHidden = true
            UIApplication.shared.keyWindow?.rootViewController = tempNavigator
            return
        }
        self.navigationController?.pushViewController(crmController, animated: true)
        
//        return
        
        
//        let alertController = UIAlertController(title: NSLocalizedString("Welcome to REroot!", comment: ""), message: NSLocalizedString("CRM functionality is under development. \nCRM feature will be released shortly", comment: ""), preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
//
//        alertController.addAction(cancelAction)
//
//        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func approvalsTapListener(_ sender: Any) {
        
        RRUtilities.sharedInstance.model.restApprovalsEntity()
        let crmController = CRMViewController(nibName: "CRMViewController", bundle: nil)
        crmController.isApprovalScreen = true
        if(PermissionsManager.shared.isSigleTabEabled){
            let tempNavigator = UINavigationController.init(rootViewController: crmController)
            tempNavigator.navigationBar.isHidden = true
            UIApplication.shared.keyWindow?.rootViewController = tempNavigator
            return
        }
        self.navigationController?.pushViewController(crmController, animated: true)
    }
    func projectsExist()->Bool{
        
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        request.resultType = NSFetchRequestResultType.countResultType
        
//        let projecct = fetchedResultsControllerProjects!.object(at: selectedIndexPath)
//        let predicate = NSPredicate(format: "project CONTAINS[c] %@", projecct.id!)
//        request.predicate = predicate
        
        do {
            let count = try RRUtilities.sharedInstance.model.managedObjectContext.count(for: request)
            
            if(count > 0){
                print(count)
                return true
            }
            else{
                return false
            }
        }
        catch {
            return false
//            fatalError("Error in fetching records")
        }
    }
    @objc func getNotifications(){
        
        if(UserDefaults.standard.value(forKey: "Cookie") == nil || RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            return
        }
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.notificationsCountLabel.text = String(format: "%d",RRUtilities.sharedInstance.model.notificationsCount())
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
//        HUD.show(.progress)
        
//        AF.request(urlRequest).responseJSON { (response) in
//
//            var lCookie : String?
//            let cookies = HTTPCookieStorage.shared.cookies!
//
//            for cookie: HTTPCookie in cookies{
//                if (cookie.name == "connect.sid") {
//                    lCookie = cookie.value
//                }
//            }
//
//            if lCookie != nil{
//                let dummy = String(format:"connect.sid=%@", lCookie!)
//                UserDefaults.standard.set(dummy, forKey: Constants.UserDefaultConstants.studCookieID)
//            }
//            if let headerFields = response.response?.allHeaderFields as? [String: String], let url = response.request?.url
//            {
//                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
//                print(cookies)
//
//                for cookie: HTTPCookie in cookies{
//                    if (cookie.name == "connect.sid") {
//                        lCookie = cookie.value
//                    }
//                }
//
//                if lCookie != nil{
//                    let dummy = String(format:"connect.sid=%@", lCookie!)
//                    UserDefaults.standard.set(dummy, forKey: Constants.UserDefaultConstants.studCookieID)
//                }
//            }
//
//            switch(response.result) {
//            case .success(_):
//                if let data = response.result.value{
//                    print(data)
//                    completionHandler(response)
//                }
//                break
//            case .failure(_):
//                completionHandler(response)
//                print(response.debugDescription)
//                break
//            }
//        }
        
        AF.request(RRAPI.API_NOTIFICATIONS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(NOTIFICATIONS_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == -1 ){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                        return
                    }
                    else{
                        if((urlResult.notifications?.count)! > 0){
                            RRUtilities.sharedInstance.model.writeNotificationsToDB(notifications: urlResult.notifications!)
                            sleep(1)
                            self.notificationsCountLabel.text = String(format: "%d", (urlResult.notifications?.count)!)
                            self.updateNotificationCountLabel()
                            NotificationCenter.default.post(name: NSNotification.Name("FetchNotifications"), object: nil)
                        }
                        else{
                            if((urlResult.notifications?.count)! == 0){
                                RRUtilities.sharedInstance.model.resetEntity(entityName: "Notifications")
                                self.notificationsCountLabel.text = String(format: "%d", (urlResult.notifications?.count)!)
                                self.updateNotificationCountLabel()
                                NotificationCenter.default.post(name: NSNotification.Name("FetchNotifications"), object: nil)
                            }
                        }
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                HUD.hide()
                
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
                break
            }
        }
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

extension HomeViewController: UISideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
    
}

