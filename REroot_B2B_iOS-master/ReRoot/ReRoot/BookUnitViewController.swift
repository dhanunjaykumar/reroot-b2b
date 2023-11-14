//
//  BookUnitViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 27/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import IQKeyboardManagerSwift

//protocol BookUnitDelegate: class {
//    func didFinishBookUnit(clientId : String,bookedUnit : UnitDetails,selectedIndexPath : IndexPath)
//}

class BookUnitViewController: UIViewController ,UITextFieldDelegate , UIPopoverPresentationControllerDelegate,DateSelectedFromPicker ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var agreementValueView: UIView!
    @IBOutlet var totalCostInclTaxesView: UIView!
    @IBOutlet var totalCostExclTaxesView: UIView!
    @IBOutlet var unitCostView: UIView!
    @IBOutlet var premiumValueView: UIView!
    
    @IBOutlet var heightOfUnitBillElementsView: NSLayoutConstraint!
    @IBOutlet var unitPremiumBillingElementsView: UIView!
    @IBOutlet var heightOfPremiumBillingElementsView: NSLayoutConstraint!
    
    @IBOutlet var actualPremiumValueLabel: UILabel!
    @IBOutlet var discountedPremiumValue: UILabel!
    @IBOutlet var finalPremiumValue: UILabel!
    
    @IBOutlet var actualUnitCostLabel: UILabel!
    @IBOutlet var discountedUnitCostLabel: UILabel!
    @IBOutlet var finalUnitCostLabel: UILabel!
    
    @IBOutlet var heightOfPremiumValInfoLabel: NSLayoutConstraint!
    @IBOutlet var premiumElementsView: UIView!
    @IBOutlet var heightOfReservationsTableView: NSLayoutConstraint!
    
    @IBOutlet var heightOfCompleteUnitDetailsView: NSLayoutConstraint!
    @IBOutlet var bottomSpaceOfScrollView: NSLayoutConstraint!
    var reservationsTableViewDataSource : [RESERVED_UNITS]!
    @IBOutlet var reservationsTableView: UITableView!
//    @IBOutlet var reservedTillDateLabel: UILabel!
//    @IBOutlet var reservedFromDateLabel: UILabel!
//    @IBOutlet var reservationHolderNameLabel: UILabel!
    @IBOutlet var heightOfSaveButton: NSLayoutConstraint!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var carParksView: UIView!
    @IBOutlet var viewFloorPlanView: UIView!
    @IBOutlet var heightOfViewFloorPlanView: NSLayoutConstraint!
    
    @IBOutlet var viewFloorPlanButton: UIButton!
    @IBOutlet var heightOfBookedDate: NSLayoutConstraint!
    @IBOutlet var bookedDateView: UIView!
    @IBOutlet var bookedDateTextField: UITextField!
    @IBOutlet var heightOfBlockingReason: NSLayoutConstraint!
    
    @IBOutlet var blockingReasonView: UIView!
    @IBOutlet var blockingReasonLabel: UILabel!
    @IBOutlet var heightOfPremiumElements: NSLayoutConstraint!
    @IBOutlet var heightOfPremiumValue: NSLayoutConstraint!
    
    var selectedBlockName : String!
    @IBOutlet var heightOfUnitDetailsView: NSLayoutConstraint!
    @IBOutlet var unitBillingElementsView: UIView!
    
    @IBOutlet var topOfBookingInfoView: NSLayoutConstraint!
    @IBOutlet var phoneNumberView: UIView!
    @IBOutlet var customerNameView: UIView!
    
    @IBOutlet var scrollViewContentView: UIView!
    @IBOutlet var premiumElements: UILabel!
    @IBOutlet var premiumValue: UILabel!
    @IBOutlet var bookingDatesView: UIView!
    @IBOutlet var customerDetailsView: UIView!
