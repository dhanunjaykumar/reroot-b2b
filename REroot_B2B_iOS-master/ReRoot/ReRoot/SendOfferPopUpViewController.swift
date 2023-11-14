//
//  SendOfferPopUpViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 11/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class SendOfferPopUpViewController: UIViewController {

    var prevSelectedStatus : Int!
    var isFromRegistrations : Bool = false
    var selectedProspect : REGISTRATIONS_RESULT!
    var statusID : Int?
    @IBOutlet var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        emailTextField.text = selectedProspect.userEmail
        //IQPreviousNextView
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okAction(_ sender: Any) {
        //show schedule states ***
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
        leadsPopUpController.prospectDetails = selectedProspect
        leadsPopUpController.selctedScheduleCallOption = prevSelectedStatus + 1
        leadsPopUpController.isFromRegistrations = self.isFromRegistrations
        leadsPopUpController.statusID = self.statusID
        self.present(leadsPopUpController, animated: true, completion: nil)

        
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
