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

class PreSalesViewController: UIViewController,UISearchBarDelegate ,CAPSPageMenuDelegate {
   
    var projectsWiseController : ProjectWiseViewController!
    var salesWiseController : SalesPersonWiseViewController!
    var enquiryWiseController : EnquiryWiseViewController!
    
    @IBOutlet var titleLabel: UILabel!
    var pageMenu : CAPSPageMenu!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var titleView: UIView!
    @IBOutlet var searchButton: UIButton!
    
    var selectedPageMenuIndex : Int = 0
    
    @objc func injected() {
        configureView()
    }
    func configureView() {
        // Update the user interface for the detail item.
        
        self.view.backgroundColor = UIColor.orange
        titleView.backgroundColor = UIColor.blue
//        if let detail = detailItem {
//            if let label = detailDescriptionLabel {
//                label.text = detail.description + "?"
//            }
//        }
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //configureView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        projectsWiseController = storyboard.instantiateViewController(withIdentifier :"projectWise") as? ProjectWiseViewController
        projectsWiseController.title = "Projectwise"
         salesWiseController = storyboard.instantiateViewController(withIdentifier :"salesWise") as? SalesPersonWiseViewController
        salesWiseController.title = "Sales Personwise"
        enquiryWiseController = storyboard.instantiateViewController(withIdentifier :"enquiryWise") as? EnquiryWiseViewController
        enquiryWiseController.title = "Enquirywise"
        
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        controllerArray.append(projectsWiseController)
        controllerArray.append(salesWiseController)
        controllerArray.append(enquiryWiseController)
        
        
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
        
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.hexStringToUIColor(hex: "35495d")),
            .viewBackgroundColor(UIColor.hexStringToUIColor(hex: "35495d")),
            .selectionIndicatorColor(UIColor.white),
            .bottomMenuHairlineColor(UIColor.white),
            .menuItemFont(UIFont(name: "Montserrat-Bold", size: 11.0)!),
            .useMenuLikeSegmentedControl(true),
            .menuHeight(60.0),
            .centerMenuItems(true),
            .menuItemSeparatorColor(UIColor.clear),
            .menuItemWidthBasedOnTitleTextWidth(true)
        ]
        // Initialize page menu with controller array, frame, and optional parameters

        print(PreSalesViewController.hasTopNotch)
        print(titleView.frame.size.height + titleView.frame.origin.y)
        print(titleView.frame)
        
        var yValue = (titleView.frame.size.height + titleView.frame.origin.y + 0)
        
        if(PreSalesViewController.hasTopNotch){
            yValue = (titleView.frame.size.height + titleView.frame.origin.y + 24)
        }
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y:yValue, width: self.view.frame.size.width, height: self.view.frame.size.height-yValue), pageMenuOptions: parameters)
        //(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
//        self.view.addSubview(pageMenu.view)
        self.addChild(pageMenu)
        let tempView : UIView = pageMenu.view
        self.view.addSubview(tempView)
        
        pageMenu.didMove(toParent: self)
        
        pageMenu.delegate = self
        
        pageMenu.view.layoutIfNeeded()
        pageMenu.view.superview?.layoutIfNeeded()
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = UIColor.hexStringToUIColor(hex: "ffce76")
        
        actionButton.addItem(title: "", image: UIImage(named: "quick_registration_icon")?.withRenderingMode(.alwaysTemplate)) { item in
            // do something
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let registerController = storyboard.instantiateViewController(withIdentifier :"registration") as! RegistrationViewController
            self.present(registerController, animated: true, completion: nil)
        }
        
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
        
        selectedPageMenuIndex = 0
        self.shouldShowSearchBar(shouldShow: false)
        
        self.getProjects()
        self.getAPISources()
        self.getDriversFromServer()
        self.getVehiclesFromServer()

    }
    // MARK: - pagemenu delegate
    func willMoveToPage(_ controller: UIViewController, index: Int){
        print(index)
    }
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        print(index)
        self.selectedPageMenuIndex = index
    }
    
    @IBAction func showSearchBar(_ sender: Any) {
            self.shouldShowSearchBar(shouldShow: true)
    }
    func shouldShowSearchBar(shouldShow : Bool){
        
        searchBar.isHidden = !shouldShow
        searchBar.showsCancelButton = shouldShow
        searchButton.isHidden = shouldShow
        searchBar.delegate = self // ** Should search here and pass data to controller
        titleLabel.isHidden = shouldShow

    }
    class var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
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
        
        HUD.show(.progress)
        
        Alamofire.request(RRAPI.API_SOURCE_STATUS_DATA, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(API_SOURCE_RESULT.self, from: responseData)
                let ss : [STATUS_SOURCES] = urlResult.ss ?? []

                for tempSource in ss{
                    if(tempSource.label  == "Not Interested Status"){
                        RRUtilities.sharedInstance.notInterestedSources = tempSource
                        break
                    }
                }
                
                if(urlResult.status == -1 ){
                    RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                    return
                }
                else{
//                    RRUtilities.sharedInstance.vehicles = urlResult.vehicles!
                    
                }
                HUD.hide()
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
        
        Alamofire.request(RRAPI.PROJECTS_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                //                print(response)
                
                do{
                    print(response)
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try! JSONDecoder().decode(projectsResult.self, from: responseData)
                    
                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        let isWritten = RRUtilities.sharedInstance.model.writeAllProjectsToDB(projectsArray: urlResult.projects!)
                        return
                    }
                    else if(urlResult.status == -1){
                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
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
        
        Alamofire.request(RRAPI.GET_VEHICLES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(VEHICLE_RESULT.self, from: responseData)
                
                if(urlResult.status == -1 ){
                    RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                    return
                }
                else{
                    RRUtilities.sharedInstance.vehicles = urlResult.vehicles!
                }
                
                HUD.hide()
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
        
        Alamofire.request(RRAPI.GET_DRIVERS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(DRIVER_RESULT.self, from: responseData)
                
                if(urlResult.status == -1 ){
                    RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                    return
                }
                else{
                    RRUtilities.sharedInstance.drivers = urlResult.drivers!
                }
                
                HUD.hide()
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
    @IBAction func back(_ sender: Any) {
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
        self.shouldShowSearchBar(shouldShow: false)

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
