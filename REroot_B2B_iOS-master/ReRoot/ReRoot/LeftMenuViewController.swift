//
//  LeftMenuViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import Firebase

class LeftMenuViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var imageHolderView: UIView!
    @IBOutlet var labelsHolderView: UIView!
    @IBOutlet var loggedinUserEmailLabel: UILabel!
    
    var leftOrderedMenu : NSMutableOrderedSet = []
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet var versionInfoLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(RRUtilities.sharedInstance.keychain["Cookie"] == nil || RRUtilities.sharedInstance.keychain["userName"] == nil){
            RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
            return
        }

        loggedinUserEmailLabel.text = RRUtilities.sharedInstance.keychain["userName"]!
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        leftOrderedMenu.add("Settings")
        leftOrderedMenu.add("Change Password")
        
        if #available(iOS 13.0, *) {
            leftOrderedMenu.add("Downloads")
        }
        leftOrderedMenu.add("Logout")
        
        imageHolderView.backgroundColor = UIColor.hexStringToUIColor(hex: "#01012a")
        labelsHolderView.backgroundColor = UIColor.hexStringToUIColor(hex: "#01012a")
        
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
//        mTableView.tableHeaderView = headerView
        
        mTableView.delegate = self
        mTableView.dataSource = self
        
        mTableView.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0 ) )
        
        mTableView.estimatedRowHeight = 50.0
        mTableView.rowHeight = UITableView.automaticDimension
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        versionInfoLabel.text = String(format: "Version:-  %@", appVersion!)
    }
    func showDownloadedFiles(){
        
        let tempCtrl = QuickLookViewController(nibName: "QuickLookViewController", bundle: nil)
        self.navigationController?.pushViewController(tempCtrl, animated: true)

    }

    //MARK: - Tableview Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leftOrderedMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : LeftMenuTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "leftMenuCell",
            for: indexPath) as! LeftMenuTableViewCell
        
        let title  = leftOrderedMenu[indexPath.row] as? String
        cell.mLeftMenuTitleLabel.text = title
        cell.mImageView.image = UIImage.init(named: title!)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let str = leftOrderedMenu[indexPath.row] as! String
        
        if(str == "Settings"){
            //settings
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingsController = storyboard.instantiateViewController(withIdentifier :"settings") as! SettingsViewController
            self.navigationController?.pushViewController(settingsController, animated: true)
        }
        else if(str == "Change Password"){
            //change password
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let passwordController = storyboard.instantiateViewController(withIdentifier :"changePassword") as! ChangePassWordViewController
            self.navigationController?.pushViewController(passwordController, animated: true)

        }
        else if(str == "Downloads")
        {
            self.showDownloadedFiles()
        }
        else if(str == "Logout")
        {
            logout()
        }

//        else if(indexPath.row == 2){
//            //Logout
//            logout()
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func removeFCMID(){
        
        var parameters : [String : Any] = ["fcm_id" : Messaging.messaging().fcmToken!]
        parameters["device_id"] = UIDevice.current.identifierForVendor?.uuidString
        
//        print(parameters)
        parameters["src"] = "3"
        parameters["app_platform"] = 2
        
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]

        AF.request(RRAPI.REMOVE_FCM_ID, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    _ = try JSONDecoder().decode(otpResult.self, from: responseData)
//                    print(urlResult)
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    func logout() {
        
        if(PermissionsManager.shared.isSigleTabEabled){
            self.navigationController?.popToRootViewController(animated: true)
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "rootNavigation")
            UIApplication.shared.keyWindow?.rootViewController = navigationController
        }
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        self.removeFCMID()
        HUD.show(.labeledProgress(title: "", subtitle: "Syncing Data.."))
        SyncHelper.shared.uploadHandoverData(completionHandler: {(response,error) in
            HUD.hide()
            self.logoutServerCall()
        })
    }
    func logoutServerCall(){
        
        let url = RRAPI.LOGOUT_URL
        
        if(RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            UserDefaults.standard.set(nil, forKey: "Cookie")
            self.dismiss(animated: true, completion: nil)
            
            // Throw notificationt to show login view
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)
            return
        }
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.labeledProgress(title: "", subtitle: "Logging out.."))

        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success:
                print("Logout response \(response)")
                DispatchQueue.main.async {
                    HUD.hide()

                    HUD.flash(.label("Successfully Logged out!"), delay: 1.0)
                    //show Login View
                    self.resetAllEntities()
                    PermissionsManager.shared.isAdmin = false
                    //resultCode should be 404
                    UserDefaults.standard.set(true, forKey: "showCommission")
                    UserDefaults.standard.set(false, forKey: "promptOTP")
                    UserDefaults.standard.set(false, forKey: "siteVisitUser")

                    RRUtilities.sharedInstance.keychain["Cookie"] = nil
                    UserDefaults.standard.set(nil, forKey: "Cookie")
                    self.dismiss(animated: true, completion: nil)
                    
                    // Throw notificationt to show login view
                        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)

                }
                
                //            if response.response?.statusCode == 200
                //            {
                //            }
                
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                }
                print(error)
            }
        }
    }
    func resetAllEntities(){
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Blocks")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "ChequeBank")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Driver")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Employee")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "EnquirySources")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "LandOwner")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "ModulePermissions")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "NewEnquirySources")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Notifications")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "OtherPremiums")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Permissions")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Project")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "ReceiptEntriesCount")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "ReceiptEntry")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "SourceStatuses")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "SubStatuses")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "TempObj")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Towers")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "UnitCarParks")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Units")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "UpdateBy")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Vehicle")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "RRUser")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "RRUserRole")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "Approvals")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "ApprovalHistory")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "BillingInfo")
        RRUtilities.sharedInstance.model.resetEntity(entityName: "ApprovalPricingInfo")

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
