//
//  BookingFormViewController.swift
//  REroot
//
//  Created by Dhanunjay on 10/11/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import CoreData
import SDWebImage
import FloatingPanel

protocol BookUnitDelegate: class {
    func didFinishBookUnit(clientId : String,bookedUnit : Units,selectedIndexPath : IndexPath)
}

class BookingFormViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPopoverPresentationControllerDelegate,DateSelectedFromPicker{
    
    var selectedScheme : Schemes!
    @IBOutlet weak var schemeTitleView: UIView!
    @IBOutlet weak var schemeNameLabel: UILabel!
    @IBOutlet weak var schemeSelectionView: UIView!
    @IBOutlet weak var heightOfSchemeSelectionView: NSLayoutConstraint!
    
    @IBOutlet weak var selectedSchemeLabel: UILabel!
    @IBOutlet weak var selectedSchemeInfoView: UIView!
    @IBOutlet weak var heightOfSelectedShemeInfoView: NSLayoutConstraint!
    var countryCodePopOver : PopOverViewController!
    var countryCodeNavigator : UINavigationController!
    var countryCodesArray : NSMutableArray = []

    @IBOutlet weak var ownersCountInfoLabel: UILabel!
    @IBOutlet weak var secondRowButtonsStackView: UIStackView!
    @IBOutlet weak var firstRowButtonsStackView: UIStackView!
    @IBOutlet weak var heightOfQuickLinksView: NSLayoutConstraint!
    @IBOutlet weak var heightOfQuickLinkStackView: NSLayoutConstraint!
    @IBOutlet weak var quickLinksView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedProspect : REGISTRATIONS_RESULT!
    weak var unitStatusDelegate:UnitStatusChangeDelegateDelegate?
    var selectedUnitIndexPath : IndexPath!
    var agreeentDateTimeStamp : String!
    var indexPathOfSelectedUnit : IndexPath!
    weak var delegate:BookUnitDelegate?
    @IBOutlet weak var viewFloorPlanButton: UIButton!
    @IBOutlet weak var heightOfFloorPlanButtonView: NSLayoutConstraint!
    @IBOutlet weak var floorPlanButtonView: UIView!
    @IBOutlet weak var agreementDateInfoView: UIView!
    @IBOutlet weak var dateOfAgreementLabel: UILabel!
    @IBOutlet weak var heightOfAgreementDateView: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfRsrvInfoView: NSLayoutConstraint!
    @IBOutlet weak var heightOfSaveButton: NSLayoutConstraint!
    @IBOutlet weak var heightOfReservationsTableView: NSLayoutConstraint!
    var bookingFormDetails : BOOKING_FORM_RESULT_DETAILS!
    var bookingFormOutput : BOOKING_FORM_RESULT!
    
    @IBOutlet weak var blockOrReleseButtonsView: UIView!
    @IBOutlet weak var revokeAllButton: UIButton!
    
    @IBOutlet weak var unitDetailsView: UIView!
    @IBOutlet weak var heightOfUnitDetailsView: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfLandOwnerInfoView: NSLayoutConstraint!
    @IBOutlet weak var landOwnerNameLabel: UILabel!
    @IBOutlet weak var landOnwerInfoLabel: UILabel!
    @IBOutlet weak var landOwnerInfoView: UIView!

    @IBOutlet weak var salesPersonInfoView: UIView!
    @IBOutlet weak var salesPersonNameLabel: UILabel!
    @IBOutlet weak var salesPersonInfoLabel: UILabel!
    @IBOutlet weak var heightOfSalesPersonInfoView: NSLayoutConstraint!
    
    
    @IBOutlet weak var heightConstraintOfCustomerDetails: NSLayoutConstraint!
    @IBOutlet weak var bookingDateTextField : UITextField!
    @IBOutlet weak var blockedReasonLabel: UILabel!
    
    var reservationsTableViewDataSource : [RESERVED_UNITS]!
    
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var heightOfReservationView: NSLayoutConstraint!
    @IBOutlet weak var reservationQueueView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var heightConstaintOfClientView: NSLayoutConstraint!
    @IBOutlet weak var clientCollectionView: UIView!
    @IBOutlet weak var customerDetailsView: UIView!
    @IBOutlet weak var heightOfBookingDetailsView: NSLayoutConstraint!
    @IBOutlet weak var bookingDetailsView: UIView!
    @IBOutlet weak var heightOfBlockedView: NSLayoutConstraint!
    @IBOutlet weak var blockedReasonView: UIView!
    @IBOutlet weak var reservationsTableView: UITableView!
    
    @IBOutlet weak var commentsTextView: KMPlaceholderTextView!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var titleInfoView: UIView!
    @IBOutlet weak var unitFacingLabel: UILabel!
    
    @IBOutlet weak var heightOfProspectDetailsView: NSLayoutConstraint!
    @IBOutlet weak var prospectDetailsView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    var selectedUnit : Units! //UnitDetails!
    var blockReasons : [COMMON_FORMAT] = []
    var selectedBlockingReason : String!
    var selectedBookingDate : Date!
    @IBOutlet weak var blockReasonsView: UIView!
    @IBOutlet weak var heightOfBlockReasonButtonsView: NSLayoutConstraint!
    var clientsArray : [ClientList] = []
    var selectedIndexPathForReceiptEntry : IndexPath!
    
     var isReceiptEnabled = false
     var isSOAEnabled = false
     var isPaymentScheduleEnabled = false
     var isProspectsEnabled = false
    
    let fpc = FloatingPanelController()

    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleInfoView.clipsToBounds = true
        
        titleInfoView.layer.masksToBounds = false
        titleInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        titleInfoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleInfoView.layer.shadowOpacity = 0.4
        titleInfoView.layer.shadowRadius = 1.0
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleInfoView)
        
    }
    @objc func injected() {
        configureView()
//        self.getReserations()
//        self.hideAll()
//        self.getBookingFormInfo()
//
//        self.buildUnitDetailsView()
//        print(selectedUnit)
//        self.getAgreementDate()
//        print("")
//        self.shouldShowAgreementDateView(shouldShow: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        if(selectedUnit.carParks != nil){
//            let tempDIct : NSDictionary = (selectedUnit.carParks as? NSDictionary)!
//            print(selectedUnit.carParkings)
        
//        let carFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UnitCarParks")
//        let carsResults = try RRUtilities.sharedInstance.model.managedObjectContext.fetch(carFetch)
//        print(carsResults)
        
        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LandOwner")
//
//        let predicate = NSPredicate(format: "parentId CONTAINS[c] %@", selectedUnit.id!)
//        request.predicate = predicate
//
//        let LandOwnwerResults = try RRUtilities.sharedInstance.model.managedObjectContext.fetch(request)
//
//        print(LandOwnwerResults)
//
//        print(selectedUnit.owner)

        
        //fetch carparks
        
//        }
//        else{
//            print(selectedUnit)
//        }
        
        schemeTitleView.layer.cornerRadius = 8.0
        schemeTitleView.layer.borderWidth = 0.4
        schemeTitleView.layer.borderColor = UIColor.lightGray.cgColor
        schemeNameLabel.text = "None"
        
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showSchemesForSelection))
        schemeTitleView.addGestureRecognizer(tapGuesture)

        viewFloorPlanButton.layer.cornerRadius = 8
        viewFloorPlanButton.layer.borderWidth = 0.6
        viewFloorPlanButton.layer.borderColor = UIColor.lightGray.cgColor
        self.hideAll()
        self.configureView()
        
        if(selectedUnit != nil && selectedUnit.hasImages == false)
        {
            heightOfFloorPlanButtonView.constant = 0
            floorPlanButtonView.isHidden = true
        }

        let nib = UINib(nibName: "ReservationTableViewCell", bundle: nil)
        reservationsTableView.register(nib, forCellReuseIdentifier: "reservQueueCell")
        
        reservationsTableView.tableFooterView = UIView()
        
        reservationsTableView.rowHeight = UITableView.automaticDimension
        reservationsTableView.estimatedRowHeight = UITableView.automaticDimension

        saveButton.backgroundColor = UIColor.hexStringToUIColor(hex: "35495d")
        saveButton.setTitleColor(UIColor.white, for: .normal)
        
        let dateImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        dateImage.image = UIImage.init(named: "calendar")
        dateImage.contentMode = UIView.ContentMode.center
        bookingDateTextField.rightView = dateImage
        bookingDateTextField.rightViewMode = .always
        
        bookingDateTextField.delegate = self
        
        countryCodeTextField.delegate = self
        phoneNumberTextField.delegate = self
        
