//
//  CosFollowUpViewController.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 20/11/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PKHUD

class CosFollowUpViewController: UIViewController {

    @IBOutlet weak var commentsTextView: KMPlaceholderTextView!
    @IBOutlet weak var modeTextField: UITextField!
    @IBOutlet weak var outstandingAmtLabel: UILabel!
    @IBOutlet weak var receivedAmtLabel: UILabel!
    @IBOutlet weak var invoicedAmtLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var unitDetailsLabel: UILabel!
    @IBOutlet weak var unitNameLabel: UILabel!
    
    var selectedOutstanding : CustomerOutstanding!
    lazy var modesArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        modesArray = ["Select Mode","Call","Email","Personal Visit","By Post"]
        
        commentsTextView.layer.cornerRadius = 8
        commentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentsTextView.layer.borderWidth = 1.0

        unitNameLabel.text = String(format: "%@ (%@)", selectedOutstanding.unitDisplayName ?? "",selectedOutstanding.description1 ?? "")
        unitDetailsLabel.text = String(format: "%@ | %@ | %@", selectedOutstanding.projectName ?? "",selectedOutstanding.blockName ?? "",selectedOutstanding.towerName ?? "")

        invoicedAmtLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,(selectedOutstanding.demandLetterTax + selectedOutstanding.demandLetterAmount))
        receivedAmtLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,selectedOutstanding.totalReceipt)
        outstandingAmtLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,((selectedOutstanding.demandLetterTax + selectedOutstanding.demandLetterAmount) - selectedOutstanding.totalReceipt))
        
        modeTextField.delegate = self
        
    }
    @IBAction func addFollowUp(_ sender: Any) {
        
        if(modeTextField.text == "Select Mode" || modeTextField.text!.isEmpty){
            HUD.flash(.label("Select Followed-up Mode"), delay: 1.0)
            return
        }
        if(commentsTextView.text.isEmpty){
            HUD.flash(.label("Enter Comments"), delay: 1.0)
            return
        }
        var parameters : Dictionary<String,Any> = [:]
        parameters["mode"] = modeTextField.text
        parameters["comment"] = commentsTextView.text
        parameters["customer"] = selectedOutstanding.cosCustomerId
        parameters["outstandingAmount"] = ((selectedOutstanding.demandLetterTax + selectedOutstanding.demandLetterAmount) - selectedOutstanding.totalReceipt)
        parameters["unit"] = selectedOutstanding.unitId
        
        ServerAPIs.addCosFollowUp(parameters: parameters, completion: { [weak self] result in
            HUD.hide()
            switch result {
            case .success(let result):
                self?.dismiss(animated: true, completion: nil)
                let resultStr = result ? "Added succesfully" : "Faild to add."
                HUD.flash(.label(resultStr), delay: 1.5)
                break
            case .failure(let error):
                HUD.flash(.label(error.localizedDescription), delay: 1.0)
                break
            }

        })
        
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func showModes(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .COMMON
        vc.preferredContentSize = CGSize(width:  300, height: (self.modesArray.count - 1) * 44)
        
        if(CGFloat((self.modesArray.count * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 300, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.commonDataSource = self.modesArray
        
        popOver?.sourceView = modeTextField
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

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
extension CosFollowUpViewController : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.showModes()
        return false
    }
}
extension CosFollowUpViewController : UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
extension CosFollowUpViewController : HidePopUp{
    func didSelectRow(selectedRowText: String, selectedIndex: Int) {
        modeTextField.text = selectedRowText
        
        let tmpController :UIViewController! = self.presentedViewController;
              self.dismiss(animated: false, completion: {()->Void in
                  tmpController.dismiss(animated: false, completion: nil);
              });
    }
}
