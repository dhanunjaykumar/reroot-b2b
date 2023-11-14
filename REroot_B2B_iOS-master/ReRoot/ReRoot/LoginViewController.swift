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
import Firebase
import FirebaseCrashlytics
import FirebaseMessaging

class LoginViewController: UIViewController {

    @IBOutlet var logoLabel: UILabel!
    var showPwdImage : UIImageView!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.isHidden = true
        let attr1 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-Bold", size: 20), NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedString1 = NSMutableAttributedString(string:"RE", attributes:attr1 as [NSAttributedString.Key : Any])
        let attr2 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-italic", size: 18), NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedString2 = NSMutableAttributedString(string:"root", attributes:attr2 as [NSAttributedString.Key : Any])

        attributedString1.append(attributedString2)

        logoLabel.attributedText = attributedString1

        emailIdTextField.text = RRUtilities.sharedInstance.keychain["userName"]  // UserDefaults.standard.value(forKey: "userName") as? String
        passwordTextField.text = UserDefaults.standard.value(forKey: "pwd") as? String
        passwordTextField.clearsOnBeginEditing = false
        
        passwordTextField.delegate = self

//        #if DEBUG
//        emailIdTextField.text = "admin@prestige.com"
//        passwordTextField.text = "siso@123"
//        #endif

//        print(RRUtilities.sharedInstance.keychain["Cookie"])
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#00327f")
        loginButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#00ca9d")
        loginButton.layer.cornerRadius = 30
        
        emailIdTextField.layer.cornerRadius = 2
        passwordTextField.layer.cornerRadius = 2
        
        emailIdTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "#345b96")
        passwordTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "#345b96")
        
        emailIdTextField.clearsOnBeginEditing = false
        forgotPasswordButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#00ca9d"), for: UIControl.State.normal)
        
        let emailImage = UIImageView.init(image: UIImage.init(named: "user"))
        emailImage.contentMode = UIView.ContentMode.center
        emailImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let userView = UIView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        userView.addSubview(emailImage)
        emailIdTextField.leftView = userView
        emailIdTextField.leftViewMode = .always
       
        let passwordImage = UIImageView.init(image: UIImage.init(named: "password")) //UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        passwordImage.contentMode = UIView.ContentMode.center
        passwordImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let pwdView = UIView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        pwdView.addSubview(passwordImage)
        passwordTextField.leftView = pwdView
        passwordTextField.leftViewMode = .always
                
        showPwdImage = UIImageView.init(image: UIImage.init(named: "hide_password_white"))
        showPwdImage.isUserInteractionEnabled = true
        showPwdImage.tag = 0
        
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showPassword))
        showPwdImage.addGestureRecognizer(tapGuesture)

        showPwdImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        showPwdImage.contentMode = .center
        let showPwdView = UIView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        showPwdView.addSubview(showPwdImage)
        passwordTextField.rightView = showPwdView
        passwordTextField.rightViewMode = UITextField.ViewMode.always

        
        emailIdTextField.attributedPlaceholder = NSAttributedString(string: "Phone number / Email ID",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])


        
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
        let tempNavigator = UINavigationController.init(rootViewController: pwdController)
        self.present(tempNavigator, animated: true, completion: nil)
        
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
            urlRequest1.httpMethod = "POST" //HTTPMethod.post.rawValue
//            urlRequest1.me
            
            urlRequest1.httpShouldHandleCookies = false
            
//            print(urlRequest1.url)
            
            urlRequest1.addValue("User-Agent", forHTTPHeaderField: "RErootMobile")
//            urlRequest1.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//            urlRequest1.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            
            urlRequest1.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest1.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

            

//            let temper =  String(decoding: jsonData, as: UTF8.self)
//            print(temper)

            urlRequest1.httpBody = jsonData
            
            