//        print(selectedUnit.bookingform)
        
        if(selectedUnit.status == UNIT_STATUS.VACANT.rawValue || selectedUnit.status == UNIT_STATUS.RESERVED.rawValue || selectedUnit.status == UNIT_STATUS.BLOCKED.rawValue) {//(selectedUnit.bookingform != nil){
//            print(selectedUnit.bookingform)
            
            // get preivew
            if(selectedProspect == nil){
                ServerAPIs.getUnitPreviewPrice(regInfo: "", unitID: selectedUnit.id!, scheme:"" ,completionHandler: {(bookingFormResult, error) in
                    if(bookingFormResult?.status == 1){
                        self.bookingFormOutput = bookingFormResult
                        self.bookingFormDetails = bookingFormResult?.booking
                        self.buildUnitDetailsView()
                    }
                    else{
                        self.buildUnitDetailsView()
                    }
                })
            }
            else{
                self.buildUnitDetailsView()
            }
//            self.getBookingFormInfo()
        }
        else{
            // show info with red text
//            self.buildUnitDetailsView()
            self.getBookingFormInfo()
        }
        if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue)
        {
            if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RESERVE_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
                self.shouldShowReservationQueueView(shouldShow: false)
            }
            else{
                self.getReserations()
                self.shouldShowReservationQueueView(shouldShow: true)
            }
            self.shouldShowProspectDetailsView(shouldShow: false)
            self.shouldShowBookingDetailsView(shouldShow: false)
            self.shouldShowBlockingInfoView(shouldShow: false)
            self.shouldShowAgreementDateView(shouldShow: false)
            self.shouldShowSalesPersonInfo(shoudlShow: false)
            self.shouldShowQuickLinksView(shouldShow: false)
        }
        
        
        if(selectedUnit.status == UNIT_STATUS.VACANT.rawValue){
            
            saveButton.isHidden = true
            heightOfSaveButton.constant = 0
            self.shouldShowProspectDetailsView(shouldShow: false)
            self.shouldShowBookingDetailsView(shouldShow: false)
            self.shouldShowReservationQueueView(shouldShow: false)
            self.shouldShowBlockingInfoView(shouldShow: false)
            self.shouldShowAgreementDateView(shouldShow: false)
            self.shouldShowSalesPersonInfo(shoudlShow: false)
            self.shouldShowQuickLinksView(shouldShow: false)
            if(self.selectedUnit.schemes?.count ?? 0 > 0){
                self.shouldShowSchemeSelectionView(shouldShow: true)
            }
        }
        
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue){
            
            saveButton.isHidden = true
            heightOfSaveButton.constant = 0
            
            self.shouldShowProspectDetailsView(shouldShow: false)
            self.shouldShowReservationQueueView(shouldShow: false)
            self.shouldShowBookingDetailsView(shouldShow: false)
            self.shouldShowBlockingInfoView(shouldShow: false)
            self.shouldShowAgreementDateView(shouldShow: false)
            self.shouldShowSalesPersonInfo(shoudlShow: false)
            self.shouldShowQuickLinksView(shouldShow: false)
        }
        
        if(selectedUnit.status == UNIT_STATUS.SOLD.rawValue || selectedProspect != nil){
            
            saveButton.isHidden = true
            heightOfSaveButton.constant = 0
            
            self.getAgreementDate()

//            self.shouldShowProspectDetailsView(shouldShow: true)
//            self.shouldShowBookingDetailsView(shouldShow: true)
            
        }
        
        if(selectedUnit.status == UNIT_STATUS.BLOCKED.rawValue){
            
            self.shouldShowSaveButton(shouldShow: false)
            self.shouldShowAgreementDateView(shouldShow: false)
            self.shouldShowProspectDetailsView(shouldShow: false)
            self.shouldShowBookingDetailsView(shouldShow: false)
            self.shouldShowReservationQueueView(shouldShow: false)
            self.shouldShowBlockingInfoView(shouldShow: true)
            self.shouldShowSalesPersonInfo(shoudlShow: false)
            
            blockedReasonLabel.text = selectedUnit.blockingReason
            self.selectedBlockingReason = selectedUnit.blockingReason

            var tempBlockReason = COMMON_FORMAT.init()
            
            tempBlockReason.name = "None"
            tempBlockReason._id = "None"
            
            self.blockReasons.append(tempBlockReason)
            
            self.blockedReasonLabel.text = self.selectedUnit.blockingReason ?? tempBlockReason.name
            
            self.blockReasons += RRUtilities.sharedInstance.defaultBookingFormSetUp.blockReason! + RRUtilities.sharedInstance.customBookingFormSetUp.blockReason!
            
            self.blockReasonsView.layer.cornerRadius = 8
            self.blockReasonsView.layer.borderWidth = 0.6
            self.blockReasonsView.layer.borderColor = UIColor.lightGray.cgColor
            
            self.heightOfBlockReasonButtonsView.constant = 50
            
        }
        
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue){
        }
        
        
        viewFloorPlanButton.titleLabel?.font = UIFont.init(name: "Montserrat-Regular", size: 14)
        
        
        if(selectedProspect != nil){
            
            self.bookingFormDetails = self.bookingFormOutput.booking
            self.customerDetailsView.isHidden = false
            self.heightConstraintOfCustomerDetails.constant = 202
            
            self.heightConstaintOfClientView.constant = 0
            self.clientCollectionView.isHidden = true
            
            saveButton.isHidden = false
            saveButton.setTitle("CONFIRM BOOKING", for:.normal)
            heightOfSaveButton.constant = 50

            self.phoneNumberTextField.text = selectedProspect.userPhone
            self.emailTextField.text = selectedProspect.userEmail
            self.nameTextField.text = selectedProspect.userName
            self.commentsTextView.text = selectedProspect.comment
            self.countryCodeTextField.text = selectedProspect.userPhoneCode
            
            let bookingDate = Formatter.ISO8601.string(from: Date())
            let dateString = RRUtilities.sharedInstance.getDateWithEnglishWord(dateStr: bookingDate)
            // "2018-01-23T03:06:46.232Z"
            
            self.bookingDateTextField.text = dateString
            
            self.shouldShowProspectDetailsView(shouldShow: true)
            self.shouldShowBookingDetailsView(shouldShow: true)
            self.shouldShowSaveButton(shouldShow: true)
            self.buildUnitDetailsView()
        }

        self.shouldShowLandOwner(shouldShow: selectedUnit.hasLandOwner)
//        self.setUpQuickLinks()
        
//        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue){
//
//            self.shouldShowReservationQueueView(shouldShow: false)
//            self.shouldShowBlockingInfoView(shouldShow: false)
//
//            self.shouldShowProspectDetailsView(shouldShow: true)
//            self.shouldShowBookingDetailsView(shouldShow: true)
//
//        }
//
        

//        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue)
//        {
//            self.shouldShowProspectDetailsView(shouldShow: true)
//            self.shouldShowReservationQueueView(shouldShow: false)
//
//            self.shouldShowBookingDetailsView(shouldShow: true)
//
//        }
//        else if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue)
//        {
//            self.getReserations()
//            self.shouldShowReservationQueueView(shouldShow: true)
//        }
//        else if(selectedUnit.status == UNIT_STATUS.BLOCKED.rawValue){
//
//            heightOfReservationsTableView.constant = 0
//            self.shouldShowProspectDetailsView(shouldShow: false)
//            self.shouldShowReservationQueueView(shouldShow: false)
//            blockedReasonLabel.text = selectedUnit.blockingReason
//            heightOfBlockedView.constant = 65
//            blockedReasonView.isHidden = false
//        }
        
//        self.buildUnitDetailsView()
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BOOKING_FORM.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) || !PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BOOKING_FORM.rawValue, permissionType: UserRolePermissions.CREATE.rawValue)){
            self.shouldShowSaveButton(shouldShow: false)
        }
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BLOCK_RELEASE_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) || !PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BLOCK_RELEASE_UNIT.rawValue, permissionType: UserRolePermissions.CREATE.rawValue)){
            self.shouldShowBlockOrReleaseButton(shouldShow: false)
        }
        
    }
    func fetchSchemesForSelectdUnit()->[Schemes]{
        
        let entity = NSEntityDescription.entity(forEntityName: "Schemes", in: RRUtilities.sharedInstance.model.managedObjectContext)
        let noneScheme = Schemes.init(entity: entity!, insertInto: nil)
        noneScheme.name  = "None"
        noneScheme.id = "None"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Schemes")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptors = [sortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            
            let fetchedSchemes = try RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest) as! [Schemes]
            
            var schemesForUnit : [Schemes] = []
            schemesForUnit.append(noneScheme)
            
            if(fetchedSchemes.count > 0){
                let definedSchemes =  self.selectedUnit!.schemes!
                for eachSchemeId in definedSchemes{
                    let filteredSchmes = fetchedSchemes.filter({ $0.id == eachSchemeId })
                    if(filteredSchmes.count == 1){
                        schemesForUnit.append(filteredSchmes[0])
                    }
                }
            }
            
            return schemesForUnit
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
        }
        
    }
    @objc func showSchemesForSelection(){
        
        let schemes = self.fetchSchemesForSelectdUnit()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let schemesPopOver = (storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController)
        schemesPopOver.dataSourceType = .SCHEMES
        schemesPopOver.preferredContentSize = CGSize(width:  300, height: (schemes.count - 1) * 44)
        
        if(schemes.count == 0){
            schemesPopOver.preferredContentSize = CGSize(width:  300, height:1)
        }
        let navigationContoller = UINavigationController(rootViewController: schemesPopOver)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        schemesPopOver.schemesDataSource = schemes
        
        popOver?.sourceView = schemeNameLabel
        
        schemesPopOver.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    func setUpUnitDetails(){
        
    }
    func setUpQuickLinks(){
        
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue || selectedUnit.status == UNIT_STATUS.HANDEDOVER.rawValue){
            
        }
        else{
            return
        }
        
        if(self.bookingFormOutput == nil){
            self.shouldShowQuickLinksView(shouldShow: false)
            return
        }

        
        self.isReceiptEnabled = PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) && PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.CREATE.rawValue) && ((self.bookingFormOutput.booking?._id ?? nil) != nil)
        
        self.isPaymentScheduleEnabled =  PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BOOKING_FORM.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) &&  (self.bookingFormOutput.booking?.installments?.count ?? 0 > 0) //(booking?.installments ?: ArrayList()).isNotEmpty()
        
        let prospectID = self.bookingFormOutput.booking?.prospect?.regInfo ?? self.bookingFormOutput.booking?.prospect?._id
        self.isProspectsEnabled = PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.PROSPECTS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) && (prospectID != nil ? true : false)
        
