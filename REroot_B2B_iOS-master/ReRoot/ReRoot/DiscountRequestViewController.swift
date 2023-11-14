//
//  DiscountRequestViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
//import DropDown



class DiscountRequestViewController: UIViewController ,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var subPremiumElementsTextField: UITextField!
    var viewType : VIEW_TYPE!
    var isFromNotification = false
    
    @IBOutlet var heightOfSubElementsView: NSLayoutConstraint!
    @IBOutlet var heightOfSubDiscountTextField: NSLayoutConstraint!
    var isLeads = false
    
    @IBOutlet var heightOfTableView: NSLayoutConstraint!
    var discountInputDictionay : Dictionary<String,Any> = [:]
    var selectedDiscountElements : [DISOCUNT_INPUT] = []
    var selectedBillAmount : Double = 0
    
    var selectedBillingElements : [BILLING_INFO] = []
    
    var selectedBillingElement : BILLING_INFO?
    
    @IBOutlet var unitNameLabel: UILabel!
    @IBOutlet var currentRateLabel: UILabel!
    
    @IBOutlet var addButton: UIButton!
    @IBOutlet var revisedRateLabel: UILabel!
    @IBOutlet var discountsTableView: UITableView!
    @IBOutlet var costTypeTextField: UITextField!
    @IBOutlet var discountPercentageTextField: UITextField!
    @IBOutlet var discountAmtTextField: UITextField!
    
    var selectedIndex : Int = 0
    
    var selectedProspect : REGISTRATIONS_RESULT!
    var statusID : Int? = 0
    var isFromRegistrations : Bool = false
    var unitBillingInfo : UNIT_PRICE_DETAILS!
    
    var billingElementsDataSource : [String] = []
    
    let billingElementSelectionDropDown = DropDown()
    let billingElementSubDropDown = DropDown()
    let premiumBillingElementSubDropDown = DropDown()
    var subElementsOfPremiumBillingDropDown = DropDown()

    @IBOutlet var billingTypeInfoLabel: UILabel!
    @IBOutlet var billingTypeSelectionView: UIView!
    
    var billingTypesArray : [BILLING_INFO] = []
    var premiumBillingTypesArray : [PREMIUM_BILLING_INFO] = []
    var subPremiumBillingTypesArray : [BILLING_INFO] = []
    
    var billingElements : [BILLING_INFO]?
    var premiumBillingElements : [PREMIUM_BILLING_INFO]?
    var subPremiumBillingElements : [BILLING_INFO]?
    
    @objc func injected(){
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideAll), name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)

        billingElementSelectionDropDown.showingBillingElementTypes = true
        
        heightOfSubElementsView.constant = heightOfSubElementsView.constant - 50
        heightOfSubDiscountTextField.constant = 0
        
        billingElementsDataSource.append("Billing Element")
        billingElementsDataSource.append("Premium Billing Element")
        billingTypeInfoLabel.text = "Billing Element"
        
        costTypeTextField.delegate = self
        subPremiumElementsTextField.delegate = self
        
        let tempUnits = selectedProspect.actionInfo?.units
        let counter = tempUnits?.count
        
        if(counter! > 0){
            let unitDetails : UNITS = (selectedProspect.actionInfo?.units![0])!
            unitNameLabel.text = unitDetails.description
        }
        
        let billingInfo = unitBillingInfo.billingInfo
        
        billingElements = unitBillingInfo.billingInfo
        
        premiumBillingElements = unitBillingInfo.premiumBillingInfo
        
        billingTypesArray.removeAll()
        
        billingTypesArray = unitBillingInfo.billingInfo!
        
