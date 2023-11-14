//
//  ReceiptEntryFormViewController.swift
//  REroot
//
//  Created by Dhanunjay on 19/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit                       
import Alamofire
import PKHUD
import AWSS3

class ReceiptEntryFormViewController: UIViewController,UITextFieldDelegate,UIPopoverPresentationControllerDelegate,DateSelectedFromPicker {
    
    let receiptEntryGroup = DispatchGroup()
    var fileManager = FileManager.default
    var imagePicker: ImagePicker!
    var receiptEntryImages : [String] = []
    var uploadedImageUrls : [String] = []
    @IBOutlet weak var recieptImageView: UIImageView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var heightOfChequePhotosView: NSLayoutConstraint!
    @IBOutlet weak var chequePhotosView: UIView!
    var customer : CLIENT_CUSTOMER!
    var selectedProject : Project!
    var selectedUnit : Units!
    var selectedClient : RESERVED_UNITS!
    var selectedBookedClint : BOOKED_CUSTOMER!
    
    @IBOutlet weak var heightOfCreateButton: NSLayoutConstraint!
    var selectedCurrencyConverter : Double!
    
    var selectedReceiptEntry : ReceiptEntry! //= ReceiptEntry.init()

    var projectBanks : [BANK_ACCOUNTS]!
    var selectedProjectBank : BANK_ACCOUNTS!
    var ifscCode : IFSC_CODE_OUTPUT!
    var selectedPaymentMode : String!
    var selectedPaymentToWards : String!
    
    var selectedPaymentTowardsDict : PaymentToWards!
    var prevSelectedPaymentTowards : PaymentToWards!
    
    @IBOutlet var heightOfBankBranchInfoView: NSLayoutConstraint!
    @IBOutlet var heightOfReferenceNumberView: NSLayoutConstraint!
    @IBOutlet var referenceNumberView: UIView!
    @IBOutlet var heightOfPaymentDateView: NSLayoutConstraint!
    @IBOutlet var depositBankNameLabel: UILabel!
    @IBOutlet var currencyInfoLabel: UILabel!
    
    @IBOutlet var currencyInfoView: UIView!
    
    var selectedChequeDate : Date!
    var selectedDepositeDate : Date!
    var selectedPaymentDate : Date!
    
    @IBOutlet var viewReceiptButton: UIButton!
    @IBOutlet var receiptEntryCreateButton: UIButton!
    @IBOutlet var paymentDateView: UIView!
    @IBOutlet var heightOfReferenceAndDateInfoView: NSLayoutConstraint!
    @IBOutlet var heightOfChequeView: NSLayoutConstraint!
    @IBOutlet var referenceNumberAndDateInfoView: UIView!
    @IBOutlet var bankBranchIFSCInfoView: UIView!
    @IBOutlet var chequeDetailsView: UIView!
    @IBOutlet var paymentTowardsTextField: UITextField!
    @IBOutlet var paymentModeTextField: UITextField!
    
    @IBOutlet var chequeNumberTextField: UITextField!
    @IBOutlet var chequeDateTextField: UITextField!
    @IBOutlet var depositeDateTextField: UITextField!
    @IBOutlet var referenceNumberTextField: UITextField!
    @IBOutlet var paymentDateTextField: UITextField!
    
    @IBOutlet var depositeBankTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var currencyNameTextField: UITextField!
    @IBOutlet var foreignCurrencyTextField: UITextField!
    
    @IBOutlet var ifscCodeTextField: UITextField!
    
    @IBOutlet var bankBranchLabel: UILabel!
    @IBOutlet var bankNameLabel: UILabel!
    
    @IBOutlet var clientName: UILabel!
    @IBOutlet var clientID: UILabel!
    @IBOutlet var unitStatus: UILabel!
    @IBOutlet var unitNameLabel: UILabel!
    @IBOutlet var projectNameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleView: UIView!
    
    var isEditingReceiptEntry : Bool = false
    var isAddingFromBookingForm : Bool = false
    
    var paymentModesDataSource : [String] = []
    
    @IBOutlet var balanceAmountLabel: UILabel!
    @IBOutlet var amountReceivedLabel: UILabel!
    
    var paymentTowardsComponentsArray : [PaymentToWards] = []
    
    var currencies : [CURRENCY] = []
    var selectedCurrency : CURRENCY!
    
    var currenciesPopUp : PopOverViewController! = nil
    
    @IBOutlet var amountReceivedView: UIView!
    @IBOutlet var heightOfAmountReceivedView: NSLayoutConstraint!
    @IBOutlet var pendingAmountsView: UIView!
    @IBOutlet var heightOfPendingAmountsView: NSLayoutConstraint!
    @IBOutlet var outStandingAmoutLabel: UILabel!
    
    @IBOutlet var paidBalancesView: UIView!
    @IBOutlet var heightOfPaidBalancesView: NSLayoutConstraint!
    
    @IBOutlet var heightOfReceiptQuickView: NSLayoutConstraint!
    @IBOutlet var receiptQuickView: UIView!
     
    
    
    // MARK: - View LIfe cycle
    @objc func injectable(){
        self.hideAllPaymentModeFields()
    }
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(selectedReceiptEntry != nil && selectedReceiptEntry.id != nil){
            self.setUIForPayment(selectedPaymetnMode: selectedReceiptEntry.paymentMode!)
        }
        self.photosCollectionView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        paymentModesDataSource = ["Select Payment Mode","Cheque","NEFT","RTGS","IMPS","Cash"]
        
        currencies = RRUtilities.sharedInstance.defaultBookingFormSetUp!.currency! + RRUtilities.sharedInstance.customBookingFormSetUp!.currency!
    
        let selecteInfo = PaymentToWards(name: "Select Payment Towards", count: 0, amount: 0, _id: "none")
        let advancedReceipts = PaymentToWards(name: "Advance Receipts", count: 0, amount: 0, _id: "AR")
        
        paymentTowardsComponentsArray.append(selecteInfo)
        
        if(self.isEditingReceiptEntry)
        {
            if(self.selectedReceiptEntry.unitStatus == UNIT_STATUS.RESERVED.rawValue){
                paymentTowardsComponentsArray.append(advancedReceipts)
            }
            else if(self.selectedReceiptEntry.unitStatus == UNIT_STATUS.BOOKED.rawValue || self.selectedReceiptEntry.unitStatus == UNIT_STATUS.SOLD.rawValue){
                
                if(RRUtilities.sharedInstance.defaultBookingFormSetUp != nil){
                    paymentTowardsComponentsArray += RRUtilities.sharedInstance.defaultBookingFormSetUp!.paymentTowards!
                }
                if(RRUtilities.sharedInstance.customBookingFormSetUp != nil){
                    paymentTowardsComponentsArray += RRUtilities.sharedInstance.customBookingFormSetUp!.paymentTowards!
                }
            }
        }
        else{
            
            if(self.selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                    paymentTowardsComponentsArray.append(advancedReceipts)
            }
            else if(self.selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || self.selectedUnit.status == UNIT_STATUS.SOLD.rawValue){
                
//                if(RRUtilities.sharedInstance.defaultBookingFormSetUp != nil){
//                    paymentTowardsComponentsArray += RRUtilities.sharedInstance.defaultBookingFormSetUp!.paymentTowards!
//                }
//                if(RRUtilities.sharedInstance.customBookingFormSetUp != nil){
//                    paymentTowardsComponentsArray += RRUtilities.sharedInstance.customBookingFormSetUp!.paymentTowards!
//                }
            }
        }
        
        self.configureView()
        self.hideAllPaymentModeFields()
        self.setUpImgesToTextFields()
        self.getProjectBanks()
        