//        self.isSOAEnabled = PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.STATEMENT_OF_ACCOUNT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) && (self.bookingFormOutput.booking?.prospect != nil) //booking?.prospect != null
        
        var buttonsArray : Array<UIButton> = []
        
        if(self.isPaymentScheduleEnabled){
            let paymentSchduleButton = UIButton.init()
            paymentSchduleButton.addTarget(self, action: #selector(showPaymentSchdule), for: .touchUpInside)
            paymentSchduleButton.setTitle("Payment Schedule", for: .normal)
            paymentSchduleButton.layer.cornerRadius = 1.0
            buttonsArray.append(paymentSchduleButton)
            self.setButton(button: paymentSchduleButton)
        }
        if(self.isReceiptEnabled){
            let receiptEnableButton = UIButton.init()
            receiptEnableButton.addTarget(self, action: #selector(showAddReceipt(_:)), for: .touchUpInside)
            receiptEnableButton.setTitle("Add Receipt", for: .normal)
            buttonsArray.append(receiptEnableButton)
            self.setButton(button: receiptEnableButton)
        }
        if(self.isProspectsEnabled){
            let prospectsButton = UIButton.init()
            prospectsButton.addTarget(self, action: #selector(showProspectHistory), for: .touchUpInside)
            prospectsButton.setTitle("Show History", for: .normal)
            buttonsArray.append(prospectsButton)
            self.setButton(button: prospectsButton)

        }
        if(self.isSOAEnabled){
            let SOAButton = UIButton.init()
            SOAButton.addTarget(self, action: #selector(showStatementOfAccount), for: .touchUpInside)
            SOAButton.setTitle("Statement Of Account", for: .normal)
            buttonsArray.append(SOAButton)
            self.setButton(button: SOAButton)
        }
//        print(buttonsArray)
        if(buttonsArray.count <= 2){
            self.heightOfQuickLinkStackView.constant = 50
            self.heightOfQuickLinksView.constant = 90
            for tempButton in buttonsArray{
                self.firstRowButtonsStackView.addArrangedSubview(tempButton)
            }
        }
        else{
            self.secondRowButtonsStackView.isHidden = false
            var counter = 0
            for tempButton in buttonsArray{
                if(counter < 2){
                    self.firstRowButtonsStackView.addArrangedSubview(tempButton)
                }
                if(counter > 1){
                    self.secondRowButtonsStackView.addArrangedSubview(tempButton)
                }
                counter += 1
            }
        }
    }
    func setButton(button : UIButton){
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1.0
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.sizeToFit()
        button.titleLabel?.font =  UIFont.init(name: "Montserrat-Medium", size: 15)
        button.setTitleColor(self.view.tintColor, for: .normal)
    }
    @objc func showPaymentSchdule(){
        print("show paymetn schedule")
        let quickController = QuickLinksViewController(nibName: "QuickLinksViewController", bundle: nil)
        quickController.cellType = TabelViewCellType.PaymentSchdule
        quickController.installments = self.bookingFormOutput.booking!.installments!
        quickController.unitRate = self.bookingFormOutput?.booking?.unitRate ?? nil
        quickController.paymentScheduleUnitRate = self.bookingFormOutput?.booking?.unitRate ?? nil
        self.showFloatingPanel(controller: quickController)

    }
    @objc func showAddReceipt(_ sender : UIButton){
        print("showAddReceipt")
        
        let receiptFormController = ReceiptEntryFormViewController(nibName: "ReceiptEntryFormViewController", bundle: nil)
        receiptFormController.isEditingReceiptEntry = false
        receiptFormController.selectedUnit = self.selectedUnit
        receiptFormController.selectedProject = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: self.selectedUnit.project!)
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue){
            let client = self.clientsArray[self.selectedIndexPathForReceiptEntry.row]
            receiptFormController.customer = client.customer
        }
        else if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
            receiptFormController.selectedClient = self.reservationsTableViewDataSource[sender.tag]
        }
        if(self.bookingFormOutput.booking!.clients?.count ?? 0 > 0){
            receiptFormController.customer = self.bookingFormOutput.booking!.clients![0].customer
        }
        receiptFormController.isAddingFromBookingForm = true
//        receiptFormController.selectedClient = self.reservationsTableViewDataSource[sender.tag]
        //        receiptFormController.selectedReceiptEntry = receiptEntriesFetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(receiptFormController, animated: true)

    }
    @objc func showProspectHistory(){
        print("show prospect history")
        
        let quickController = QuickLinksViewController(nibName: "QuickLinksViewController", bundle: nil)
        quickController.cellType = TabelViewCellType.ProspectHistory
        quickController.prospectDetails = self.selectedProspect
        quickController.prospectRegId = self.bookingFormOutput.booking?.prospect?.regInfo ?? self.bookingFormOutput.booking?.prospect?._id
        self.showFloatingPanel(controller: quickController)
    }
    @objc func showStatementOfAccount(){
        
        
        
    }
    //MARK: - FLOAT PANEL BEGIN
    @objc func moveFpcViewToFull() {
        fpc.move(to: .full, animated: true)
    }
    func showFloatingPanel(controller : QuickLinksViewController){
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.delegate = self
        
        fpc.set(contentViewController: controller)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: controller.tableView)
        
        self.present(fpc, animated: true, completion: nil)
    }
    //MARK: - FLOAT PANEL END
    func hideAll(){
        heightOfBlockedView.constant = 0
        heightOfReservationView.constant = 0
        heightOfBookingDetailsView.constant = 0
        heightOfProspectDetailsView.constant = 0
        heightOfLandOwnerInfoView.constant = 0
        heightOfQuickLinksView.constant = 0
        
        landOwnerInfoView.isHidden = true
        blockedReasonView.isHidden = true
        reservationQueueView.isHidden = true
        prospectDetailsView.isHidden = true
        bookingDetailsView.isHidden = true
        quickLinksView.isHidden = true
        self.shouldShowAgreementDateView(shouldShow: true)
        self.shouldShowSchemeInfo(shouldShow: false)
        self.shouldShowSchemeSelectionView(shouldShow: false)
    }
    func shouldShowQuickLinksView(shouldShow : Bool){
        
        if(shouldShow){
            self.heightOfQuickLinksView.constant = 150
            self.quickLinksView.isHidden = false
        }
        else{
            self.heightOfQuickLinksView.constant = 0
            self.quickLinksView.isHidden = true
        }
        self.quickLinksView.superview?.layoutIfNeeded()
    }
    func shouldShowLandOwner(shouldShow : Bool){
        if(shouldShow){
            landOwnerInfoView.isHidden = false
            heightOfLandOwnerInfoView.constant = 60
            landOwnerNameLabel.text = selectedUnit.owner?.name ?? ""
        }
        else{
            landOwnerInfoView.isHidden = true
            heightOfLandOwnerInfoView.constant = 0
        }
    }
    func shouldShowSchemeSelectionView(shouldShow : Bool){
        if(shouldShow){
            self.heightOfSchemeSelectionView.constant = 90
        }
        else{
            self.heightOfSchemeSelectionView.constant = 0
        }
        self.schemeSelectionView.isHidden = !shouldShow
    }
    func shouldShowSchemeInfo(shouldShow : Bool){
        
        if(shouldShow){
            self.heightOfSelectedShemeInfoView.constant = 60
        }
        else{
            self.heightOfSelectedShemeInfoView.constant = 0
        }
        self.selectedSchemeInfoView.isHidden = !shouldShow
    }
    func shouldShowSalesPersonInfo(shoudlShow : Bool){
        
        if(shoudlShow){
            self.heightOfSalesPersonInfoView.constant = 60
            self.salesPersonInfoView.isHidden = !shoudlShow
            self.salesPersonInfoLabel.isHidden = !shoudlShow
            self.salesPersonNameLabel.isHidden = !shoudlShow
            
            if(self.bookingFormOutput?.booking?.salesPerson != nil)
                
            {
                let employee : String = RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: self.bookingFormOutput.booking!.salesPerson ?? "Super Admin") ?? "Super Admin"
                
                self.salesPersonNameLabel.text = employee //selectedUnit.salesPersonUserInfoName //selectedUnit.bookingform?.salesPerson?.userInfo?.name
            }
            else{
                self.salesPersonNameLabel.text = "Super Admin"
            }
        }
        else{
            self.heightOfSalesPersonInfoView.constant = 0
            self.salesPersonInfoView.isHidden = shoudlShow
            self.salesPersonInfoLabel.isHidden = !shoudlShow
            self.salesPersonNameLabel.isHidden = !shoudlShow
        }
    }
    func shouldShowBlockOrReleaseButton(shouldShow : Bool){
        if(shouldShow){
            self.blockOrReleseButtonsView.isHidden = !shouldShow
            self.heightOfBlockReasonButtonsView.constant = 50
        }
        else{
            self.blockOrReleseButtonsView.isHidden = !shouldShow
            self.heightOfBlockReasonButtonsView.constant = 0
        }
    }
    func shouldShowSaveButton(shouldShow : Bool){
     
        if(shouldShow){
            self.saveButton.isHidden = !shouldShow
            heightOfSaveButton.constant = 50
        }
        else{
            self.saveButton.isHidden = !shouldShow
            heightOfSaveButton.constant = 0
        }

    }
    func shouldShowAgreementDateView(shouldShow : Bool){
        
        if(shouldShow){
            heightOfAgreementDateView.constant = 50
//            dateOfAgreementLabel.text = ""
            agreementDateInfoView.isHidden = !shouldShow
        }
        else{
            heightOfAgreementDateView.constant = 0
            dateOfAgreementLabel.text = ""
            agreementDateInfoView.isHidden = !shouldShow
        }
    }
    func shouldShowReservationQueueView(shouldShow : Bool){
        
        if(shouldShow){
            heightOfReservationView.constant = 170
            heightOfReservationsTableView.constant = 100
            heightOfRsrvInfoView.constant = 50
        }
        else{
            heightOfReservationView.constant = 0
            heightOfReservationsTableView.constant = 0
            heightOfRsrvInfoView.constant = 0
        }
        reservationQueueView.isHidden = !shouldShow
    }
    func shouldShowBookingDetailsView(shouldShow : Bool){
        
        if(shouldShow){
            heightOfBookingDetailsView.constant = 140
        }
        else{
            heightOfBookingDetailsView.constant = 0
        }
        bookingDetailsView.isHidden = !shouldShow

    }
    func shouldShowProspectDetailsView(shouldShow : Bool){
        
        if(shouldShow){
            heightOfProspectDetailsView.constant = 330
        }else{
            heightOfProspectDetailsView.constant = 0
        }
        prospectDetailsView.isHidden = !shouldShow
        
//        print(selectedUnit)
    }
    func shouldShowBlockingInfoView(shouldShow : Bool){
        
        if(shouldShow){
            heightOfBlockedView.constant = 80
        }else{
            heightOfBlockedView.constant = 0
        }
        blockedReasonView.isHidden = !shouldShow
    }
    func configureView(){
        
        collectionView.alwaysBounceHorizontal = true
        
        collectionView.register(UINib(nibName: "OwnerDetailsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ownerDetailsCell")
        revokeAllButton.layer.cornerRadius = 8
        
        unitFacingLabel.numberOfLines = 0
        unitFacingLabel.lineBreakMode = .byWordWrapping
        unitFacingLabel.text = String(format: "%@ (%@)", selectedUnit.unitDisplayName ?? "",selectedUnit.description1 ?? "")

        let statusColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: Int(selectedUnit!.status))

        statusButton.backgroundColor = statusColorDict["color"] as? UIColor
        statusButton.setTitle(String(format: "  %@  ", statusColorDict["statusString"] as! String), for: .normal)
        statusButton.layer.cornerRadius = 8.0

        commentsTextView.layer.borderWidth = 0.4
        commentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentsTextView.layer.cornerRadius = 8.0
        
        if(selectedUnit.status != UNIT_STATUS.BOOKED.rawValue || selectedUnit.status != UNIT_STATUS.SOLD.rawValue){ //Booked
            
//            self.shouldShowProspectDetailsView(shouldShow: true)
//            self.shouldShowBookingDetailsView(shouldShow: true)

//            self.shouldShowProspectDetailsView(shouldShow: true)
            
//            heightOfProspectDetails.constant = 0
//            prospectDetailsView.isHidden = true
//            saveButton.isHidden = true
//            heightOfSaveButton.constant = 0
//            heightOfPremiumBillingElementsView.constant = 0
        }
        
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue)
        {
//            self.shouldShowProspectDetailsView(shouldShow: true)
            
//            self.hideReservationInfoView()
//            saveButton.isHidden = false
//            heightOfSaveButton.constant = 50
//            heightOfProspectDetails.constant = 330
//            prospectDetailsView.isHidden = false
//            if(selectedUnit.bookingform != nil){
//                self.getBookingFormInfo()
//            }
//        }
        }