//        for billType in billingInfo!{
//            billingTypesArray.append(billType.name!)
//        }
        
        print(billingTypesArray)
        
        costTypeTextField.text = billingTypesArray[0].name
        let tempBill = billingInfo![0]
        selectedBillingElement = tempBill
        currentRateLabel.text = String(format: "%d", tempBill.cost!)
        selectedBillAmount = Double(tempBill.cost!)
        billingElementSubDropDown.showingBillingElements = true
        self.setUpBllingElements()
        
        let premiumBillingInfo = unitBillingInfo.premiumBillingInfo
        premiumBillingTypesArray.removeAll()
        
        premiumBillingTypesArray = unitBillingInfo.premiumBillingInfo!
        
//        for billType in premiumBillingInfo!{
//            premiumBillingTypesArray.append(billType.name!)
//        }
        
        if((premiumBillingInfo?.count)! > 0){
            let billInfo = premiumBillingInfo?[0].billings
            if(billInfo?.count != 0){
                for tempBill in billInfo!{
                    subPremiumBillingTypesArray.append(tempBill)
                }
            }
            self.subPremiumElementsTextField.text = self.subPremiumBillingTypesArray[0].name
        }
        print(subPremiumBillingTypesArray)
        
        print(premiumBillingTypesArray)
        self.setUpPremiumElements()

        self.setUpBillingTypesDropDown()
        
        //Register cell
//        DiscountRequestTableViewCell
        let nib = UINib(nibName: "DiscountRequestTableViewCell", bundle: nil)
        discountsTableView.register(nib, forCellReuseIdentifier: "discountCell")
        discountsTableView.tableFooterView = UIView()
        
        discountAmtTextField.delegate = self
        discountPercentageTextField.delegate = self
        
        addButton.layer.cornerRadius = 8
        
        discountsTableView.delegate = self
        discountsTableView.dataSource = self
        