        if(self.isEditingReceiptEntry){
            if(selectedReceiptEntry.receiptType == RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue)
            {
                self.getTransactions()
            }
        }
        else{
            if(selectedUnit.status != UNIT_STATUS.RESERVED.rawValue)
            {
                self.getTransactions()
            }
        }
        
    }
    func showChequeDetailsView(){
        
        chequeDetailsView.isHidden = false
        heightOfChequeView.constant = 240
        
        bankBranchIFSCInfoView.isHidden = false
        heightOfBankBranchInfoView.constant = 180
        
        heightOfReferenceAndDateInfoView.constant = 0
        referenceNumberAndDateInfoView.isHidden = true
    }
    func showInternetTransferView(){
        
        self.hideAllPaymentModeFields()
        
        heightOfReferenceAndDateInfoView.constant = 160
        referenceNumberAndDateInfoView.isHidden = false
        
        heightOfReferenceNumberView.constant = 80
        referenceNumberView.isHidden = false

        heightOfBankBranchInfoView.constant = 180
        bankBranchIFSCInfoView.isHidden = false
        
    }
    func showCashView(){
        self.hideAllPaymentModeFields()
        
        heightOfReferenceNumberView.constant = 0
        referenceNumberView.isHidden = true
        
        heightOfReferenceAndDateInfoView.constant = 80
        referenceNumberAndDateInfoView.isHidden = false

    }
    func hideAllPaymentModeFields(){
        
        heightOfChequeView.constant = 0
        chequeDetailsView.isHidden = true
        heightOfBankBranchInfoView.constant = 0
        bankBranchIFSCInfoView.isHidden = true
        referenceNumberAndDateInfoView.isHidden = false
        
//        heightOfReferenceNumberView.constant = 0
//        referenceNumberView.isHidden = true

        heightOfReferenceAndDateInfoView.constant = 0
        referenceNumberAndDateInfoView.isHidden = true
        
    }
    func setUpImgesToTextFields(){
        
        let dropImage = UIImageView.init(image: UIImage.init(named: "drop"))
        dropImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        dropImage.contentMode = .center
        
        let dropImage1 = UIImageView.init(image: UIImage.init(named: "drop"))
        dropImage1.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        dropImage1.contentMode = .center

        paymentTowardsTextField.rightView = dropImage
        paymentTowardsTextField.rightViewMode = .always
        paymentModeTextField.rightView = dropImage1
        paymentModeTextField.rightViewMode = .always
        
        let calendarImage = UIImageView.init(image: UIImage.init(named: "calendar"))
        calendarImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        calendarImage.contentMode = .center
        
        let calendarImage1 = UIImageView.init(image: UIImage.init(named: "calendar"))
        calendarImage1.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        calendarImage1.contentMode = .center

        let calendarImage2 = UIImageView.init(image: UIImage.init(named: "calendar"))
        calendarImage2.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        calendarImage2.contentMode = .center
        
        chequeDateTextField.rightViewMode = .always
        chequeDateTextField.rightView = calendarImage
        depositeDateTextField.rightViewMode = .always
        depositeDateTextField.rightView = calendarImage1
        paymentDateTextField.rightViewMode = .always
        paymentDateTextField.rightView = calendarImage2
        
        let searchImage = UIImageView.init(image: UIImage.init(named: "search"))
        searchImage.isUserInteractionEnabled = true
        searchImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        searchImage.contentMode = .center
        ifscCodeTextField.rightViewMode = .always
        ifscCodeTextField.rightView = searchImage
        let guesture = UITapGestureRecognizer.init(target: self, action: #selector(searchIfscCode))
        searchImage.addGestureRecognizer(guesture)
        currencyInfoView.layer.cornerRadius = 8
        currencyInfoView.layer.borderColor = UIColor.lightGray.cgColor
        currencyInfoView.layer.borderWidth = 0.4
    }
    func configureView(){
        
//        print(selectedReceiptEntry.paymentTowards)
        
        viewReceiptButton.layer.cornerRadius = 4
        viewReceiptButton.layer.borderColor = UIColor.lightGray.cgColor
        viewReceiptButton.layer.borderWidth = 0.5
        
        recieptImageView.layer.masksToBounds = true
        recieptImageView.layer.cornerRadius = 8
        recieptImageView.layer.borderWidth = 1
        recieptImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)

        photosCollectionView.register(UINib(nibName: "ReceiptImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "receiptImage")
        
        let tempLayout = UICollectionViewFlowLayout.init()
        tempLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tempLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout.itemSize = CGSize(width: 93, height: 91)
        tempLayout.minimumInteritemSpacing = 10
        tempLayout.minimumLineSpacing = 10
        tempLayout.scrollDirection = .horizontal
        photosCollectionView.collectionViewLayout = tempLayout
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
            self.receiptEntryCreateButton.isHidden = true
            self.heightOfCreateButton.constant = 0
        }
        else{
            self.receiptEntryCreateButton.isHidden = false
            self.heightOfCreateButton.constant = 50
        }

        if(isEditingReceiptEntry){
            
            self.titleLabel.text = String(format: "Edit Receipt Entry  #%@",selectedReceiptEntry.receiptNumber!)
            self.hideAllPaymentModeFields()
            receiptEntryCreateButton.setTitle("UPDATE ENTRY", for: .normal)
            
            depositBankNameLabel.text = self.selectedReceiptEntry.projectBank ?? "Select Deposite Bank"
            
            paymentTowardsTextField.isEnabled = false
            paymentTowardsTextField.delegate = nil
            paymentTowardsTextField.textColor = UIColor.lightGray

            self.setUpViewWIthRecietpEntry()
            
            photosCollectionView.delegate = self
            photosCollectionView.dataSource = self
        }
        else{
            self.titleLabel.text = "Receipt Entry"
            
            projectNameLabel.text = selectedProject?.name!
            
            unitNameLabel.text = String(format: "%@ (%@)", selectedUnit.unitDisplayName ?? selectedReceiptEntry?.unitDisplayName ?? "",selectedUnit.description1 ?? selectedReceiptEntry?.unitDescription ?? "")
            
            if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue)
            {
                clientName.text = selectedClient.prospect?.userName ?? "-"
                clientID.text = "-"
            }
            else if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue){
                
                if(selectedBookedClint != nil){
                    clientName.text = selectedBookedClint.name ?? "-"
                    clientID.text = selectedBookedClint.customerId ?? "-"
                }
                else{
                    clientName.text = customer.name ?? "-"
                    clientID.text = customer.customerId ?? "-"
                }
            }
            else if(selectedUnit.status == UNIT_STATUS.SOLD.rawValue){
                
                if(selectedBookedClint != nil){
                    clientName.text = selectedBookedClint.name ?? "-"
                    clientID.text = selectedBookedClint.customerId ?? "-"
                }
                else{
                    clientName.text = customer.name ?? "-"
                    clientID.text = customer.customerId ?? "-"
                }
            }
            
            let statusDict = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: Int(selectedUnit!.status))
            unitStatus.text = statusDict["statusString"] as? String
            unitStatus.textColor = statusDict["color"] as? UIColor
            
            self.photosCollectionView.delegate = self
            self.photosCollectionView.dataSource = self
        }

        paymentModeTextField.delegate = self
        paymentTowardsTextField.delegate = self
        chequeDateTextField.delegate = self
        depositeDateTextField.delegate = self
        paymentDateTextField.delegate = self
        ifscCodeTextField.delegate = self
        currencyNameTextField.delegate = self
        amountTextField.delegate = self

        if(isEditingReceiptEntry){ //&& selectedReceiptEntry.receiptType == RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue
            
            if(selectedReceiptEntry.receiptType == RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue){
                
                heightOfReceiptQuickView.constant = 80
                receiptQuickView.isHidden = false
                heightOfPaidBalancesView.constant = 80
                
                amountReceivedView.isHidden  = true
                heightOfAmountReceivedView.constant = 0
                pendingAmountsView.isHidden = true
                heightOfPendingAmountsView.constant = 0
            }
            else{
                
            }
            
            paymentTowardsTextField.isEnabled = false
            paymentTowardsTextField.delegate = nil
            
//            pendingAmountsView.isHidden = true
//            heightOfPendingAmountsView.constant = 0
            
//            amountReceivedView.isHidden  = true
//            heightOfAmountReceivedView.constant = 0
//
//            heightOfPaidBalancesView.constant = 80
            
        }
        else{
            
            if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                paidBalancesView.isHidden = true
                heightOfPaidBalancesView.constant = 0
                heightOfReceiptQuickView.constant = 0
                receiptQuickView.isHidden = true
                amountReceivedView.isHidden  = true
                heightOfAmountReceivedView.constant = 0
                pendingAmountsView.isHidden = true
                heightOfPendingAmountsView.constant = 0
            }
            else{
                paidBalancesView.isHidden = false
                heightOfPaidBalancesView.constant = 60
                
                heightOfReceiptQuickView.constant = 0
                receiptQuickView.isHidden = true

                amountReceivedView.isHidden  = false
                heightOfAmountReceivedView.constant = 20
                pendingAmountsView.isHidden = false
                heightOfPendingAmountsView.constant = 20

            }
    
            paymentTowardsTextField.text = "Select Payment Towards"
            paymentModeTextField.text = "Select Payment Mode"
            foreignCurrencyTextField.text = "0.00"
            receiptEntryCreateButton.setTitle("CREATE ENTRY", for: .normal)
            depositBankNameLabel.text = "Select deposite bank"
        }
    }
    func shouldShowChequePhotos(shouldShow : Bool){
        
        if(shouldShow){
            self.chequePhotosView.isHidden = !shouldShow
            self.heightOfChequePhotosView.constant = 128
            self.photosCollectionView.isHidden = !shouldShow
        }
        else{
            self.chequePhotosView.isHidden = true
            self.heightOfChequePhotosView.constant = 0
            self.photosCollectionView.isHidden = true
        }
    }
    func setUpViewWIthRecietpEntry(){
//        print(selectedReceiptEntry)
//        print(selectedReceiptEntry.paymentTowards)
//        print(selectedReceiptEntry.paymentMode)
        let project = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: selectedReceiptEntry.project!)
        projectNameLabel.text = project?.name!
        
        unitNameLabel.text = String(format: "%@ (%@)", selectedReceiptEntry.unitDisplayName ?? "",selectedReceiptEntry.unitDescription ?? "")
        paymentDateTextField.text = RRUtilities.sharedInstance.getDateWithDateFormat(dateStr: selectedReceiptEntry.createdDate!, dateFormat: "LLLL,yyyy")
        
        amountTextField.text = String(format: "%.2f", selectedReceiptEntry.amount)
        selectedPaymentToWards = selectedReceiptEntry.paymentTowards
        self.paymentTowardsTextField.text = selectedReceiptEntry.paymentTowards
        foreignCurrencyTextField.text = String(format: "%.2f",selectedReceiptEntry.curAmount)
        currencyNameTextField.text = selectedReceiptEntry.currency
        
        clientName.text = selectedReceiptEntry.customerName ?? "-"
        clientID.text = selectedReceiptEntry.customer_customerID ?? "-"
        
        let statusDict = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: Int(selectedReceiptEntry.unitStatus))
        unitStatus.text = statusDict["statusString"] as? String
        unitStatus.textColor = statusDict["color"] as? UIColor
        
        self.paymentModeTextField.text = selectedReceiptEntry.paymentMode
        
        self.selectedPaymentMode = selectedReceiptEntry.paymentMode
        self.selectedPaymentToWards = self.selectedReceiptEntry.paymentTowards

        
        if(selectedReceiptEntry.paymentMode == "NEFT" || selectedReceiptEntry.paymentMode == "RTGS" || selectedReceiptEntry.paymentMode == "IMPS"){
            
            paymentDateTextField.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedReceiptEntry.depositDate!, dateFormat: "dd-MMM-yyyy")
            self.selectedPaymentDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: selectedReceiptEntry.depositDate!)
            referenceNumberTextField.text = selectedReceiptEntry.referenceNumber
            bankNameLabel.text = selectedReceiptEntry.chequeBank?.bankName
            bankBranchLabel.text = selectedReceiptEntry.chequeBank?.bankBranch
            ifscCodeTextField.text = selectedReceiptEntry.chequeBank?.bankIfscCode
            currencyNameTextField.text = selectedReceiptEntry.currency
            
            self.searchIfscCode()