//    weak var delegate:BookUnitDelegate?
    var indexPathOfSelectedUnit : IndexPath!
    @IBOutlet var unitCostLabel: UILabel!
    @IBOutlet var agreementValueLabel: UILabel!
    
    @IBOutlet var premiumValueLabel: UILabel!
    @IBOutlet var unitFacingSubViewLabel: UILabel!
    @IBOutlet var unitTypeLabel: UILabel!
    @IBOutlet var totalCostWithOutTaxesLabel: UILabel!
    @IBOutlet var totalCostWithTaxesLabel: UILabel!
    
    @IBOutlet var carParkingInfoLabel: UILabel!
    @IBOutlet var carpetAreaLabel: UILabel!
    @IBOutlet var superBuiltUpAreaLabel: UILabel!
    
    public var overrideIteratingTextFields: [UIView]?

    @IBOutlet var reservationInfoView: UIView!
    @IBOutlet var heightOfReservationInfoView: NSLayoutConstraint!
    @IBOutlet var heigtOfUnitTypeView: NSLayoutConstraint!
    @IBOutlet var heightOfUnitFacingView: NSLayoutConstraint!
    @IBOutlet var heightOfCarpetAreaView: NSLayoutConstraint!
    @IBOutlet var heightOfBuildUpAreaView: NSLayoutConstraint!
    @IBOutlet var heightOfCarParkingView: NSLayoutConstraint!
    
    @IBOutlet var heightOfUnitCostView: NSLayoutConstraint!
    @IBOutlet var heightOfTotalUnitCostExcluingTaxesView: NSLayoutConstraint!
    
    @IBOutlet var heightOfPremiumValueView: NSLayoutConstraint!
    
    @IBOutlet var heightOfTotalUnitCostIncludingTaxesView: NSLayoutConstraint!
    
    @IBOutlet var heightOfAgreementValueView: NSLayoutConstraint!
    
    
    @IBOutlet var unitFacingLabel: UILabel!
    var bookingDetailsDict = Dictionary<String,Any>()
    var selectedUnit : UnitDetails!
    
    @IBOutlet var bookUnitButton: UIButton!
    @IBOutlet var titleInfoView: UIView!
    @IBOutlet var commentsTextView: KMPlaceholderTextView!

    @IBOutlet var countryCodeTextField: UITextField!
    
    @IBOutlet var stausButton: UIButton!
    @IBOutlet var possessionFinalDateTextField: UITextField!
    @IBOutlet var possessionDatePrelimTextField: UITextField!
    @IBOutlet var saleDeedDateTextField: UITextField!
    @IBOutlet var agreementDateTextField: UITextField!
    @IBOutlet var dateOfBookingTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var discountTextField: UITextField!
    
    @IBOutlet var emailIdTextField: UITextField!
    @IBOutlet var customerNameTextField: UITextField!
    
    @IBOutlet var heightOfProspectDetails: NSLayoutConstraint!
    
    @IBOutlet var heightOfBookingDetailsView: NSLayoutConstraint!
    @IBOutlet var heightOfCustomerInfoView: NSLayoutConstraint!
    
    @IBOutlet var prospectDetailsView: UIView!
    
    @IBAction func viewFloorPlan(_ sender: Any) {
        
//        let floorPlanController = storyboard?.instantiateViewController(withIdentifier: "floorPlan") as! FloorPlanViewController
//        floorPlanController.floorPlans = selectedUnit.i //selectedUnit.type?.floorPlan ?? []
//        self.navigationController?.pushViewController(floorPlanController, animated: true)
    }
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
    private func responderViews()-> [UIView]? {
        
        if let overriddenTextFields = overrideIteratingTextFields {
            return overriddenTextFields
        }
        return nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        heightOfBookingDetailsView.constant = 0
//        heightOfCustomerInfoView.constant = 0

    }
    override func viewDidLayoutSubviews() {
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue || selectedUnit.status == UNIT_STATUS.HANDEDOVER.rawValue){
            unitPremiumBillingElementsView.isHidden = false
            heightOfPremiumBillingElementsView.constant = 160
            heightOfUnitDetailsView.constant = heightOfUnitDetailsView.constant - heightOfUnitBillElementsView.constant
            heightOfUnitBillElementsView.constant = 0
            unitBillingElementsView.isHidden = true
            
        }
        else{
            heightOfUnitDetailsView.constant = heightOfUnitDetailsView.constant - heightOfPremiumBillingElementsView.constant
            heightOfPremiumBillingElementsView.constant = 0
            unitPremiumBillingElementsView.isHidden = true
            heightOfUnitBillElementsView.constant = 160
            unitBillingElementsView.isHidden = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if(selectedUnit != nil && selectedUnit.type?.floorPlan == nil || selectedUnit.type?.floorPlan?.count == 0)
        {
            heightOfViewFloorPlanView.constant = 0
            viewFloorPlanView.isHidden = true
        }
        
        saveButton.backgroundColor = UIColor.hexStringToUIColor(hex: "35495d")
        saveButton.setTitleColor(UIColor.white, for: .normal)
        
        unitFacingLabel.numberOfLines = 0
        unitFacingLabel.lineBreakMode = .byWordWrapping
        unitFacingLabel.text = String(format: "%@ (%@)", selectedUnit.unitNo?.displayName ?? "",selectedUnit.description ?? "")
        
        let statusColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: selectedUnit.status!)

        stausButton.backgroundColor = statusColorDict["color"] as? UIColor
        stausButton.setTitle(String(format: "  %@  ", statusColorDict["statusString"] as! String), for: .normal)
        stausButton.layer.cornerRadius = 8.0
        
        self.handleUnitInfoView()
        scrollViewContentView.layoutIfNeeded()
        
        
