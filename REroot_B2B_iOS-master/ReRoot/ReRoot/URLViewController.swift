//
//  URLViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 05/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import PKHUD

class URLViewController: UIViewController,UITextFieldDelegate,HidePopUp ,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate{
    
    var urlsTypesArray : NSMutableOrderedSet = []
    var serverIPSDict : Dictionary<String,String> = [:]
    
    @IBOutlet var serverURLInfoLabel: UILabel!
    @IBOutlet var editUrlTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var urlTextField: UITextField!
    
    @IBOutlet var heightOfEditUrlField: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        
//        print(editUrlTextField.text)
        
        let urlStrig : String = UserDefaults.standard.value(forKey: "url") as? String ?? ""
        
        serverIPSDict = ["PRODUCTION" :"http://13.233.30.97:3000","DEVELOPMENT": "http://52.66.34.235:3000","OTHER":""]
        urlsTypesArray.add("PRODUCTION")
        urlsTypesArray.add("DEVELOPMENT")
        urlsTypesArray.add("OTHER")
        
        heightOfEditUrlField.constant = 0
        urlTextField.delegate = self
        
        urlTextField.textAlignment = .center
        editUrlTextField.textAlignment = .center
        
        
        if(urlStrig.count > 0){
            urlTextField.text = "PRODUCTION"
            editUrlTextField.text = "http://xxx.xx.xx.xxx:3000"
        }
        else{
            #if DEBUG
            urlTextField.text = "PRODUCTION"
            #else
            urlTextField.text = "DEVELOPMENT"
            #endif
        }
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: Any) {
        
        if(editUrlTextField.text?.count == 0){
            HUD.flash(.label("Enter proper URL"))
            return
        }
        heightOfEditUrlField.constant = 0
        
        let serverKey = urlTextField.text
        
        if(serverKey != "OTHER"){
            let serverIP = serverIPSDict[serverKey!]
            UserDefaults.standard.set(serverIP, forKey: "url")
            UserDefaults.standard.synchronize()
        }
        else{
            
            if(editUrlTextField.text != "http://xxx.xx.xx.xxx:3000")
            {
                urlTextField.text = editUrlTextField.text
                UserDefaults.standard.set(editUrlTextField.text, forKey: "url")
                UserDefaults.standard.synchronize()
            }
            else{
                HUD.flash(.label("Enter Proper Server IP"), delay: 1.0)
                return
            }
        }

        self.dismiss(animated: true, completion: nil)
    }
     // MARK: - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == urlTextField) {
            //show popup
            self.showPopUp()
            return false
        }
        if(textField == editUrlTextField){
            
        }
        
        return true
        
    }
    func showPopUp(){
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .URLS
        vc.preferredContentSize = CGSize(width: 250, height: (serverIPSDict.keys.count - 1) * 44)
        
        if(CGFloat((serverIPSDict.keys.count * 44)) > (self.view.frame.size.height - 80)){
            
            vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.up
//        let allKeys : Array<String> = Array(self.serverIPSDict.keys)
        vc.tableViewDataSourceOne = urlsTypesArray.array as! [String]
        popOver?.sourceView = urlTextField
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func didSelectProject(optionType: String, optionIndex: Int) {
        
    }
    
    func didFinishTask(optionType: String, optionIndex: Int) {
        print(optionType)
        print(optionIndex)
        
        if(optionIndex == 0)
        {
//            UserDefaults.standard.set("http://13.233.30.97:3000", forKey: "url")
//            UserDefaults.standard.synchronize()
            urlTextField.text = "PRODUCTION"
            heightOfEditUrlField.constant = 0

        }
        else if(optionIndex == 1)
        {
//            UserDefaults.standard.set("http://52.66.34.235:3000", forKey: "url")
//            UserDefaults.standard.synchronize()
            urlTextField.text = "DEVELOPMENT"
            heightOfEditUrlField.constant = 0
        }
        else if(optionIndex == 2) //Other
        {
            urlTextField.text = "OTHER"
            heightOfEditUrlField.constant = 60
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func didSelectOptionForUnitsView(selectedIndex: Int) {
        
    }
    
    func shouldShowUnitsWithSelectedStatus(selectedStatus: Int) {
        
    }
    
    func showSelectedTowerFromFloatButton(selectedTower: TOWERDETAILS, selectedBlock: String) {
    
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