//        unitNameLabel.text = selectedProspect
        
    }
    @objc func hideAll(){
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
    }
    @IBAction func addBillingElement(_ sender: Any) {
        
        //Clear text fields on addig?
        if(selectedBillAmount == 0){
            return
        }
        
        if(selectedBillingElement?._id == nil){
            HUD.flash(.label("Add selected discount!"), delay: 0.8)
            return
        }
        
        if((discountAmtTextField.text?.count)! <= 0)
        {
            HUD.flash(.label("Enter discount amount"), delay: 0.8)
            return
        }
        if((discountPercentageTextField.text?.count)! <= 0){
            HUD.flash(.label("Enter discount percentage"), delay: 0.8)
            return
        }
        
        let discountAmt = Double(discountAmtTextField.text!)
        let discountPercentage = Double(discountPercentageTextField.text!)
        
        let rate = selectedBillingElement?.rate

        var requestedDiscountDetails = DISOCUNT_INPUT()
        requestedDiscountDetails.billingElement = selectedBillingElement?._id
        requestedDiscountDetails.status = 1
        requestedDiscountDetails.rate = selectedBillingElement?.rate
        requestedDiscountDetails.prospectLead = selectedProspect._id
        requestedDiscountDetails.regInfo = selectedProspect.regInfo
        
        requestedDiscountDetails.unit = selectedProspect.project?._id // ***
        
        requestedDiscountDetails.discountedAmt =  Double(discountAmtTextField.text!)
        requestedDiscountDetails.discountedPercent = Double(discountPercentageTextField.text!)
        
        var temprate = Double(rate!)
        let tempAmt  = Double(discountAmt!)
        temprate = temprate - tempAmt
        requestedDiscountDetails.discountedRate =  temprate//Int(temprate)
        
        let tempUnits = selectedProspect.actionInfo?.units
        let counter = tempUnits?.count
        
        if(counter! > 0){
            let unitDetails : UNITS = (selectedProspect.actionInfo?.units![0])!
            requestedDiscountDetails.unit = unitDetails._id
        }

        print(requestedDiscountDetails)
        
        if(discountAmt == 0){
            HUD.flash(.label("Enter Discount amount"), delay: 0.8)
            return
        }
        if(discountPercentage == 0){
            HUD.flash(.label("Enter Discount amount"), delay: 0.8)
            return
        }
        
        let elementCount = selectedBillingElements.count
        
        if(elementCount == 0){
         
            selectedBillingElements.append(selectedBillingElement!)
            selectedDiscountElements.append(requestedDiscountDetails)
        }
        else{
            
            var didFind : Bool = false
            
            for element in selectedBillingElements{
                if(element._id == selectedBillingElement?._id){
                    HUD.flash(.label("Already added"), delay: 0.8)
                    didFind = true
                    return
                }
            }
            
            if(didFind == false){
                selectedBillingElements.append(selectedBillingElement!)
                selectedDiscountElements.append(requestedDiscountDetails)
            }
        }
        
        discountsTableView.reloadData()
        heightOfTableView.constant = discountsTableView.contentSize.height
        self.resetAllLabels()
        
    }
    func submitDiscountRequest(){

        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        if(selectedBillingElements.count == 0){
            HUD.flash(.label("Select Billing element for discount"), delay: 0.8)
            return
        }
        
        HUD.show(.progress)
        
        var parameters : Dictionary<String,Any> = [:]
        
        parameters["_id"] = selectedProspect._id
        
//        if(selectedProspect.viewType == nil){
            parameters["viewType"] = self.viewType.rawValue
//        }else{
//            parameters["viewType"] = selectedProspect.viewType
//        }
        
        var billingElementesArray : Array<Dictionary<String,Any>> = []
        
        for tempBillingElement in selectedDiscountElements{
            
            var billingElementDict : Dictionary<String,Any> = [:]
            billingElementDict["billingElement"] = tempBillingElement.billingElement
            billingElementDict["discountedAmt"] = tempBillingElement.discountedAmt
            billingElementDict["discountedPercent"] = tempBillingElement.discountedPercent
            billingElementDict["discountedRate"] = tempBillingElement.discountedRate
            billingElementDict["prospectlead"] = tempBillingElement.prospectLead
            billingElementDict["qty"] = tempBillingElement.qty
            billingElementDict["rate"] = tempBillingElement.rate
            billingElementDict["regInfo"] = tempBillingElement.regInfo
//            billingElementDict["status"] = tempBillingElement.status
            billingElementDict["unit"] = tempBillingElement.unit
            billingElementDict["type"] = tempBillingElement.type
            
            billingElementesArray.append(billingElementDict)
        }
        
        parameters["unitBillingInfos"] =  billingElementesArray //selectedDiscountElements
        parameters["src"] = 3
        var urlString = ""
        
        var towerId : String = ""
        var blockId : String = ""
        
        if(selectedProspect.unit?.tower != nil){
            towerId = selectedProspect.unit?.tower ?? ""
        }
        else{
            
            if let units = selectedProspect.actionInfo?.units{
                if(units.count > 0){
                    if let unit = selectedProspect.actionInfo?.units?.last as? UNITS{
                        towerId = unit.tower ?? ""
                    }
                }
            }
        }
        
        if(selectedProspect.unit?.block != nil){
            blockId = selectedProspect.unit?.block ?? ""
        }
        else{
            if let units = selectedProspect.actionInfo?.units{
                if(units.count > 0){
                    if let unit = selectedProspect.actionInfo?.units?.last as? UNITS{
                        blockId = unit.block ?? ""
                    }
                }
            }
        }

        
        if(isLeads){
            urlString = String(format:RRAPI.API_APPLY_DISCOUNT,towerId)
        }
        else{
            urlString = String(format:RRAPI.API_APPLY_DISCOUNT,towerId)
        }
        parameters["tower"] = towerId
        parameters["block"] = blockId
        
        

        print(urlString)
//        print(parameters)
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                do{
                    let urlResult = try JSONDecoder().decode(REGISTRATIONS.self, from: responseData)
                    //                print(urlResult)
                    
                    if(urlResult.status == -1){
                        // Logout
                    }
                    HUD.hide()
                    
                    if(urlResult.status == 1){
                        DispatchQueue.main.async {
                            HUD.flash(.label("Unit Discount Submitted"), delay: 1.5)
                            if(!self.isFromNotification){
                                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
                            }
                            else{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.DELETE_NOTIFICATION), object: nil)
                            }
                            //                        self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                }

                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    func resetAllLabels(){
        discountAmtTextField.text = "0"
        discountPercentageTextField.text = "0"
        revisedRateLabel.text = "0"
    }
    func setUpBillingTypesDropDown(){ ///PARENT
        
        billingElementSelectionDropDown.anchorView = billingTypeSelectionView
        billingElementSelectionDropDown.showingBillingElements = true
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        billingElementSelectionDropDown.bottomOffset = CGPoint(x: 0, y: billingTypeSelectionView.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        billingElementSelectionDropDown.dataSource = self.billingElementsDataSource
        
        // Action triggered on selection9
        billingElementSelectionDropDown.selectionAction = { [weak self] (index, item) in
            //            self?.projectNameTextField.setTitle(item, for: .normal)
//            self?.blockNameTextField.text = item
//            let temmm = item
            self?.billingTypeInfoLabel.text  = (item as! String)
//            self?.setupTowersDropDown(selectedBlockName: item)
            if(index == 0){
                //premiumBillingElementSubDropDown
                
                self?.heightOfSubElementsView.constant = 80
                self?.heightOfSubDiscountTextField.constant = 0

                self?.selectedIndex = index
                self?.costTypeTextField.text = self?.billingTypesArray[0].name
                let itemName = self?.billingTypesArray[0].name
                let filterBillElement = self?.billingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(itemName!))! }
                //            print(filterBillElement)
                if(filterBillElement!.count > 0){
                    let billElement = filterBillElement![0]
                    self?.currentRateLabel.text = String(format: "%d", billElement.rate ?? "")
                    self?.selectedBillAmount = Double(billElement.rate!)
                }
            }
            else if(index == 1){
                
                self?.heightOfSubElementsView.constant = self!.heightOfSubElementsView.constant + 50
                self?.heightOfSubDiscountTextField.constant = 50

                self?.selectedIndex = index
                self?.costTypeTextField.text = self?.premiumBillingTypesArray[0].name
                let itemName = self?.premiumBillingTypesArray[0].name
                let filterBillElement = self?.premiumBillingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(itemName!))! }
                //            print(filterBillElement)
                if(filterBillElement!.count > 0){
                    let billElement = filterBillElement![0]
                    self?.currentRateLabel.text = String(format: "%d", billElement.agreeValItem ?? "")
                    self?.selectedBillAmount = Double(billElement.agreeValItem!)
                }
            }
        }
    }
    func setUpBllingElements(){
        //premium unitBillingInfo
        
        billingElementSubDropDown.anchorView = costTypeTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        billingElementSubDropDown.bottomOffset = CGPoint(x: 0, y: costTypeTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        billingElementSubDropDown.dataSource = self.billingTypesArray
        
        // Action triggered on selection9
        billingElementSubDropDown.selectionAction = { [weak self] (index, item) in
            let tempBillingInfo = item as! BILLING_INFO
            self?.costTypeTextField.text  = tempBillingInfo.name
            // filter the item form array
//            billingElements
            
            let filterBillElement = self?.billingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(tempBillingInfo.name!))! }
//            print(filterBillElement)
            if(filterBillElement!.count > 0){
                let billElement = filterBillElement![0]
                self?.selectedBillingElement = filterBillElement![0]
                self?.currentRateLabel.text = String(format: "%d", billElement.rate ?? "")
                self?.selectedBillAmount = Double(billElement.rate!)
            }
        }
        
    }
    func setUpPremiumElements(){
        //unitBillingInfo
        
        premiumBillingElementSubDropDown.anchorView = costTypeTextField
        premiumBillingElementSubDropDown.showingPremiumBillingElements = true
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        premiumBillingElementSubDropDown.bottomOffset = CGPoint(x: 0, y: costTypeTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        premiumBillingElementSubDropDown.dataSource = self.premiumBillingTypesArray
        
        // Action triggered on selection9
        premiumBillingElementSubDropDown.selectionAction = { [weak self] (index, item) in
            let premiumBillInfo = item as! PREMIUM_BILLING_INFO
            self?.costTypeTextField.text = premiumBillInfo.name
            // filter the item form array
            //            billingElements
            
            let filterBillElement = self?.premiumBillingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(premiumBillInfo.name!))! }
            //            print(filterBillElement)
            if(filterBillElement!.count > 0){
                let billElement = filterBillElement![0].billings
                self?.subPremiumBillingElements = billElement
                
//                let premiumBillingInfo = unitBillingInfo.premiumBillingInfo
//                premiumBillingTypesArray.removeAll()
//
//                for billType in premiumBillingInfo!{
//                    premiumBillingTypesArray.append(billType.name!)
//                }
//
                self?.subPremiumBillingTypesArray.removeAll()
                    if(billElement?.count != 0){
                        for tempBill in billElement!{
                            self?.subPremiumBillingTypesArray.append(tempBill)
                        }
                    }
                self?.subPremiumElementsTextField.text = self?.subPremiumBillingTypesArray[0].name
                let tempBillElement = billElement![0]
                self?.currentRateLabel.text = String(format: "%d", tempBillElement.rate ?? "0")
                self?.setUpChildPremiumElementes()
                
//
//                self?.currentRateLabel.text = String(format: "%d", billElement.agreeValItem ?? "")
//                self?.selectedBillAmount = billElement.agreeValItem!
            }
        }
    }
    func setUpChildPremiumElementes(){
//        subElementsOfPremiumBillingDropDown
        //subPremiumBillingTypesArray
        
        subElementsOfPremiumBillingDropDown = DropDown()
        subElementsOfPremiumBillingDropDown.showingBillingElements = true
        
        subElementsOfPremiumBillingDropDown.anchorView = subPremiumElementsTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        subElementsOfPremiumBillingDropDown.bottomOffset = CGPoint(x: 0, y: subPremiumElementsTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        subElementsOfPremiumBillingDropDown.dataSource = self.subPremiumBillingTypesArray
        
        // Action triggered on selection9
        subElementsOfPremiumBillingDropDown.selectionAction = { [weak self] (index, item) in
            let subBillingElement = item as! BILLING_INFO
            self?.subPremiumElementsTextField.text = subBillingElement.name
            // filter the item form array
            //            billingElements
        
            let filterBillElement = self?.subPremiumBillingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(subBillingElement.name!))! }
            //            print(filterBillElement)
            if(filterBillElement!.count > 0){
                let billElement = filterBillElement![0]
                self?.selectedBillingElement = filterBillElement![0]
                self?.currentRateLabel.text = String(format: "%d", billElement.rate ?? "")
                self?.selectedBillAmount = Double(billElement.rate!)
            }
        }
    }
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func hide(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func applyDiscount(_ sender: Any) {
        self.submitDiscountRequest()
    }
    @IBAction func showBillingTypeSelectionView(_ sender: Any) {
        billingElementSelectionDropDown.show()
    }
    // MARK: - Textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if(textField == costTypeTextField){
            
            if(self.selectedIndex == 0){
                
                billingElementSubDropDown.show()
            }
            else if(selectedIndex == 1){
                
                premiumBillingElementSubDropDown.show()
            }
            return false
        }
        if(textField == subPremiumElementsTextField){
            subElementsOfPremiumBillingDropDown.show()
            return false
        }
        if(textField == discountAmtTextField){
            return true
        }
        if(textField == discountPercentageTextField){
            
            return true
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print(string)
        
        if(textField == discountAmtTextField){
            
            if(selectedBillAmount == 0){
                self.resetAllLabels()
                return false
            }

            print(selectedBillAmount)
            var totalString = String(format: "%@%@", discountAmtTextField.text!,string)
            
            if (string.count == 0) { //Delete any cases
                if(range.length > 1){
                    //Delete whole word
                    totalString = "0.0"
                }
                else if(range.length == 1){
                    //Delete single letter
                    let stringer =  discountAmtTextField.text
                    let tempStr = String(stringer!.dropLast())
                    totalString = String(format: "%@%@", tempStr,string)
                    if(totalString.count == 0){
                        totalString = "0.0"
                    }
                }
                else if(range.length == 0){
                    //Tap delete key when textField empty
                    totalString = "0.0"
                }
            }

            
            let reqAmt = Double(totalString)
            let percentage : Double = (Double(reqAmt!) / Double(selectedBillAmount)) * 100.0
            
            if(percentage >= 100 ){
                discountPercentageTextField.text = String(format: "%.2f", percentage)
                let tem = selectedBillAmount - reqAmt!
                revisedRateLabel.text = String(format: "%d", tem)
                HUD.flash(.label("Discount is more than bill price"), delay: 0.7)
            }
            else{
                selectedBillingElement?.selectedDiscountAmt = Double(reqAmt!)
                
                let tem = selectedBillAmount - reqAmt!
                revisedRateLabel.text = String(format: "%d", tem)

                selectedBillingElement?.selectedDiscountPercentage = Double(percentage)
                discountPercentageTextField.text = String(format: "%.2f", percentage)
            }
        }
        else if(textField == discountPercentageTextField){
            
            if(selectedBillAmount == 0){
                self.resetAllLabels()
                return false
            }
            var totalString = String(format: "%@%@", discountPercentageTextField.text!,string)

            if (string.count == 0) { //Delete any cases
                if(range.length > 1){
                    //Delete whole word
                    totalString = "0.0"
                }
                else if(range.length == 1){
                    //Delete single letter
                    let stringer =  discountPercentageTextField.text
                    let tempStr = String(stringer!.dropLast())
                    totalString = String(format: "%@%@", tempStr,string)
                    if(totalString.count == 0){
                        totalString = "0.0"
                    }
                }
                else if(range.length == 0){
                    //Tap delete key when textField empty
                    totalString = "0.0"
                }
            }

            var reqAmt = Double(totalString)
            reqAmt = reqAmt ?? 0.0
            print((reqAmt! * Double(selectedBillAmount)) / 100)
            let discountAmt = (reqAmt! * Double(selectedBillAmount)) / 100
            
            print(discountAmt)
            let tem = Double(selectedBillAmount) - discountAmt
            revisedRateLabel.text = String(format: "%.2f", tem)
            
            
            selectedBillingElement?.selectedDiscountAmt = Double(discountAmt)
            selectedBillingElement?.selectedDiscountPercentage = Double(reqAmt!)
            
            discountAmtTextField.text = String(format: "%.2f", discountAmt)
            
        }
        
        return true
    }
    // MARK: - Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numOfRows: Int = self.selectedBillingElements.count
        
        if (numOfRows > 0)
        {
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Discount Requests"
            noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfRows

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : DiscountRequestTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "discountCell",
            for: indexPath) as! DiscountRequestTableViewCell
        
        let billingElement = selectedBillingElements[indexPath.row]
        
        cell.discountAmountLabel.text = String(format: "%.2f", billingElement.selectedDiscountAmt!)
        cell.discountTypeLabel.text = String(format: "%@", billingElement.name!)
        cell.deleteButton.addTarget(self, action: #selector(deleteBillingItemFromTable(_:)), for: .touchUpInside)
        cell.deleteButton.tag = indexPath.row
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    @objc func deleteBillingItemFromTable(_ sender : UIButton){
        
        //get cell from touch
        
        let tag = sender.tag
        
        let billingElement = selectedBillingElements[tag]
        print(billingElement._id)
        selectedBillingElements.remove(at: tag)
        discountsTableView.reloadData()
        
        heightOfTableView.constant = discountsTableView.contentSize.height


//        for element in selectedBillingElements{
//            if(element._id == billingElement._id){
//                selectedBillingElements.remove(at: tag)
//            }
//        }
        
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