//        if(bookingDateStr != nil){
//            //        let bookingDateStr = selectedUnit.bookingform?.bookingDate
//
////            bookedDateTextField.text = RRUtilities.sharedInstance.getDateStringFromServerDateStr(dateStr: bookingDateStr!)
//        }
//        else{
//            bookedDateView.isHidden = true
//            heightOfBookedDate.constant = 0
//        }
        
        commentsTextView.layer.borderWidth = 0.5
        commentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentsTextView.layer.cornerRadius = 8.0
        
        if(selectedUnit.status != UNIT_STATUS.BOOKED.rawValue || selectedUnit.status != UNIT_STATUS.SOLD.rawValue){ //Booked
            heightOfProspectDetails.constant = 0
            prospectDetailsView.isHidden = true
            saveButton.isHidden = true
            heightOfSaveButton.constant = 0
            heightOfPremiumBillingElementsView.constant = 0
        }
        
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue)
        {
            self.hideReservationInfoView()
            saveButton.isHidden = false
            heightOfSaveButton.constant = 50
            heightOfProspectDetails.constant = 330
            prospectDetailsView.isHidden = false
            if(selectedUnit.bookingform != nil){
                self.getBookingFormInfo()
            }
        }
        else if(selectedUnit.status != UNIT_STATUS.RESERVED.rawValue){
            hideReservationInfoView()
        }
        if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){ //reserved
            
            let nib = UINib(nibName: "ReservationTableViewCell", bundle: nil)
            reservationsTableView.register(nib, forCellReuseIdentifier: "reservQueueCell")
            
            reservationsTableView.tableFooterView = UIView()
            
            reservationsTableView.estimatedRowHeight = UITableView.automaticDimension
            reservationsTableView.rowHeight = 80
            
            heightOfSaveButton.constant = 0
//            bottomSpaceOfScrollView.constant = 0
            
            self.getReserations()
        }
        if(selectedUnit.status == UNIT_STATUS.VACANT.rawValue){
            heightOfSaveButton.constant = 0
//            bottomSpaceOfScrollView.constant = 0
        }
        
        heightOfCompleteUnitDetailsView.constant = 0
        
    }
    func hideReservationInfoView(){
        heightOfReservationInfoView.constant = 0
        reservationInfoView.isHidden = true
    }
    // MARK:- URL CALLS
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
        
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue){
            if(selectedUnit.bookingform != nil){
//                print(selectedUnit.bookingform)
                parameters["bookingform"] = selectedUnit.bookingform?._id
            }
            else{
                return
            }
        }
        else{
            return
        }
