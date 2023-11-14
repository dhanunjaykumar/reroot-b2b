//
//  ApprovalFormViewController.swift
//  REroot
//
//  Created by Dhanunjay on 28/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import CoreData

protocol ApprovalDelegate : class {
    func didApproveApproval(selectedApproval : Approvals)
    func didClickPdfView(approvalType : APPROVAL_TYPES,selectedApproval : Approvals)
}
extension ApprovalDelegate {
    func didApproveApproval(selectedApproval : Approvals){
        // leaving this empty
    }
    func didClickPdfView(approvalType : APPROVAL_TYPES,selectedApproval : Approvals){}
}


class ApprovalFormViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {
    
    
    @IBOutlet weak var heightOfDebitOrCreditInfoView: NSLayoutConstraint!
    @IBOutlet weak var debitOrCreditInfoView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var narrationLabel: UILabel!
    @IBOutlet weak var debitOrCreditNoteDueDateLabel: UILabel!
    @IBOutlet weak var debitOrCreditNoteTaxLabel: UILabel!
    @IBOutlet weak var debitOrCreditAmountLabel: UILabel!
    
        
    var fetchedResultsControllerBillingElementes : NSFetchedResultsController<BillingInfo> =  NSFetchedResultsController.init()

    var isFromNotification = false
    @IBOutlet weak var gapBwPhoneAndApproverInfoViews: NSLayoutConstraint!
    @IBOutlet weak var gapBwEmailAndPhoneViews: NSLayoutConstraint!
    @IBOutlet weak var heightOfEmailView: NSLayoutConstraint!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var heightOfPhoneNumberView: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var revisedUnitCostLabel: UILabel!
    @IBOutlet weak var discountAmountLabel: UILabel!
    @IBOutlet weak var totalUnitCostLabel: UILabel!
    @IBOutlet weak var gepBetweenApproverNDiscountView: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintOfRevisedUnitView: NSLayoutConstraint!
    @IBOutlet weak var gapBetweenUnitCostsViews: NSLayoutConstraint!
    @IBOutlet weak var heightOfRevisedUnitCostView: NSLayoutConstraint!
    @IBOutlet weak var revisedUnitCostView: UIView!
    @IBOutlet weak var heightOfUnitCostView: NSLayoutConstraint!
    @IBOutlet weak var unitCostVIew: UIView!
    var selectedApproval : Approvals!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var heightConstraintOfButtonsView: NSLayoutConstraint!
    @IBOutlet weak var unitInfoLabel: UILabel!
    @IBOutlet weak var approverOrRequesterNameLabel: UILabel!
    @IBOutlet weak var approvalTypeInfoLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    var approvalType : APPROVAL_TYPES!
    var isIncomingApprovals : Bool = false
    var approvalHistoryDataSource : [ApprovalHistory]!

    weak var delegate:ApprovalDelegate?

    @IBOutlet weak var heightOfApprovalInfoView: NSLayoutConstraint!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var heightOfBillingElemetnsView: NSLayoutConstraint!
    @IBOutlet weak var heightOfBillingElementsTableView: NSLayoutConstraint!
    @IBOutlet weak var heightOfHistoryTableView: NSLayoutConstraint!
    @IBOutlet weak var billingElementsView: UIView!
    @IBOutlet weak var billingElemensTableView: UITableView!
    @IBOutlet weak var approvalsHistoryTableView: UITableView!
    @IBOutlet weak var heightOfHistoryView: NSLayoutConstraint!
    @IBOutlet weak var pdfButtonView: UIView!
    @IBOutlet weak var heightOfPDFView: NSLayoutConstraint!
    @IBOutlet weak var viewPdfButton: UIButton!
    @IBOutlet weak var approverNameLabel: UILabel!
    @IBOutlet weak var requesterNameLabel: UILabel!
    
    @IBOutlet weak var assignUnitView: UIView!
    @IBOutlet weak var cancelOrTransferUnitView: UIView!
    @IBOutlet weak var heightOfAssignChargesView: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfCancelChargesView: NSLayoutConstraint!
    @IBOutlet weak var heightOfCancelOrTransferChargesView: NSLayoutConstraint!
    
    @IBOutlet weak var assignUnitTaxOnAmountBilled: UILabel!
    @IBOutlet weak var assignUnitAmountBilledLabel: UILabel!
    @IBOutlet weak var assignUnitAmountDue: UILabel!
    @IBOutlet weak var assignUnitAmountReceived: UILabel!
    @IBOutlet weak var assignUnitClientName: UILabel!
    @IBOutlet weak var assignUnitAssignmentCharges: UILabel!
    @IBOutlet weak var assignUnitTaxOnAssignmentCharges: UILabel!
    
