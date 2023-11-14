//
//  ViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class LoginViewController: UIViewController {

    var showPwdImage : UIImageView!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.isHidden = true
        
//        #if DEBUG
//            emailIdTextField.text = "admin@prestige.com"
//            passwordTextField.text = "siso@123"
//        #endif
        
        emailIdTextField.text = UserDefaults.standard.value(forKey: "userName") as? String
        passwordTextField.text = UserDefaults.standard.value(forKey: "pwd") as? String
        
//        print(RRUtilities.sharedInstance.keychain["Cookie"])
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#00327f")
        loginButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#00ca9d")
        loginButton.layer.cornerRadius = 30
        
        emailIdTextField.layer.cornerRadius = 2
        passwordTextField.layer.cornerRadius = 2
        
        emailIdTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "#345b96")
        passwordTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "#345b96")
        
        forgotPasswordButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#00ca9d"), for: UIControl.State.normal)
        
        let emailImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        emailImage.contentMode = UIView.ContentMode.center
        emailIdTextField.leftView = emailImage
        emailIdTextField.leftViewMode = .always
       
        let passwordImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        passwordImage.contentMode = UIView.ContentMode.center
        passwordTextField.leftView = passwordImage
        passwordTextField.leftViewMode = .always
        
        let pwdImage = UIImageView.init(image: UIImage.init(named: "password"))
        pwdImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        pwdImage.contentMode = .center
        passwordTextField.leftView = pwdImage
        
        showPwdImage = UIImageView.init(image: UIImage.init(named: "hide_password_white"))
        showPwdImage.isUserInteractionEnabled = true
        showPwdImage.tag = 0
        
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showPassword))
        showPwdImage.addGestureRecognizer(tapGuesture)

        showPwdImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        showPwdImage.contentMode = .center
        passwordTextField.rightView = showPwdImage
        passwordTextField.rightViewMode = UITextField.ViewMode.always
        
        let userImage = UIImageView.init(image: UIImage.init(named: "user"))
        userImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        userImage.contentMode = .center
        emailIdTextField.leftView = userImage
        
    }
    @objc func showPassword() {
        
        if(showPwdImage.tag == 0){
            showPwdImage.image = UIImage.init(named: "show_password")
            showPwdImage.tag = 1
            passwordTextField.isSecureTextEntry = false
        }
        else{
            showPwdImage.tag = 0
            showPwdImage.image = UIImage.init(named: "hide_password_white")
            passwordTextField.isSecureTextEntry = true
        }
        
    }
    @IBAction func forgotPassword(_ sender: Any) {
        
        //ForgotPassword
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pwdController = storyboard.instantiateViewController(withIdentifier :"ForgotPassword") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(pwdController, animated: true)
//        self.view.window?.rootViewController?.navigationController?.pushViewController(pwdController, animated: true)
//        let tempNavigator = UINavigationController.init(rootViewController: pwdController)
//        self.present(tempNavigator, animated: true, completion: nil)
        
    }
    @IBAction func login(_ sender: Any) {
        
        if (emailIdTextField.text?.isEmpty)! {
            HUD.flash(.label("Enter Login ID"), delay: 1.0)
            return
        }
        if (passwordTextField.text?.isEmpty)! {
            HUD.flash(.label("Enter Password"), delay: 1.0)
            return
        }
        
        guard let email = emailIdTextField.text , RRUtilities.sharedInstance.isValidEmail(emailID: emailIdTextField.text!) != false else{
            HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
            return
        }
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }

        HUD.show(.progress)
        
        var loginDetailsDict : [String : String] =  ["username" : email]
        loginDetailsDict["password"] = passwordTextField.text!

        var jsonData : Data!
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: loginDetailsDict, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
        }
        
        if let tempUrl = URL(string: RRAPI.LOGIN_URL) {
            var urlRequest1 = URLRequest(url: tempUrl)
            urlRequest1.httpMethod = HTTPMethod.post.rawValue
            urlRequest1.httpShouldHandleCookies = false
            
            urlRequest1.addValue("User-Agent", forHTTPHeaderField: "RErootMobile")
            urlRequest1.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest1.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

            let temper =  String(decoding: jsonData, as: UTF8.self)
            print(temper)

            urlRequest1.httpBody = jsonData
            
            Alamofire.request(urlRequest1)
                .responseJSON { response in
                    switch response.result {
                    case .success :
                        print(response)
                        HUD.hide()
                        
                        if response.response?.statusCode == 200
                        {
                            do{
                                
                                guard let responseData = response.data else {
                                    print("Error: did not receive data")
                                    return
                                }
                                
                                guard let loginResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                                    print("error trying to convert data to JSON")
                                    return
                                }
                                
                                print(loginResult)
                                
                                if case let status as Int = loginResult["status"] //We can store by just checking http status code, but doing with response
                                {
                                    if (status == 1)
                                    {
                                        let httpResponse : [String : String] = (response.response?.allHeaderFields as? Dictionary)!
                                        let cookieArray = httpResponse["Set-Cookie"]?.split(separator: ";")
                                        print(cookieArray as Any)
                                        
                                        if(cookieArray != nil){
                                            RRUtilities.sharedInstance.keychain["userName"] = self.emailIdTextField.text
                                            //                                    RRUtilities.sharedInstance.keychain["password"] = self.passwordTextField.text
                                            RRUtilities.sharedInstance.keychain["Cookie"] = String( (cookieArray?[0])!)
                                             UserDefaults.standard.setValue(self.emailIdTextField.text, forKey: "userName")
                                             UserDefaults.standard.setValue(self.passwordTextField.text, forKey: "pwd")
                                            UserDefaults.standard.set(String( (cookieArray?[0])!), forKey: "Cookie")
                                            UserDefaults.standard.set(self.emailIdTextField.text, forKey: "userName")
                                            UserDefaults.standard.set(loginResult["groupId"], forKey: "groupId")
                                            UserDefaults.standard.synchronize()
                                        }
                                        
                                        
                                        //                                UserDefaults.standard.set(true, forKey: "hasRunBefore") //To  remove keychain details
                                        //                                UserDefaults.standard.synchronize()
                                        
                                        print("httpResponse \(httpResponse)")
                                        
                                        //                                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeView") as? HomeViewController
                                        //                                self.navigationController?.pushViewController(vc!, animated:true)
                                        
                                        self.dismiss(animated: true, completion: nil)
                                        
                                    }
                                    else if(status == 0)
                                    {
                                        let err = loginResult["err"] as! String
                                        HUD.flash(.label(err), delay: 1.0)
                                    }
                                }
                                else
                                {
                                    print("Error in parsing :")
                                    HUD.flash(.label("Something went wrong Try Again!"), delay: 1.0)
                                }
                            }
                            catch let jsonError{
                                print("Error in parsing :" , jsonError)
                                return
                            }
                        }
                        else if(response.response?.statusCode == 401){
                            HUD.flash(.label("Username or password is not correct"), delay: 1.0)
                        }
                        else{
                            print("something went wrond")
                        }
                        break;
                    case .failure(let error):
                        HUD.hide()
                        HUD.flash(.label(error.localizedDescription), delay: 1.0)
                        print(error)
                    }
                    
            }
        }
            
    }
    
    @IBAction func showUrlController(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let urlController = storyboard.instantiateViewController(withIdentifier :"urlController") as! URLViewController
        self.present(urlController, animated: true, completion: nil)

    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

