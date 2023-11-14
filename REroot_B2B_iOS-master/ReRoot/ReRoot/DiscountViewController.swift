//
//  DisocuntViewController.swift
//  REroot
//
//  Created by Dhanunjay on 08/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import FloatingPanel
import DLRadioButton

protocol MOVE_TO_FULL_DELEGATE : class {
    func moveFpcViewToFull()
}

struct DISOCUNT_INPUT : Codable{
    var billingElement : String?
    var discountedAmt : Double?
    var discountedPercent  : Double?
    var discountedRate : Double?
    var prospectLead : String?
    var rate : Double?
    var regInfo : String?
    var status : Int?
    var unit : String?
    var qty : Double?
    var type : String?
    var discountOnRate : Double?
}

class DiscountViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var heightOfDiscountPercentageInfoView: NSLayoutConstraint!
    @IBOutlet var revisedRateInfoView: UIView!
    @IBOutlet var discountOnAmountInfoView: UIView!
    @IBOutlet var discountPercentageInfoView: UIView!
    weak var delegate:MOVE_TO_FULL_DELEGATE?

    var isFromNotification = false
    
    @IBOutlet var discountPercentageInfoLabel: UILabel!
    @IBOutlet var discountAmountInfoLabel: UILabel!
    @IBOutlet var widthOfDiscountPercentageView: NSLayoutConstraint!
    @IBOutlet var discountPercentageView: UIView!
    var selectedBillingTypeIndex : Int = 0
    var selectedBillAmount : Double = 0
    var currentRateAmount : Double = 0
    var selectedBillingElements : [BILLING_INFO] = []
    var selectedBillingElement : BILLING_INFO?
    var selectedDiscountElements : [DISOCUNT_INPUT] = []

    @IBOutlet var discountOnAmountButton: DLRadioButton!
    @IBOutlet var discountOnRateButton: DLRadioButton!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var addDiscountButton: UIButton!
    @IBOutlet var heightOfBillingElementView: NSLayoutConstraint!
    @IBOutlet var heightOfSubBillingElementView: NSLayoutConstraint!
    @IBOutlet var biliingElementView: UIView!
    @IBOutlet var subBillingElementsView: UIView!
    
    var selectedBillElementsDict : Dictionary<String,Array<DISOCUNT_INPUT>> = [:]
    var isPremiumBillingElement : Bool = false
    var selectedPremiumBillingElements : [BILLING_INFO] = []
    
    var prospectDetails : REGISTRATIONS_RESULT!
    var isFromRegistrations : Bool = false
    var viewType : VIEW_TYPE!
    var statusID : Int!
    var unitBillingInfo : UNIT_PRICE_DETAILS!
    @IBOutlet var currentCostLabel: UILabel!
    @IBOutlet var areaLabel: UILabel!
    @IBOutlet var pricingTypeLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    
    @IBOutlet var subBillingElementTextField: UITextField!
    @IBOutlet var billingElementTextField: UITextField!
    @IBOutlet var billingTypesTextField: UITextField!
    
    @IBOutlet var unitNameLabel: UILabel!
    
    @IBOutlet var heightOfDisReqTableView: NSLayoutConstraint!
    @IBOutlet var disReqsTableView: UITableView!
    @IBOutlet var revisedRateLabel: UILabel!
    @IBOutlet var discountPercentageTextField: UITextField!
    @IBOutlet var discountAmountTextField: UITextField!
    var elementTypesDataSource : [String] = []
    