//            var chequeBank : Dictionary<String,String> = [:]
//            chequeBank["bankIfscCode"] = ifscCodeTextField.text?.uppercased()
//            parameters["chequeBank"] = chequeBank
//            parameters["referenceNumber"] = referenceNumberTextField.text
//            parameters["depositeDate"] = Formatter.ISO8601.string(from: selectedPaymentDate)
        }
        else if(selectedReceiptEntry.paymentMode == "Cash"){
//            parameters["depositeDate"] = Formatter.ISO8601.string(from: selectedPaymentDate)
            paymentDateTextField.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedReceiptEntry.depositDate!, dateFormat: "dd-MMM-yyyy")
            self.selectedPaymentDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: selectedReceiptEntry.depositDate!)
        }
        else if(selectedReceiptEntry.paymentMode == "Cheque"){
            
            chequeDateTextField.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedReceiptEntry.chequeDate!, dateFormat: "dd-MM-yyyy")
//            self.selectedChequeDate =
            chequeNumberTextField.text = selectedReceiptEntry.referenceNumber
            
            chequeDateTextField.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedReceiptEntry.chequeDate!, dateFormat: "dd-MMM-yyyy")
            self.selectedChequeDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: selectedReceiptEntry.chequeDate!)
            self.selectedDepositeDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: selectedReceiptEntry.depositDate!)
            depositeDateTextField.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedReceiptEntry.depositDate!, dateFormat: "dd-MMM-yyyy")
            
            ifscCodeTextField.text = selectedReceiptEntry.chequeBank?.bankIfscCode
            self.searchIfscCode()
            bankNameLabel.text = selectedReceiptEntry.chequeBank?.bankName
            bankBranchLabel.text = selectedReceiptEntry.chequeBank?.bankBranch
    
            depositBankNameLabel.text = selectedReceiptEntry.projectBank ?? "Select Deposite Bank"
            
            
//            depositeBankTextField.text = String(format: "%ld", selectedProjectBank.accountNumber!) + "-" + selectedProjectBank.bankBranch!
            
