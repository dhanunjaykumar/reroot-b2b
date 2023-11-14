//
//  OTPViewController.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 01/02/21.
//  Copyright © 2021 ReRoot. All rights reserved.
//

import UIKit
import PKHUD

protocol OTPProtool : class {
    
    func didVerifyOtp()
    func didResendOtp()
}
extension OTPProtool{
    
    func didVerifyOtp(){}
    func didResendOtp(){}

}
class OTPViewController: UIViewController {

    var resendTimer = Timer()

    @IBOutlet weak var resendView: UIView!
    @IBOutlet weak var counterLabel: UILabel!
    weak var delegate : OTPProtool?
    
    @IBOutlet weak var veifyOtpButton: UIButton!
    @IBOutlet weak var resendOtpButton: UIButton!
    @IBOutlet weak var otpTextField: UITextField!
    var phoneNumberStr : String = ""
    var otpString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resendView.layer.cornerRadius = 8
        veifyOtpButton.layer.cornerRadius = 8
        
        resendView.backgroundColor = .lightGray
        
//        otpTextField.delegate = self
        
        // Do any additional setup after loading the view.
        
        startTimer()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resendTimer.invalidate()
    }
    func startTimer(){
        
        var counter = 30
        var counterLabelText = ""
        self.resendView.backgroundColor = .lightGray
        self.resendView.isUserInteractionEnabled = false

        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            counterLabelText = "( " + "\(counter)" + "s )"
            self.counterLabel.text = counterLabelText
            self.counterLabel.isHidden = false
            counter = counter - 1
            if counter == 0{
                timer.invalidate()
                self.resendView.isUserInteractionEnabled = true
                self.counterLabel.text = ""
                self.counterLabel.isHidden = true
                self.resendView.backgroundColor = self.veifyOtpButton.backgroundColor
            }
        }

    }
    @IBAction func verify(_ sender: Any) {
        
        if(otpTextField.text!.count < 4){
            HUD.flash(.label("Enter proper OTP"), delay: 2.0)
            return
        }
        HUD.show(.progress, onView: self.view)

        ServerAPIs.verifyOTP(phoneNumber: self.phoneNumberStr, otpStr: otpTextField.text!, completion: { response in
            
            DispatchQueue.main.async {
                HUD.hide()
            }

            switch response {
            case .success(let response):
                HUD.flash(.label(response.msg), delay: 2.0)
                self.delegate?.didVerifyOtp()
                break
            case .failure(_):
                HUD.flash(.label("Failed to verify. Try again"), delay: 2.0)
                break

            }
            
        })
        
        
    }
    @IBAction func resend(_ sender: Any) {
     
        HUD.show(.progress, onView: self.view)
        
        ServerAPIs.resendOTP(phoneNumber: phoneNumberStr, completion: { response in
            
            DispatchQueue.main.async {
                HUD.hide()
            }

            switch response {
            case .success(let response):
                DispatchQueue.main.async {
                    self.startTimer()
                    HUD.flash(.label(response.msg), delay: 2.0)
                }
                break
            case .failure(_):
                HUD.flash(.label("Failed to resend. Try again"), delay: 2.0)
                break
            }
            
        })
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
extension OTPViewController : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if(textField.text!.count + string.count == 4){
         
            self.otpString = textField.text! + string
            self.verify(UIButton())
        }
      
        
        return true
    }
    
}