//        else if(selectedUnit.status == UNIT_STATUS.VACANT.rawValue){
//
//            saveButton.isHidden = true
//            self.heightOfReservationView.constant = 0
//            self.heightOfReservationsTableView.constant = 0
//            self.hideAll()
//
//        }
    }
    func buildUnitDetailsView(){
        
        for tempView in unitDetailsView.subviews{
            tempView.removeFromSuperview()
        }
        var lastView : UnitInfoView? = nil
        
//        print(selectedUnit)
        
//        if(selectedUnit.type?.name != nil){
        
            let unitInfoView : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView.translatesAutoresizingMaskIntoConstraints = false
            unitDetailsView.addSubview(unitInfoView)
            let bindings = ["unitInfoView" : unitInfoView]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let topCons = NSLayoutConstraint.init(item: unitInfoView, attribute: .top, relatedBy: .equal, toItem: unitDetailsView, attribute: .top, multiplier: 1.0, constant: 5.0)
            unitDetailsView.addConstraint(topCons)
            
            let height = NSLayoutConstraint.init(item: unitInfoView, attribute: .height, relatedBy:.greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView
            
            unitInfoView.leftLabel.text = "Unit Type:"
            unitInfoView.leftLabel.numberOfLines = 0
            unitInfoView.leftLabel.lineBreakMode = .byWordWrapping
            unitInfoView.leftLabel.layoutIfNeeded()
//            print(selectedUnit.type?.name)
        
            unitInfoView.rightLabel.text = selectedUnit.typeName ?? "No Unit Type"
        
//            if(selectedUnit.unitTypeName != nil){
//                unitInfoView.rightLabel.text = selectedUnit.unitTypeName
//            }else{
//                unitInfoView.rightLabel.text = "No Unit Type"
//            }
        
//            unitInfoView.backgroundColor = UIColor.red
//        }
        
        
        if(selectedUnit.facing != nil){
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Unit Facing:"
            unitInfoView1.rightLabel.text = selectedUnit.facing
        }
        
//        let unitTypeDict : NSDictionary = selectedUnit.type as! NSDictionary
        
        if(selectedUnit.superBuiltUpArea != nil && selectedUnit.superBuiltUpArea!.doubleValue > 0.0 && selectedUnit.superBuiltUpAreaUOM != nil){
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Super Built-Up Area:"
            if(selectedUnit.superBuiltUpAreaUOM != nil){
                unitInfoView1.rightLabel.text = String(format: "%@ %@", (selectedUnit.superBuiltUpArea!.description),(selectedUnit.superBuiltUpAreaUOM!))
            }
        }
        var shouldAddGap = true
        if(selectedUnit.carpetArea != nil && selectedUnit.carpetArea!.doubleValue > 0.0 && selectedUnit.superBuiltUpArea != selectedUnit.carpetArea){ //Carpet Area
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Carpet Area:"
            if(selectedUnit.company_group == "5c6f0627d2a2cb1f913a44e4"){
                unitInfoView1.leftLabel.text = "Garden Area / UDS:"
            }
            unitInfoView1.rightLabel.text = String(format: "%@ %@", selectedUnit.carpetArea!.description,selectedUnit.capetAreaUOM!)
        }
        let number = selectedUnit.balconyArea
        if((number?.doubleValue)! > 0.0){ //balcony Area
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Balcony Area:"
            let groupID = selectedUnit.company_group
            if(groupID == "5c6f0627d2a2cb1f913a44e4"){
                unitInfoView1.leftLabel.text = "Carpet Area:"
            }
            unitInfoView1.rightLabel.text = String(format: "%@ %@", (selectedUnit.balconyArea?.description)!,selectedUnit.balconyAreaUOM!)
        }
        if(selectedUnit.bedRooms != nil && selectedUnit.bedRooms?.doubleValue ?? 0.0 > 0.0){ //Bedrooms
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "No.of Bedrooms:"
            unitInfoView1.rightLabel.text = String(format: "%@", selectedUnit.bedRooms?.description ?? "")
        }
        if(selectedUnit.bathRooms != nil && selectedUnit.bathRooms?.doubleValue ?? 0.0 > 0.0){ //Bathrooms
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "No.of Bathrooms:"
            unitInfoView1.rightLabel.text = String(format: "%@", selectedUnit.bathRooms?.description ?? "")
        }
        if(selectedUnit.carParksCount > 0){

            let carsPark = selectedUnit!.carParkings?.allObjects as! [UnitCarParks]
            var parkingString = ""
            let totalCarParks = carsPark.count
            var counter = 0
            if(totalCarParks == 1){
                for tempPark in carsPark{
                    if(tempPark.cType != nil){
                        let tempString = String(format: "%u (%@)", tempPark.count,tempPark.cType!.capitalizingFirstLetter())
                        parkingString.append(tempString)
                    }
                    else
                    {
                        continue
                    }
                }
            }else{
                for tempPark in carsPark{
                    if(tempPark.cType != nil){
                        counter += 1
                        var tempString = String(format: "%u (%@)", tempPark.count,tempPark.cType!.capitalizingFirstLetter())
                        if(counter != totalCarParks){
                            tempString.append(",")
                        }
                        parkingString.append(tempString)
                    }
                    else{
                        continue
                    }
                }
            }
//            print(parkingString)

            if(parkingString.count > 0){  // Car parking

                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false

                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]

                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)

                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                unitDetailsView.addConstraint(temperrr)

                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)

                lastView = unitInfoView1

                unitInfoView1.leftLabel.text =  "No.of Car Parks (Type):"//"Car Parking:"

                unitInfoView1.rightLabel.text = parkingString
            }
        }
        // show premium only , SOLD , BOOKED , HANDED OVER
         //|| selectedUnit.status == UNIT_STATUS.SOLD.rawValue
        if(selectedUnit.status == UNIT_STATUS.VACANT.rawValue || selectedUnit.status == UNIT_STATUS.RESERVED.rawValue || selectedUnit.status == UNIT_STATUS.BLOCKED.rawValue || selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.HANDEDOVER.rawValue){  //(selectedUnit.bookingform == nil)
            
            let saleValue : Double = selectedUnit.salevalue
            let unitRate : Double = selectedUnit.rate
            
            let premiumValue = saleValue - unitRate
            
            if(self.bookingFormOutput  == nil && selectedUnit.salevalue > 0 && selectedUnit.rate > 0 && premiumValue > 0.0 && (selectedUnit.salevalue - selectedUnit.rate) > 0.0){  // Premium Value
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                shouldAddGap = false
                
                unitInfoView1.leftLabel.text = "Premium Value:"

                let premiumValue = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, selectedUnit.salevalue - selectedUnit.rate)
                unitInfoView1.rightLabel.text = premiumValue
                
//                if(self.bookingFormOutput.booking?.unitRate?.pBes?.total != nil){
//                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, (self.bookingFormOutput.booking?.unitRate?.pBes?.total)!)
//                }
                
            }
            
            var premiumUnitsString = ""
            
            if(selectedUnit.floorPremium != nil)
            {
                premiumUnitsString.append(selectedUnit.floorPremium!)
            }
            var counterForNewLine = 0
            if(selectedUnit.otherPremiumsCount > 0){

                for tempUnit in selectedUnit.otherPremiums!
                {
                    counterForNewLine = counterForNewLine + 1
                    if(premiumUnitsString.count > 0)
                    {
                        premiumUnitsString.append("\n")
                        premiumUnitsString.append(tempUnit)
                    }
                    else
                    {
                        premiumUnitsString.append(tempUnit)

                        if(counterForNewLine < (selectedUnit.otherPremiums?.count)!){
                            premiumUnitsString.append("\n")
                        }
                    }
                    //                premiumUnitsString.append("\n")
                }
            }
            
            if(premiumUnitsString.count > 0 && self.bookingFormOutput  == nil)
            {
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Premium Elements:"
                
//                let premiumValue = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, selectedUnit.salevalue! - selectedUnit.rate!)
                unitInfoView1.rightLabel.text = premiumUnitsString
            }