//            var chequeBank : Dictionary<String,String> = [:]
//            chequeBank["bankAddress"] = selectedProjectBank.bankAddress
//            chequeBank["bankBrach"] = selectedProjectBank.bankBranch
//            chequeBank["bankIfscCode"] = ifscCodeTextField.text
//            chequeBank["bankName"] = selectedProjectBank.bankName
//
//            parameters["chequeBank"] = chequeBank
//            parameters["referenceNumber"] = referenceNumberTextField.text
//            parameters["chequeDate"] = Formatter.ISO8601.string(from: selectedChequeDate)
//            parameters["depositeDate"] = Formatter.ISO8601.string(from: selectedDepositeDate)
        }
        
        if(self.isEditingReceiptEntry){
            if(selectedReceiptEntry.allocationStatus == ALLOCATION_STATUS.NOT_ALLOCATED.rawValue){
                amountTextField.isEnabled = true
            }else{
                amountTextField.isEnabled = false
            }
        }

    }
    @objc func searchIfscCode(){
        if(ifscCodeTextField.text?.count == 0 || ifscCodeTextField.text!.count < 11){
            HUD.flash(.label("Enter Valid IFSC Code"), delay: 1.0)
            return
        }
        ServerAPIs.searchForIfscCode(ifscCode: ifscCodeTextField.text!, completionHandler: { responseObject , error in
            if(responseObject != nil){
                self.ifscCode = responseObject
                self.bankBranchLabel.text = self.ifscCode.branch
                self.bankNameLabel.text = self.ifscCode.bank
            }
            else{
                HUD.flash(.label("Couldn't find IFSC Code\nEnter valid IFSC code"), delay: 1.5)
            }
        })
    }
    func uploadRecieptEntryImages(){
//        uploadedImageUrls
        
        let tempImages = self.receiptEntryImages
        
        HUD.show(.progress, onView: self.view)
        for eachImagePath in tempImages{
            
            
            let imageDetails = AWS_INPUTS(imageName: URL.init(string: eachImagePath)?.lastPathComponent, imageURL: URL.init(string: eachImagePath), type: AWS_TYPE.receiptEntry)

            self.receiptEntryGroup.enter()
            RRUtilities.sharedInstance.uploadImge(imageDetails: imageDetails, completionHandler: { (responeStr , error) in
                if(responeStr != nil){
                    
                    self.uploadedImageUrls.append(responeStr!)
                    
                    if(self.fileManager.fileExists(atPath: URL.init(string: eachImagePath)!.relativePath)){
                        try! self.fileManager.removeItem(at: URL.init(string: eachImagePath)!)
                        self.receiptEntryImages.remove(at: self.receiptEntryImages.index(of: eachImagePath)!)
                    }
                }
                else{
                    print("Failed??")
                }
                self.receiptEntryGroup.leave()
            })
        }
        
        self.receiptEntryGroup.notify(queue: DispatchQueue.main, execute: {
            print("Finished all requests.")
            HUD.hide()
            self.createOrUpdateReceiptEntry(UIButton())
        })
    }
    @IBAction func createOrUpdateReceiptEntry(_ sender: Any) {
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }

        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
            HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
            return
        }
        
        if(selectedPaymentToWards == nil){
            HUD.flash(.label("Please select payment towards"), delay: 1.0)
            return
        }
        
        if(selectedPaymentMode == nil){
            HUD.flash(.label("Please select payment mode"), delay: 1.0)
            return
        }

        if(self.selectedPaymentMode == "Cash"){
            if(selectedPaymentDate == nil){
                HUD.flash(.label("Please select payment date"), delay: 1.0)
                return
            }
        }

        if(self.selectedPaymentMode == "NEFT" || self.selectedPaymentMode == "RTGS" || self.selectedPaymentMode == "IMPS"){
            
            if(referenceNumberTextField.text?.count == 0){
                HUD.flash(.label("Enter Reference numebr"), delay: 1.0)
                return
            }
            if(selectedPaymentDate == nil){
                HUD.flash(.label("Please select payment date"), delay: 1.0)
                return
            }
        }

        if(self.selectedPaymentMode == "Cheque"){
            
            if(self.chequeNumberTextField.text?.count == 0){
                HUD.flash(.label("Enter cheque numebr"), delay: 1.0)
                return
            }
            if(selectedChequeDate == nil){
                HUD.flash(.label("Please select cheque date"), delay: 1.0)
                return
            }
            if(selectedDepositeDate == nil){
                HUD.flash(.label("Please select deposite date"), delay: 1.0)
                return
            }
        }
        
        if(self.selectedPaymentMode != "Cash" && self.ifscCode == nil){
            HUD.flash(.label("Please enter valid IFSC Code"), delay: 1.0)
            return
        }
        
        if(amountTextField.text!.isEmpty){
            HUD.flash(.label("Enter Amount"), delay: 1.0)
            return
        }
        
        if(selectedProjectBank == nil){
            HUD.flash(.label("Select Deposit Bank"), delay: 1.0)
            return
        }
        
        if(self.receiptEntryImages.count > 0){
            self.uploadRecieptEntryImages()
            return
        }

        var urlString = String.init()
        
        if(isEditingReceiptEntry){
            urlString = RRAPI.API_EDIT_RECEIPT_ENTRY
        }
        else{
            urlString = RRAPI.API_ADD_RECEIPT_ENTRY
        }
    
        var parameters : Dictionary<String,Any> = [:]
        
        if(isEditingReceiptEntry == false){
            
//            parameters["project"] = selectedReceiptEntry.project
//            parameters["block"] = selectedReceiptEntry.block
//            parameters["tower"] = selectedReceiptEntry.tower
//            parameters["unit"] = selectedReceiptEntry.unitId
//            parameters["customer"] = selectedReceiptEntry.customerId
            
            parameters["unitNo"] = String(format: "%d", selectedUnit.unitIndex)
            parameters["unitDescription"] = selectedUnit.description1
            parameters["projectName"] = selectedUnit.project

            parameters["images"] = self.uploadedImageUrls
            
            parameters["project"] = selectedProject.id
            parameters["block"] = selectedUnit.block
            parameters["tower"] = selectedUnit.tower
            parameters["unit"] = selectedUnit.id
            
            if(selectedUnit != nil && selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                parameters["customer"] = selectedClient._id
            }
            else if(isAddingFromBookingForm){
                parameters["customer"] = customer.clientId ?? customer.customerId ?? ""
            }
            else{
                parameters["customer"] = selectedBookedClint._id ?? selectedBookedClint.customerId ?? ""
            }
            
            if(self.depositBankNameLabel.text != "Select deposite bank"){
                parameters["projectBank"] = self.selectedProjectBank._id
            }
            
            parameters["paymentMode"] = paymentModeTextField.text
                        
//            parameters["depositDate"] = Formatter.ISO8601.string(from: selectedPaymentDate)

            if(selectedReceiptEntry == nil && selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                parameters["paymentTowards"] = selectedPaymentToWards //"Advance Receipts"
                parameters["receiptType"] = RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue
                parameters["allocationStatus"] = ALLOCATION_STATUS.NOT_ALLOCATED.rawValue
                let temp = amountTextField.text

                parameters["allocationBalance"] = Double(temp!)
//                parameters["curAmount"] = ""
            }
            else{
                
                parameters["paymentTowards"] = selectedPaymentToWards
                parameters["receiptType"] = RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue
                
                if(selectedPaymentToWards == "Advance Receipts" || selectedPaymentToWards == "On Booking"){
                    parameters["allocationStatus"] = ALLOCATION_STATUS.NOT_ALLOCATED.rawValue
                    let temp = amountTextField.text
                    parameters["allocationBalance"] =  Double(temp!)
                }
                else if(selectedPaymentToWards == "Against Demand Note"){
                    parameters["allocationStatus"] = ALLOCATION_STATUS.ALLOCATED.rawValue
                    parameters["allocationBalance"] = 0.00
                }
                else{
                    parameters["allocationStatus"] = ALLOCATION_STATUS.ALLOCATED.rawValue
                    parameters["allocationBalance"] = 0.00
                }
            }            
            
            if(selectedPaymentMode == "NEFT" || selectedPaymentMode == "RTGS" || selectedPaymentMode == "IMPS"){
                
                var chequeBank : Dictionary<String,String> = [:]
                chequeBank["bankIfscCode"] = ifscCodeTextField.text?.uppercased()
                parameters["chequeBank"] = chequeBank
                parameters["referenceNumber"] = referenceNumberTextField.text
                parameters["depositDate"] = Formatter.ISO8601.string(from: selectedPaymentDate)
                
                if(referenceNumberTextField.text?.count == 0){
                    HUD.flash(.label("Enter Reference numebr"), delay: 1.0)
                    return
                }

                parameters["referenceNumber"] = referenceNumberTextField.text

            }
            else if(selectedPaymentMode == "Cash"){
                parameters["depositDate"] = Formatter.ISO8601.string(from: selectedPaymentDate)
            }
            else if(selectedPaymentMode == "Cheque"){
                
                var chequeBank : Dictionary<String,String> = [:]
                chequeBank["bankAddress"] = selectedProjectBank.bankAddress
                chequeBank["bankBrach"] = selectedProjectBank.bankBranch
                chequeBank["bankIfscCode"] = self.ifscCode.ifsc
                chequeBank["bankName"] = selectedProjectBank.bankName
                
                parameters["chequeBank"] = chequeBank
//                if(referenceNumberTextField.text?.count == 0){
//                    HUD.flash(.label("Enter Reference numebr"), delay: 1.0)
//                    return
//                }
                parameters["referenceNumber"] = chequeNumberTextField.text
                parameters["chequeDate"] = Formatter.ISO8601.string(from: selectedChequeDate)
                parameters["depositDate"] = Formatter.ISO8601.string(from: selectedDepositeDate)
            }

            if(currencyNameTextField.text!.count > 0){
                parameters["currency"] = currencyNameTextField.text
                parameters["curAmount"] = foreignCurrencyTextField.text
                
                parameters["createdDate"] = Formatter.ISO8601.string(from: Date())
            }

            let temp = amountTextField.text
            parameters["amount"] = Double(temp!)
            
            parameters["paymentTowards"] = paymentTowardsTextField.text
            
            parameters["projectName"] = selectedProject.name
            parameters["unitNo"] = selectedUnit.description1
            
//            print(parameters)

        }
        else{
            
            var entryImagesArray = self.selectedReceiptEntry.images
            entryImagesArray?.append(contentsOf: self.uploadedImageUrls)

            parameters["images"] = entryImagesArray

            parameters["_id"] = selectedReceiptEntry.id
            
            parameters["block"] = selectedReceiptEntry.block
            parameters["unit"] = selectedReceiptEntry.unitId
            parameters["project"] = selectedReceiptEntry.project
            parameters["tower"] = selectedReceiptEntry.tower
            
            parameters["company_group"] = selectedReceiptEntry.company_group
//            selectedReceiptEntry.allocationBalance
            
            parameters["customerId"] = selectedReceiptEntry.customer_customerID
            
            parameters["customer"] = selectedReceiptEntry.customerId

            if(self.depositBankNameLabel.text != "Select deposite bank"){
                parameters["projectBank"] = selectedProjectBank._id
            }
            
            parameters["paymentMode"] = paymentModeTextField.text
            
            if(selectedPaymentDate != nil){
                parameters["depositDate"] = Formatter.ISO8601.string(from: selectedPaymentDate)
            }
            else{
                parameters["depositDate"] = selectedReceiptEntry.depositDate
            }
            
            if(selectedReceiptEntry == nil && selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                parameters["paymentTowards"] = selectedPaymentToWards //"Advance Receipts"
                parameters["receiptType"] = RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue
                parameters["allocationStatus"] = ALLOCATION_STATUS.NOT_ALLOCATED.rawValue
                let temp = amountTextField.text
                
                parameters["allocationBalance"] = Double(temp!)
            }
            else{
                
                parameters["paymentTowards"] = selectedPaymentToWards ?? selectedReceiptEntry.paymentTowards
                if(selectedReceiptEntry.unitStatus == UNIT_STATUS.RESERVED.rawValue){
                    parameters["receiptType"] = RECEIPT_ENTRY_TYPE.RESERVED_RECEIPT.rawValue
                }
                else{
                    parameters["receiptType"] = RECEIPT_ENTRY_TYPE.BOOKED_SOLD_RECEIPT.rawValue
                }
                
                if(selectedPaymentToWards == "Advance Receipts" || selectedPaymentToWards == "On Booking"){
                    parameters["allocationStatus"] = ALLOCATION_STATUS.NOT_ALLOCATED.rawValue
                    let temp = amountTextField.text
                    parameters["allocationBalance"] = Double(temp!)
                }
                else if(selectedPaymentToWards == "Against Demand Note"){
                    parameters["allocationStatus"] = ALLOCATION_STATUS.NOT_ALLOCATED.rawValue
                    parameters["allocationBalance"] = selectedReceiptEntry.amount
                }
                else{
                    parameters["allocationStatus"] = ALLOCATION_STATUS.ALLOCATED.rawValue
                    let temp = amountTextField.text
                    parameters["allocationBalance"] = Double(temp!)
                }
            }
            
            if(selectedPaymentMode == "NEFT" || selectedPaymentMode == "RTGS" || selectedPaymentMode == "IMPS"){
                
                var chequeBank : Dictionary<String,String> = [:]
                chequeBank["bankIfscCode"] = ifscCodeTextField.text?.uppercased()
                parameters["chequeBank"] = chequeBank
                parameters["referenceNumber"] = referenceNumberTextField.text
                parameters["depositDate"] = Formatter.ISO8601.string(from: selectedPaymentDate)
                
                if(referenceNumberTextField.text?.count == 0){
                    HUD.flash(.label("Enter Reference numebr"), delay: 1.0)
                    return
                }
                
                parameters["referenceNumber"] = referenceNumberTextField.text
                
            }
            else if(selectedPaymentMode == "Cash"){
                parameters["depositDate"] = Formatter.ISO8601.string(from: selectedPaymentDate)
            }
            else if(selectedPaymentMode == "Cheque"){
                
                var chequeBank : Dictionary<String,String> = [:]
                chequeBank["bankAddress"] = selectedProjectBank.bankAddress
                chequeBank["bankBrach"] = selectedProjectBank.bankBranch
                chequeBank["bankIfscCode"] = ifscCodeTextField.text
                chequeBank["bankName"] = selectedProjectBank.bankName
                
                parameters["chequeBank"] = chequeBank
//                if(referenceNumberTextField.text?.count == 0){
//                    HUD.flash(.label("Enter Reference numebr"), delay: 1.0)
//                    return
//                }
                parameters["referenceNumber"] = chequeNumberTextField.text
                parameters["chequeDate"] = Formatter.ISO8601.string(from: selectedChequeDate)
                parameters["depositDate"] = Formatter.ISO8601.string(from: selectedDepositeDate)
            }
            
            if(currencyNameTextField.text!.count > 0){
                parameters["currency"] = currencyNameTextField.text
                parameters["curAmount"] = foreignCurrencyTextField.text
                
                parameters["createdDate"] = selectedReceiptEntry.createdDate

            }
            
            let temp = amountTextField.text
            parameters["amount"] = Double(temp!)
            
            parameters["paymentTowards"] = paymentTowardsTextField.text

        }
        
        parameters["src"] = 3
        