    @IBOutlet weak var ctTotalAmountReceivedLabel: UILabel!
    @IBOutlet weak var ctUnitCancelDateLabel: UILabel!
    @IBOutlet weak var ctTaxLabel: UILabel!
    @IBOutlet weak var ctTaxRefundLabel: UILabel!
    @IBOutlet weak var ctInvoiceAmountLabel: UILabel!
    
    @IBOutlet weak var ctTaxOnUnitCancellationLabel: UILabel!
    @IBOutlet weak var ctUnitCancellationCharges: UILabel!
    @IBOutlet weak var ctTotalUnitCancellationLabel: UILabel!
    
    @IBOutlet weak var ctWaiveOfUnitCancellationCharges: UILabel!
    @IBOutlet weak var totalAmountPayable: UILabel!
    @IBOutlet weak var ctPDCReturnDateLabel: UILabel!
    @IBOutlet weak var ctAgreementCollectedDate: UILabel!
    
    var didClickAcceptButton : Bool = false
    
    @IBOutlet weak var unitTypeRequestLetterLabel: UILabel!
    
    @IBOutlet weak var unitTypeCancellationChargesLabel: UILabel!
    @IBOutlet weak var unitTypeTaxOnUnitLabel: UILabel!
    
    @IBOutlet weak var unitWaiveOffTypeChargesLabel: UILabel!
    @IBOutlet weak var unitTotalTypeChargesLabel: UILabel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.heightOfBillingElementsTableView.constant = self.billingElemensTableView.contentSize.height + 12
        self.heightOfHistoryTableView.constant = self.approvalsHistoryTableView.contentSize.height + 25
        if(self.billingElemensTableView.contentSize.height == 0){
            self.heightOfBillingElemetnsView.constant = 0
        }else{
            self.heightOfBillingElemetnsView.constant = self.billingElemensTableView.contentSize.height + 20
        }
        if(self.approvalsHistoryTableView.contentSize.height == 0){
            self.heightOfHistoryView.constant = 0
        }
        else{
            self.heightOfHistoryView.constant = self.approvalsHistoryTableView.contentSize.height + 30
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.heightOfBillingElementsTableView.constant = self.billingElemensTableView.contentSize.height + 12
        self.heightOfHistoryTableView.constant = self.approvalsHistoryTableView.contentSize.height + 25
        
        if(self.billingElemensTableView.contentSize.height == 0){
            self.heightOfBillingElemetnsView.constant = 0
        }else{
            self.heightOfBillingElemetnsView.constant = self.billingElemensTableView.contentSize.height + 20
        }
        if(self.approvalsHistoryTableView.contentSize.height == 0){
            self.heightOfHistoryView.constant = 0
        }
        else{
            self.heightOfHistoryView.constant = self.approvalsHistoryTableView.contentSize.height + 30
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    func configureView(){
        
        scrollView.delegate = self
        
        heightOfPDFView.constant = 0
        pdfButtonView.isHidden = true
        
        heightConstraintOfButtonsView.constant = 0
        buttonsView.isHidden = true
        heightOfApprovalInfoView.constant = heightOfApprovalInfoView.constant - 100

        viewPdfButton.layer.cornerRadius = 4
        viewPdfButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "f5f5f5").cgColor
        viewPdfButton.layer.borderWidth = 1.5
        
        approvalTypeInfoLabel.layer.masksToBounds = true
        approvalTypeInfoLabel.layer.cornerRadius = 4
        
        heightOfAssignChargesView.constant = 0
        heightOfCancelOrTransferChargesView.constant = 0
//        heightOfCancelChargesView.constant = 0
        assignUnitView.isHidden = true
        cancelOrTransferUnitView.isHidden = true
        
        debitOrCreditInfoView.isHidden = true
        heightOfDebitOrCreditInfoView.constant = 0
    
        let nib = UINib(nibName: "ApprovalHistoryTableViewCell", bundle: nil)
        approvalsHistoryTableView.register(nib, forCellReuseIdentifier: "approvalHistoryCell")
        
        approvalsHistoryTableView.tableFooterView = UIView()
        
        approvalsHistoryTableView.rowHeight = UITableView.automaticDimension
        approvalsHistoryTableView.estimatedRowHeight = 44
        
        approvalHistoryDataSource = (selectedApproval!.history?.allObjects as? [ApprovalHistory])
        
        approvalHistoryDataSource.sort( by: { $0.orderID < $1.orderID })
        
        approvalsHistoryTableView.delegate = self
        approvalsHistoryTableView.dataSource = self
        
        if(self.isIncomingApprovals && !PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.INCOMING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
            self.buttonsView.isHidden = true
            self.heightConstraintOfButtonsView.constant = 0
        }
        else if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.OUTGOING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
            self.buttonsView.isHidden = true
            self.heightConstraintOfButtonsView.constant = 0
        }
        
        self.shouldShowUnitDiscountDetails(shouldShow: false)
        
        if(approvalType == APPROVAL_TYPES.DISCOUNT_APPROVAL){
        
            self.shouldShowUnitDiscountDetails(shouldShow: true)
            
            approvalTypeInfoLabel.text = " Discount "
            
            self.shouldShowIncoming(isIncomingApprovals: self.isIncomingApprovals)
            
            phoneNumberLabel.text = selectedApproval.regInfo_userPhone

        }
        else if(approvalType == APPROVAL_TYPES.CREDIT_NOTES_APPROVAL){
            
            debitOrCreditInfoView.isHidden = false
            heightOfDebitOrCreditInfoView.constant = 242

            approvalTypeInfoLabel.text = " Credit Note Approval "
            
            phoneNumberLabel.text = selectedApproval.customer_phone
            
            
            descriptionLabel.text = self.selectedApproval.descp ?? "--"
            debitOrCreditAmountLabel.text = String(format: "%.2f", self.selectedApproval.amount)
            narrationLabel.text = selectedApproval.narration ?? "--"
            debitOrCreditNoteTaxLabel.text = selectedApproval.creditOrDebitTax ?? "--"
            if let dueDate = selectedApproval.dueDate{
                debitOrCreditNoteDueDateLabel.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: dueDate, dateFormat: "dd/MM/yyyy")
            }

            approvalTypeInfoLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "EFDD4A")
            self.shouldShowIncoming(isIncomingApprovals: self.isIncomingApprovals)

        }
        else if(approvalType == APPROVAL_TYPES.DEBIT_NOTES_APPROVAL){
            
            debitOrCreditInfoView.isHidden = false
            heightOfDebitOrCreditInfoView.constant = 242

            approvalTypeInfoLabel.text = " Debit Note Approval "
            
            phoneNumberLabel.text = selectedApproval.customer_phone
            descriptionLabel.text = self.selectedApproval.descp ?? "--"
            debitOrCreditAmountLabel.text = String(format: "%.2f", self.selectedApproval.amount)
            narrationLabel.text = selectedApproval.narration ?? "--"
            debitOrCreditNoteTaxLabel.text = selectedApproval.creditOrDebitTax ?? "--"
            if let dueDate = selectedApproval.dueDate{
                debitOrCreditNoteDueDateLabel.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: dueDate, dateFormat: "dd/MM/yyyy")
            }
            approvalTypeInfoLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "56BDAD")
            self.shouldShowIncoming(isIncomingApprovals: self.isIncomingApprovals)


        }
        else if(approvalType == APPROVAL_TYPES.CANCEL_UNIT_APPROVAL){
            approvalTypeInfoLabel.text = " Cancel Unit "
            
            phoneNumberLabel.text = selectedApproval.customer_phone
            
            heightConstraintOfButtonsView.constant = 0
            buttonsView.isHidden = true
            heightOfHistoryView.constant = 0
            historyView.isHidden = true
            heightOfBillingElemetnsView.constant = 0
            billingElementsView.isHidden = true
            
            heightOfHistoryView.constant = 200
            historyView.isHidden = false
            
            heightOfCancelOrTransferChargesView.constant = 600
//            heightOfCancelChargesView.constant
            cancelOrTransferUnitView.isHidden = false
            
            let pricingInfo : ApprovalPricingInfo = selectedApproval.pricingInfo!
            
            ctTotalAmountReceivedLabel.text = String(format: "%.2f", pricingInfo.amountReceived)
            ctUnitCancelDateLabel.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedApproval.updateByDate!, dateFormat: "dd/MM/yy")
            ctTaxLabel.text =  String(format: "%.2f", pricingInfo.taxPaid)
            ctTaxRefundLabel.text = String(format: "%.2f", pricingInfo.taxAmountRefund)
            ctInvoiceAmountLabel.text = String(format: "%.2f", pricingInfo.demandLetterAmount)
            ctUnitCancellationCharges.text = String(format: "%.2f", pricingInfo.cancellationCharge)
            ctTaxOnUnitCancellationLabel.text = String(format: "%.2f", pricingInfo.cancellationChargeTax)
            ctTotalUnitCancellationLabel.text = String(format: "%.2f", pricingInfo.cancellationCharge)
            ctWaiveOfUnitCancellationCharges.text = String(format: "%.2f", pricingInfo.waiveOffCharges)
            totalAmountPayable.text = String(format: "%.2f", pricingInfo.amountPayable)
            if(selectedApproval.pdc_return_date != nil){
                ctPDCReturnDateLabel.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedApproval.pdc_return_date!, dateFormat: "dd/MM/yy")
            }
            else{
                ctPDCReturnDateLabel.text = "--"
            }
            if(selectedApproval.agreement_collected_date != nil){
                ctAgreementCollectedDate.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedApproval.agreement_collected_date!, dateFormat: "dd/MM/yy")
            }
            else{
                ctAgreementCollectedDate.text = "--"
            }
            
            self.shouldShowIncoming(isIncomingApprovals: self.isIncomingApprovals)

        }
        else if(approvalType == APPROVAL_TYPES.ASSIGN_UNIT_APPROVAL){
            approvalTypeInfoLabel.text = " Unit Assignment "
            
            phoneNumberLabel.text = selectedApproval.customer_phone
            
            heightConstraintOfButtonsView.constant = 0
            buttonsView.isHidden = true
            heightOfHistoryView.constant = 0
            historyView.isHidden = true
            heightOfBillingElemetnsView.constant = 0
            billingElementsView.isHidden = true
            
            heightOfHistoryView.constant = 200
            historyView.isHidden = false
            
            heightOfCancelOrTransferChargesView.constant = 0
            cancelOrTransferUnitView.isHidden = true
            
            heightOfAssignChargesView.constant = 400
            assignUnitView.isHidden = false
            
            let pricingInfo : ApprovalPricingInfo = selectedApproval.pricingInfo!
            assignUnitAmountBilledLabel.text = String(format: "%.2f", pricingInfo.demandLetterAmount)
            assignUnitTaxOnAmountBilled.text = String(format: "%.2f", pricingInfo.taxPaid)
            assignUnitAmountReceived.text = String(format: "%.2f", pricingInfo.amountReceived)
            assignUnitAmountDue.text = String(format: "%.2f", pricingInfo.amountDue)
            assignUnitClientName.text = selectedApproval.new_customer_name
            assignUnitAssignmentCharges.text = String(format: "%.2f", pricingInfo.assignmentCharge)
            assignUnitTaxOnAssignmentCharges.text = String(format: "%.2f", pricingInfo.assignmentChargeTax)
            self.shouldShowIncoming(isIncomingApprovals: self.isIncomingApprovals)

            
        }
        else if(approvalType == APPROVAL_TYPES.TRANSFER_UNIT_APPROVAL){
            approvalTypeInfoLabel.text = " Transfer Unit "
            
            unitTypeRequestLetterLabel.text = "Unit Transfer Request Letter"
            unitTypeCancellationChargesLabel.text = "Unit Cancellation Charges"
            unitTypeTaxOnUnitLabel.text = "Tax on Unit Transfer"
            unitTotalTypeChargesLabel.text = "Total Unit Transfer Charges"
            unitWaiveOffTypeChargesLabel.text = "Waive of Transfer Charges (Amt)"
            
            phoneNumberLabel.text = selectedApproval.approver_userinfo_phone
            
            heightConstraintOfButtonsView.constant = 0
            buttonsView.isHidden = true
            heightOfHistoryView.constant = 0
            historyView.isHidden = true
            heightOfBillingElemetnsView.constant = 0
            billingElementsView.isHidden = true
            
            heightOfHistoryView.constant = 200
            historyView.isHidden = false
            
            heightOfCancelOrTransferChargesView.constant = 600
            cancelOrTransferUnitView.isHidden = false

            let pricingInfo : ApprovalPricingInfo = selectedApproval.pricingInfo!
            
            ctTotalAmountReceivedLabel.text = String(format: "%.2f", pricingInfo.amountReceived)
            ctUnitCancelDateLabel.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedApproval.cancellation_date!, dateFormat: "dd/MM/yy")
            ctTaxLabel.text =  String(format: "%.2f", pricingInfo.taxPaid)
            ctTaxRefundLabel.text = String(format: "%.2f", pricingInfo.taxAmountRefund)
            ctInvoiceAmountLabel.text = String(format: "%.2f", pricingInfo.amountReceived)
            ctUnitCancellationCharges.text = String(format: "%.2f", pricingInfo.cancellationCharge)
            ctTaxOnUnitCancellationLabel.text = String(format: "%.2f", pricingInfo.cancellationChargeTax)
            totalAmountPayable.text = String(format: "%.2f", pricingInfo.amountDue)
            
            ctTaxOnUnitCancellationLabel.text = String(format: "%.2f", pricingInfo.cancellationChargeTax)
            ctTotalUnitCancellationLabel.text = String(format: "%.2f", pricingInfo.cancellationCharge)
            ctWaiveOfUnitCancellationCharges.text = String(format: "%.2f", pricingInfo.waiveOffCharges)

            
            if(selectedApproval.pdc_return_date != nil){
                ctPDCReturnDateLabel.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedApproval.pdc_return_date!, dateFormat: "dd/MM/yy")
            }else{
                ctPDCReturnDateLabel.text = "-"
            }
            if(selectedApproval.agreement_collected_date != nil){
                ctAgreementCollectedDate.text = RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: selectedApproval.agreement_collected_date!, dateFormat: "dd/MM/yy")
            }
            else{
                ctAgreementCollectedDate.text = "-"
            }
            self.shouldShowIncoming(isIncomingApprovals: self.isIncomingApprovals)
        }
        else if(approvalType == APPROVAL_TYPES.BOOKING_FORM_APPROVAL){
            
            approvalTypeInfoLabel.text = " Booking Form "
            approvalTypeInfoLabel.backgroundColor = .blue
//            print(selectedApproval.id)
//            print(selectedApproval)

            phoneNumberLabel.text = selectedApproval?.customer_phone ?? "--"
            
            heightOfAssignChargesView.constant = 0
            assignUnitView.isHidden = true

            heightOfHistoryView.constant = 0
            historyView.isHidden = true
            
            heightOfBillingElemetnsView.constant = 0
            billingElementsView.isHidden = true

            heightOfCancelOrTransferChargesView.constant = 0
            cancelOrTransferUnitView.isHidden = true

            heightOfPDFView.constant = 100
            pdfButtonView.isHidden = false
            
            self.shouldShowIncoming(isIncomingApprovals: self.isIncomingApprovals)

        }
        else if(approvalType == APPROVAL_TYPES.AGREEMENTS_PRINT_APPROVAL){
            approvalTypeInfoLabel.text = " Agreement Print "
            approvalTypeInfoLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "408f2b")
            
            phoneNumberLabel.text = selectedApproval?.customer_phone ?? "--"
            assignUnitView.isHidden = true
            billingElementsView.isHidden = true
            
            if(selectedApproval?.customer_phone == nil){
                self.heightOfPhoneNumberView.constant = 0
                self.phoneNumberView.isHidden = true
                self.gapBwPhoneAndApproverInfoViews.constant = 0
            }
            
            self.shouldShowIncoming(isIncomingApprovals: self.isIncomingApprovals)

        }
        
        let nib1 = UINib(nibName: "ApprovalBillingTableViewCell", bundle: nil)
        billingElemensTableView.register(nib1, forCellReuseIdentifier: "billingInfoCell")
        
        billingElemensTableView.tableFooterView = UIView()
        
        billingElemensTableView.estimatedRowHeight = 180
        billingElemensTableView.rowHeight = UITableView.automaticDimension
        
        billingElemensTableView.delegate = self
        billingElemensTableView.dataSource = self
        
        if(!isFromNotification){
            self.fetchBillingElements()
        }
        
        approverOrRequesterNameLabel.text = selectedApproval.regInfo_userName ?? selectedApproval.customer_name ?? "Unit"
        var unitInfoStr = String(format: "%@ | %@ | %@ | %@", (selectedApproval.unitDescription ?? ""),(selectedApproval.blockName ?? ""),(selectedApproval.towerName ?? ""),(selectedApproval.projectName ?? ""))
        
        if(self.selectedApproval.scheme != nil){
            unitInfoStr.append(String(format: " | Scheme: %@", RRUtilities.sharedInstance.model.getSchemeByID(schemeID: self.selectedApproval.scheme!)))
        }
        
        unitInfoLabel.text = unitInfoStr
        emailLabel.text = selectedApproval.regInfo_userEmail ?? selectedApproval.customer_email ?? "--"

        if(emailLabel.text != nil && emailLabel.text!.count == 0){
            emailLabel.text = "--"
        }
        
        if(emailLabel.text == "--"){ //selectedApproval.regInfo_userEmail == nil
            self.heightOfEmailView.constant = 0
            self.gapBwEmailAndPhoneViews.constant = 0
            self.emailView.isHidden = true
        }
        
        requesterNameLabel.text = selectedApproval.requester_userinfo_name ?? "Super Admin"
        approverNameLabel.text = selectedApproval.approver_userinfo_name
        
        if(approvalType == APPROVAL_TYPES.DISCOUNT_APPROVAL){
            
            var totalUnitCost : Double = 0.0
            var discountedAmount : Double = 0.0
            
            if(isFromNotification){
                for eachBillingElement in selectedApproval.billingInfos?.array as? [BillingInfo] ?? []{
                    totalUnitCost += eachBillingElement.rate
                    discountedAmount += eachBillingElement.discountedAmt
                }
            }
            else
            {
                for eachBillingElement in fetchedResultsControllerBillingElementes.fetchedObjects!{
                    totalUnitCost += eachBillingElement.rate
                    discountedAmount += eachBillingElement.discountedAmt
                }
            }
            
            self.totalUnitCostLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,totalUnitCost)
            self.discountAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,discountedAmount)
            self.revisedUnitCostLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,(totalUnitCost - discountedAmount))
        }

        
    }
    func shouldShowUnitDiscountDetails(shouldShow : Bool){
        
        if(shouldShow){
            self.heightOfUnitCostView.constant = 49
            self.heightOfRevisedUnitCostView.constant = 30
            self.gapBetweenUnitCostsViews.constant = 28
            self.gepBetweenApproverNDiscountView.constant = 30
        }else{
            self.heightOfUnitCostView.constant = 0
            self.heightOfRevisedUnitCostView.constant = 0
            self.gapBetweenUnitCostsViews.constant = 0
            self.gepBetweenApproverNDiscountView.constant = 0
        }
        self.unitCostVIew.isHidden = !shouldShow
        self.revisedUnitCostView.isHidden = !shouldShow
        
        self.bottomConstraintOfRevisedUnitView.constant = 10
    }
    func shouldShowIncoming(isIncomingApprovals : Bool){
        if(!isIncomingApprovals){
            
            heightConstraintOfButtonsView.constant = 0
            buttonsView.isHidden = true
            
        }
        else{
            
            heightOfHistoryView.constant = 0
            historyView.isHidden = true
            
            heightConstraintOfButtonsView.constant = 50
            buttonsView.isHidden = false
        }
    }
    func fetchBillingElements(){
        
        if(isFromNotification){
            return
        }
        let request: NSFetchRequest<BillingInfo> = BillingInfo.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(BillingInfo.orderID), ascending: true)
        request.sortDescriptors = [sort]
        
        let predicate = NSPredicate(format: "isIncoming == %d AND approval_type == %d AND approval_id == %@", self.isIncomingApprovals,self.approvalType.rawValue,self.selectedApproval.id!)
        request.predicate = predicate
        
        fetchedResultsControllerBillingElementes = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try fetchedResultsControllerBillingElementes.performFetch()
            print(fetchedResultsControllerBillingElementes.fetchedObjects!.count)
            self.heightOfBillingElementsTableView.constant = CGFloat(fetchedResultsControllerBillingElementes.fetchedObjects!.count * 180)
            self.billingElemensTableView.reloadData()
            if(fetchedResultsControllerBillingElementes.fetchedObjects!.count > 0){
                self.billingElemensTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            }
        }
        catch {
            fatalError("Error in fetching records")
        }

    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showPDFView(_ sender: UIButton) {
        
        if(approvalType == APPROVAL_TYPES.BOOKING_FORM_APPROVAL){
            self.delegate?.didClickPdfView(approvalType: approvalType, selectedApproval: self.selectedApproval)
        }
    }
    @IBAction func acceptApproval(_ sender: Any) {

        if(self.isIncomingApprovals){
            if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.INCOMING_APPROVALS.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
                HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
                return
            }
        }
        else{
            if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.OUTGOING_APPROVALS.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
                HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
                return
            }
        }
        
        didClickAcceptButton = true
        self.makeServerCall()
    }
    
    @IBAction func rejectApproval(_ sender: Any) {
        
        if(self.isIncomingApprovals){
            if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.INCOMING_APPROVALS.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
                HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
                return
            }
        }
        else{
            if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.OUTGOING_APPROVALS.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
                HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
                return
            }
        }

        didClickAcceptButton = false
        self.makeServerCall()
    }
    func makeServerCall(){
        showInputDialog(title: "REroot",
                        subtitle: "Leave Remark",
                        actionTitle: "CONFIRM",
                        cancelTitle: "CANCEL",
                        inputPlaceholder: "Remarks",
                        inputKeyboardType: .default)
        { (input:String?) in
            print("The Remark is \(input ?? "")")
            
            var parameters : Dictionary<String,String> = [:]
            
            parameters["id"] = self.selectedApproval.id
            parameters["approval_type"] = String(format: "%d", self.approvalType.rawValue)
            parameters["reference"] = self.selectedApproval.reference_item_id
            parameters["remarks"] = input
            
            if(self.didClickAcceptButton){ //accept
                
                ServerAPIs.approveIncomingApproval(parameteres: parameters, completionHandler: { (responseObject, erro) in
                    if(responseObject){
                        self.delegate?.didApproveApproval(selectedApproval: self.selectedApproval)
                        if(self.isFromNotification){
                            NotificationCenter.default.post(name: NSNotification.Name("NotificationsCall"), object: nil)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                    else{
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
            else{ //reject
                
                ServerAPIs.rejectIncomingApproval(parameteres: parameters, completionHandler: { (responseObject, erro) in
                    if(responseObject){
                        self.delegate?.didApproveApproval(selectedApproval: self.selectedApproval)
                        if(self.isFromNotification){
                            NotificationCenter.default.post(name: NSNotification.Name("NotificationsCall"), object: nil)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                    else{
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
            
        }
    }
    // MARK: - Tableview Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == approvalsHistoryTableView){
            return approvalHistoryDataSource.count
        }
        if(isFromNotification){
            return selectedApproval.billingInfos?.array.count ?? 0
        }
        return fetchedResultsControllerBillingElementes.fetchedObjects!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == approvalsHistoryTableView){
            
            let cell : ApprovalHistoryTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "approvalHistoryCell",
                for: indexPath) as! ApprovalHistoryTableViewCell

            let approvalHistory = approvalHistoryDataSource[indexPath.row]

            var infoLabelText = String(format: "Approver: %@\nRequested On: %@", approvalHistory.approver_userinfo_name!,RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: approvalHistory.created!, dateFormat: "dd MMM,yyyy • hh:mm a"))

            if(approvalHistory.status == APPROVAL_STATUS.PENDING.rawValue){
                cell.approvalStatusLabel.text = "Pending"
                cell.statusTypeImageView.image = UIImage.init(named: "pending")
            }
            else if(approvalHistory.status == APPROVAL_STATUS.APPROVED.rawValue){
                cell.approvalStatusLabel.text = "Approved"
                cell.statusTypeImageView.image = UIImage.init(named: "otp_success_icon")
                infoLabelText.append(String(format: "\nApproved On: %@",RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: approvalHistory.lastModified!, dateFormat: "dd mm yyyy . hh:mm a")))
            }
            else if(approvalHistory.status == APPROVAL_STATUS.REJECTED.rawValue){
                cell.approvalStatusLabel.text = "Rejected"
                cell.statusTypeImageView.image = UIImage.init(named: "reject")
                infoLabelText.append(String(format: "\nRejected On: %@",RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: approvalHistory.lastModified!, dateFormat: "dd mm yyyy . hh:mm a")))
            }
            else if(approvalHistory.status == APPROVAL_STATUS.IN_PIPELINE.rawValue){
                cell.approvalStatusLabel.text = "In Pipeline"
                cell.statusTypeImageView.image = UIImage.init(named: "pending")
            }
            else if(approvalHistory.status == APPROVAL_STATUS.INVALIDATED.rawValue){
                cell.approvalStatusLabel.text = "Invalid"
                cell.statusTypeImageView.image = UIImage.init(named: "invalid")
                infoLabelText.append(String(format: "\nInvalidated On: %@",RRUtilities.sharedInstance.getDateWithCustomDateFormat(dateStr: approvalHistory.lastModified!, dateFormat: "dd mm yyyy . hh:mm a")))
            }
            
            if(approvalHistory.remarks != nil){
                infoLabelText.append(String(format: "\nRemarks: %@",approvalHistory.remarks!))
            }

            
            cell.approvalDetailsLabel.text = infoLabelText
            
            if(indexPath.row == approvalHistoryDataSource.count - 1){
                cell.verticalLineView.isHidden = true
            }
            else{
                cell.verticalLineView.isHidden = false
            }
            cell.contentView.backgroundColor = UIColor.red
            return cell
        }
        else{
            let cell : ApprovalBillingTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "billingInfoCell",
                for: indexPath) as! ApprovalBillingTableViewCell
            
            var billingElement : BillingInfo!
            
            if(isFromNotification){
                let infos = selectedApproval.billingInfos?.array as! [BillingInfo]
                billingElement = infos[indexPath.row]
            }
            else{
                billingElement = fetchedResultsControllerBillingElementes.object(at: indexPath)
            }
            
            if(billingElement.sub_BillingElement_name != nil){
                cell.billingElementTypeLabel.text = String(format: "%@\n(%@)", billingElement.billingElement_name!,billingElement.sub_BillingElement_name!)
            }
            else{
                cell.billingElementTypeLabel.text = billingElement.billingElement_name
            }
            
            if(billingElement.discountedPercent > 0){
                cell.billingElementTypeLabel.textColor = .red
                cell.heightConstraintOfDiscountView.constant = 60
                cell.discountInfoView.isHidden = false
            }
            else{
                cell.billingElementTypeLabel.textColor = .black
                cell.heightConstraintOfDiscountView.constant = 0
                cell.discountInfoView.isHidden = true
            }
            
            cell.discountPercentLabel.text = String(format: "%.2f", billingElement.discountedPercent)
            cell.discoutnAmountLabel.text = String(format: "%.2f", billingElement.discountedAmt)
            cell.currentRateLabel.text = String(format: "%.2f", (billingElement.rate/Double(billingElement.qty)))
            cell.revisedAmountLabel.text = String(format: "%.2f", billingElement.discountedRate)
            cell.amountLabel.text = String(format: "%.2f", billingElement.rate)
            cell.areaQtyLabel.text = String(format: "%.2f", billingElement.qty)
            cell.pricingTypeLabel.text = String(format: "%@", billingElement.type ?? "--")
            
            return cell
        }
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        self.approvalsHistoryTableView.reloadData()
//        self.billingElemensTableView.reloadData()
//        self.approvalsHistoryTableView.layoutIfNeeded()
//        self.billingElemensTableView.layoutIfNeeded()
        self.heightOfBillingElementsTableView.constant = self.billingElemensTableView.contentSize.height + 12
        self.heightOfHistoryTableView.constant = self.approvalsHistoryTableView.contentSize.height + 25

        if(self.billingElemensTableView.contentSize.height == 0){
            self.heightOfBillingElemetnsView.constant = 0
        }else{
            self.heightOfBillingElemetnsView.constant = self.billingElemensTableView.contentSize.height + 20
        }
        if(self.approvalsHistoryTableView.contentSize.height == 0){
            self.heightOfHistoryView.constant = 0
        }
        else{
            self.heightOfHistoryView.constant = self.approvalsHistoryTableView.contentSize.height + 30
        }

    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.billingElemensTableView.reloadData()
        self.approvalsHistoryTableView.reloadData()
//        self.approvalsHistoryTableView.layoutIfNeeded()
//        self.billingElemensTableView.layoutIfNeeded()
        self.heightOfBillingElementsTableView.constant = self.billingElemensTableView.contentSize.height + 12
        self.heightOfHistoryTableView.constant = self.approvalsHistoryTableView.contentSize.height + 25

        if(self.billingElemensTableView.contentSize.height == 0){
            self.heightOfBillingElemetnsView.constant = 0
        }else{
            self.heightOfBillingElemetnsView.constant = self.billingElemensTableView.contentSize.height + 20
        }
        if(self.approvalsHistoryTableView.contentSize.height == 0){
            self.heightOfHistoryView.constant = 0
        }
        else{
            self.heightOfHistoryView.constant = self.approvalsHistoryTableView.contentSize.height + 30
        }

    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.approvalsHistoryTableView.layoutIfNeeded()
//        self.billingElemensTableView.layoutIfNeeded()
        self.heightOfBillingElementsTableView.constant = self.billingElemensTableView.contentSize.height + 12
        self.heightOfHistoryTableView.constant = self.approvalsHistoryTableView.contentSize.height + 25
        
        if(self.billingElemensTableView.contentSize.height == 0){
            self.heightOfBillingElemetnsView.constant = 0
        }else{
            self.heightOfBillingElemetnsView.constant = self.billingElemensTableView.contentSize.height + 20
        }
        if(self.approvalsHistoryTableView.contentSize.height == 0){
            self.heightOfHistoryView.constant = 0
        }
        else{
            self.heightOfHistoryView.constant = self.approvalsHistoryTableView.contentSize.height + 30
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.heightOfBillingElementsTableView.constant = self.billingElemensTableView.contentSize.height + 12
        self.heightOfHistoryTableView.constant = self.approvalsHistoryTableView.contentSize.height + 25
        
        if(self.billingElemensTableView.contentSize.height == 0){
            self.heightOfBillingElemetnsView.constant = 0
        }else{
            self.heightOfBillingElemetnsView.constant = self.billingElemensTableView.contentSize.height + 20
        }
        if(self.approvalsHistoryTableView.contentSize.height == 0){
            self.heightOfHistoryView.constant = 0
        }
        else{
            self.heightOfHistoryView.constant = self.approvalsHistoryTableView.contentSize.height + 30
        }
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
extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Confirm",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}