//        print(parameters)
        
        let urlString = String(format: RRAPI.API_UNIT_BOOKING_INFO, (selectedUnit.bookingform?._id)!)
        print(urlString)

        HUD.show(.progress)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                HUD.hide()
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    let urlResult = try JSONDecoder().decode(BOOKING_FORM_RESULT.self, from: responseData)
//                    print(urlResult)
                    if(urlResult.booking!.unitRate == nil){
                        return
                    }
                    if(urlResult.status == 1){
                        let pBes : PREMIUM_BILLING_ELEMENTS = urlResult.booking!.unitRate!.pBes!
                        let unitRate = urlResult.booking!.unitRate!
                        
                        self.actualPremiumValueLabel.text = String(format: "%d", pBes.total!)
                        self.discountedPremiumValue.text = String(format: "%d", pBes.discountTotal!)
                        self.finalPremiumValue.text = String(format: "%d", pBes.finalTotal!)
                        
                        self.actualUnitCostLabel.text = String(format: "%d", unitRate.total!)
                        self.discountedUnitCostLabel.text = String(format: "%d", unitRate.discountTotal!)
                        self.finalUnitCostLabel.text = String(format: "%d", unitRate.finalTotal!)
                    }
                    else if(urlResult.status == -1){
                        //Logout
                    }
                    else{ ///fail status
                        
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
        
        let urlString = String(format: RRAPI.API_GET_RESERVATIONS_OF_UNIT, selectedUnit._id!)
        
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
                        print(self.reservationsTableViewDataSource.count)
                        self.reservationsTableView.delegate = self
                        self.reservationsTableView.dataSource = self
                        self.reservationsTableView.reloadData()
                        self.heightOfReservationsTableView.constant = CGFloat((self.reservationsTableViewDataSource.count * 80))
                        self.heightOfReservationInfoView.constant = CGFloat(self.reservationsTableViewDataSource.count * 80) + 70
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
    
    /*
     let project : String?
     let tower : String?
     let block : String?
     let description : String?
     let company_group : String?
     var status : Int?
     let rate : Double?
     let agreeValItemRate : Double?
     let salevalue : Double?
     let gst : Int?
     let totalCost : Double?
     let floor : Floor?
     let unitNo : Floor?
     let otherPremiums : [Premium]?
     let updatedBy : [UPDATEDBY]?
     let floorPremium : Premium?
     let type : Type?
    */
    @objc func injected() {
        configureView()
    }
    func configureView(){
        handleUnitInfoView()
//        getBookingFormInfo()
    }
    func handleUnitInfoView(){
        
        countryCodeTextField.text = "91"
        
        if(selectedUnit.type?.name != nil){
            unitTypeLabel.text = selectedUnit.type?.name
        }
        else{
            heigtOfUnitTypeView.constant = 0
        }
        
        if(selectedUnit.facing != nil){
            unitFacingSubViewLabel.text = selectedUnit.facing
            heightOfUnitFacingView.constant = 20
        }
        else{
            heightOfUnitFacingView.constant = 0
        }
        
        if(selectedUnit.type?.superBuiltUpArea != nil){
            superBuiltUpAreaLabel.text = String(format: "%lu %@", (selectedUnit.type?.superBuiltUpArea?.value)!,(selectedUnit.type?.superBuiltUpArea?.uom)!)
        }
        
        if(selectedUnit.type?.carpetArea != nil){
            carpetAreaLabel.text = String(format: "%lu %@", (selectedUnit.type?.carpetArea?.value)!,(selectedUnit.type?.carpetArea?.uom)!)
        }
        
        if(selectedUnit.blockingReason != nil && selectedUnit.blockingReason?.count ?? "".count > 0){
            blockingReasonLabel.text = selectedUnit.blockingReason
        }
        else{
            blockingReasonView.isHidden = true
            heightOfBlockingReason.constant = 0
        }
        
        // car parkings
        if(selectedUnit.type?.carParks != nil){
            
            let carsPark : [CarParks] = (selectedUnit.type?.carParks)!
            print(selectedUnit.type?.carParks! as Any)
            
            var parkingString = ""
            let totalCarParks = carsPark.count
            var counter = 0
            if(totalCarParks == 1){
                for tempPark in carsPark{
                    if(tempPark.cType != nil){
                        let tempString = String(format: "%u (%@)", tempPark.count!,tempPark.cType!.capitalizingFirstLetter())
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
                        var tempString = String(format: "%u (%@)", tempPark.count!,tempPark.cType!.capitalizingFirstLetter())
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
            print(parkingString)
            
            if(parkingString.count > 0){
                carParkingInfoLabel.text = parkingString
                heightOfCarParkingView.constant = 20
                carParksView.isHidden = false
            }
            else{
                carParkingInfoLabel.text = ""
                heightOfCarParkingView.constant = 0
                carParksView.isHidden = true
            }
        }
        
        if(selectedUnit.rate != nil){
            unitCostLabel.text = String(format: "%@ %.0f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, selectedUnit.rate!)
        }
        
        if(selectedUnit.floorPremium != nil){
            premiumValue.text = String(format: "%@ %.0f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, selectedUnit.salevalue!)
        }
        else{
            premiumValue.text = ""
            heightOfPremiumValueView.constant = 0
            heightOfPremiumElements.constant = 0
        }
        //make premium floor string
        
        var premiumUnitsString = ""
        
        if(selectedUnit.floorPremium?.name != nil)
        {
            premiumUnitsString.append(selectedUnit.floorPremium!.name!)
        }
        var counterForNewLine = 0
        if((selectedUnit.otherPremiums?.count)! > 0){

            for tempUnit in selectedUnit.otherPremiums!
            {
                counterForNewLine = counterForNewLine + 1
                if(premiumUnitsString.count > 0)
                {
                    premiumUnitsString.append("\n")
                    premiumUnitsString.append(tempUnit?.name ?? "")
                }
                else
                {
                    premiumUnitsString.append(tempUnit?.name ?? "")
                    
                    if(counterForNewLine < (selectedUnit.otherPremiums?.count)!){
                        premiumUnitsString.append("\n")
                    }
                }
//                premiumUnitsString.append("\n")
            }
        }
        
        if(premiumUnitsString.count > 0)
        {
            premiumElements.text =  premiumUnitsString
            premiumElements.sizeToFit()
            heightOfPremiumElements.constant = premiumElements.frame.size.height
        }
        else
        {
            premiumElements.text = ""
            heightOfPremiumElements.constant = 0
        }
        
        if(selectedUnit.type != nil){
            unitCostLabel.text = String(format: "%@ %0.f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!, selectedUnit.rate!)
        }
        else{
            heightOfUnitCostView.constant = 0
        }

        if(selectedUnit.salevalue != nil){
            totalCostWithOutTaxesLabel.text = String(format: "%@ %.0f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")! ,selectedUnit.salevalue!)
        }
        else{
            
        }
        
        if(selectedUnit.salevalue != nil && selectedUnit.rate != nil){
            let premiumValue = selectedUnit.salevalue! - selectedUnit.rate!
            if(premiumValue > 0){
                premiumValueLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")! ,premiumValue)
            }
            else{
//                heightOfPremiumValInfoLabel.constant = 0
                heightOfPremiumValueView.constant = 0
            }
        }
     
        if(selectedUnit.status == UNIT_STATUS.BOOKED.rawValue || selectedUnit.status == UNIT_STATUS.SOLD.rawValue || selectedUnit.status == UNIT_STATUS.HANDEDOVER.rawValue){
            unitPremiumBillingElementsView.isHidden = false
            heightOfPremiumBillingElementsView.constant = 160
//            heightOfUnitDetailsView.constant = heightOfUnitDetailsView.constant - heightOfUnitBillElementsView.constant
            heightOfUnitBillElementsView.constant = 0
            unitBillingElementsView.isHidden = true
            
        }
        else{
//            heightOfUnitDetailsView.constant = heightOfUnitDetailsView.constant - heightOfPremiumBillingElementsView.constant
            heightOfPremiumBillingElementsView.constant = 0
            unitPremiumBillingElementsView.isHidden = true
            heightOfUnitBillElementsView.constant = 160
            unitBillingElementsView.isHidden = false
            
        }
        unitDetailsView.layoutIfNeeded()
        
        heightOfAgreementValueView.constant = 0
        heightOfPremiumValueView.constant = 0
        heightOfPremiumElements.constant = 0
        heightOfTotalUnitCostIncludingTaxesView.constant = 0
        heightOfTotalUnitCostExcluingTaxesView.constant = 0
        unitBillingElementsView.superview?.layoutIfNeeded()
        
        if(selectedUnit.totalCost != nil){
            // extraTax = ( extraTx * mTotalCostIncludingTaxes ) /100.;
//            let gst = Double(selectedUnit.gst!)
//            let taxAmount = (gst * selectedUnit.totalCost!) / 100
//            let total = selectedUnit.totalCost! + taxAmount
            totalCostWithTaxesLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")! ,selectedUnit.totalCost ?? "")
        }
        else{
            
        }

        if(selectedUnit.agreeValItemRate != nil){
            agreementValueLabel.text = String(format: "%@ %.0f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,selectedUnit.agreeValItemRate!)
            heightOfAgreementValueView.constant = 20
        }
        else{
            heightOfAgreementValueView.constant = 0
        }
        
//        if(selectedUnit.bookingform != nil){
//
//            let client = selectedUnit.bookingform?.clients
//
//            if(client?.count ?? "".count > 0){
//
//                let tempClient : ClientList = client![0]
//                let actualClient = tempClient.client
//
//                if(actualClient.phone != nil){
//                    phoneNumberTextField.text = actualClient.phone
//                }
//                if(actualClient.email != nil){
//                    emailIdTextField.text = actualClient.email
//                }
//                if(actualClient.name != nil){
//                    customerNameTextField.text = actualClient.name
//                }
//
//            }
//            if(selectedUnit.bookingform?.comments != nil){
//                commentsTextView.text = selectedUnit.bookingform?.comments
//            }
//
//            unitDetailsView.layoutIfNeeded()
//            heightOfUnitDetails.constant = heightOfUnitDetails.constant + (premiumElements.frame.size.height - 20)
//            unitDetailsView.layoutSubviews()
//            unitDetailsView.sizeToFit()
//
//        }
//        topOfBookingInfoView.constant = 10
    }
    
    @IBOutlet var unitDetailsView: UIView!
    @IBAction func bookUnit(_ sender: Any) {
        
      
            if(phoneNumberTextField.text?.count == 0){
                HUD.flash(.label("Please enter phone number"))
                return
            }
            if(customerNameTextField.text?.count == 0){
                HUD.flash(.label("Please enter customer name"))
                return
            }

            if((emailIdTextField.text?.count)! > 0){
                if(RRUtilities.sharedInstance.isValidEmail(emailID: emailIdTextField.text!) == false){
                    HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
                    return
                }
            }
            
            bookingDetailsDict["_id"] = selectedUnit._id
            bookingDetailsDict["phone"] = phoneNumberTextField.text!
            bookingDetailsDict["email"] = emailIdTextField.text!
            bookingDetailsDict["comments"] = commentsTextView.text!
            bookingDetailsDict["name"] = customerNameTextField.text!
//            bookingDetailsDict["countryCode"] = "91"//countryCodeTextField.text!.split(separator: "+")[1]
            
            bookingDetailsDict["unit"] = selectedUnit._id
            bookingDetailsDict["block"] = selectedUnit.block
            bookingDetailsDict["tower"] = selectedUnit.tower
            bookingDetailsDict["project"] = selectedUnit.project
            
            if(selectedUnit.clientId != nil){
                bookingDetailsDict["clientId"] = selectedUnit.clientId
            }
            
            bookingDetailsDict["src"] = 3
            print(bookingDetailsDict)
            
            if !RRUtilities.sharedInstance.getNetworkStatus()
            {
                HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
                return
            }
            let headers: HTTPHeaders = [
                "User-Agent" : "RErootMobile",
                "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
            ]

            let urlString = (selectedUnit.clientId == nil) ? RRAPI.BOOK_UNIT : RRAPI.BOOK_UNIT_EDIT
            
            print(urlString)
//            if(selectedUnit.clientId == nil){
////                urlString =
//            }
            
            HUD.show(.progress)
        
            
            AF.request(urlString, method: .post, parameters: bookingDetailsDict, encoding: JSONEncoding.default, headers: headers).responseJSON{
                response in
                switch response.result {
                case .success:
//                    print(response)
                    guard response.data != nil else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    do{
                        let urlResult = try JSONDecoder().decode(BOOK_UNIT_RESULT.self, from: response.data!)
                        
                        //                    print(urlResult)
                        
                        if(urlResult.status == 1){ //success
                            // store the client id
                            // pass client id and
                            //                        self.delegate?.didFinishBookUnit(clientId: (urlResult.data?.clientId) ?? "", bookedUnit: self.selectedUnit,selectedIndexPath: self.indexPathOfSelectedUnit)
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
        
//        bookingDetailsDict["customerLocalId"] = UDID.
        
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
        
       
    }
    @IBAction func saveUpdate(_ sender: Any) {
        self.bookUnit(sender)
    }
    
    @IBAction func closeUnitView(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    // MARK:- Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.reservationsTableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ReservationTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "reservQueueCell",
            for: indexPath) as! ReservationTableViewCell
        
        let reservation : RESERVED_UNITS = self.reservationsTableViewDataSource[indexPath.row]
        
        cell.reservationHolderNameLabel.text = reservation.prospect?.userName
        
        let fromDate = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: reservation.reserveDate!)
        let toDate = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: reservation.expiryDate!)
        
        cell.fromDateLabel.text = fromDate
        cell.toDateLabel.text = toDate
        
        return cell
    }

    // MARK:- Textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if ((textField == dateOfBookingTextField) || (textField == saleDeedDateTextField) || (textField == agreementDateTextField) || (textField == possessionFinalDateTextField) || (textField == possessionDatePrelimTextField)) {
            self.showDatePicker(textField: textField)
            return false
        }
        
        return true

    }
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        return false
//    }
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//
//
//        if textField == discountTextField {
////            self.showDatePicker(textField: discountTextField)
//        }
//        else if textField == dateOfBookingTextField {
//
//        }
//    }
    @objc func showDatePicker(textField : UITextField){
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "datePicker") as! DatePickerViewController
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
        
        print(optionType)
        let timeStamp = optionType.timeIntervalSince1970
        print(timeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // This formate is input formated .
        let dateStr = dateFormatter.string(from: optionType)
        
        print(dateStr)

        DispatchQueue.main.async {
            
            if(optionIndex == 1){
                self.dateOfBookingTextField.text = dateStr
                let dateString = Formatter.ISO8601.string(from: Date())   // "2018-01-23T03:06:46.232Z"
                self.bookingDetailsDict["bookingDate"] = dateString
            }
            else if(optionIndex == 2){
                self.agreementDateTextField.text = dateStr
                self.bookingDetailsDict["agreementDate"] = timeStamp
            }
            else if(optionIndex == 3){
                self.saleDeedDateTextField.text = dateStr
                 self.bookingDetailsDict["saleDeedDate"] = timeStamp
            }
            else if(optionIndex == 4){
                self.possessionDatePrelimTextField.text = dateStr
                 self.bookingDetailsDict["prelimsPossessionDate"] = timeStamp
            }
            else if(optionIndex == 5){
                self.possessionFinalDateTextField.text = dateStr
                self.bookingDetailsDict["finalPossessionDate"] = timeStamp
            }
        }
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func hideKeyBoard(_ sender: Any) {
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