//        print(parameters)
        HUD.show(.progress, onView: self.view)
        ServerAPIs.editOrCreateReceiptEntry(urlString: urlString, parameters: parameters, isEditing: self.isEditingReceiptEntry, completionHandler: { (responseObject, error) in
            HUD.hide()
            if(responseObject?.status == 1){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_RECEIPT_ENTRIES), object: nil)
                if(self.isEditingReceiptEntry){
                    HUD.flash(.label("Updated Succesfully."), delay: 2.0)
                    self.perform(#selector(self.popController), with: nil, afterDelay: 2.0)
                }
                else{
//                    HUD.flash(.label("Added Succesfully."), delay: 2.0)
                    HUD.flash(.label("Added Succesfully."), onView:self.view, delay: 2.0, completion: nil)
                    self.perform(#selector(self.popController), with: nil, afterDelay: 2.0)
                }
            }
            else if(responseObject?.status == -1){
                HUD.flash(.label(responseObject?.msg ?? responseObject?.err ?? "Failed to add entry. Try Again."), delay: 2.0)
            }
            else{
                HUD.flash(.label(responseObject?.msg ?? "Failed to add entry. Try Again."), delay: 2.0)
            }
        })
        
        
//        parameters["chequeBank"] = selectedReceiptEntry.chequeBank.
        
        /*
 
         var _id = StringConstants.STRING_DEFAULT_VALUE
         var project = StringConstants.STRING_DEFAULT_VALUE
         var block = StringConstants.STRING_DEFAULT_VALUE
         var tower = StringConstants.STRING_DEFAULT_VALUE
         var unit: Unit? = Unit()
         var customer: Client.RegInfo? = Client.RegInfo()
         var unitId = StringConstants.STRING_DEFAULT_VALUE
         var customerId = StringConstants.STRING_DEFAULT_VALUE
         var receiptType = RESERVED_RECEIPT
         var paymentMode = StringConstants.STRING_DEFAULT_VALUE
         var paymentTowards = StringConstants.STRING_DEFAULT_VALUE
         var depositDate = StringConstants.STRING_DEFAULT_VALUE
         var receiptNumber = StringConstants.STRING_DEFAULT_VALUE
         var referenceNumber = StringConstants.STRING_DEFAULT_VALUE
         var chequeDate = StringConstants.STRING_DEFAULT_VALUE
         var amount = 0.00
         var currency = StringConstants.STRING_DEFAULT_VALUE
         var curAmount: String? = StringConstants.STRING_DEFAULT_VALUE
         var projectBank: String? = StringConstants.STRING_DEFAULT_VALUE
         var createdDate = StringConstants.STRING_DEFAULT_VALUE
         var status = STATUS_CREATED
         var allocationStatus = ALLOCATED
         var allocationBalance = 0.00
         var chequeBank: ReceiptBank?  = ReceiptBank()
         */
        
        