//            let session = URLSession.shared
//            session.dataTask(with: urlRequest1) { (data, response, error) in
//                if let response = response {
//                    print(response)
//
//                    let str = String(data: data!, encoding: .utf8)
//                    print(str!)
//
//                }
//                if let data = data {
//                    do {
//                        let str = String(data: data, encoding: .utf8)
//                        print(str)
//                        let json = try JSONSerialization.jsonObject(with: data, options: [])
//                        print(json)
//                    } catch {
//                        print(error)
//                    }
//                }
//            }.resume()

            
            AF.request(urlRequest1)
                .responseJSON { response in
//                    print(response)
                    switch response.result {
                    case .success :
//                        print(response)

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

//                                print(loginResult)

                                if case let status as Int = loginResult["status"] //We can store by just checking http status code, but doing with response
                                {
                                    if (status == 1)
                                    {
                                        let httpResponse : [String : String] = (response.response?.allHeaderFields as? Dictionary)!
                                        let cookieArray = httpResponse["Set-Cookie"]?.split(separator: ";")
//                                        print(cookieArray as Any)

                                        if(cookieArray != nil){
                                            RRUtilities.sharedInstance.keychain["userName"] = self.emailIdTextField.text
                                            //                                    RRUtilities.sharedInstance.keychain["password"] = self.passwordTextField.text

                                            let urlResult = try JSONDecoder().decode(LOGIN_OUTPUT.self, from: responseData)

//                                            Answers.logLogin(withMethod: "Login",
//                                                                       success: true,
//                                                                       customAttributes: [
//                                                                        "User": self.emailIdTextField.text!,
//                                                ])
                                            if(urlResult.user != nil){
                                                if(urlResult.user?.type == USER_ROLE_TYPE.ADMIN.rawValue){
                                                    PermissionsManager.shared.isAdmin = true
                                                    UserDefaults.standard.set(true, forKey: "showCommission")
                                                    UserDefaults.standard.set(false, forKey: "promptOTP")
                                                    UserDefaults.standard.set(false, forKey: "siteVisitUser")
                                                }
                                                UserDefaults.standard.set(urlResult.user?.userInfo?.showCommissions ?? false, forKey: "showCommission")
                                                UserDefaults.standard.set(urlResult.user?.userInfo?.promptOtp ?? false, forKey: "promptOTP")
                                                UserDefaults.standard.set(urlResult.user?.userInfo?.siteVisitUser ?? false, forKey: "siteVisitUser")

                                                RRUtilities.sharedInstance.model.writeRRUser(loggedInUser: urlResult.user!, completionHandler: { (result, error) in
                                                    if(result){
                                                        // update UI
                                                    }
                                                    else{

                                                    }
                                                })
                                            }
                                            else{
                                                PermissionsManager.shared.isAdmin = true
                                                UserDefaults.standard.set(true, forKey: "showCommission")
                                                UserDefaults.standard.set(false, forKey: "promptOTP")
                                                UserDefaults.standard.set(false, forKey: "siteVisitUser")
                                            }
                                            if(cookieArray?.count ?? 0 > 0){

                                                for eachOne in cookieArray!{
                                                    let tempStr : String = String(eachOne)

                                                    if(tempStr.contains("BuildEz")){

                                                        var cookieValue : String = tempStr
                                                        cookieValue = cookieValue.replacingOccurrences(of: " HttpOnly,", with: "")
                                                        let tempArray = cookieValue.components(separatedBy: ",")
                                                        var cookie = tempArray.last
                                                        cookie = cookie?.replacingOccurrences(of: " ", with: "")
                                                        //                                                print(cookieValue)
                                                        RRUtilities.sharedInstance.keychain["Cookie"] = cookie
                                                        UserDefaults.standard.set(cookie, forKey: "Cookie")
                                                        break
                                                    }

                                                }
                                            }

                                            UserDefaults.standard.setValue(self.emailIdTextField.text, forKey: "userName")
                                            UserDefaults.standard.setValue(self.passwordTextField.text, forKey: "pwd")
                                            UserDefaults.standard.set(self.emailIdTextField.text, forKey: "userName")
                                            UserDefaults.standard.set(loginResult["groupId"], forKey: "groupId")
                                            UserDefaults.standard.synchronize()
                                            NotificationCenter.default.post(name: NSNotification.Name("NotificationsCall"), object: nil)
                                            NotificationCenter.default.post(name: NSNotification.Name("SetUpCall"), object: nil)
//                                            NotificationCenter.default.post(name: NSNotification.Name("HomeScreenSetUp"), object: nil)
                                            self.sendFCMTokenToServer()
                                            self.getUserPermissions()
                                        }


                                        //                                UserDefaults.standard.set(true, forKey: "hasRunBefore") //To  remove keychain details
                                        //                                UserDefaults.standard.synchronize()

//                                        print("httpResponse \(httpResponse)")

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
    func getUserPermissions(){
     
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        print(RRAPI.API_GET_PERMISSIONS)
        AF.request(RRAPI.API_GET_PERMISSIONS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
//                print(response)
                let str = String(data: response.data!, encoding: .utf8)
                print(str!)

                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(USER_PERMISSIONS_OUTPUT.self, from: responseData)
                    
                    if((urlResult.permArray?.count ?? 0) > 0){
                        RRUtilities.sharedInstance.model.writeAllPermissonsToDB(permissions: urlResult.permArray!)
                        sleep(1)
                        NotificationCenter.default.post(name: NSNotification.Name("HomeScreenSetUp"), object: nil)
                    }

                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    func sendFCMTokenToServer(){
        
//        let delgate = UIApplication.shared.delegate as! AppDelegate
        
        
        //    if([FIRMessaging messaging].FCMToken == nil)

        if(Messaging.messaging().fcmToken != nil){
            
            var parameters : [String : Any] = [:]
            //["fcm_id" : Messaging.messaging().fcmToken!]
            
            parameters["fcm_id"] = Messaging.messaging().fcmToken!
            parameters["device_id"] = UIDevice.current.identifierForVendor?.uuidString
            parameters["app_platform"] = 2
            
//            print(parameters)
            
            print(RRUtilities.sharedInstance.keychain["Cookie"]!)
            
            let headers: HTTPHeaders = [
                "User-Agent" : "RErootMobile",
                "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
            ]
            parameters["src"] = 3
            AF.request(RRAPI.ADD_FCM_ID, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
                response in
                switch response.result {
                case .success :
                    
//                    print(response)
                    
                    do{
                        
                        guard let responseData = response.data else {
                            print("Error: did not receive data")
                            return
                        }

                        let urlResult = try JSONDecoder().decode(otpResult.self, from: responseData)
                        
//                        print(urlResult)

                        if(urlResult.status == 1){
                            // successfully added fcm
                            print("successfully added fcm")
                        }
                        else{
                            print("unable to add fcm")
                        }
                    }
                    catch let error{
                        print(error)
                    }
                    
                    
                    break;
                case .failure(let error):
                    HUD.hide()
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

extension LoginViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(textField == passwordTextField){
            self.login(UIButton())
        }
        return true
    }
}