//            if(selectedUnit.floorPremium != nil){  // Premium Value
//
//                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
//                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
//
//                unitDetailsView.addSubview(unitInfoView1)
//                let bindings = ["unitInfoView1" : unitInfoView1]
//
//                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
//                unitDetailsView.addConstraints(layoutConstraint)
//
//                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 20.0)
//                unitDetailsView.addConstraint(temperrr)
//
//                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
//                unitDetailsView.addConstraint(height)
//
//                lastView = unitInfoView1
//
//                unitInfoView1.leftLabel.text = "Premium Value:"
//
//                let premiumValue = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, selectedUnit.salevalue - selectedUnit.rate)
//                unitInfoView1.rightLabel.text = premiumValue
//            }
            
            if(selectedUnit.rate > 0.0 && self.bookingFormDetails == nil){  // Unit cost //|| selectedUnit.rate == nil //selectedUnit.rate != nil
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(temperrr)
                
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Unit Cost:"
                if(selectedUnit.rate != nil && selectedUnit.rate > Double(0.0)){
                    let premiumValue = selectedUnit.rate
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)
                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,premiumValue )
                }else{
                    unitInfoView1.rightLabel.text = String(format: "%@ 0.00 ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!)
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)

                }
            }
            if(selectedUnit.salevalue != nil && selectedUnit.salevalue > Double(0.0) && self.bookingFormDetails == nil){  // Total unit cost excl taxes
            
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                unitDetailsView.addConstraint(temperrr)
                
            
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Total Unit Cost(excl. taxes):"
                if(selectedUnit.salevalue != nil && selectedUnit.salevalue > Double(0.0)){
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)

                    let premiumValue = selectedUnit.salevalue
                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,premiumValue)
                }
                else{
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 40.0)
                    unitDetailsView.addConstraint(height)

                    unitInfoView1.rightLabel.text = String(format: "%@ 0.00",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!)
                }
            }
            if(selectedUnit.totalCost != nil && selectedUnit.totalCost > Double(0.0) && self.bookingFormDetails == nil){  // Total unit cost incl taxes
            
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                unitDetailsView.addConstraint(temperrr)
                
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Total Unit Cost(incl. taxes):"
            
                if(selectedUnit.totalCost > 0.0){
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)

                    let premiumValue = selectedUnit.totalCost
                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,premiumValue)
                }else{
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 40.0)
                    unitDetailsView.addConstraint(height)

                    unitInfoView1.rightLabel.text = String(format: "%@ 0.00 ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!)
                }
            
            }
            let zeroCheck = 0.0
            if(selectedUnit.agreeValItemRate != nil && selectedUnit.agreeValItemRate > zeroCheck && self.bookingFormDetails == nil ){  // agreement value
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Agreement Value:"
                let premiumValue = selectedUnit.agreeValItemRate
                unitInfoView1.rightLabel.text = String(format: "%@ %.2f ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,premiumValue)
            }
//            if(lastView != nil){
//
//                let temperrr = NSLayoutConstraint.init(item: lastView!, attribute: .bottom, relatedBy: .equal, toItem: unitDetailsView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
//                unitDetailsView.addConstraint(temperrr)
//
//                unitDetailsView.layoutSubviews()
//                unitDetailsView.layoutIfNeeded()
////                return
//            }
//            else{
//
//            }
//            return
        }
        else{
            
        }
        
        if(self.bookingFormDetails == nil && lastView != nil){
            let temperrr = NSLayoutConstraint.init(item: lastView!, attribute: .bottom, relatedBy: .equal, toItem: unitDetailsView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(temperrr)
            
            unitDetailsView.layoutSubviews()
            unitDetailsView.layoutIfNeeded()
            return
        }
        
        if(self.bookingFormDetails != nil && self.bookingFormDetails.unitRate?.pBes?.total != nil && (self.bookingFormDetails.unitRate?.pBes?.total)! > Double(0.0)){  // Premium Value
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Premium Value:"
            let premiumValue = self.bookingFormDetails.unitRate?.pBes?.total!
            unitInfoView1.rightLabel.text = String(format: "%@ %.2f ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, premiumValue ?? "")
            
        }
        if(self.bookingFormDetails.unitRate?.pBes != nil && self.bookingFormDetails.unitRate?.pBes?.discountTotal != nil && self.bookingFormDetails.unitRate!.pBes!.discountTotal! > 0.0){
            
            if(self.bookingFormDetails.unitRate?.pBes?.discountTotal != nil){  // Discount Total
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Discount:"
                let premiumValue = self.bookingFormDetails.unitRate?.pBes?.discountTotal!
                unitInfoView1.rightLabel.text = String(format: "%@ %.2f ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, premiumValue ?? "")
                
            }
            if(self.bookingFormDetails.unitRate?.pBes?.finalTotal != nil){  // Revised Premium Value //finalTotal
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Revised Premium Value:"
                let premiumValue = self.bookingFormDetails.unitRate?.pBes?.finalTotal!
                unitInfoView1.rightLabel.text = String(format: "%@ %.2f ", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,premiumValue ?? "")
            }
        }
        
        
        
        var premiumUnitsString = ""
        
        // Get from booking id and take from unitRAte
        
        let billingElements : [P_BILLING_ELEMENTS] = self.bookingFormDetails.unitRate?.pBes?.pDetails! ?? []
        
        for tempElement in billingElements{
//            print(tempElement.details ?? "")
            
            let billingElement : PELEMENT = tempElement.pElement!
//            print(billingElement.name!)
            premiumUnitsString.append(billingElement.name!)
            premiumUnitsString.append("\n")
            
        }
        
        if(premiumUnitsString.count > 0){  // Premium Elements:
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Premium Elements:"
            unitInfoView1.rightLabel.text = String(format: "%@",premiumUnitsString)
            
        }
        
        //        let elementDetails : BILLING_ELEMENT_DETAILS = self.bookingFormDetails.unitRate?.bes?.details![0]
        
        //        let besElementRate : BILLING_ELEMENT_DETAILS =  self.bookingFormDetails.unitRate!.bes!.total //self.bookingFormDetails.unitRate!.bes!.details![0]
        
        if(self.bookingFormDetails.unitRate?.bes?.total != nil){  // Unit cost
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            var constant : CGFloat = 1.0
            if(shouldAddGap){
                constant = 20.0
            }
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: constant)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Unit Cost:"
            let premiumValue = self.bookingFormDetails.unitRate!.bes!.total
            unitInfoView1.rightLabel.text = String(format: "%@ %.2f ",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, premiumValue ?? "")
        }
        var tempTopConstraint = 1.0

        if(self.bookingFormDetails.unitRate != nil){
            
            if(self.bookingFormDetails.unitRate!.bes != nil && self.bookingFormDetails.unitRate!.bes!.discountTotal != nil && self.bookingFormDetails.unitRate!.bes!.discountTotal! > 0.0){
                if(self.bookingFormDetails.unitRate!.bes!.discountTotal != nil){  // Discount Value
                    
                    let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                    unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                    
                    unitDetailsView.addSubview(unitInfoView1)
                    let bindings = ["unitInfoView1" : unitInfoView1]
                    
                    let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                    unitDetailsView.addConstraints(layoutConstraint)
                    
                    let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                    unitDetailsView.addConstraint(temperrr)
                    
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)
                    
                    lastView = unitInfoView1
                    
                    unitInfoView1.leftLabel.text = "Discount:"
                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,self.bookingFormDetails.unitRate!.bes!.discountTotal!)
                }
                if(self.bookingFormDetails.unitRate!.bes!.finalTotal != nil){  // Revised Unit cost
                    
                    let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                    unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                    
                    unitDetailsView.addSubview(unitInfoView1)
                    let bindings = ["unitInfoView1" : unitInfoView1]
                    
                    let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                    unitDetailsView.addConstraints(layoutConstraint)
                    
                    let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                    unitDetailsView.addConstraint(temperrr)
                    
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)
                    
                    lastView = unitInfoView1
                    
                    unitInfoView1.leftLabel.text = "Revised Unit Cost:"
                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,self.bookingFormDetails.unitRate!.bes!.finalTotal!)
                }
                tempTopConstraint = 20.0
            }
            
            
            if(self.bookingFormDetails.unitRate!.total != nil){  // Total Unit Cost excl.taxes
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: CGFloat(tempTopConstraint))
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Total Unit Cost (excl.taxes):"
                unitInfoView1.rightLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,self.bookingFormDetails.unitRate!.total!)
            }
        
            if(self.bookingFormDetails.unitRate!.discountTotal != nil && self.bookingFormDetails.unitRate!.discountTotal! > 0.0){  // Discount on taxes
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Discount:"
                unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,self.bookingFormDetails.unitRate!.discountTotal!)
            }
            
            if(self.bookingFormDetails.unitRate!.finalTotal != nil && self.bookingFormDetails.unitRate!.total != self.bookingFormDetails.unitRate!.finalTotal){  // Revised Unit Cost (excl.taxes)
                
                
                if(selectedUnit.salevalue == self.bookingFormDetails.unitRate!.finalTotal!){
                    tempTopConstraint = 1.0
                }
                else
                {
                    let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                    unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                    
                    unitDetailsView.addSubview(unitInfoView1)
                    let bindings = ["unitInfoView1" : unitInfoView1]
                    
                    let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                    unitDetailsView.addConstraints(layoutConstraint)
                    
                    let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                    unitDetailsView.addConstraint(temperrr)
                    
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)
                    
                    lastView = unitInfoView1
                    
                    unitInfoView1.leftLabel.text = "Revised Unit Cost (excl.taxes):"
                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,self.bookingFormDetails.unitRate!.finalTotal!)
                    
                    tempTopConstraint = 20
                }
                
                
                
            }
            
            if(self.bookingFormDetails.unitRate!.total != nil && self.bookingFormOutput.tax?.total != nil){  // Total Unit Cost (incl.taxes)
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: CGFloat(tempTopConstraint))
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Total Unit Cost (incl.taxes):"
                unitInfoView1.rightLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, (self.bookingFormDetails.unitRate!.total! + self.bookingFormOutput.tax!.total!))
            }
            
            //discountTotal
            if(self.bookingFormDetails.unitRate!.discountTotal != nil){  // Discount
                
                let unitCostIncludingTaxes = self.bookingFormDetails.unitRate!.finalTotal! + self.bookingFormOutput.tax!.finalTotal!
                
                let unitDiscount = (self.bookingFormDetails.unitRate!.total! + self.bookingFormOutput.tax!.total!) - unitCostIncludingTaxes

                if(unitDiscount > 0.0)
                {
                    let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                    unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                    
                    unitDetailsView.addSubview(unitInfoView1)
                    let bindings = ["unitInfoView1" : unitInfoView1]
                    
                    let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                    unitDetailsView.addConstraints(layoutConstraint)
                    
                    let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                    unitDetailsView.addConstraint(temperrr)
                    
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)
                    
                    lastView = unitInfoView1
                    
                    unitInfoView1.leftLabel.text = "Discount:"
                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, unitDiscount) //self.bookingFormDetails.unitRate!.discountTotal!

                }
            }
            
            if(self.bookingFormDetails.unitRate!.discountTotal != nil && (self.bookingFormDetails.unitRate!.total != nil && self.bookingFormOutput.tax!.total != nil)){  // Revised Unit Cost (incl.taxes)
                
                let unitCostIncludingTaxes = self.bookingFormDetails.unitRate!.finalTotal! + self.bookingFormOutput.tax!.finalTotal!
                
                let discount = (self.bookingFormDetails.unitRate!.total! + self.bookingFormOutput.tax!.total!) - unitCostIncludingTaxes

                if(discount > 0.0){
                    
                    let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                    unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                    
                    unitDetailsView.addSubview(unitInfoView1)
                    let bindings = ["unitInfoView1" : unitInfoView1]
                    
                    let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                    unitDetailsView.addConstraints(layoutConstraint)
                    
                    let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                    unitDetailsView.addConstraint(temperrr)
                    
                    let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                    unitDetailsView.addConstraint(height)
                    
                    lastView = unitInfoView1
                    
                    unitInfoView1.leftLabel.text = "Revised Unit Cost (incl.taxes):"
                    //                let totalUnitCost = (self.bookingFormDetails.unitRate!.total! + self.bookingFormOutput.tax!.total!) - self.bookingFormDetails.unitRate!.discountTotal!
                    unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,unitCostIncludingTaxes)
                    
                    tempTopConstraint = 20.0
                }
                else{
                    tempTopConstraint = 1.0
                }
            }
        }
        
        
        if(self.bookingFormOutput.agVal?.total != nil && self.bookingFormOutput.agVal!.total! > 0.0 ){  // agreement value
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: CGFloat(tempTopConstraint))
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Agreement Value:"
            unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,self.bookingFormOutput.agVal!.total!)
        }
        let discount = Double(self.bookingFormOutput.agVal!.total!) - Double(self.bookingFormOutput.agVal!.finalTotal!)
        if(discount > 0.0){  // Discount
            
            let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
            unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
            
            unitDetailsView.addSubview(unitInfoView1)
            let bindings = ["unitInfoView1" : unitInfoView1]
            
            let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
            unitDetailsView.addConstraints(layoutConstraint)
            
            let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(temperrr)
            
            let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
            unitDetailsView.addConstraint(height)
            
            lastView = unitInfoView1
            
            unitInfoView1.leftLabel.text = "Discount:"
            let discountAmt =  Double(self.bookingFormOutput.agVal!.total!) - Double(self.bookingFormOutput.agVal!.finalTotal!)
            unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,discountAmt)
        }
        if(self.bookingFormOutput.agVal!.finalTotal != nil && self.bookingFormOutput.agVal!.finalTotal! > 0.0){  // Revised agreement value  finalTotal
            
            let revisedAGValue = self.bookingFormOutput.agVal!.total! - self.bookingFormOutput.agVal!.finalTotal!
            
            if(revisedAGValue > 0.0){
                
                let unitInfoView1 : UnitInfoView = UnitInfoView.instanceFromNib() as! UnitInfoView
                unitInfoView1.translatesAutoresizingMaskIntoConstraints = false
                
                unitDetailsView.addSubview(unitInfoView1)
                let bindings = ["unitInfoView1" : unitInfoView1]
                
                let layoutConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(12)-[unitInfoView1]-(12)-|", options: [], metrics: nil, views: bindings)
                //H:|-(8)-
                unitDetailsView.addConstraints(layoutConstraint)
                
                let temperrr = NSLayoutConstraint.init(item: unitInfoView1, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
                unitDetailsView.addConstraint(temperrr)
                
                let height = NSLayoutConstraint.init(item: unitInfoView1, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
                unitDetailsView.addConstraint(height)
                
                lastView = unitInfoView1
                
                unitInfoView1.leftLabel.text = "Revised Agreement Value:"
                unitInfoView1.rightLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,self.bookingFormOutput.agVal!.finalTotal!)

            }else{
                
            }
        }
        if(lastView != nil){
            
            let temperrr = NSLayoutConstraint.init(item: lastView!, attribute: .bottom, relatedBy: .equal, toItem: unitDetailsView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
            unitDetailsView.addConstraint(temperrr)
            
            unitDetailsView.layoutSubviews()
            unitDetailsView.layoutIfNeeded()
            
        }
        else{
            
        }

//        let temperrr = NSLayoutConstraint.init(item: lastView!, attribute: .bottom, relatedBy: .equal, toItem: unitDetailsView, attribute: .bottom, multiplier: 1.0, constant: 1.0)
//        unitDetailsView.addConstraint(temperrr)
//        
//        unitDetailsView.layoutSubviews()
//        unitDetailsView.layoutIfNeeded()
        
    }
    @IBAction func viewFloorPlan(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let floorPlanController = storyboard.instantiateViewController(withIdentifier :"floorPlan") as! FloorPlanViewController
        floorPlanController.planType = PLAN_TYPE.FLOOR_PLAN
//        floorPlanController.floorPlans = selectedUnit.type?.floorPlan ?? []
        floorPlanController.floorPlans = selectedUnit.floorPlanImages as! [String]
        
        self.navigationController?.pushViewController(floorPlanController, animated: true)
    }
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    @objc func revokeReservation(_ sender : UIButton){
        
        let selectedRsrvIndex = sender.tag
        
        if(self.reservationsTableViewDataSource.count == 1){
            self.revokeAll(sender)
        }
        else{
            self.revokeSelectedReservation(selectedIndex: selectedRsrvIndex)
        }
    }
    @IBAction func revokeAll(_ sender: Any) {
        
        //delete all Reservations
        
        //array of reservations to revoke
        
        self.revokeAllReservations()

    }
    @IBAction func showUnitCostBreakUp(_ sender: Any) {
        
        let quickController = QuickLinksViewController(nibName: "QuickLinksViewController", bundle: nil)
        quickController.cellType = TabelViewCellType.UNIT_COST_BREAKUP
        
        
        var unitRate : UNIT_RATE! = self.bookingFormOutput?.booking?.unitRate ?? nil
        
        unitRate?.bes?.details?.sort(by: { $0.element?.viewIndex ?? 0 < $1.element?.viewIndex ?? 0 })
        unitRate.pBes?.pDetails?.sort(by: { $0.pElement?.viewIndex ?? 0 < $1.pElement?.viewIndex ?? 0 })
        
        quickController.unitRate = unitRate // self.bookingFormOutput?.booking?.unitRate ?? nil
        quickController.selectedUnitStatus = UNIT_STATUS(rawValue: Int(selectedUnit.status))
        self.showFloatingPanel(controller: quickController)
    }
    // MARK: - Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reservationsTableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ReservationTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "reservQueueCell",
            for: indexPath) as! ReservationTableViewCell
        
        let reservation : RESERVED_UNITS = self.reservationsTableViewDataSource[indexPath.row]
        
        cell.reservationHolderNameLabel.text = String(format: "%@",(reservation.prospect?.userName)!)
        cell.queuePositionLabel.text = String(format: "#%d", indexPath.row + 1)
        
        let tempUpdate = reservation.updateBy?.last
        
        let userInfo = tempUpdate?.user!.userInfo
        
        if(userInfo?.name != nil && (userInfo?.name?.count)! > 0){
            cell.reservedByLabel.text = String(format: "%@", userInfo!.name ?? "")
        }
        else{
            cell.reservedByLabel.text = String(format: "%@", "Super admin")
        }        
        cell.revokeButton.addTarget(self, action: #selector(revokeReservation(_:)), for: .touchUpInside)
        cell.revokeButton.tag = indexPath.row
        
        cell.addReceiptButton.addTarget(self, action: #selector(showAddReceipt(_:)), for: .touchUpInside)
        cell.addReceiptButton.tag = indexPath.row
        
        let fromDate = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: reservation.reserveDate!)
        let toDate = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: reservation.expiryDate!)
        
        cell.fromDateLabel.text = fromDate
        cell.toDateLabel.text = toDate
        
        return cell
    }
    
    // MARK:- URL CALLS
    
    @IBAction func blockOrReleaseUnit(_ sender: Any) {
        
        var blockedUnitDetails : Dictionary<String,Any> = [:]
        
        blockedUnitDetails["_id"] = selectedUnit.id
        
        let button = sender as! UIButton
        
        if(button.tag == 1)
        {
            blockedUnitDetails["status"] = UNIT_STATUS.BLOCKED.rawValue //selectedUnit.status
        }
        else{
            blockedUnitDetails["status"] = UNIT_STATUS.VACANT.rawValue //selectedUnit.status
            
            if(selectedUnit.status == UNIT_STATUS.VACANT.rawValue){
                HUD.flash(.label("Can't release vacant unit"), delay: 1.0)
                return
            }
        }
        
        if(button.tag == 1){
            if(self.selectedBlockingReason == "None"){
                HUD.flash(.label("Select Blocking Reason"), delay: 1.0)
                return
            }
            blockedUnitDetails["blockingReason"] = self.selectedBlockingReason
            
            if(self.selectedBlockingReason.count == 0){
                HUD.flash(.label("Select Blocking Reason"), delay: 1.0)
                return
            }
        }
        
        var blockedUnitsArray : Array<Dictionary<String,Any>> = []
        blockedUnitsArray.append(blockedUnitDetails)
        
//        print(blockedUnitDetails)
//        print(blockedUnitsArray)
        
        var parameters : Dictionary<String,Any> = [:]
        
        parameters["units"] = blockedUnitsArray
        
        ServerAPIs.blockOrReleaseSelectedUnit(parameters: parameters, tag: button.tag, completionHandler: ({ responseObject , error in
            
            if(responseObject != nil){
                
                if(responseObject?.status == 1){
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_UNIT_DETAILS), object: nil)
                    if(button.tag == 1){
                        self.updateUnitStatusInDatabase(unitStatus: UNIT_STATUS.BLOCKED.rawValue)
                        HUD.flash(.label("UNIT BLOCKED SUCCESSFULLY"), delay: 1.0)
                        self.unitStatusDelegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.BLOCKED.rawValue)
                    }
                    else{
                        self.updateUnitStatusInDatabase(unitStatus: UNIT_STATUS.VACANT.rawValue)
                        HUD.flash(.label("UNIT RELEASED SUCCESSFULLY"), delay: 1.0)
                        self.unitStatusDelegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.VACANT.rawValue)
                        
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else{
                
            }
        }))
    }
    func updateUnitStatusInDatabase(unitStatus : Int){
        
        RRUtilities.sharedInstance.model.updateStatusOfSelectedUnit(selectedProjectId: selectedUnit.project!, oldStatus: Int(selectedUnit.status),updatedStatus: unitStatus)
        
        let unitDetsils = RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: selectedUnit.id!)
        
        let childContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = RRUtilities.sharedInstance.model.managedObjectContext
        
        let childEntry = childContext.object(
            with: unitDetsils!.objectID) as? Units
        
        childEntry?.status = Int64(unitStatus)
        childEntry?.blockingReason = self.selectedBlockingReason
        
        childContext.perform {
            do {
                try childContext.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            RRUtilities.sharedInstance.model.saveContext()
        }
    }
    @IBAction func save(_ sender: Any) {
        
        print("You should write save action ?")
//        HUD.flash(.label("YET TO IMPLEMENT RAISE BUG"), delay: 1.0)
        self.bookUnit(sender)
    }
    @IBAction func bookUnit(_ sender: Any){
        
        var bookingDetailsDict = Dictionary<String,Any>()
        
        if(self.selectedProspect != nil && phoneNumberTextField.text?.count == 0){
            HUD.flash(.label("Please enter phone number"))
            return
        }
        if(self.selectedProspect != nil && nameTextField.text?.count == 0){
            HUD.flash(.label("Please enter customer name"))
            return
        }
        if(self.selectedProspect != nil && (emailTextField.text?.count)! > 0){
            if(RRUtilities.sharedInstance.isValidEmail(emailID: emailTextField.text!) == false){
                HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
                return
            }
        }
        
        if(self.selectedProspect != nil && !self.isCountryCodeValid(countryCode: countryCodeTextField.text!,isAlternate: false)){
            HUD.flash(.label("Please enter proper country code"), delay: 1.0)
            return
        }
        
        /*
         
         val CUSTOMER_ID = "_id"
         val PROSPECT_ID = "pId"
         val REG_INFO = "regInfo"
         val CLIENT_ID = "clientId"
         val CUSTOMER_LOCAL_ID = "bookingLocalId"
         val COUNTRY_CODE = "countryCode"
         val CUSTOMER_NAME = "name"
         val CUSTOMER_PHONE = "phone"
         val CUSTOMER_EMAIL = "email"
         val CUSTOMER_COMMENTS = "comments"
         val DISCOUNT = "discount"
         val BOOKING_DATE = "bookingDate"
         val SALE_DEED_DATE = "saleDeedDate"
         val AGREEMENT_DATE = "agreementDate"
         val PRELIMS_POSSESSION_DATE = "prelimsPossessionDate"
         val FINAL_POSSESSION_DATE = "finalPossessionDate"
         val UNIT_ID = "unit"
         val BLOCK_ID = "block"
         val TOWER_ID = "tower"
         val PROJECT_ID = "project"
         val SYNC_VALUE = "sync"
         val UPDATED_STATUS = "updatedStatus"
 */
        if(selectedProspect == nil){
            bookingDetailsDict["_id"] = selectedUnit.id
            bookingDetailsDict["prospectName"] = selectedProspect?.userName
        }
        
//        unitNo, unitDescription, projectName, prospectName
        
        bookingDetailsDict["unitNo"] = String(format: "%d", selectedUnit.unitIndex)
        bookingDetailsDict["unitDescription"] = selectedUnit.description1
        bookingDetailsDict["projectName"] = selectedUnit.project
        
        bookingDetailsDict["phone"] = phoneNumberTextField.text!
        bookingDetailsDict["email"] = emailTextField.text!
        bookingDetailsDict["comments"] = commentsTextView.text!
        bookingDetailsDict["name"] = nameTextField.text!
        bookingDetailsDict["countryCode"] = countryCodeTextField.text!
        
        bookingDetailsDict["unit"] = selectedUnit.id //self.bookingFormOutput.booking?.unitRate?.unit
        bookingDetailsDict["block"] = selectedUnit.block
        bookingDetailsDict["tower"] = selectedUnit.tower
        bookingDetailsDict["project"] = selectedUnit.project
        
        if(selectedProspect != nil){
            bookingDetailsDict["pId"] = selectedProspect.prospectId ?? ""
            bookingDetailsDict["regInfo"] = selectedProspect.regInfo
            bookingDetailsDict["_id"] = selectedProspect._id
        }
        
        
        if(selectedBookingDate == nil){
            bookingDetailsDict["bookingDate"] = self.bookingFormOutput.booking?.bookingDate
        }
        else{
            bookingDetailsDict["bookingDate"] = Formatter.ISO8601.string(from: selectedBookingDate)
//            print(Formatter.ISO8601.string(from: selectedBookingDate))
        }
        bookingDetailsDict["customerLocalId"] = self.bookingFormOutput.booking?.bookingLocalId
        
        if(self.selectedScheme != nil){
            bookingDetailsDict["scheme"] = self.selectedScheme.id
        }
        
        if(self.agreeentDateTimeStamp != nil && self.agreeentDateTimeStamp.count > 0){
            bookingDetailsDict["agreementDate"] = self.agreeentDateTimeStamp
        }
        
        var cleintID = ""
        if(selectedProspect == nil){
            if(selectedUnit.clientId != nil){
                bookingDetailsDict["clientId"] = selectedUnit.clientId
                cleintID = selectedUnit.clientId!
                bookingDetailsDict["_id"] = self.bookingFormOutput.booking?._id
                //            requestBody.put(Booking.CUSTOMER_ID, bookingDetail._id)
                
            }
            else{
                if(self.bookingFormOutput.booking?.clients?.count ?? 0 > 0){
                    let tempClient : ClientList = (self.bookingFormOutput.booking?.clients![0])!
                    let clientID =  tempClient.customer?.clientId
                    cleintID = clientID!
                    bookingDetailsDict["clientId"] = clientID
                    bookingDetailsDict["_id"] = self.bookingFormOutput.booking?._id
                }
            }
        }
//        else{
//
//            let tempClient : ClientList = (self.bookingFormOutput.booking?.clients![0])!
//            let clientID =  tempClient.customer?.clientId
//            cleintID = clientID!
//            bookingDetailsDict["clientId"] = clientID
//            bookingDetailsDict["_id"] = self.bookingFormOutput.booking?._id
//        }
        
        /*
         
         val CUSTOMER_ID = "_id"
         val CUSTOMER_LOCAL_ID = "customerLocalId"
         val COUNTRY_CODE = "countryCode"
         val CUSTOMER_NAME = "name"
         val CUSTOMER_PHONE = "phone"
         val CUSTOMER_EMAIL = "email"
         val CUSTOMER_COMMENTS = "comments"
         val DISCOUNT = "discount"
         val BOOKING_DATE = "bookingDate"
         val SALE_DEED_DATE = "saleDeedDate"
         val AGREEMENT_DATE = "agreementDate"
         val PRELIMS_POSSESSION_DATE = "prelimsPossessionDate"
         val FINAL_POSSESSION_DATE = "finalPossessionDate"
         val UNIT_ID = "unit"
         val BLOCK_ID = "block"
         val TOWER_ID = "tower"
         val PROJECT_ID = "project"
         val SYNC_VALUE = "sync"
         */

//        print(bookingDetailsDict)
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
//        print(bookingDetailsDict)
        bookingDetailsDict["src"] = 3
        
//        let urlString = (cleintID.count == 0) ? RRAPI.BOOK_UNIT : RRAPI.BOOK_UNIT_EDIT
        
        var urlString = ""
        
        if(selectedProspect != nil){
            urlString = RRAPI.BOOK_UNIT
        }
        else{
            urlString = RRAPI.BOOK_UNIT_EDIT
        }
        
        print(urlString)
        //            if(selectedUnit.clientId == nil){
        ////                urlString =
        //            }
        
        HUD.show(.progress)
        
        AF.request(urlString, method: .post, parameters: bookingDetailsDict, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success:
//                print(response)
                guard response.data != nil else {
                    print("Error: did not receive data")
                    return
                }
                do{
                    let urlResult = try JSONDecoder().decode(BOOK_UNIT_RESULT.self, from: response.data!)
                    HUD.hide()
                    
                    //                print(urlResult)
                    
                    if(urlResult.status == 1){ //success
                        // store the client id
                        // pass client id and
                        //                    print(urlResult.data?.clientId)
//                        print(self.indexPathOfSelectedUnit)
                        self.delegate?.didFinishBookUnit(clientId: (urlResult.data?.clientId) ?? "", bookedUnit: self.selectedUnit,selectedIndexPath: self.indexPathOfSelectedUnit ?? IndexPath(item: 0, section: 0))
                        HUD.flash(.label("Booking details updated"), delay: 1.5)
                        if(self.selectedProspect == nil){
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else{
                        HUD.flash(.label("Couldn't book unit try again!"))
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
        //        bookingDetailsDict["sync"] = selectedUnit.status
        
        //        bookingDetailsDict["customerLocalId"] = UDID
        
    }
    func getAgreementDate(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]

        let urlString = String(format: RRAPI.API_GET_TRACKER_DETAILS, selectedUnit.id!,AGREEMENT_TYPES.Sales_Agreement) //passing
        print(urlString)
        
        HUD.show(.progress)

        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(AST_DETAILS.self, from: responseData)
                    
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        
                        let tempAST =  urlResult.astInfo!.ast!.filter({ ($0.name!.localizedCaseInsensitiveContains("Final Agreement Sent to Customer"))})
//                        print(tempAST)
                        if(tempAST.count == 1 && tempAST[0].dates != nil){
//                            print(tempAST[0].dates![0])
                            let dates = tempAST[0].dates
                            if(dates!.count >= 1){
                                self.agreeentDateTimeStamp = tempAST[0].dates![0]
                                let agreementDate = RRUtilities.sharedInstance.getDateWithEnglishWord(dateStr: tempAST[0].dates![0])
//                                print(agreementDate)
                                self.dateOfAgreementLabel.text = agreementDate
                            }
                        }
                        else{
                            self.dateOfAgreementLabel.text = "-"
                            
                        }
                    }
                    else if(urlResult.status == 0){
                        
                    }
                    else{
                        
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
    func getBookingFormInfo(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var parameters : Dictionary<String,String> = [:]
        
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue || selectedUnit.status == UNIT_STATUS.HANDEDOVER.rawValue){
            if(selectedUnit.bookingFormID != nil){
                //                print(selectedUnit.bookingform)
                parameters["bookingform"] = selectedUnit.bookingFormID
            }
            else{
                HUD.flash(.label("Booking form not linked"), delay: 1.5)
                self.buildUnitDetailsView()
                self.setUpQuickLinks()
                self.shouldShowSalesPersonInfo(shoudlShow: true)
                self.shouldShowAgreementDateView(shouldShow: false)
                self.shouldShowSaveButton(shouldShow: false)
                return
            }
        }
        else{
            self.buildUnitDetailsView()
            self.setUpQuickLinks()
            self.shouldShowAgreementDateView(shouldShow: false)
            return
        }
//        print(parameters)
        
        let urlString = String(format: RRAPI.API_UNIT_BOOKING_INFO, selectedUnit.bookingFormID!)
        print(urlString)
        
        HUD.show(.progress)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(BOOKING_FORM_RESULT.self, from: responseData)
                    
                    self.bookingFormOutput = urlResult

//                    self.bookingFormOutput.
//                    print(urlResult)
                    //                    if(urlResult.booking!.unitRate == nil){
                    //                        return
                    //                    }
                    if(urlResult.status == 1){
                        //                        let pBes : PREMIUM_BILLING_ELEMENTS = urlResult.booking!.unitRate!.pBes!
                        //                        let unitRate = urlResult.booking!.unitRate!
                        
                        let bookingDate = urlResult.booking?.bookingDate
                        self.bookingFormDetails = urlResult.booking!
                        //bookingDate
                        let dateString = RRUtilities.sharedInstance.getDateWithEnglishWord(dateStr: bookingDate!)
                        //                        let dateString = Formatter.ISO8601.string(from: Date())   // "2018-01-23T03:06:46.232Z"
                        
                        self.bookingDateTextField.text = dateString

                        if(self.bookingFormDetails.scheme != nil){
                            self.shouldShowSchemeInfo(shouldShow: true)
                            self.selectedSchemeLabel.text = self.bookingFormDetails.scheme?.name
                        }
                        else{
                            self.shouldShowSchemeInfo(shouldShow: false)
                        }
                        
                        
                        let clientList = urlResult.booking?.clients
                        self.clientsArray.removeAll()
                        self.clientsArray = urlResult.booking?.clients ?? []
                        if(self.clientsArray.count > 0){
                            self.ownersCountInfoLabel.text = String(format: "Owners (%d)", self.clientsArray.count)
                            self.collectionView.delegate = self
                            self.collectionView.dataSource = self
                            self.collectionView.reloadData()
                        }
                        
                        if((clientList?.count)! > 0){
                            
//                            let tempClient : ClientList = clientList![0]
//                            let client : Client =  tempClient.client
//                            if(client.phone != nil){
//                                self.phoneNumberTextField.text = client.phone
//                                self.emailTextField.text = client.email
//                                self.nameTextField.text = client.name
//                            }
                            self.commentsTextView.text = urlResult.booking!.comments
//                            self.countryCodeTextField.text = "91"
                            
                            if(self.selectedUnit.status == UNIT_STATUS.HANDEDOVER.rawValue){
                                
                                self.shouldShowSalesPersonInfo(shoudlShow: true)
                                self.shouldShowProspectDetailsView(shouldShow: true)
                                self.shouldShowBookingDetailsView(shouldShow: true)
                                self.shouldShowBlockingInfoView(shouldShow: false)
                                self.shouldShowReservationQueueView(shouldShow: false)
                                self.shouldShowAgreementDateView(shouldShow: true)
                                self.dateOfAgreementLabel.text = "-"
                                self.shouldShowQuickLinksView(shouldShow: true)
                                self.shouldShowSaveButton(shouldShow: false)
                            }
                            if(self.selectedUnit.status == UNIT_STATUS.SOLD.rawValue){
                                self.shouldShowSalesPersonInfo(shoudlShow: true)
                                self.shouldShowProspectDetailsView(shouldShow: true)
                                self.shouldShowBookingDetailsView(shouldShow: true)
                                self.shouldShowBlockingInfoView(shouldShow: false)
                                self.shouldShowReservationQueueView(shouldShow: false)
                                self.shouldShowAgreementDateView(shouldShow: true)
                                self.shouldShowQuickLinksView(shouldShow: true)
//                                print(self.selectedUnit)
                            }
                            if(self.selectedUnit.status == UNIT_STATUS.BOOKED.rawValue){
                                self.shouldShowSalesPersonInfo(shoudlShow: true)
                                self.shouldShowProspectDetailsView(shouldShow: true)
                                self.shouldShowBookingDetailsView(shouldShow: true)
                                self.shouldShowBlockingInfoView(shouldShow: false)
                                self.shouldShowReservationQueueView(shouldShow: false)
                                self.shouldShowAgreementDateView(shouldShow: true)
//                                self.saveButton.isHidden = false
                                self.shouldShowQuickLinksView(shouldShow: true)
                                self.shouldShowSaveButton(shouldShow: true)
                                
                                self.dateOfAgreementLabel.text = "-"
                            }
                            
                            //                            self.reservationQueueView.isHidden = false
                            self.buildUnitDetailsView()
                            
                            
                            //                            self.configureView()
                            
                        }
                        else{
                                self.shouldShowProspectDetailsView(shouldShow: false)
                                self.shouldShowSalesPersonInfo(shoudlShow: false)
                                self.buildUnitDetailsView()
                            
                        }
                        self.setUpQuickLinks()
                        
                        //                        self.actualPremiumValueLabel.text = String(format: "%d", pBes.total!)
                        //                        self.discountedPremiumValue.text = String(format: "%d", pBes.discountTotal!)
                        //                        self.finalPremiumValue.text = String(format: "%d", pBes.finalTotal!)
                        //
                        //                        self.actualUnitCostLabel.text = String(format: "%d", unitRate.total!)
                        //                        self.discountedUnitCostLabel.text = String(format: "%d", unitRate.discountTotal!)
                        //                        self.finalUnitCostLabel.text = String(format: "%d", unitRate.finalTotal!)
                    }
                    else if(urlResult.status == -1){
                        //Logout
                    }
                    else{ ///fail status
                        
                    }
                    
                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                    self.buildUnitDetailsView()
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                self.buildUnitDetailsView()
                break
            }
        }
        
    }
    func getReserations(){
        
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_RESERVATIONS_OF_UNIT, selectedUnit.id!)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(RESERVATIONS_API_RESULT.self, from: responseData)
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        
                        self.reservationsTableViewDataSource = urlResult.reservedUnits
                        //                        print(self.reservationsTableViewDataSource.count)
                        self.reservationsTableView.delegate = self
                        self.reservationsTableView.dataSource = self
                        self.reservationsTableView.reloadData()
                        self.reservationsTableView.layoutIfNeeded()
                        
                        if(self.reservationsTableViewDataSource.count == 0){
                            self.reservationQueueView.isHidden = true
                            self.unitStatusDelegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.VACANT.rawValue)
                        }
                        
                        //                        self.heightOfReservationView.constant = CGFloat((self.reservationsTableViewDataSource.count * 80))
                        self.reservationsTableView.heightAnchor.constraint(equalToConstant: self.reservationsTableView.contentSize.height).isActive = true
                        self.heightOfReservationView.constant = self.reservationsTableView.contentSize.height + 80
//                        print(self.reservationsTableView.contentSize.height)
                        
                        self.shouldShowSaveButton(shouldShow: false)
                    }
                    else if(urlResult.status == -1){
                        //Logout
                    }
                    else{ ///fail status
                        
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
    
    func revokeAllReservations(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_REVOKE_ALL_RESERVATIONS)
        
        var parameters : Dictionary<String,Any> = [:]
        
        var arrayOfRsrvIds : [String] = []
        
        for reseration in self.reservationsTableViewDataSource{
            arrayOfRsrvIds.append(reseration._id!)
        }
        
        parameters["rIds"] = arrayOfRsrvIds
        parameters["unit"] = selectedUnit.id
        
        parameters["unitNo"] = String(format: "%d", Int(selectedUnit.unitIndex))
        parameters["unitDescription"] = selectedUnit.description1
        parameters["projectName"] = selectedUnit.project
        parameters["src"] = 3
//        parameters["userName"] =

//        print(parameters)
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    HUD.hide()
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        //fetch all again // send notification to fetch again
                        
                        self.unitStatusDelegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.VACANT.rawValue)

                        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_UNIT_DETAILS), object: nil)
                        
                        self.navigationController?.popViewController(animated: true)
                        HUD.flash(.label("Reservation(s) revoked successfully."), delay: 2.0)
                    }
                    else if(urlResult.status == -1){
                        //Logout
                        HUD.flash(.label(urlResult.err), delay: 1.0)
                        
                    }
                    else{ ///fail status
                        HUD.flash(.label(urlResult.err), delay: 1.0)
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

    func revokeSelectedReservation(selectedIndex : Int){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_REVOKE_RESERVATION, selectedUnit.id!)
        
        
        // r_id  //r._id
        // next id
        var parameters : Dictionary<String,String> = [:]
        
        let selectedReservation = self.reservationsTableViewDataSource[selectedIndex]
        
        if(selectedIndex + 1 <= self.reservationsTableViewDataSource.count){
            let nextReservation = self.reservationsTableViewDataSource?[selectedIndex]
            parameters["nextRId"] = nextReservation?._id
        }
        
        parameters["rId"] = selectedReservation._id
        
        parameters["unitNo"] = String(format: "%d", Int(selectedUnit.unitIndex))
        parameters["unitDescription"] = selectedUnit.description1
        parameters["projectName"] = selectedUnit.project
        parameters["userName"] = selectedReservation.prospect?.userName
        parameters["src"] = "3"
        
//        print(parameters)
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        self.getReserations()
                    }
                    else if(urlResult.status == -1){
                        //Logout
                    }
                    else{ ///fail status
                        
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
    
    // MARK:- Textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if ((textField == bookingDateTextField)) {
            self.showDatePicker(textField: textField)
            return false
        }
        
        return true
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == self.phoneNumberTextField && countryCodeTextField.text == "91"){
            return textField.text!.count < 10 || string == ""
        }
        
        if(textField == self.countryCodeTextField){
            // perfomr search and update data source
            var isDelete = false
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    isDelete = true
                }
            }
            if(isDelete){
//                print(textField.text!)
                let tempStr = textField.text!.dropLast()
                self.showCountryCodePopUp(searchString: String(tempStr))
            }
            else{
                self.showCountryCodePopUp(searchString: textField.text! + string)
            }
            if(countryCodePopOver != nil && countryCodePopOver.mTableView != nil){
                countryCodePopOver.mTableView.reloadData()
            }
        }
        
        return true
    }
    func isCountryCodeValid(countryCode : String,isAlternate : Bool)->Bool{
        
        if(countryCodesArray.count == 0){
            let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
            countryCodesArray = NSMutableArray.init(contentsOfFile: path!)!
        }
        let predicate = NSPredicate.init(format: "dial_code CONTAINS[cd] %@",countryCode)
        let fileredArray : NSArray = self.countryCodesArray.filtered(using: predicate) as NSArray
        var arrayCounter = 0
        if(fileredArray.count > 0){
            for counter in 0...fileredArray.count-1{
                let tempDict : NSDictionary = fileredArray[counter] as! NSDictionary
                let tempCode = tempDict["dial_code"] as! String
                let code = tempCode.dropFirst()
                arrayCounter = arrayCounter + 1
                if(!isAlternate && String(code) == countryCodeTextField.text!){
                    return true
                }
            }
            return false
        }
        else{
            return false
        }
    }
    func showCountryCodePopUp(searchString : String){
        
        if(countryCodesArray.count == 0){
            let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
            countryCodesArray = NSMutableArray.init(contentsOfFile: path!)!
        }
        let predicate = NSPredicate.init(format: "name CONTAINS[cd] %@ || dial_code CONTAINS[cd] %@", searchString,searchString)
//        print(predicate)
        let fileredArray : NSArray = self.countryCodesArray.filtered(using: predicate) as NSArray
        
        if(fileredArray.count == 0){
            //dismiss
            print("Not found")
            self.hideCountryCodePopUp()
            return
        }
        
        if(countryCodePopOver == nil){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            countryCodePopOver = (storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController)
            countryCodePopOver.dataSourceType = .COUNTRY_CODE
            countryCodePopOver.preferredContentSize = CGSize(width:  300, height: (self.countryCodesArray.count - 1) * 44)
        }
        
        if(CGFloat((self.countryCodesArray.count * 44)) > (self.view.frame.size.height - 150)){
            countryCodePopOver.preferredContentSize = CGSize(width: 300, height: 300)
        }
        let navigationContoller = UINavigationController(rootViewController: countryCodePopOver)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        countryCodePopOver.countryCodeDataSouce = fileredArray
        
        popOver?.sourceView = countryCodeTextField
        
        countryCodePopOver.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    func didSelectScheme(selectedScheme: Schemes) {
        
        if(!RRUtilities.sharedInstance.getNetworkStatus()){
            HUD.flash(.label("Couldn't connect to internet"))
            return
        }
        
        self.schemeNameLabel.text = selectedScheme.name
        self.selectedScheme = selectedScheme
        HUD.show(.progress, onView: self.view)
        ServerAPIs.getUnitPreviewPrice(regInfo: "", unitID: selectedUnit.id!, scheme: selectedScheme.id ,completionHandler: {(bookingFormResult, error) in
            if(bookingFormResult?.status == 1){
                self.bookingFormOutput = bookingFormResult
                self.bookingFormDetails = bookingFormResult?.booking
                self.buildUnitDetailsView()
            }
            else{
                self.buildUnitDetailsView()
            }
            HUD.hide()
        })
        let tmpController :UIViewController! = self.presentedViewController;
        if(tmpController != nil){
            self.dismiss(animated: false, completion: {()->Void in
                tmpController.dismiss(animated: false, completion: nil);
            });
        }
    }
    func didSelectCountryCode(countryCode : String,countryName : String,forFieldIndex: Int){
        let countryCode = countryCode.dropFirst()
        self.countryCodeTextField.text = String(countryCode)
        self.hideCountryCodePopUp()
    }
    func hideCountryCodePopUp(){
        
        self.countryCodesArray.removeAllObjects()
        
        let tmpController :UIViewController! = self.presentedViewController;
        if(tmpController != nil){
            self.dismiss(animated: false, completion: {()->Void in
                tmpController.dismiss(animated: false, completion: nil);
            });
        }
        self.countryCodePopOver = nil
        self.countryCodeNavigator = nil
    }
    @IBAction func showBlockReasonsPopUp(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .BLOCKED_REASONS
        vc.preferredContentSize = CGSize(width: 250, height: self.blockReasons.count * 44)
        
        if(CGFloat((self.blockReasons.count * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        else{
            let widht : Float = Float(self.view.frame.size.width - 70.0)
            vc.preferredContentSize = CGSize(width: Int(widht) , height: (blockReasons.count - 1) * 44)
        }
        
        vc.blockReasonsDataSource = self.blockReasons
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.down
        popOver?.sourceView = self.blockedReasonLabel
        
        vc.delegate = self
        popOver?.sourceRect = blockedReasonLabel.frame
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    @objc func showDatePicker(textField : UITextField){
        
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
    func didSelectDate(optionType: Date, optionIndex: Int) {
        
//        print(optionType)
        let timeStamp = optionType.timeIntervalSince1970
//        print(timeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // This formate is input formated .
        let dateStr = dateFormatter.string(from: optionType)
        
//        print(dateStr)
        
//        DispatchQueue.main.async {
            
            if(optionIndex == 0){
                self.bookingDateTextField.text = dateStr
                let dateString = Formatter.ISO8601.string(from: optionType)   // "2018-01-23T03:06:46.232Z"
                self.selectedBookingDate = optionType
//                self.bookingDetailsDict["bookingDate"] = dateString
            }
//            else if(optionIndex == 2){
//                self.agreementDateTextField.text = dateStr
//                self.bookingDetailsDict["agreementDate"] = timeStamp
//            }
//            else if(optionIndex == 3){
//                self.saleDeedDateTextField.text = dateStr
//                self.bookingDetailsDict["saleDeedDate"] = timeStamp
//            }
//            else if(optionIndex == 4){
//                self.possessionDatePrelimTextField.text = dateStr
//                self.bookingDetailsDict["prelimsPossessionDate"] = timeStamp
//            }
//            else if(optionIndex == 5){
//                self.possessionFinalDateTextField.text = dateStr
//                self.bookingDetailsDict["finalPossessionDate"] = timeStamp
//            }
//        }
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
extension BookingFormViewController : HidePopUp{
 
    // MARK: - HIDE POPUP
    func didSelectProject(optionType: String, optionIndex: Int) {
//        print(optionType)
        
        self.selectedBlockingReason = optionType
        self.blockedReasonLabel.text = optionType
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
}

extension BookingFormViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    // MARK: - CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.clientsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ownerDetailsCell", for: indexPath) as! OwnerDetailsCollectionViewCell
        
        let tempClient =  self.clientsArray[indexPath.row]
        self.selectedIndexPathForReceiptEntry = indexPath
        let ownerDetails = tempClient.client
        
        cell.nameLabel.text = ownerDetails.name
        cell.phoneNumberLabel.text = String(format: "%@ %@", (ownerDetails.phoneCode ?? ""),(ownerDetails.phone ?? "")) 
        cell.emailIDLabel.text = ownerDetails.email
        
        cell.callButton.tag = indexPath.row
        cell.whatsappButton.tag = indexPath.row
        cell.emailButton.tag = indexPath.row
        cell.editDetailsButton.tag = indexPath.row
        
        cell.backgroundColor = UIColor.hexStringToUIColor(hex: "f6f6f6")
        
        if(self.selectedUnit.status == UNIT_STATUS.BOOKED.rawValue){
            cell.editDetailsButton.setTitle("Edit Details", for: .normal)
        }
        
        cell.callButton.addTarget(self, action: #selector(openDialer(_:)), for: .touchUpInside)
        cell.whatsappButton.addTarget(self, action: #selector(openWhatsapp(_:)), for: .touchUpInside)
        cell.emailButton.addTarget(self, action: #selector(openEmail(_:)), for: .touchUpInside)
        cell.editDetailsButton.addTarget(self, action: #selector(showUnitDetails(_:)), for: .touchUpInside)
        
        if(ownerDetails.photo != nil){
            DispatchQueue.global().async {
                let url = ServerAPIs.getSingleSingedUrl(url: ownerDetails.photo!)
                cell.imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "photo"), options:[.highPriority])
            }
        }
        
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tempButton = UIButton()
        tempButton.tag = indexPath.row
        self.showUnitDetails(tempButton)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = (collectionView.bounds.size.width ) / 1.1
        return CGSize(width: itemWidth, height: 150)
    }

    @objc func showUnitDetails(_ sender: UIButton){
        
        let client = self.clientsArray[sender.tag]
        let ownerDetailsController = UnitOwnerDetailsViewController(nibName: "UnitOwnerDetailsViewController", bundle: nil)
        ownerDetailsController.delegate = self
        ownerDetailsController.selectedClientIndex = sender.tag
        ownerDetailsController.isSoldUnit = (selectedUnit.status == UNIT_STATUS.SOLD.rawValue) ? true : false
        ownerDetailsController.selectedUnitStatus = UNIT_STATUS(rawValue: Int(selectedUnit!.status))
        if(self.clientsArray.count > 0){
            ownerDetailsController.selectedClient = client
        }
        self.present(ownerDetailsController, animated: true, completion: nil)
    }
    @objc func openDialer(_ sender: UIButton){
        
        let client = self.clientsArray[sender.tag]
        guard let number = URL(string: "tel://" + client.client.phone!) else { return }
        UIApplication.shared.open(number)
    }
    @objc func openWhatsapp(_ sender : UIButton){
        
        let client = self.clientsArray[sender.tag]
        
        var tempCode = ""
        if let phoneCode = client.client.phoneCode{
            if(phoneCode.count > 0){
                tempCode = phoneCode
            }
            else
            {
                tempCode = "91"
            }
        }
        else{
            tempCode = "91"
        }

        let phoneNumber  = (client.client.phone!.count > 10) ? client.client.phone! : tempCode + client.client.phone!
//        whatsapp://send?phone
        guard let number = URL(string: String(format: "https://wa.me/%@?text=%@", phoneNumber,""))else{return}
        UIApplication.shared.open(number)
    }

    @objc func openEmail(_ sender: UIButton){

        let client = self.clientsArray[sender.tag]
        let emailID = client.client.email

        if(emailID != nil){

            let emailer = String(format: "mailto:%@", emailID!)
            let url = URL(string: emailer)

            UIApplication.shared.open(url!)
        }
    }
}
extension BookingFormViewController : ProspectUpdateDelegate{
    
    func didFinishProspectUpdate(updatedClient: Client, selectedCustomer: ClientList,selectedIndex : Int) {
        var modifiedClient : ClientList!
        var indexer = 0
        for tempClient in self.clientsArray{
            if(tempClient._id == selectedCustomer._id){
                modifiedClient = tempClient
                modifiedClient.client = updatedClient
                self.clientsArray.remove(at: selectedIndex)
                self.clientsArray.insert(modifiedClient, at: selectedIndex)
                break
            }
            indexer += 1
        }
        self.collectionView.reloadData()
    }
}
extension BookingFormViewController : FloatingPanelControllerDelegate{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  CustomPanelLayout(parent: self)
    }
}