//        self.convertRecieptEntryToDict
    }
    @objc func popController(){
        
        if(self.isEditingReceiptEntry){
            self.dismiss(animated: true, completion: nil)
        }
        else if(self.isAddingFromBookingForm)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    func convertRecieptEntryToDict(){
        var dict: [String: Any] = [:]
        for attribute in selectedReceiptEntry.entity.attributesByName {
            //check if value is present, then add key to dictionary so as to avoid the nil value crash
            if let value = selectedReceiptEntry.value(forKey: attribute.key) {
                dict[attribute.key] = value
            }
        }
        print(dict)
    }
    @IBAction func showReceipt(_ sender: Any) {
        
        //Lauch web
        if(isEditingReceiptEntry){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let receiptPreview = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
            receiptPreview.isRecieptView = true
            receiptPreview.receiptEntryUrlString = String(format: RRAPI.API_VIEW_RECEIPT, selectedReceiptEntry.id!)
            receiptPreview.customerPhone = selectedReceiptEntry.customerPhone
            receiptPreview.phoneCode = selectedReceiptEntry.phoneCode
            let navController = UINavigationController(rootViewController: receiptPreview)
            navController.navigationBar.isHidden = true
            self.present(navController, animated: true, completion: nil)
        }
       
    }
    @IBAction func back(_ sender: Any) {
        self.clearImages()
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    func clearImages(){
        for eachImagePath in self.receiptEntryImages{
            try! fileManager.removeItem(at: URL.init(string: eachImagePath)!)
        }
    }
    func showCurrenciesPopUp(searchString : String){
        
        let fileredArray = currencies.filter{ ($0.currencyName!.localizedCaseInsensitiveContains(searchString)) }

        if(fileredArray.count == 0){
            //dismiss
            print("Not found")
            self.hidePopUp()
            return
        }
        
        if(currenciesPopUp == nil){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            currenciesPopUp = (storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController)
            currenciesPopUp.dataSourceType = .CURRENCIES
        }
        
        currenciesPopUp.preferredContentSize = CGSize(width: 250, height: fileredArray.count * 44)
        
        if(CGFloat((self.currencies.count * 44)) > (self.view.frame.size.height - 150)){
            
            currenciesPopUp.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        else{
            let widht : Float = Float(self.view.frame.size.width - 70.0)
            if(currencies.count != 1){
                currenciesPopUp.preferredContentSize = CGSize(width: Int(widht) , height: (fileredArray.count - 1) * 44)
            }
            else{
                currenciesPopUp.preferredContentSize = CGSize(width: Int(widht) , height: fileredArray.count * 44)
            }
        }
        
        currenciesPopUp.currenciesDataSource = fileredArray
        if(currenciesPopUp.mTableView != nil){
            currenciesPopUp.mTableView.reloadData()
        }
        
        let navigationContoller = UINavigationController(rootViewController: currenciesPopUp)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        popOver?.sourceView = self.currencyInfoLabel
        
        currenciesPopUp.delegate = self
        popOver?.sourceRect = currencyInfoLabel.frame
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    @IBAction func showProjectBanksPopUp(_ sender: Any) {
        
        if(self.projectBanks == nil || self.projectBanks.count == 0){
            HUD.flash(.label("Project doesn't have any Banks"), delay: 1.0)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .BANK_ACCOUNTS
        vc.preferredContentSize = CGSize(width: 250, height: (self.projectBanks.count - 1) * 44)
        
        if(CGFloat((self.projectBanks.count * 44)) > (self.view.frame.size.height - 150)){

            vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        else{
            let widht : Float = Float(self.view.frame.size.width - 70.0)
            if(projectBanks.count != 1){
                vc.preferredContentSize = CGSize(width: Int(widht) , height: (projectBanks.count - 1) * 44)
            }
            else{
                if(projectBanks.count == 1){
                    vc.preferredContentSize = CGSize(width: Int(widht) , height: 1)
                }
                else{
                    vc.preferredContentSize = CGSize(width: Int(widht) , height: (projectBanks.count - 1) * 44)
                }
            }
        }
        
        vc.bankAccountsDataSource = self.projectBanks
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        popOver?.sourceView = self.depositBankNameLabel
        
        vc.delegate = self
        popOver?.sourceRect = depositBankNameLabel.frame
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    func showPaymentToWardsPopUp(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .PAYMENT_TOWARDS
        vc.isReceiptEntry = true
        vc.preferredContentSize = CGSize(width: 250, height: self.paymentTowardsComponentsArray.count * 44)
        
        if(CGFloat((self.paymentTowardsComponentsArray.count * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        else{
            let widht : Float = Float(self.view.frame.size.width - 70.0)
            vc.preferredContentSize = CGSize(width: Int(widht) , height: (paymentTowardsComponentsArray.count - 1) * 44)
        }
        
        vc.paymentTowardsDataSource = self.paymentTowardsComponentsArray
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        popOver?.sourceView = self.paymentTowardsTextField
        
        vc.delegate = self
        popOver?.sourceRect = paymentTowardsTextField.frame
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    @objc func showPaymentModePopUp(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .COMMON
        
        vc.preferredContentSize = CGSize(width: 150, height: (paymentModesDataSource.count-1) * 44 + 8)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0) //UIPopoverArrowDirection.any
        vc.commonDataSource = paymentModesDataSource

        popOver?.sourceView = paymentModeTextField
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    func didSelectDate(optionType : Date,optionIndex: Int){
        
        if(optionIndex != -1){
            
            let serverFormatString = Formatter.ISO8601.string(from: optionType)
            let dateStr = RRUtilities.sharedInstance.getDateWithDateFormat(dateStr: serverFormatString, dateFormat: "LLLL,yyyy")
            
            if(optionIndex == 1){ // cheque date
                chequeDateTextField.text = dateStr
                selectedChequeDate = optionType
            }
            else if(optionIndex == 2){ // deposite date
                depositeDateTextField.text = dateStr
                selectedDepositeDate = optionType
            }
            else if(optionIndex == 3){ // payment datee
                paymentDateTextField.text = dateStr
                selectedPaymentDate = optionType
            }
        }

        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    
    func showDatePicker(textField : UITextField){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "datePicker") as! DatePickerViewController
        vc.shouldSetDateLimit = false
        vc.preferredContentSize = CGSize(width: 250, height: 195)
        vc.selectedFieldTag = textField.tag
        vc.delegate = self
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        popOver?.sourceView = textField
        vc.delegate = self
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    func setUIForPayment(selectedPaymetnMode : String){
        if(selectedPaymetnMode == "Select Payment Mode"){
            self.hideAllPaymentModeFields()
        }
        else if(selectedPaymetnMode == "Cheque"){ //cheque
            
            self.showChequeDetailsView()
        }
        else if(selectedPaymetnMode == "Cash"){
            self.showCashView()
        }
        else if(selectedPaymetnMode == "NEFT" || selectedPaymetnMode == "RTGS" || selectedPaymetnMode == "IMPS"){
            self.showInternetTransferView()
        }
    }
    // MARK: - TEXTFEILD DELEGATE  ***
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if((selectedReceiptEntry != nil && selectedReceiptEntry.unitStatus == UNIT_STATUS.RESERVED.rawValue) && textField == paymentTowardsTextField){
            return false
        }
        if(textField == paymentModeTextField){
            self.showPaymentModePopUp()
            return false
        }
        else if(textField == paymentDateTextField || textField == chequeDateTextField || textField == depositeDateTextField)
        {
            self.showDatePicker(textField: textField)
            return false
        }
        else if(textField == paymentTowardsTextField){
            self.showPaymentToWardsPopUp()
            return false
        }
        else if(textField == currencyNameTextField){
//            self.showCurrenciesPopUp()
            return true
        }
       
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(ifscCodeTextField == textField){
            if(textField.text!.count == 11 || string == ""){
                self.searchIfscCode()
            }
            return textField.text!.count < 11 || string == ""
        }
        if(textField == amountTextField){
            
            let textString = textField.text! + string
            let doubleValue = Double(textString)
            
            if(doubleValue != nil && selectedPaymentToWards == "Against Demand Note"){
                if(doubleValue! > selectedPaymentTowardsDict.amount!){
                    self.prevSelectedPaymentTowards = self.selectedPaymentTowardsDict
                    self.selectedPaymentToWards = "Advance Receipts"
                    self.paymentTowardsTextField.text = self.selectedPaymentToWards
                    let filteredArray = self.paymentTowardsComponentsArray.filter({ $0.name == "Advance Receipts"})
                    self.selectedPaymentTowardsDict = filteredArray[0]
                }
            }
            else{
                if(self.prevSelectedPaymentTowards != nil){
                    self.selectedPaymentTowardsDict = self.prevSelectedPaymentTowards
                    self.selectedPaymentToWards = self.prevSelectedPaymentTowards.name
                    self.paymentTowardsTextField.text = self.selectedPaymentToWards
                    self.prevSelectedPaymentTowards = nil
                }
            }
            
            if(doubleValue != nil && self.selectedCurrencyConverter != nil){
                self.foreignCurrencyTextField.text = String(format: "%.2f", (doubleValue! * self.selectedCurrencyConverter))
            }
            else{
                self.foreignCurrencyTextField.text = "0.0"
            }
        }
        if(textField == currencyNameTextField){
            // parse **
            //            let textString = textField.text! + string
            //            let tempCurrences = currencies.filter{ ($0.currencyName!.localizedCaseInsensitiveContains(textString)) }
            //            print(tempCurrences)
            //            currenciesPopUp.currenciesDataSource = tempCurrences
            //            currenciesPopUp.mTableView.reloadData() // calcualte frame and update **
            
            var isDelete = false
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    isDelete = true
                }
            }
            if(isDelete){
                print(textField.text!)
                let tempStr = textField.text!.dropLast()
                self.showCurrenciesPopUp(searchString: String(tempStr))
            }
            else{
                self.showCurrenciesPopUp(searchString: textField.text! + string)
            }
            if(currenciesPopUp != nil && currenciesPopUp.mTableView != nil){
                currenciesPopUp.mTableView.reloadData()
            }
        }
        return true
    }
    
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    // MARK: - URL CALLS
    func getProjectBanks(){
      
        var projectID = ""
        if(selectedReceiptEntry != nil && selectedReceiptEntry.id != nil){
            projectID = selectedReceiptEntry.project!
        }
        else{
            if(selectedProject != nil){
                projectID =  selectedProject.id!
            }
            else{
                projectID =  selectedUnit.project!
            }
        }
        ServerAPIs.getProjectBank(projectID: projectID, completionHandler: { responseObject , error in
            if(responseObject?.status == 1){
                if((responseObject?.bankaccounts!.count)! > 0){
                    self.projectBanks = responseObject?.bankaccounts
                    let projectBank = self.projectBanks[0]
                    if(self.isEditingReceiptEntry){
                        for tempBank in self.projectBanks{
                            if(tempBank._id == self.selectedReceiptEntry.projectBank){
                                self.depositBankNameLabel.text = String(format: "%ld", tempBank.accountNumber!) + "-" + tempBank.bankName! + "\n" + String(format: "(%@)", tempBank.bankBranch!)
                                self.selectedProjectBank = tempBank
                            }
                        }
                    }
                    else{
                        if(self.selectedReceiptEntry != nil){
                            self.depositBankNameLabel.text = projectBank.bankName! + "\n" + projectBank.bankBranch!
                            self.selectedProjectBank = projectBank
                        }
                    }
                }
            }
            else{
                self.projectBanks = responseObject!.bankaccounts
            }
        })
    }
    func searchOFIfscCode(){
        
        ServerAPIs.searchForIfscCode(ifscCode: ifscCodeTextField.text!, completionHandler: { responseObject , error in
            if(responseObject?.bank != nil){
                self.ifscCode = responseObject
            }
            else{
                self.ifscCode = nil
                HUD.flash(.label("Wrong IFSC code! \nPlese enter correct IFSC Code"), delay: 1.0)
            }
        })
    }
    func getTransactions(){
//        if(selectedReceiptEntry != nil && selectedReceiptEntry.id == nil){
//            return
//        }
        var unitID  = ""
        if(selectedUnit != nil){
            unitID = self.selectedUnit.id!
        }
        else if(selectedReceiptEntry != nil){
            unitID = self.selectedReceiptEntry.unitId ?? ""
        }
        ServerAPIs.getUnitTransactions(unitID:unitID ,completionHandler: { responseObject ,error in
            
            if(responseObject?.status == 1){
//                print(responseObject)
                self.setUpPaymentModeTowardsAndOutStadingAmout(unitTransactions: responseObject!)
            }
            else
            {
//                print(responseObject)
            }
        })
    }
    func setUpPaymentModeTowardsAndOutStadingAmout(unitTransactions: UNIT_TRANSACTIONS_OUTPUT){
        
//        var paymentToWards : Dictionary<String,Any> = [:]
        
        var outStanding = 0.0
        var paymentTowardsArray : Array<PaymentToWards> = []
        
//        paymentTowardsArray.append(PaymentToWards(name: "Select Payment Mode", count: 0, amount: 0,_id: nil))
        paymentTowardsArray.append(PaymentToWards(name: "Advance Receipts", count: 0, amount: 0,_id: nil))
        //["Select Payment Mode","Advanced Receipts"]
    
        
        let transactions = unitTransactions.transactions
        if(transactions?.totalCredits != nil && !(transactions?.totalCredits!.isEmpty)!){
            let totalAmount = transactions!.totalCredits![0].totalAmount
            outStandingAmoutLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,totalAmount!)
//            outStanding = totalAmount!
        }
        if(transactions?.firstInstallment != nil && (transactions?.firstInstallment?.balanceAmount)! > Double(0.0)){
//            paymentTowards.add(PaymentTowards(mActivity.resources.getString(R.string.on_booking), 0, it.firstInstallment.balanceAmount))
                    let firstInstallment = transactions?.firstInstallment!

            paymentTowardsArray.append(PaymentToWards(name: "On Booking", count: 0, amount: firstInstallment?.balanceAmount,_id: nil))
            outStanding += transactions?.firstInstallment?.balanceAmount ?? 0.0
        }
        
        
        var demandNoteAmt = 0.00
        var demandNoteCount = 0
        var debitNoteAmt = 0.00
        var debitNoteCount = 0
        var debitNoteList : Array<PaymentToWards> =  []
        
        let debitDetails  = transactions?.debitDeatils
        
        if(debitDetails != nil && debitDetails!.count > 0){
            for tempDebitDetails in debitDetails!{
                
                let installments = tempDebitDetails.installments
                
                for tempInstallment in installments!{
                    if(tempInstallment.id != nil){
                        demandNoteAmt += tempInstallment.id!.balanceAmount!
                        demandNoteAmt += tempInstallment.id!.balanceTaxAmount!
                        
                        outStanding += tempInstallment.id!.balanceAmount!
                        outStanding += tempInstallment.id!.balanceTaxAmount!
                        demandNoteCount += 1
                    }
                }
                
                let debitNotes = tempDebitDetails.debitNotes
                
                for tempDebitNote in debitNotes!{
                    
                    if(tempDebitNote.id != nil){
                        
                        if(tempDebitNote.id!.descp == "Cancellation charges"){
                            continue
                        }
                        
                        outStanding += tempDebitNote.id!.balanceAmount!
                        outStanding += tempDebitNote.id!.balanceTaxAmount!
                        
                        if let descp = tempDebitNote.id!.descp{
                            
                            print(descp)
                            
                           let filteredArray =  paymentTowardsArray.filter({$0.name == descp})
                            if(filteredArray.count > 0){
                                var tempPaymentTowards = filteredArray[0]
                                paymentTowardsArray = paymentTowardsArray.filter({$0.name != descp})
                                tempPaymentTowards.count = tempPaymentTowards.count! + 1
                                tempPaymentTowards.amount = tempPaymentTowards.amount! + tempDebitNote.id!.balanceAmount! + tempDebitNote.id!.balanceTaxAmount!
                                paymentTowardsArray.append(tempPaymentTowards)
                            }
                            else{
                                paymentTowardsArray.append(PaymentToWards(name: descp, count: 1, amount: tempDebitNote.id!.balanceAmount! + tempDebitNote.id!.balanceTaxAmount!, _id: tempDebitNote.id!._id))
                            }
                            
                            if(self.isGeneralDebitNote(debitNoteString: descp.lowercased())){
                                debitNoteAmt += tempDebitNote.id!.balanceAmount! + tempDebitNote.id!.balanceTaxAmount!
                                debitNoteCount += 1
                            }
                            else{
                                var note = self.getExistingDebitNote(desp: descp, debitNoteList: debitNoteList)
                                if(note.name?.count ?? 0 > 0){
                                    debitNoteList.append(PaymentToWards(name: descp, count: 1, amount: tempDebitNote.id!.balanceAmount! + tempDebitNote.id!.balanceTaxAmount!,_id: nil))
                                }else{
                                    note.count = note.count ?? 0 + 1
                                    let tempAmount = (tempDebitNote.id!.balanceAmount! + tempDebitNote.id!.balanceTaxAmount!)
                                    note.amount = note.amount ?? 0 + tempAmount
                                }
                            }
                        }
                        else{
                            
                        }
                    }
                }
            }
        }
        
        
        if(demandNoteAmt != 0.0 && demandNoteCount > 0){
            paymentTowardsArray.append(PaymentToWards(name: "Against Demand Note", count: demandNoteCount, amount: demandNoteAmt,_id: nil))
        }
        paymentTowardsArray.append(contentsOf: debitNoteList)
        
        print(paymentTowardsArray)
        
        if(isEditingReceiptEntry){
            for tempPaymentToWards in paymentTowardsArray{
                if(selectedReceiptEntry.paymentTowards == tempPaymentToWards.name){
                    selectedPaymentToWards = selectedReceiptEntry.paymentTowards
                    if(tempPaymentToWards.count! > 0){
                        paymentTowardsTextField.text = String(format: "%@ (%d) - %@ %.2f", tempPaymentToWards.name!,tempPaymentToWards.count!,RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,tempPaymentToWards.amount!)
                    }
                    else{
                        paymentTowardsTextField.text = String(format: "%@ - %@ %.2f", tempPaymentToWards.name!,RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,tempPaymentToWards.amount!)
                    }
                }
            }
        }
        else{
            
        }
        
        
        print(outStanding)
        
        
        outStandingAmoutLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,outStanding)
        
        if((transactions?.totalCredits?.count)! > 0){
            let totalCredits = transactions!.totalCredits![0]
            amountReceivedLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,totalCredits.totalAmount!)
            
            if(self.isEditingReceiptEntry){
                heightOfPaidBalancesView.constant = 150
                paidBalancesView.isHidden = false
            }
            else{
                heightOfPaidBalancesView.constant = 60
                paidBalancesView.isHidden = false
                
                heightOfReceiptQuickView.constant = 0
                receiptQuickView.isHidden = true
            }
        }
        else{
            if(self.isEditingReceiptEntry){
                receiptQuickView.isHidden = false
                heightOfReceiptQuickView.constant = 70
                
            }
            else{
                paidBalancesView.isHidden = false
                heightOfPaidBalancesView.constant = 60
                
                heightOfReceiptQuickView.constant = 0
                receiptQuickView.isHidden = true
            }
        }
        
        print(paymentTowardsArray)
        self.paymentTowardsComponentsArray.append(contentsOf: paymentTowardsArray)
        
        //set outstand text
        
        
        /*
         if (demandNoteAmt != 0.00 && demandNoteCount > 0)
         paymentTowards.add(PaymentTowards(mActivity.resources.getString(R.string.against_demand_note), demandNoteCount, demandNoteAmt))
         
         if (debitNoteAmt != 0.00 && debitNoteCount > 0)
         paymentTowards.add(PaymentTowards(mActivity.resources.getString(R.string.against_debit_note), debitNoteCount, debitNoteAmt))
         paymentTowards.addAll(debitNoteList)
         mView.outstanding.text = mActivity.resources.getString(R.string.cost_construct,
         StringConstants.INDIA_RUPEE, DecimalFormat(StringConstants.DECIMAL_FORMAT).format(outstanding))
         (mView.payment_towards_spinner.adapter as ReceiptSpinnerAdapter).setData(paymentTowards as ArrayList<Any>)
 */
        
    }
    func isGeneralDebitNote(debitNoteString : String)->Bool{
        
        if(debitNoteString == "Stamp Duty Charges".lowercased() || debitNoteString == "Franking Charges".lowercased() || debitNoteString == "Unit Assignment Charges".lowercased() || debitNoteString == "Cancellation charges".lowercased()){
            return true
        }
        else{
            return false
        }
    }
    func getExistingDebitNote(desp : String,debitNoteList : Array<PaymentToWards>)->PaymentToWards{
        
        for paymentTowards in debitNoteList{
            if(desp == paymentTowards.name){
                return paymentTowards
            }
        }
        return PaymentToWards()
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
extension ReceiptEntryFormViewController : UICollectionViewDataSource,UICollectionViewDelegate{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(self.isEditingReceiptEntry){
            return (self.selectedReceiptEntry.images?.count ?? 0) + self.receiptEntryImages.count
        }
        else
        {
            return self.receiptEntryImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "receiptImage", for: indexPath) as! ReceiptImageCollectionViewCell
        
        if(self.isEditingReceiptEntry){
            
            let images : [String] = self.selectedReceiptEntry.images!
            
            var imageUrl = ""

            if(indexPath.row <= (self.selectedReceiptEntry.images!.count - 1)){
                imageUrl = images[indexPath.row]
                DispatchQueue.global().async {
                    let url = ServerAPIs.getSingleSingedUrl(url: imageUrl)
                    DispatchQueue.main.async {
                        cell.receiptImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "image_loading"), options:[.highPriority,.refreshCached])
                    }
                }
            }
            else{
                imageUrl = self.receiptEntryImages[indexPath.row - self.selectedReceiptEntry.images!.count]
                let imageData = try! Data(contentsOf: URL.init(string: imageUrl)!)
                cell.receiptImageView.image = UIImage(data: imageData)
            }
        }
        else{
            let imageUrl = self.receiptEntryImages[indexPath.row]
//            let imageData = try! Data(contentsOf: URL.init(string: imageUrl)!)
            cell.receiptImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "image_loading"), options:[.highPriority,.refreshCached])

//            cell.receiptImageView.image = UIImage(data: imageData)
            
        }
        cell.beleteButton.tag = indexPath.row
        cell.beleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //show image view
        
            let preview =  ImagePreviewViewController(nibName: "ImagePreviewViewController", bundle: nil)
        
        if(self.isEditingReceiptEntry){
            
            if(indexPath.row <= (self.selectedReceiptEntry.images!.count - 1)){
                let images : [String] = self.selectedReceiptEntry.images!
                preview.imageURL = images[indexPath.row]
            }
            else{
                let imageUrl = self.receiptEntryImages[indexPath.row - self.selectedReceiptEntry.images!.count]
                let imageData = try! Data(contentsOf: URL.init(string: imageUrl)!)
                preview.image = UIImage(data: imageData)
            }
        }
        else{
            let imageUrl = self.receiptEntryImages[indexPath.row]
            let imageData = try! Data(contentsOf: URL.init(string: imageUrl)!)
            preview.image = UIImage(data: imageData)
        }
        
        self.present(preview, animated: true, completion: nil)
    }
    @objc func deleteImage(_ sender : UIButton){
        
//        indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:sender.center fromView:sender.superview]];
        let indexPath = self.photosCollectionView.indexPathForItem(at: self.photosCollectionView.convert(sender.center, from: sender.superview))
        
//        print(indexPath)
        
        if(self.isEditingReceiptEntry){
            
            if(indexPath != nil && indexPath!.row <= (self.selectedReceiptEntry.images!.count - 1)){
                let images : [String] = self.selectedReceiptEntry.images!
                let selectedimage = images[indexPath!.row]
                self.selectedReceiptEntry.images = self.selectedReceiptEntry.images?.filter( { $0 != selectedimage } )
            }
            else{
                let imagePath = self.receiptEntryImages[(indexPath!.row - self.selectedReceiptEntry.images!.count)]
                try! fileManager.removeItem(at: URL.init(string: imagePath)!)
                self.receiptEntryImages.remove(at: (indexPath!.row - self.selectedReceiptEntry.images!.count))
            }
        }
        else{
            let imagePath = self.receiptEntryImages[indexPath!.row]
            try! fileManager.removeItem(at: URL.init(string: imagePath)!)
            self.receiptEntryImages.remove(at: indexPath!.row)
        }
        self.photosCollectionView.reloadData()
    }
}
extension ReceiptEntryFormViewController : ImagePickerDelegate {
    
    func didSelect(image: UIImage?,imageName : String?) {
        
        if(image == nil)
        {
            return
        }
        
//        let  tempImage = RRUtilities.sharedInstance.resize(image!)
        
        var tempImageName = ""
        
        if(imageName != nil){
            tempImageName = RRUtilities.sharedInstance.getCurrentTimeAsString() + "_" + imageName!
        }
        else{
            tempImageName = RRUtilities.sharedInstance.getCurrentTimeAsString()
        }
        
        print(tempImageName)
        
        let savedImagePath = RRUtilities.sharedInstance.saveImageToDocumentsFolder(image!, name: tempImageName,folderNameId: "RE")

        self.receiptEntryImages.append(savedImagePath!.absoluteString)
        
        print(self.receiptEntryImages)
        self.photosCollectionView.reloadData()
    }
    
}
extension ReceiptEntryFormViewController : HidePopUp {
    
    func didSelectProject(optionType: String, optionIndex: Int) {
        
        //        self.selectedBlockingReason = optionType
        self.paymentTowardsTextField.text = optionType
        self.selectedPaymentToWards = optionType
        self.selectedPaymentTowardsDict = self.paymentTowardsComponentsArray[optionIndex]
        self.hidePopUp()
    }
    func didSelectCurrency(selectedCurrency: CURRENCY, selectedIndex: Int) {
        self.selectedCurrency = selectedCurrency
        print(selectedCurrency)
        ServerAPIs.converCurrency(fromCurrencyCode: "INR", toCurrencyCode: selectedCurrency.id!, completionHandler: { (response,value ,error) in
            if(response){
                let amount = Double(self.amountTextField.text!)
                let convertedValue = value * (amount ?? 0.0)
                self.selectedCurrencyConverter = convertedValue
                self.foreignCurrencyTextField.text = String(format: "%.2f", convertedValue)
            }
            else{
                
            }
        })
        self.currencyNameTextField.text = String(format: "%@ - %@", selectedCurrency.currencyName!,selectedCurrency.currencySymbol ?? "")
        hidePopUp()
    }
    func didSelectRow(selectedRowText: String, selectedIndex: Int) {
        
        self.hideAllPaymentModeFields()
        
        paymentModeTextField.text = ""
        depositeDateTextField.text = ""
        paymentDateTextField.text = ""
        chequeNumberTextField.text = ""
        chequeDateTextField.text = ""
        referenceNumberTextField.text = ""
        ifscCodeTextField.text = ""
        bankNameLabel.text = "-"
        bankBranchLabel.text = "-"
        
        paymentModeTextField.text = selectedRowText
        self.selectedPaymentMode = selectedRowText
        
        self.setUIForPayment(selectedPaymetnMode: selectedRowText)
        
        self.hidePopUp()
    }
    func didSelectProjectBankAccount(bankAccount: BANK_ACCOUNTS, selectedIndex: Int){
        self.selectedProjectBank = bankAccount
        self.depositBankNameLabel.text = String(format: "%ld - %@\n%@", bankAccount.accountNumber!,bankAccount.bankName!, bankAccount.bankBranch!)
        self.hidePopUp()
    }
    
    @IBAction func showPopUp(_ sender: Any) {
        
        self.view.endEditing(true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .OWNER_IMAGES_POP_UP
        
        let sourcesArray : [String] = ["Take Photo","Choose from gallery"]
        
//        vc.preferredContentSize = CGSize(width: 200, height: (sourcesArray.count-1) * 44)
        
//        if(CGFloat((sourcesArray.count-1) * 44) > (self.view.frame.size.height - 150)){
        
            vc.preferredContentSize = CGSize(width: 200, height: 44)
//        }
        
//        if(sourcesArray.count == 1){
//            vc.preferredContentSize = CGSize(width: 200, height: 1)
//        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.tableViewDataSourceOne = sourcesArray
        
        vc.delegate = self
        popOver?.sourceView = recieptImageView
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    func hidePopUp(){
        let tmpController :UIViewController! = self.presentedViewController;
        if(tmpController != nil){
            self.dismiss(animated: false, completion: {()->Void in
                tmpController.dismiss(animated: false, completion: nil);
            });
        }
    }

    func didFinishTask(optionType: String, optionIndex: Int) {
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
        
        print(optionType)
        
        if(optionType == "Take Photo"){
            self.imagePicker.takePhoto(from: recieptImageView)
        }
        else if(optionType == "Choose from gallery"){
            self.imagePicker.takeFromPhotos(from: recieptImageView)
        }
    }
}