//    var billingTypesArray : [BILLING_INFO] = []
//    var premiumBillingElements : [PREMIUM_BILLING_INFO] = []
//    var subpremiumBillingElements : [BILLING_INFO] = []
    
    var billingElements : [BILLING_INFO]?
    var premiumBillingElements : [PREMIUM_BILLING_INFO]?
    var subPremiumBillingElements : [BILLING_INFO]!

    let billingElementTypesDropDown = DropDown()
    let billingElementsSubDropDown = DropDown()
    let premiumBillingElementsSubDropDown = DropDown()
    var subElementsOfPremiumBillingDropDown = DropDown()
    @IBOutlet weak var discountTypeOppositeAmountLabel: UILabel!
    
    @IBOutlet weak var discountOnAmountTitleLabel: UILabel!
    
    @objc func injected(){
        self.configureView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideAll), name: NSNotification.Name(rawValue: NOTIFICATIONS.HIDE_ALL), object: nil)
        self.configureView()
        
    }
    func shouldShowSubBillingElement(shouldShow : Bool){
        
        if(shouldShow){
            self.subBillingElementsView.isHidden = !shouldShow
            self.heightOfSubBillingElementView.constant = 80
        }else{
            self.subBillingElementsView.isHidden = !shouldShow
            self.heightOfSubBillingElementView.constant = 0
        }
    }
    func shouldShowDiscountPercentageView(shouldShow: Bool){
        if(shouldShow){
            self.widthOfDiscountPercentageView.constant = 150
            discountPercentageView.isHidden = !shouldShow
            heightOfDiscountPercentageInfoView.constant = 0
            discountPercentageInfoView.isHidden = true
        }
        else{
            self.widthOfDiscountPercentageView.constant = 10
            discountPercentageView.isHidden = !shouldShow
            heightOfDiscountPercentageInfoView.constant = 20
            discountPercentageInfoView.isHidden = false
        }
    }
    func configureView(){
        
        self.shouldShowSubBillingElement(shouldShow: false)
        
        billingElementTypesDropDown.showingBillingElementTypes = true
        billingElementsSubDropDown.showingBillingElements = true
        premiumBillingElementsSubDropDown.showingPremiumBillingElements = true

    
        self.shouldShowDiscountPercentageView(shouldShow: true)
        self.addDiscountButton.layer.cornerRadius = 8
        discountOnAmountButton.isSelected = true
        
        
        billingElements = unitBillingInfo.billingInfo
        premiumBillingElements = unitBillingInfo.premiumBillingInfo
        
        billingTypesTextField.delegate = self
        billingElementTextField.delegate = self
        subBillingElementTextField.delegate = self
        discountAmountTextField.delegate = self
        discountPercentageTextField.delegate = self
        
        let tempUnits = prospectDetails.actionInfo?.units
        let counter = tempUnits?.count
        
        if(counter! > 0){
            let unitDetails : UNITS = (prospectDetails.actionInfo?.units![0])!
            unitNameLabel.text = unitDetails.description
        }

        let billingInfo = unitBillingInfo.billingInfo
        if(billingElements?.count ?? 0 > 0){
            billingElementTextField.text = billingElements![0].name
        }
        if(billingInfo?.count ?? 0 > 0){
            let tempBill = billingInfo![0]
            self.setUpUIForSelectedBillingElement(billingElement: tempBill)
            self.selectedBillingTypeIndex = 0
        }

        self.setUpBillingTypesDropDown()
        self.setUpBllingElements()
        
        if((self.premiumBillingElements?.count)! > 0){
            self.setUpPremiumElements(shoudldSetUpUI: false)
        }
        
        if((self.premiumBillingElements?.count)! > 0){
            if(billingElements?.count ?? 0 > 0){
                elementTypesDataSource.append("Billing Element")
            }
            elementTypesDataSource.append("Premium Billing Element")
        }
        else{
            elementTypesDataSource.append("Billing Element")
        }
        billingTypesTextField.text = elementTypesDataSource[0]

        disReqsTableView.estimatedRowHeight = 44 // standard tableViewCell height
        disReqsTableView.rowHeight = UITableView.automaticDimension

        let nib = UINib(nibName: "DiscountRequestTableViewCell", bundle: nil)
        disReqsTableView.register(nib, forCellReuseIdentifier: "discountCell")
        disReqsTableView.tableFooterView = UIView()
        
        disReqsTableView.delegate = self
        disReqsTableView.dataSource = self
        
    }
    // MARK: - DROP DOWNS SET UP BEGING
    func setUpUIForSelectedBillingElement(billingElement : BILLING_INFO){
        
        self.amountLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,billingElement.cost!)
        self.revisedRateLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, billingElement.cost!)
        self.currentCostLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, billingElement.rate!)
        currentRateAmount = Double(billingElement.rate!)
        self.areaLabel.text = String(format: "%.2f", billingElement.qty!)
        self.pricingTypeLabel.text = billingElement.type
        
        if(discountOnRateButton.isSelected == true){
            self.selectedBillAmount = Double(billingElement.rate!)
        }
        else{
            self.selectedBillAmount = Double(billingElement.cost!)
        }
        self.selectedBillingElement = billingElement
        print(self.selectedBillingElement?._id)
        
        self.discountAmountTextField.text = "0"
        self.discountPercentageTextField.text = "" //0.00 %"
        
    }
    func setUpBillingTypesDropDown(){ ///PARENT
        
        billingElementTypesDropDown.anchorView = billingTypesTextField
        billingElementTypesDropDown.showingBillingElements = true
        
        billingElementTypesDropDown.bottomOffset = CGPoint(x: 0, y: billingTypesTextField.bounds.height)
        
        billingElementTypesDropDown.dataSource = self.elementTypesDataSource
        
        billingElementTypesDropDown.selectionAction = { [weak self] (index, item) in

            self?.billingTypesTextField.text = (item as! String)
            
            //            self?.setupTowersDropDown(selectedBlockName: item)
            if(index == 0){
                //premiumbillingElementsSubDropDown
                self?.isPremiumBillingElement = false
                self?.shouldShowSubBillingElement(shouldShow: false)
                self?.setUpBllingElements()
                self?.selectedBillingTypeIndex = index
                self?.billingElementTextField.text = self?.billingElements![0].name
                let itemName = self?.billingElements![0].name
                let filterBillElement = self?.billingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(itemName!))! }
                print(filterBillElement)
                if(filterBillElement!.count > 0){
                    let billElement = filterBillElement![0]
                    self?.setUpUIForSelectedBillingElement(billingElement: billElement)
                }
            }
            else if(index == 1){

                self?.isPremiumBillingElement = true
                self?.delegate?.moveFpcViewToFull()
                self?.shouldShowSubBillingElement(shouldShow: true)

                self?.selectedBillingTypeIndex = index
                self?.setUpPremiumElements(shoudldSetUpUI: true)
                
                let premiumBillingElement = self?.premiumBillingElements?[0]
                if(premiumBillingElement != nil && premiumBillingElement!.name != nil){
                    self?.billingElementTextField.text = self?.premiumBillingElements![0].name
                }
                let itemName = self?.premiumBillingElements![0].name
                
                self?.subPremiumBillingElements = self?.premiumBillingElements![0].billings
                self?.setUpChildPremiumElementes()
                
//                let filterBillElement = self?.premiumBillingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(itemName!))! }
                //            print(filterBillElement)
//                if(filterBillElement!.count > 0){
//                    let billElement = filterBillElement![0]
//                    self?.currentCostLabel.text = String(format: "%d", billElement.agreeValItem ?? "")
//                    self?.amountLabel.text = String(format: "%d", billElement.agreeValItem ?? "")
//                    self?.selectedBillAmount = Double(billElement.agreeValItem!)
//                }
            }
        }
    }
    func setUpBllingElements(){
        //premium unitBillingInfo
        
        billingElementsSubDropDown.anchorView = billingElementTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        billingElementsSubDropDown.bottomOffset = CGPoint(x: 0, y: billingElementTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
//        if(selectedBillingTypeIndex == 0){
            billingElementsSubDropDown.dataSource = self.billingElements!
//        }
//        else if(selectedBillingTypeIndex == 1){
//            billingElementsSubDropDown.dataSource = self.subPremiumBillingElements
//        }
        
        // Action triggered on selection9
        billingElementsSubDropDown.selectionAction = { [weak self] (index, item) in
            let tempBillingInfo = item as! BILLING_INFO
            self?.billingElementTextField.text  = tempBillingInfo.name
            // filter the item form array
            //            billingElements
            
            let filterBillElement = self?.billingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(tempBillingInfo.name!))! }
            //            print(filterBillElement)
            if(filterBillElement!.count > 0){
                let billElement = filterBillElement![0]
                self?.setUpUIForSelectedBillingElement(billingElement: billElement)
            }
        }
    }
    func setUpPremiumElements(shoudldSetUpUI: Bool){
        //unitBillingInfo
        if((self.premiumBillingElements?.count)! <= 0){
            return
        }
        premiumBillingElementsSubDropDown.anchorView = billingElementTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        premiumBillingElementsSubDropDown.bottomOffset = CGPoint(x: 0, y: billingElementTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        premiumBillingElementsSubDropDown.dataSource = self.premiumBillingElements!
        
        let billElement =  self.premiumBillingElements?[0].billings
        self.subPremiumBillingElements = billElement
        self.subBillingElementTextField.text = billElement?[0].name
        if(shoudldSetUpUI){
            if let tempElemet = billElement?[0]{
                self.setUpUIForSelectedBillingElement(billingElement: tempElemet)
            }
        }
        self.setUpChildPremiumElementes()
        
        // Action triggered on selection9
        premiumBillingElementsSubDropDown.selectionAction = { [weak self] (index, item) in
            let premiumBillInfo = item as! PREMIUM_BILLING_INFO
            self?.billingElementTextField.text = premiumBillInfo.name
            // filter the item form array
            //            billingElements
            
            let filterBillElement = self?.premiumBillingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(premiumBillInfo.name!))! }
            //            print(filterBillElement)
            if(filterBillElement!.count > 0){
                let billElement = filterBillElement![0].billings
                
                self?.subPremiumBillingElements = billElement
//                self?.subPremiumBillingElements.removeAll()
                
//                if(billElement?.count != 0){
//                    for tempBill in billElement!{
//                        self?.subPremiumBillingElements.append(tempBill)
//                    }
//                }
                self?.subBillingElementTextField.text = self?.subPremiumBillingElements[0].name
                let tempBillElement = billElement![0]
                self?.setUpUIForSelectedBillingElement(billingElement: tempBillElement)
                self?.setUpChildPremiumElementes()
            
            }
        }
    }
    func setUpChildPremiumElementes(){
        
        subElementsOfPremiumBillingDropDown = DropDown()
        subElementsOfPremiumBillingDropDown.showingBillingElements = true
        
        subElementsOfPremiumBillingDropDown.anchorView = subBillingElementTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        subElementsOfPremiumBillingDropDown.bottomOffset = CGPoint(x: 0, y: subBillingElementTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        subElementsOfPremiumBillingDropDown.dataSource = self.subPremiumBillingElements!
        
        // Action triggered on selection9
        subElementsOfPremiumBillingDropDown.selectionAction = { [weak self] (index, item) in
            let subBillingElement = item as! BILLING_INFO
            self?.subBillingElementTextField.text = subBillingElement.name
            // filter the item form array
            //            billingElements
            
            let filterBillElement = self?.subPremiumBillingElements?.filter{ ($0.name?.localizedCaseInsensitiveContains(subBillingElement.name!))! }
            //            print(filterBillElement)
            if(filterBillElement!.count > 0){
                let billElement = filterBillElement![0]
                self?.setUpUIForSelectedBillingElement(billingElement: billElement)
//                self?.selectedBillingElement = filterBillElement![0]
//                self?.currentCostLabel.text = String(format: "%d", billElement.rate ?? "")
//                self?.amountLabel.text = String(format: "%d", billElement.rate ?? "")
//                self?.pricingTypeLabel.text = billElement.type
//                self?.selectedBillAmount = Double(billElement.rate!)
            }
        }
    }
    // MARK: - DROP DOWNS SET UP END
    
    // MARK: - TEXT FIELD DELEGATE
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if(textField == billingTypesTextField){
            self.billingElementTypesDropDown.show()
            return false
        }
        
        if(textField == billingElementTextField){
            
            if(self.selectedBillingTypeIndex == 0){
//                billingElementTypesDropDown.show()
                self.setUpBillingTypesDropDown()
                billingElementsSubDropDown.show()
            }
            else if(self.selectedBillingTypeIndex == 1){
                premiumBillingElementsSubDropDown.show()
            }
            return false
        }
        
        if(textField == subBillingElementTextField){
            self.setUpChildPremiumElementes()
            self.subElementsOfPremiumBillingDropDown.show()
            return false
        }
        
//        if(textField == billingElementTextField){
//            billingElementsSubDropDown.show()
//            return false
//        }
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print(string)
        
        if(textField == discountAmountTextField){
            
            if(selectedBillAmount == 0){
                self.resetAllLabels()
                return false
            }
            
            print(selectedBillAmount)
            let textFieldText = discountAmountTextField.text!
            var totalString = String(format: "%@%@", discountAmountTextField.text!,string)
            
            if (string.count == 0) { //Delete any cases
                if(range.length > 1){
                    //Delete whole word
                    totalString = "0.0"
                }
                else if(range.length == 1){
                    //Delete single letter
                    let stringer =  discountAmountTextField.text
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
//            let percentage : Double = (Double(reqAmt!) / Double(selectedBillAmount)) * 100.0
            
            var amountForPecentage : Double = 0
            
            if(discountOnRateButton.isSelected){
                amountForPecentage = currentRateAmount
            }
            else{
                amountForPecentage = selectedBillAmount
            }
            
            let percentage : Double = (Double(reqAmt!) / Double(amountForPecentage)) * 100.0
            
            if(percentage >= 100){
                discountPercentageTextField.text = String(format: "%.2f", percentage)
                let tem = selectedBillAmount - reqAmt!
                revisedRateLabel.text = String(format: "%.2f", tem)
                discountAmountTextField.text = textFieldText
                HUD.flash(.label("Discount is more than bill price"), delay: 0.7)
                return false
            }
//            else{
            
            
                selectedBillingElement?.selectedDiscountAmt = Double(reqAmt!)
            
                let discountOnAmount = Double(self.selectedBillingElement!.qty!) * reqAmt!
//                let tem = Double(self.selectedBillingElement!.cost!) - discountOnAmount //selectedBillAmount - reqAmt!
            
                if(!discountOnRateButton.isSelected){
                    let tem = Double(self.selectedBillingElement!.cost!) - reqAmt!
                    revisedRateLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,tem)

                    discountAmountInfoLabel.text = RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")! + String(format: " %.2f", reqAmt!)

                    //String(format: "%.2f", discountOnAmount)
                }
                else{
                    let tem = Double(self.selectedBillingElement!.cost!) - discountOnAmount
                    revisedRateLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,tem)

                    discountAmountInfoLabel.text = RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")! + String(format: " %.2f", discountOnAmount)
                    
                    //String(format: "%.2f", discountOnAmount)
                }
                
                discountPercentageInfoLabel.text = String(format: "%.2f %%", percentage)
                selectedBillingElement?.selectedDiscountPercentage = Double(percentage)
//                if(!discountOnRateButton.isSelected)
//                {
                    selectedBillingElement?.selectedDiscountOnRate = reqAmt
//                }
            if(discountOnAmountButton.isSelected){
                let discountONRate = (percentage * Double(selectedBillingElement!.rate!)) / 100
                print(discountONRate)
                selectedBillingElement?.selectedDiscountOnRate = (percentage * Double(currentRateAmount)) / 100
            }
                if(discountOnRateButton.isSelected){
                    selectedBillingElement?.selectedDiscountAmt = Double(discountOnAmount)
                }
            print(selectedBillingElement)
                discountPercentageTextField.text = String(format: "%.2f", percentage)
//            }
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
            revisedRateLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, tem)
            let discountOnRate = (reqAmt! * currentRateAmount) / 100
            discountAmountInfoLabel.text = String(format: "%@ %@",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, String(format: "%.2f", Double(discountOnRate)))
            discountPercentageInfoLabel.text = String(format: "%.2f %%", discountAmt)

            selectedBillingElement?.selectedDiscountAmt = Double(discountAmt)
            selectedBillingElement?.selectedDiscountPercentage = Double(reqAmt!)
//            if(discountOnRateButton.isSelected)
//            {
            let discountOnRAte = (reqAmt! * Double(selectedBillingElement!.rate!)) / 100
            print(discountOnRAte)
                selectedBillingElement?.selectedDiscountOnRate = discountOnRAte
//            }
            discountAmountTextField.text = String(format: "%.2f", discountAmt)
            print(selectedBillingElement)
        }
        
        return true
    }
    // MARK: - Tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if((selectedBillingElements.count  + selectedPremiumBillingElements.count) > 0)
        {
            tableView.backgroundView = nil
        }
        else{
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Discount Requests"
            noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        if(section == 0){
            return selectedBillingElements.count
        }
        else if(section == 1){
            return selectedPremiumBillingElements.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : DiscountRequestTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "discountCell",
            for: indexPath) as! DiscountRequestTableViewCell
        
        if(indexPath.section == 0)
        {
            let billingElement = selectedBillingElements[indexPath.row]
            
            cell.discountAmountLabel.text = String(format: "%.2f", billingElement.selectedDiscountAmt!)
            cell.discountTypeLabel.text = String(format: "%@", billingElement.cellTitleLabelText!)
            cell.deleteButton.addTarget(self, action: #selector(deleteBillingItemFromTable(_:)), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.row
            cell.sectionIndex = indexPath.section
            cell.rowIndex = indexPath.row
        }
        else{
            
            let billingElement = selectedPremiumBillingElements[indexPath.row]
            
            cell.discountAmountLabel.text = String(format: "%.2f", billingElement.selectedDiscountAmt!)
            cell.discountTypeLabel.text = String(format: "%@", billingElement.cellTitleLabelText!)
            cell.deleteButton.addTarget(self, action: #selector(deleteBillingItemFromTable(_:)), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.row
            cell.sectionIndex = indexPath.section
            cell.rowIndex = indexPath.row
            
        }
        self.heightOfDisReqTableView.constant = self.disReqsTableView.contentSize.height

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @objc func deleteBillingItemFromTable(_ sender : UIButton){
        
        //get cell from touch
        
        let tag = sender.tag
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.disReqsTableView)
        let indexPath = self.disReqsTableView.indexPathForRow(at:buttonPosition)

        let tempCell : DiscountRequestTableViewCell = self.disReqsTableView.cellForRow(at: indexPath!) as! DiscountRequestTableViewCell
        print(tempCell.rowIndex)
        print(tempCell.sectionIndex)
        
        if(tempCell.sectionIndex == 0){  //billing elements
            
            let billingElement = selectedBillingElements[tag]
            print(billingElement._id)
            selectedBillingElements.remove(at: tag)
            
            var beDisocuntElements : [DISOCUNT_INPUT] = selectedBillElementsDict["BE"] ?? []
            var counter = 0
            for eachElement in beDisocuntElements{
                if(eachElement.billingElement == billingElement._id){
                    beDisocuntElements.remove(at: counter)
                    break
                }
                counter += 1
            }
            selectedBillElementsDict["BE"] = beDisocuntElements
            
        }
        else{ //premium billing elements
            
            let billingElement = selectedPremiumBillingElements[tag]
            print(billingElement._id)
            selectedPremiumBillingElements.remove(at: tag)
            
            var pbeDisocuntElements : [DISOCUNT_INPUT] = selectedBillElementsDict["PBE"] ?? []
            var counter = 0
            for eachElement in pbeDisocuntElements{
                if(eachElement.billingElement == billingElement._id){
                    pbeDisocuntElements.remove(at: counter)
                    break
                }
                counter += 1
            }
            selectedBillElementsDict["BE"] = pbeDisocuntElements
            
        }
        
        disReqsTableView.reloadData()
        
        self.perform(#selector(adjustHeightOfTableview), with: nil, afterDelay: 0.3)
        
    }
    // MARK: - ACTION METHODS BEGIN
    
    @IBAction func discountTypeAction(_ sender: DLRadioButton) {
        
        if(discountOnRateButton.isSelected){
            discountTypeOppositeAmountLabel.text = "Discount On Amount"
            self.shouldShowDiscountPercentageView(shouldShow: false)
            discountOnAmountTitleLabel.text = "Discount on Rate"
        }
        else{
            discountTypeOppositeAmountLabel.text = "Discount On Rate"
            discountOnAmountTitleLabel.text = "Discount on Amount"
            self.shouldShowDiscountPercentageView(shouldShow: true)
        }
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addDiscount(_ sender: Any) {
        
        //Clear text fields on addig?
        if(selectedBillAmount == 0){
            return
        }
        
        if(selectedBillingElement?._id == nil){
            HUD.flash(.label("Add selected discount!"), delay: 0.8)
            return
        }
        
        if((discountAmountTextField.text?.count)! <= 0)
        {
            HUD.flash(.label("Enter discount amount"), delay: 0.8)
            return
        }
        if((discountPercentageTextField.text?.count)! <= 0){
            HUD.flash(.label("Enter discount percentage"), delay: 0.8)
            return
        }
        
        let discountAmt = Double(discountAmountTextField.text!)
        let discountPercentage = Double(discountPercentageTextField.text!)
        
        let rate = selectedBillingElement?.rate
        
        var requestedDiscountDetails = DISOCUNT_INPUT()
        requestedDiscountDetails.billingElement = selectedBillingElement?._id
        requestedDiscountDetails.status = 1
        requestedDiscountDetails.rate = selectedBillingElement?.cost
        requestedDiscountDetails.prospectLead = prospectDetails._id
        requestedDiscountDetails.regInfo = prospectDetails.regInfo
        
        requestedDiscountDetails.unit = prospectDetails.project?._id // ***
        
//        requestedDiscountDetails.discountedAmt =  Double(discountAmountTextField.text!)
//        if(discountOnRateButton.isSelected){
            requestedDiscountDetails.discountedAmt = selectedBillingElement?.selectedDiscountAmt
//        }
        requestedDiscountDetails.discountedPercent = Double(discountPercentageTextField.text!)
        requestedDiscountDetails.discountOnRate = selectedBillingElement?.selectedDiscountOnRate
        requestedDiscountDetails.qty = selectedBillingElement?.qty
        requestedDiscountDetails.type = selectedBillingElement?.type
        
        var temprate = Double(rate!)
        let tempAmt  = Double(discountAmt!)
        temprate = temprate - tempAmt
        requestedDiscountDetails.discountedRate =  temprate //Int(temprate)
        
        if(discountOnRateButton.isSelected){
            let discountedRate : Double = (Double(selectedBillingElement!.rate!) - selectedBillingElement!.selectedDiscountOnRate!) * Double(selectedBillingElement!.qty!)
            requestedDiscountDetails.discountedRate = discountedRate
        }
        else{ //discount percentage wise
            let discountedRate = Double(selectedBillingElement!.cost!) - selectedBillingElement!.selectedDiscountAmt!
            requestedDiscountDetails.discountedRate = discountedRate
        }
        
        let tempUnits = prospectDetails.actionInfo?.units
        let counter = tempUnits?.count
        
        if(counter! > 0){
            let unitDetails : UNITS = (prospectDetails.actionInfo?.units![0])!
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
        
//        let elementCount = selectedBillingElements.count
        

        if(isPremiumBillingElement){
            
            var didFind : Bool = false

            var selectedElements : Array<DISOCUNT_INPUT> = selectedBillElementsDict["PBE"] ?? []
            
            for element in selectedElements{
                if(element.billingElement == selectedBillingElement?._id){
                    HUD.flash(.label("Already added"), delay: 0.8)
                    didFind = true
                    return
                }
            }
            if(!didFind){
                selectedElements.append(requestedDiscountDetails)
                selectedBillElementsDict["PBE"] = selectedElements
                selectedBillingElement?.cellTitleLabelText = String(format: "%@ - %@ - %@", billingTypesTextField.text!,billingElementTextField.text!,subBillingElementTextField.text!)
                print(selectedBillingElement?.cellTitleLabelText as Any)
                selectedPremiumBillingElements.append(selectedBillingElement!)
            }
        }
        else{
            
            var didFind : Bool = false
            
            if(selectedBillElementsDict["BE"] != nil){
                
            }
            else{
                
            }
            var selectedElements : Array<DISOCUNT_INPUT> = selectedBillElementsDict["BE"] ?? []
            
            for element in selectedElements{
                if(element.billingElement == selectedBillingElement?._id){
                    HUD.flash(.label("Already added"), delay: 0.8)
                    didFind = true
                    return
                }
            }
            if(!didFind){
                selectedElements.append(requestedDiscountDetails)
                selectedBillElementsDict["BE"] = selectedElements
                let tempStr = String(format: "%@ - %@", billingTypesTextField.text!,billingElementTextField.text!)
                selectedBillingElement?.cellTitleLabelText = tempStr
                print(selectedBillingElement?.cellTitleLabelText as Any)
                selectedBillingElements.append(selectedBillingElement!)
            }
        }
        
        self.resetAllLabels()
        
        DispatchQueue.main.async {
            self.disReqsTableView.reloadData()
            self.perform(#selector(self.adjustHeightOfTableview), with: nil, afterDelay: 0.3)
        }
    }
    @objc func adjustHeightOfTableview(){
        if(self.disReqsTableView.contentSize.height == 0){
            self.heightOfDisReqTableView.constant = 44
        }
        else{
            self.heightOfDisReqTableView.constant = self.disReqsTableView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }
    func resetAllLabels(){
        discountAmountTextField.text = "0"
        discountPercentageTextField.text = "0" //0.00 %"
        revisedRateLabel.text = String(format: "%.2f", selectedBillAmount)
        discountAmountInfoLabel.text = "0.00"
        discountPercentageInfoLabel.text = ""
    }
    @IBAction func applyDiscount(_ sender: Any) {
        
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
        
        parameters["_id"] = prospectDetails._id
        parameters["projectName"] = prospectDetails.project?.name
        parameters["unitDescription"] = unitNameLabel.text
        
        //        if(selectedProspect.viewType == nil){
        parameters["viewType"] = self.viewType.rawValue
        //        }else{
        //            parameters["viewType"] = selectedProspect.viewType
        //        }
        
        var prospectLead = ""
        var unit  = ""
        var regInfo = ""
        
        
        let beDisocuntElements : [DISOCUNT_INPUT] = selectedBillElementsDict["BE"] ?? []
        let pBeDisocuntElements : Array<DISOCUNT_INPUT> = selectedBillElementsDict["PBE"] ?? []

        var beBillingElementsArray : Array<Dictionary<String,Any>> = []
        var pBeBillingElementsArray : Array<Dictionary<String,Any>> = []
        
        for tempBillingElement in beDisocuntElements{
            
            var billingElementDict : Dictionary<String,Any> = [:]
            billingElementDict["billingElement"] = tempBillingElement.billingElement
            billingElementDict["discountedAmt"] = tempBillingElement.discountedAmt
            billingElementDict["discountedPercent"] = tempBillingElement.discountedPercent
            billingElementDict["discountedRate"] = tempBillingElement.discountedRate
            billingElementDict["discountOnRate"] = tempBillingElement.discountOnRate
            billingElementDict["prospectlead"] = tempBillingElement.prospectLead
            prospectLead = tempBillingElement.prospectLead!
            unit = tempBillingElement.unit!
            regInfo = tempBillingElement.regInfo!
            billingElementDict["qty"] = tempBillingElement.qty
            billingElementDict["rate"] = tempBillingElement.rate
            billingElementDict["regInfo"] = tempBillingElement.regInfo
            //            billingElementDict["status"] = tempBillingElement.status
            billingElementDict["unit"] = tempBillingElement.unit
            billingElementDict["type"] = tempBillingElement.type
            if(self.prospectDetails.actionInfo?.scheme != nil && self.prospectDetails.actionInfo?.scheme?._id != nil){
                billingElementDict["scheme"] = self.prospectDetails.actionInfo?.scheme?._id
            }
            beBillingElementsArray.append(billingElementDict)

        }
        
        for tempBillingElement in pBeDisocuntElements{
            
            var billingElementDict : Dictionary<String,Any> = [:]
            billingElementDict["billingElement"] = tempBillingElement.billingElement
            billingElementDict["discountedAmt"] = tempBillingElement.discountedAmt
            billingElementDict["discountedPercent"] = tempBillingElement.discountedPercent
            billingElementDict["discountedRate"] = tempBillingElement.discountedRate
            billingElementDict["discountOnRate"] = tempBillingElement.discountOnRate
            billingElementDict["prospectlead"] = tempBillingElement.prospectLead
            prospectLead = tempBillingElement.prospectLead!
            unit = tempBillingElement.unit!
            regInfo = tempBillingElement.regInfo!
            billingElementDict["qty"] = tempBillingElement.qty
            billingElementDict["rate"] = tempBillingElement.rate
            billingElementDict["regInfo"] = tempBillingElement.regInfo
            //            billingElementDict["status"] = tempBillingElement.status
            billingElementDict["unit"] = tempBillingElement.unit
            billingElementDict["type"] = tempBillingElement.type
            
            if(self.prospectDetails.actionInfo?.scheme != nil && self.prospectDetails.actionInfo?.scheme?._id != nil){
                billingElementDict["scheme"] = self.prospectDetails.actionInfo?.scheme?._id
            }

            pBeBillingElementsArray.append(billingElementDict)
        }

        
        
        for billingElemnt in self.billingElements!
        {
            var didFound = false
            
            for addedElemetn in beDisocuntElements{
                if(addedElemetn.billingElement == billingElemnt._id){
                    didFound = true
                }
            }
            if(didFound == false){
                
                var billingElementDict : Dictionary<String,Any> = [:]
                billingElementDict["billingElement"] = billingElemnt._id
                billingElementDict["qty"] = billingElemnt.qty
                billingElementDict["unit"] = unit
                billingElementDict["type"] = billingElemnt.type
                billingElementDict["prospectlead"] = prospectLead
                billingElementDict["regInfo"] = regInfo
                billingElementDict["rate"] = billingElemnt.cost
                billingElementDict["discountedRate"] = billingElemnt.cost
                
                if(self.prospectDetails.actionInfo?.scheme != nil && self.prospectDetails.actionInfo?.scheme?._id != nil){
                    billingElementDict["scheme"] = self.prospectDetails.actionInfo?.scheme?._id
                }

                beBillingElementsArray.append(billingElementDict)
            }
        }
        
//        for eachElement in billingElementesArray{
//            print(eachElement)
//        }
//
//        print(billingElementesArray.count)
//        print(billingElementesArray)
        
        if(self.premiumBillingElements != nil  && (self.premiumBillingElements?.count)! > 0){
            
            for tempBillingElement in self.premiumBillingElements!
            {
                for billingElemnt in tempBillingElement.billings!{
                    
                    var didFound = false
                    
                    for addedElemetn in pBeDisocuntElements{
                        if(addedElemetn.billingElement == billingElemnt._id){
                            didFound = true
                        }
                    }
                    if(didFound == false){
                        
                        var billingElementDict : Dictionary<String,Any> = [:]
                        billingElementDict["billingElement"] = billingElemnt._id
                        billingElementDict["qty"] = billingElemnt.qty
                        billingElementDict["unit"] = unit
                        billingElementDict["type"] = billingElemnt.type
                        billingElementDict["prospectlead"] = prospectLead
                        billingElementDict["regInfo"] = regInfo
                        billingElementDict["rate"] = billingElemnt.cost
                        billingElementDict["discountedRate"] = billingElemnt.cost
                        if(self.prospectDetails.actionInfo?.scheme != nil && self.prospectDetails.actionInfo?.scheme?._id != nil){
                            billingElementDict["scheme"] = self.prospectDetails.actionInfo?.scheme?._id
                        }

                        pBeBillingElementsArray.append(billingElementDict)
                    }
                }
            }

        }
        
//        print(billingElementesArray.count)
//        print(billingElementesArray)

        
        /*
         
         var billingElement : String?
         var discountedAmt : Double?
         var discountedPercent  : Double?
         var discountedRate : Double?
         var prospectLead : String?
         var rate : Int?
         var regInfo : String?
         var status : Int?
         var unit : String?
         var qty : Int?
         var type : String?
         var discountOnRate : Double?
         
         */
        
        var allBillingElementsArray : Array<Dictionary<String,Any>> = []
        allBillingElementsArray.append(contentsOf: beBillingElementsArray)
        allBillingElementsArray.append(contentsOf: pBeBillingElementsArray)
        
        parameters["unitBillingInfos"] =  allBillingElementsArray //selectedDiscountElements
        
        if(prospectDetails.actionInfo?.units?.count ?? 0 > 0){
            let unitDetails : UNITS = (prospectDetails.actionInfo?.units![0])!
            parameters["unitDescription"] = unitDetails.description
            if let unitID = unitDetails._id{
                if let storedUnitDetails = RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: unitID){
                    parameters["unitDescription"] = storedUnitDetails.description1
                    parameters["unitNo"] = String(format: "%d", storedUnitDetails.unitIndex)
                }
            }
        }
        
        var urlString = ""
        
        var towerId : String = ""
        var blockId : String = ""
        
        if(prospectDetails.unit?.tower != nil){
            towerId = prospectDetails.unit?.tower ?? ""
        }
        else{
            
            if let units = prospectDetails.actionInfo?.units{
                if(units.count > 0){
                    if let unit = prospectDetails.actionInfo?.units?.last as? UNITS{
                        towerId = unit.tower ?? ""
                    }
                }
            }
        }
        
        if(prospectDetails.unit?.block != nil){
            blockId = prospectDetails.unit?.block ?? ""
        }
        else{
            if let units = prospectDetails.actionInfo?.units{
                if(units.count > 0){
                    if let unit = prospectDetails.actionInfo?.units?.last as? UNITS{
                        blockId = unit.block ?? ""
                    }
                }
            }
        }
        
        if(self.viewType == VIEW_TYPE.LEADS){ //if(isLeads){
            urlString = String(format:RRAPI.API_APPLY_DISCOUNT,towerId)
        }
        else{
            urlString = String(format:RRAPI.API_APPLY_DISCOUNT,towerId)
        }
        
        parameters["tower"] = towerId
        parameters["block"] = blockId
        parameters["src"] = 3
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
                    else if(urlResult.status == -1){
                        let tempResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                        HUD.flash(.label(tempResult.err ?? ""), delay: 1.0)

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
    @objc func hideAll(){
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.POP_CONTROLLERS), object: nil)
    }

    // MARK: - ACTION METHODS END
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
