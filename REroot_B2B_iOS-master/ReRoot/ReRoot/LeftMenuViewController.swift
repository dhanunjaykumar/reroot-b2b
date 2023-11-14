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

class LeftMenuViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var imageHolderView: UIView!
    @IBOutlet var labelsHolderView: UIView!
    @IBOutlet var loggedinUserEmailLabel: UILabel!
    
    var leftOrderedMenu : NSMutableOrderedSet = []
    @IBOutlet weak var mTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loggedinUserEmailLabel.text = RRUtilities.sharedInstance.keychain["userName"]!
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        leftOrderedMenu.add("Settings")
        leftOrderedMenu.add("Change Password")
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
        if(indexPath.row == 0){
            //settings
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let settingsController = storyboard.instantiateViewController(withIdentifier :"settings") as! SettingsViewController
            self.navigationController?.pushViewController(settingsController, animated: true)
        }
        else if(indexPath.row == 1){
            //change password
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let passwordController = storyboard.instantiateViewController(withIdentifier :"changePassword") as! ChangePassWordViewController
            self.navigationController?.pushViewController(passwordController, animated: true)

        }
        else if(indexPath.row == 2){
            //Logout
            logout()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func logout() {
        
        let url = RRAPI.LOGOUT_URL
//        let cookie  = RRUtilities.sharedInstance.keychain["Cookie"]
        
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
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
           response in
           switch response.result {
            
           case .success:
            
            print("Logout response \(response)")
            HUD.hide()
            
//            if response.response?.statusCode == 200
//            {
                HUD.flash(.label("Successfully Logged out!"), delay: 1.0)
                //show Login View
                
                //resultCode should be 404
                RRUtilities.sharedInstance.keychain["Cookie"] = nil
                UserDefaults.standard.set(nil, forKey: "Cookie")
                self.dismiss(animated: true, completion: nil)
                
                // Throw notificationt to show login view
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)
                
//            }

                break
           case .failure(let error):
            HUD.hide()
            HUD.flash(.label(error.localizedDescription), delay: 1.0)
            print(error)
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
