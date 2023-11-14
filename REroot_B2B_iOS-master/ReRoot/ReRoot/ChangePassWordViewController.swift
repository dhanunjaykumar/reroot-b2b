//
//  ChangePassWordViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 25/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class ChangePassWordViewController: UIViewController {

    @IBOutlet var titleView: UIView!
    @IBOutlet var reTypePasswordField: UITextField!
    @IBOutlet var newPasswordField: UITextField!
    @IBOutlet var oldPasswordField: UITextField!
    @IBOutlet var changePwdButton: UIButton!
    
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
        changePwdButton.layer.cornerRadius = 8
    }
    

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func changePassword(_ sender: Any) {
        
        //validate and submit n logout on success
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        if(oldPasswordField.text?.isEmpty)!{
            HUD.flash(.label("Enter current password"), delay: 0.8)
            return
        }
        if(newPasswordField.text?.isEmpty)!{
            HUD.flash(.label("Enter new password"), delay: 0.8)
            return
        }
        
        if(reTypePasswordField.text != newPasswordField.text){
            HUD.flash(.label("Passwords not matching"), delay: 0.8)
            return
        }
        
        var parameters : Dictionary<String,String> = [:]
        parameters["username"] = UserDefaults.standard.value(forKey: "userName") as? String
        parameters["password"] = oldPasswordField.text
        parameters["newPassword"] = reTypePasswordField.text
        parameters["src"] = "3"
        
        AF.request(RRAPI.API_UPDATE_PASSWORD, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                HUD.hide()
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
//                print(urlResult)
                
                if(urlResult.status == 0){
                    HUD.flash(.label(urlResult.err), delay: 0.8)
                }
                else if(urlResult.status == 1){
                    RRUtilities.sharedInstance.keychain["Cookie"] = nil
                    UserDefaults.standard.set(nil, forKey: "Cookie")
                    self.navigationController?.popToRootViewController(animated: true)
                    // Throw notificationt to show login view
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)
                    HUD.flash(.label("Password has been changed successfully.\n Please login with new password"), delay: 2.0) //logout
                }
                else if(urlResult.status == -1){ //logout
                    RRUtilities.sharedInstance.keychain["Cookie"] = nil
                    UserDefaults.standard.set(nil, forKey: "Cookie")
                    self.navigationController?.popToRootViewController(animated: true)
                    // Throw notificationt to show login view
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
        
        
        
    }
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
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
