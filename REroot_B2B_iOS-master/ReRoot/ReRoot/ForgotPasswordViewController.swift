//
//  ForgotPasswordViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 04/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire

struct otpResult : Codable {
    let status : Int
    let msg : String?
    let token : String?
    let err : String?
}

class ForgotPasswordViewController: UIViewController ,UITextFieldDelegate {

    @IBOutlet var otpSuccessImage: UIImageView!
    var otpToken : String!
    @IBOutlet var changePwdButton: UIButton!
    @IBOutlet var reEnterPwdField: UITextField!
    @IBOutlet var newPwdField: UITextField!
    @IBOutlet var otpFieldView: UIView!
    @IBOutlet var heightOfOtpView: NSLayoutConstraint!
    
    @IBOutlet var mEmailAddressField: UITextField!
    @IBOutlet var sendOTPButton: UIButton!
    @IBOutlet var heightOfPwdFieldsView: NSLayoutConstraint!
    @IBOutlet var passwordView: UIView!
    
    @IBOutlet var otpTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        
        heightOfOtpView.constant = 0.0
        heightOfPwdFieldsView.constant = 0.0
        
        otpTextField.delegate = self
        sendOTPButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#34495e")
        changePwdButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#34495e")
        sendOTPButton.layer.cornerRadius = 8
        changePwdButton.layer.cornerRadius = 8
        
        otpFieldView.isHidden = true
        passwordView.isHidden = true
        
        self.otpSuccessImage.isHidden = true
        
    }

    @IBAction func getOTP(_ sender: Any) {
        
        guard let email = mEmailAddressField.text , RRUtilities.sharedInstance.isValidEmail(emailID: mEmailAddressField.text!) != false else{
            HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
            return
        }
        
        mEmailAddressField.isEnabled = false
        
        var parameters : [String : String] = ["email" : email]
        parameters["src"] = "3"
        
        AF.request(RRAPI.CREATE_OTP_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders.init(RRAPI.DEFAULT_HEADER)).responseJSON{
            response in
            switch response.result {
            case .success :
                
//                print(response)
                HUD.hide()
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    self.mEmailAddressField.isEnabled = true
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(otpResult.self, from: responseData)
                    
                    //                print(urlResult)
                    
                    if(urlResult.status == 0){
                        HUD.flash(.label("Invalid Email ID"), delay: 1.0)
                        self.mEmailAddressField.isEnabled = true
                        return
                    }
                    else{
                        HUD.flash(.label("OTP Sent Successfully"), delay: 1.0)
                    }
                    
                    self.heightOfOtpView.constant = 116
                    self.otpFieldView.isHidden = false
                    self.sendOTPButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#9b9b9b")
                    self.sendOTPButton.setTitle("Re-send OTP", for: .normal)
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
    
    func verifyOTP()  {
        
        guard let otp = otpTextField.text , otp.count == RRAPI.OTP_LENGTH else{
            return
        }
        
        var parameters: [String : String] = ["email" : mEmailAddressField.text!,"otp" : otpTextField.text!]
        parameters["src"] = "3"
        
        AF.request(RRAPI.VERIFY_OTP_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders.init(RRAPI.DEFAULT_HEADER)).responseJSON{
            response in
            switch response.result {
            case .success :
                
//                print(response)
                
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                
                let httpResponse : [String : String] = (response.response?.allHeaderFields as? Dictionary)!
                let cookieArray = httpResponse["Set-Cookie"]?.split(separator: ";")
                print(cookieArray as Any)

                    do{
                        let urlResult = try JSONDecoder().decode(otpResult.self, from: responseData)
                        
                        //                    print(urlResult)
                        
                        if(urlResult.status == 0){
                            HUD.flash(.label(urlResult.msg), delay: 1.0)
                            self.otpTextField.isEnabled = true
                            
                            return
                        }
                        else{
                            HUD.flash(.label("OTP Verified !"), delay: 1.0)
                            self.otpSuccessImage.isHidden = false
                            self.sendOTPButton.isEnabled = false
                            self.otpToken = urlResult.token
                        }
                        
                        //                    print(urlResult)
                        self.heightOfPwdFieldsView.constant = 353
                        self.passwordView.isHidden = false
                        
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
    func reSendOTP() {
        
        guard let email = mEmailAddressField.text , RRUtilities.sharedInstance.isValidEmail(emailID: mEmailAddressField.text!) != false else{
            HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
            return
        }
        var parameters : [String : String] = ["email" : email]
        parameters["src"] = "3"
        
        AF.request(RRAPI.RESEND_OTP_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders.init(RRAPI.DEFAULT_HEADER)).responseJSON{
            response in
            switch response.result {
            case .success :
                
//                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                HUD.hide()
                do{
                    let urlResult = try JSONDecoder().decode(otpResult.self, from: responseData)
                    
                    //                print(urlResult)
                    
                    if(urlResult.status == 0){
                        HUD.flash(.label("Invalid Email ID"), delay: 1.0)
                        return
                    }
                    else{
                        HUD.flash(.label("OTP Sent Successfully"), delay: 1.0)
                    }
                    
                    self.heightOfOtpView.constant = 116
                    self.otpFieldView.isHidden = false
                    self.sendOTPButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#9b9b9b")
                    self.sendOTPButton.setTitle("Re-send OTP", for: .normal)
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
    
    @IBAction func changePassword(_ sender: Any) {
        
        guard let newPwd = newPwdField.text else {
            HUD.flash(.label("Enter new password"), delay: 1.0)
            return
        }
        guard let retypedPwd = reEnterPwdField.text else {
            HUD.flash(.label("Re-Enter new password"), delay: 1.0)
            return
        }
        
        if(newPwd != retypedPwd){
            HUD.flash(.label("Re-Entered Password is not matching!"), delay: 1.0)
            return
        }
       
        newPwdField.isEnabled = false
        reEnterPwdField.isEnabled = false
        HUD.show(.progress)
        var parameters: [String : String] = ["password" : newPwd,"token" : self.otpToken]
        parameters["src"] = "3"
        
        AF.request(RRAPI.CHNAGE_PASSWORD_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders.init(RRAPI.DEFAULT_HEADER)).responseJSON{
            response in
            switch response.result {
            case .success :
//                print(response)
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
//                    guard let urlResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
//                        print("error trying to convert data to JSON")
//                        HUD.hide()
//                        return
//                    }
                    
                    do{
                        let urlResult = try JSONDecoder().decode(ForgotPasswordResult.self, from: responseData)
                        
                        //                    print(urlResult)
                        if(urlResult.status == 0){
                            HUD.flash(.label(urlResult.err), delay: 2.0)
                            self.newPwdField.isEnabled = true
                            self.reEnterPwdField.isEnabled = true
                            return
                        }
                        else{
                            HUD.hide()
                            HUD.flash(.label(urlResult.msg), delay: 2.0)
//                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        print(updatedText)

        if (updatedText.count == RRAPI.OTP_LENGTH && textField === otpTextField) {
            self.otpTextField.text = updatedText
            self.otpTextField.isEnabled = false
            self.verifyOTP()
        }
        
        return updatedText.count <= RRAPI.OTP_LENGTH;
    }

    @IBAction func hideKeyboard(_ sender: Any) {
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
