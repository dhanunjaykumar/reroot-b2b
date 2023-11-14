//
//  QuickLinksViewController.swift
//  REroot
//
//  Created by Dhanunjay on 18/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PKHUD

enum TabelViewCellType : Int{
    case PaymentSchdule = 1
    case ProspectHistory = 2
    case StatementOfAccount = 3
    case HANDOVER_HOSTORY = 4
    case UNIT_COST_BREAKUP = 5
    case OUTSTANDINGS = 6
}

class QuickLinksViewController: UIViewController {

    var siteVistActionId : String = ""
    var isFromDatePopUp = false
    var isFromOpportunitites = false
    var isFromDiscountView = false
    
    var prospectDetails : REGISTRATIONS_RESULT!
    @IBOutlet weak var unitDetailsLabel: UILabel!
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var heightOfTitleView: NSLayoutConstraint!
    @IBOutlet weak var invoicedAmountLabel: UILabel!
    @IBOutlet weak var receivedAmountLabel: UILabel!
    @IBOutlet weak var outstandingAmountLabel: UILabel!
    @IBOutlet weak var outstandingInfoView: UIView!
    @IBOutlet weak var heightOfOutstandingView: NSLayoutConstraint!
    var isOutstanding : Bool = false
    var selectedOutstanding : CustomerOutstanding!
    var cosTimelineData : [Cof] = []
    // ** OUTstanding data
    
    var titleText : String!
    @IBOutlet weak var widthOfCloseButton: NSLayoutConstraint!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var cellType : TabelViewCellType!
    var qrHistoryDataSource : QR_HISTORY!
    var isSuperAdminDone : Bool = false
    var prospectRegId : String!
    var installments : [INSTALLMENT_ID] = []
    var handOverItemHistory : [UnitHandOverHistory] = []
    var unitRate : UNIT_RATE!
    var paymentScheduleUnitRate : UNIT_RATE!
    var selectedUnitStatus : UNIT_STATUS!
    var selectedPaymentScheduleIndexPath : IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    func configureView(){
        
//        print("handOverHistory")
//        print(handOverItemHistory)
        
        if(isOutstanding){
            
            heightOfOutstandingView.constant = 150
            outstandingInfoView.isHidden = false
            
            unitNameLabel.text = String(format: "%@ (%@)", selectedOutstanding.unitDisplayName ?? "",selectedOutstanding.description1 ?? "")
            unitDetailsLabel.text = String(format: "%@ | %@ | %@", selectedOutstanding.projectName ?? "",selectedOutstanding.blockName ?? "",selectedOutstanding.towerName ?? "")

            invoicedAmountLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,(selectedOutstanding.demandLetterTax + selectedOutstanding.demandLetterAmount))
            receivedAmountLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,selectedOutstanding.totalReceipt)
            outstandingAmountLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,((selectedOutstanding.demandLetterTax + selectedOutstanding.demandLetterAmount) - selectedOutstanding.totalReceipt))
            heightOfTitleView.constant = 0
            titleView.isHidden = true
            
            let nib = UINib(nibName: "OutstandingTimelineTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "cosTimeline")

            tableView.estimatedRowHeight = 50
            tableView.rowHeight = UITableView.automaticDimension
            tableView.separatorStyle = .none
            self.reloadTableView()

        }
        else{
            heightOfOutstandingView.constant = 0
            outstandingInfoView.isHidden = true
        }
        
        let tempHistory = UnitHandOverHistory.init(context: RRUtilities.sharedInstance.model.managedObjectContext)
        tempHistory.user = ""
        tempHistory.status = 0
        tempHistory.modifiedDate = ""
        
        handOverItemHistory.insert(tempHistory, at: 0)
        

        tableView.separatorColor = UIColor.hexStringToUIColor(hex: "f9f9f9")
        
        let nib2 = UINib(nibName: "HandOverHistoryTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "itemHistory")
        
        let nib = UINib(nibName: "PaymentScheduleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "paymentSchedule")
        
        let nib1 = UINib(nibName: "QRHistoryTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "qrHistoryCell")
        
        let nib3 = UINib(nibName: "BillingElementsTableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "unitCostBreakUpCell")
        
        tableView.tableFooterView = UIView()
        
        if(cellType == TabelViewCellType.PaymentSchdule){
            
            tableView.estimatedRowHeight = UITableView.automaticDimension
            tableView.rowHeight = UITableView.automaticDimension

            self.titleLabel.text = "PAYMENT SCHEDULE"
            self.tableView.separatorStyle = .singleLine
            self.reloadTableView()
        }
        else if(cellType == TabelViewCellType.ProspectHistory){
            self.titleLabel.text = "ACTION HISTORY"
            self.getProspectActionHistory(prospectRegId: prospectRegId)
        }
        else if(cellType == TabelViewCellType.HANDOVER_HOSTORY){
            
            self.titleLabel.text = self.titleText
            self.titleLabel.textAlignment = .center
            self.widthOfCloseButton.constant = 0
            self.reloadTableView()
        }
        else if(cellType == TabelViewCellType.UNIT_COST_BREAKUP){
            
            let headerNib = UINib.init(nibName: "PopUpHeaderView", bundle: Bundle.main)
            tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "PopUpHeaderView")

            tableView.estimatedRowHeight = UITableView.automaticDimension
            tableView.rowHeight = UITableView.automaticDimension

            self.tableView.separatorStyle = .none
            self.titleView.backgroundColor = .white
            self.titleLabel.text = "UNIT COST BREAKUP"
            self.widthOfCloseButton.constant = 50
            self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
            tableView.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
            self.reloadTableView()
            self.perform(#selector(adjustTableViewHeight), with: nil, afterDelay: 0.3)
        }
        else{
            self.titleLabel.text = "STATEMENT OF ACCOUNT"
        }
    }
    @objc func adjustTableViewHeight(){
        //self.tableView.contentSize.height
    }
    func reloadTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    func getProspectActionHistory(prospectRegId : String){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        HUD.show(.progress)
        ServerAPIs.getProspectActionHistory(prospectRegID: prospectRegId, completionHandler: { (responseObject,error) in
            HUD.hide()
            if(responseObject != nil){
                self.qrHistoryDataSource = responseObject?.data
                self.reloadTableView()
            }
            else{
                HUD.flash(.label("Couldn't fetch history. Plese try later"), delay: 1.0)
            }
        })
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
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
extension QuickLinksViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(tableView.tag == 100){
            if(unitRate != nil && (unitRate.pBes?.pDetails?.count) ?? 0 > 0){
                return (unitRate.pBes?.pDetails?.count ?? 0) + 1
            }
            return 1
        }
        else if(cellType == TabelViewCellType.ProspectHistory){
            return 1 + (self.qrHistoryDataSource.leads?.count ?? 0) + (self.qrHistoryDataSource.opportunities?.count ?? 0)
        }
        else if(cellType == TabelViewCellType.PaymentSchdule)
        {
            return 1
        }
        else if(cellType == TabelViewCellType.UNIT_COST_BREAKUP){
            
            if(unitRate != nil && (unitRate.pBes?.pDetails?.count) ?? 0 > 0){
                return (unitRate.pBes?.pDetails?.count ?? 0) + 1
            }
            return 1
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(isOutstanding){
            
            if (cosTimelineData.count > 0)
            {
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text = "No data available"
                noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return cosTimelineData.count

        }
        
        if(cellType == TabelViewCellType.UNIT_COST_BREAKUP){
            if(section == 0){
                return unitRate?.bes?.details?.count ?? 0
            }
            else if(section >= 1){
                if(((unitRate?.pBes?.pDetails?.count ?? 0)) > 0){
                    let pElemetns : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![section-1])!
                    return pElemetns.details?.count ?? 0
                }
                return 0
            }
        }
        else if(tableView.tag == 100){
            if(section == 0){
                return unitRate?.bes?.details?.count ?? 0
            }
            else if(section >= 1){
                if(((unitRate?.pBes?.pDetails?.count ?? 0)) > 0){
                    let pElemetns : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![section-1])!
                    return pElemetns.details?.count ?? 0
                }
                return 0
            }
        }
        else if(cellType == TabelViewCellType.ProspectHistory){
            
            let registrations = self.qrHistoryDataSource.quickregistrations!
            
            var registrationRowsCount = 1
            
            let leadsAndRegCount = (1 + self.qrHistoryDataSource.leads!.count)
            let allSectionsCount = (1 + self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)
            
            if(section == 0){
                if((registrations.updateBy?.count)! > 0){
                    
                    let updateBysArray : [UpdatedByForProspects] = registrations.updateBy!
                    
                    for updateBy in updateBysArray{
                        
                        if(updateBy.oldSalesPerson != nil)
                        {
                            registrationRowsCount = registrationRowsCount + 1
                        }
                    }
                }
                return registrationRowsCount
            }
            else if(section > 0 && section < leadsAndRegCount){
                var leadsRowsCount = 1
                let rowLead = self.qrHistoryDataSource.leads![section-1]
                
                if((rowLead.updateBy?.count)! > 0){
                    let leadUpdates : [UpdatedByForProspects] = rowLead.updateBy!
                    for leadUpdate in leadUpdates{
                        if(leadUpdate.oldSalesPerson != nil){
                            leadsRowsCount = leadsRowsCount + 1
                        }
                    }
                    return leadsRowsCount
                }
                else{
                    return 1
                }
            }
            else if(section >= leadsAndRegCount && section <= allSectionsCount)
            {
                var opportunitiesRowsCount = 1
                let opportunity = self.qrHistoryDataSource.opportunities![(section - leadsAndRegCount)]
                if((opportunity.updateBy?.count)! > 0){
                    let oppUpdates : [UpdatedByForProspects] = opportunity.updateBy!
                    for oppUpdate in oppUpdates{
                        if(oppUpdate.oldSalesPerson != nil){
                            opportunitiesRowsCount = opportunitiesRowsCount + 1
                        }
                    }
                    return opportunitiesRowsCount
                }
                else{
                    return opportunitiesRowsCount
                }
            }
        }
        else if(cellType == TabelViewCellType.PaymentSchdule){
            return installments.count
        }
        else if(cellType == TabelViewCellType.HANDOVER_HOSTORY){
            return handOverItemHistory.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(isOutstanding){
            
            let cell : OutstandingTimelineTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "cosTimeline",
                for: indexPath) as! OutstandingTimelineTableViewCell

            let timelineInfo = cosTimelineData[indexPath.row]
            
            if(timelineInfo.mode == "By Post"){
                cell.modeImageView.image = UIImage.init(named: "post_box")
            }
            else if(timelineInfo.mode == "Email"){
                cell.modeImageView.image = UIImage.init(named: "mail")
            }
            else if(timelineInfo.mode == "Personal Visit"){
                cell.modeImageView.image = UIImage.init(named: "person")
            }
            else if(timelineInfo.mode == "Call"){
                cell.modeImageView.image = UIImage.init(named: "phone")
            }
            else{
                cell.modeImageView.image = UIImage.init(named: "post_box")
            }

            
            cell.modeLabel.text = timelineInfo.mode
            var detailsStr = ""
            detailsStr.append(contentsOf: String(format: "Comments: %@", timelineInfo.comment ?? ""))
            if let updateBy : CosUpdateBy = timelineInfo.updateBy?[0]{
                detailsStr.append(contentsOf: String(format: "\nFollowed By: %@\n%@", updateBy.user?.email ?? "",RRUtilities.sharedInstance.getNotificationViewDate(dateStr: updateBy.date ?? "")))
            }
            let amtStr = String(format: "Outstanding Amount: %@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")! ,timelineInfo.outstandingAmount)
            detailsStr.append(contentsOf: String(format: "\nOutstanding Amount: %@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")! ,timelineInfo.outstandingAmount))

            let range = (detailsStr as NSString).range(of: amtStr)
            let attribute = NSMutableAttributedString.init(string: detailsStr)
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.hexStringToUIColor(hex: "7093C8") , range: range)

            cell.followDetailsInfoLabel.attributedText = attribute
            
            if(indexPath.row == cosTimelineData.count-1){
                cell.verticalLineView.isHidden = true
            }
            else{
                cell.verticalLineView.isHidden = false
            }
            
            return cell
            
        }
        
        
        if(cellType == TabelViewCellType.UNIT_COST_BREAKUP || tableView.tag == 100){
            
            let cell : BillingElementsTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "unitCostBreakUpCell",
                for: indexPath) as! BillingElementsTableViewCell
            
            cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
            cell.heightOfPermiumInfoView.constant = 0
            cell.premiumViewInfo.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
            
            if(indexPath.section == 0){  // billing elements
                
                cell.heightOfPermiumInfoView.constant = 0
                cell.premiumViewInfo.isHidden = true
                
                cell.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")
                cell.taxesInfoView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")
                cell.premiumAmountView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")
                cell.amountIncludingTaxesView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")


//                cell.premiumAmountStackView.isHidden = false
                
                cell.premiumAmountView.isHidden = true
                cell.heightOfPremiumAmountView.constant = 0
                
                let element : BILLING_ELEMENT_DETAILS = (unitRate.bes?.details![indexPath.row])!
                
                cell.elementNameLabel.text = String(format: "%@", element.name!)
                cell.rateLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.elementRate!)
                cell.areaOrQtyLabel.text = String(format: "%.2f", element.qty!)
                cell.pricingTypeLabel.text = element.pricingType
                
                if(element.discountedRate == 0 || element.discountedPercent == 0){
                    cell.discountInfoView.isHidden = true
                    cell.heightOfDiscountView.constant = 0
                }
                else{
                    cell.discountInfoView.isHidden = false
                    cell.heightOfDiscountView.constant = 40
                    
                    cell.discountAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.discountedRate!)
                    cell.discountPercentageLabel.text = String(format: "%.2f %%",element.discountedPercent!)
                }
                
                if(selectedUnitStatus == UNIT_STATUS.VACANT || selectedUnitStatus == UNIT_STATUS.RESERVED || selectedUnitStatus == UNIT_STATUS.BLOCKED){
                    cell.amountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.totalElementRate!)
                    cell.revisedAmountLabel.text = "--"
                }
                else{
                    cell.amountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.totalElementRate!)
                    cell.revisedAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.finalRate!)
                }
                
                if((element.element?.taxVal ?? 0) <= 0 || (element.element?.finalTaxVal ?? 0) <= 0){
                    cell.taxesInfoView.isHidden = true
                    cell.heightOfTaxView.constant = 0
                }
                else{
                    cell.taxesInfoView.isHidden = false
                    cell.heightOfTaxView.constant = 40

                    if(selectedUnitStatus == UNIT_STATUS.VACANT || selectedUnitStatus == UNIT_STATUS.RESERVED || selectedUnitStatus == UNIT_STATUS.BLOCKED){
                        let percentage = ((element.element?.finalTaxVal  ?? 0.0) / (element.finalRate ?? 0.0)) * 100
                        cell.taxesAmountLabel.text = String(format: "%@ %.2f (%.2f%%)", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.element!.taxVal!,percentage)
                        cell.revisedTaxesAmountLabel.text = "--"
                    }
                    else{
                        let percentage = ((element.element?.finalTaxVal  ?? 0.0) / (element.finalRate ?? 0.0)) * 100
                        cell.taxesAmountLabel.text = String(format: "%@ %.2f (%.2f%%)", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.element!.taxVal!,percentage)
                        cell.revisedTaxesAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.element!.finalTaxVal!)
                    }
                }
                
                if(selectedUnitStatus == UNIT_STATUS.VACANT || selectedUnitStatus == UNIT_STATUS.RESERVED || selectedUnitStatus == UNIT_STATUS.BLOCKED){
                    cell.amountIncludingTaxesLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,((element.totalElementRate ?? 0) + Double(element.element?.taxVal ?? 0)))
                    cell.revisedAmountIncludingTaxesLabl.text = "--"
                }
                else{
                    cell.amountIncludingTaxesLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,((element.totalElementRate ?? 0) + Double(element.element?.taxVal ?? 0)))
                    cell.revisedAmountIncludingTaxesLabl.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,(element.finalRate ?? 0) + Double( element.element!.finalTaxVal ?? 0))
                }
//                cell.premiumAmountStackView.isHidden = true
//                cell.amountIncludingTaxesStackView.isHidden = true
                cell.subContentView.layoutIfNeeded()
            }
            else{ //Premium billing elements
                
//                let pElemetns : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![section])!
//                return pElemetns.details?.count ?? 0

                let tempElement : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![indexPath.section-1])!
                
                let element : PREMIUM_BILLING_ELEMENT_DETAILS = tempElement.details![indexPath.row]

                if(indexPath.row == 0){
                    cell.heightOfPermiumInfoView.constant = 40
                    cell.premiumViewInfo.isHidden = false
                }
                else{
                    cell.heightOfPermiumInfoView.constant = 0
                    cell.premiumViewInfo.isHidden = true
                    
                    if(element.name != nil){
                        cell.premiumUnitImageView.image = UIImage(named: "premium_icon")
                    }

                    if(tempElement.pElement?.name != nil){
                        cell.premiumUnitImageView.image = UIImage(named: "other_premium_icon")
                    }
                    
//                    cell.premiumUnitImageView.image = UIImage(named: "other_premium_icon")
//                    cell.premiumUnitImageView.image = UIimage(named : "other_premium_icon")
                    //premium_icon
                    //premiumUnitImageView
                }
                
                
//                print(tempElement)
                
//                cell.topConstraintOfSubContentView.constant = 1
//                cell.bottomConstraintOfSubContentView.constant = 0
                
                
                cell.elementNameLabel.text = String(format: "%@", element.name!)
                cell.rateLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.elementRate!)
                cell.areaOrQtyLabel.text = String(format: "%.2f", element.qty!)
                cell.pricingTypeLabel.text = element.pricingType

                if(element.discountedRate == 0 || element.discountedPercent == 0){
                    cell.discountInfoView.isHidden = true
                    cell.heightOfDiscountView.constant = 0
                }
                else{
                    cell.discountInfoView.isHidden = false
                    cell.heightOfDiscountView.constant = 40
                }

//                cell.amountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.totalElementRate!)
//                cell.revisedAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.finalRate!)
                
                if(selectedUnitStatus == UNIT_STATUS.VACANT || selectedUnitStatus == UNIT_STATUS.RESERVED || selectedUnitStatus == UNIT_STATUS.BLOCKED){
                    cell.amountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.totalElementRate ?? 0)
                    cell.revisedAmountLabel.text = "--"
                }
                else{
                    cell.amountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.totalElementRate ?? 0)
                    cell.revisedAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.finalRate ?? 0)
                }

                

                let pElemetns : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![indexPath.section-1])!
                let counter = pElemetns.details?.count ?? 0
                cell.premiumCompnentLabel.text = tempElement.pElement?.name
                if(indexPath.row == counter-1){
                    // show pElement details

                    let pElement = tempElement.pElement
                    
//                    cell.premiumAmountStackView.isHidden = false
//                    cell.amountIncludingTaxesStackView.isHidden = false
//                    cell.amountStackView.isHidden = false
                    
//                    cell.premiumAmountStackView.isHidden = false
                    
                    if((pElement?.taxVal ?? 0.0) <= 0.0 || (pElement?.finalTaxVal ?? 0.0) <= 0.0){
                        
                        cell.taxesInfoView.isHidden = true
                        cell.heightOfTaxView.constant = 0
                    }
                    else{
                        cell.taxesInfoView.isHidden = false
                        cell.heightOfTaxView.constant = 40
                        
                        if(selectedUnitStatus == UNIT_STATUS.VACANT || selectedUnitStatus == UNIT_STATUS.RESERVED || selectedUnitStatus == UNIT_STATUS.BLOCKED){
                            let percentage = ((pElement?.finalTaxVal ?? 0.0) / (pElement?.finalPcost ?? 0.0)) * 100
                            cell.taxesAmountLabel.text = String(format: "%@ %.2f (%.2f%%)", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,Double(pElement?.taxVal ?? 0),percentage)
                            cell.revisedTaxesAmountLabel.text = "--"
                        }
                        else{
                            let percentage = ((pElement?.finalTaxVal ?? 0.0) / (pElement?.finalPcost ?? 0.0)) * 100
                            cell.taxesAmountLabel.text = String(format: "%@ %.2f (%.2f%%)", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,Double(pElement!.taxVal ?? 0),percentage)
                            cell.revisedTaxesAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,Double(pElement!.finalTaxVal ?? 0))
                        }
                        
                    }
                    

                    let amountStr = String(format: "%.2f", (Double(pElement!.pCost ?? 0.0) + (pElement!.taxVal ?? 0.0)))
                    let finalAmountStr = String(format: "%.2f", (Double(pElement?.finalPcost ?? 0.0) + (pElement?.finalTaxVal ?? 0.0)))

                    if(selectedUnitStatus == UNIT_STATUS.VACANT || selectedUnitStatus == UNIT_STATUS.RESERVED || selectedUnitStatus == UNIT_STATUS.BLOCKED){
                        cell.amountIncludingTaxesLabel.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,amountStr.count > 0 ? amountStr : "--")
                        cell.revisedAmountIncludingTaxesLabl.text = "--"
                    }
                    else{
                        cell.amountIncludingTaxesLabel.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,amountStr.count > 0 ? amountStr : "--")
                        cell.revisedAmountIncludingTaxesLabl.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,finalAmountStr.count > 0 ? finalAmountStr : "--")
                    }
                    
                    let amountStr1 = String(format: "%.2f", (Double(pElement?.pCost ?? 0.0)))
                    let finalAmountStr1 = String(format: "%.2f", (Double(pElement?.finalPcost ?? 0)))
                    
                    if(selectedUnitStatus == UNIT_STATUS.VACANT || selectedUnitStatus == UNIT_STATUS.RESERVED || selectedUnitStatus == UNIT_STATUS.BLOCKED){
                        cell.premiumAmoutLabel.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,amountStr.count > 0 ? amountStr1 : "--")
                        cell.premiumRevisedAmountLabel.text = "--"
                    }
                    else{
                        cell.premiumAmoutLabel.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,amountStr.count > 0 ? amountStr1 : "--")
                        cell.premiumRevisedAmountLabel.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,finalAmountStr.count > 0 ? finalAmountStr1 : "--")
                    }

                    cell.premiumAmountView.isHidden = false
                    cell.heightOfPremiumAmountView.constant = 40

                    cell.taxesInfoView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
                    cell.premiumAmountView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
                    cell.amountIncludingTaxesView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
                    
//                    cell.premiumStackView.addBackground(color: UIColor.hexStringToUIColor(hex: "fff5f4"))
//                    cell.amountIncludingTaxesStackView.addBackground(color: UIColor.hexStringToUIColor(hex: "fff5f4"))
//                    cell.premiumAmountStackView.addBackground(color: UIColor.hexStringToUIColor(hex: "fff5f4"))
//                    cell.taxesStackView.addBackground(color: UIColor.hexStringToUIColor(hex: "fff5f4"))
                    cell.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
                }
                else{
                    cell.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")
                    
                    cell.taxesInfoView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")
                    cell.premiumAmountView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")
                    cell.amountIncludingTaxesView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")
                    
//                    cell.premiumStackView.addBackground(color: UIColor.hexStringToUIColor(hex: "ffffff"))
//                    cell.taxesStackView.isHidden = true
                    //                    cell.amountIncludingTaxesStackView.isHidden = true
                    //                    cell.premiumAmountStackView.isHidden = true
                    cell.taxesInfoView.isHidden  = true
                    cell.heightOfTaxView.constant = 0
                    cell.amountIncludingTaxesView.isHidden = true
                    cell.heightOfPremiumAmountIncludingTaxesView1.constant = 0
                    cell.premiumAmountView.isHidden = true
                    cell.heightOfPremiumAmountView.constant = 0
                    
                    cell.discountInfoView.isHidden = true
                    cell.heightOfDiscountView.constant = 0
                }
            }
            return cell
        }
        else if(cellType == TabelViewCellType.ProspectHistory)
        {
            let cell : QRHistoryTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "qrHistoryCell",
                for: indexPath) as! QRHistoryTableViewCell
            
            cell.heightOfApprovalButton.constant = 0
            cell.checkApprovalButton.isHidden = true
            
            cell.heightOfEditCompletionDate.constant = 0
            cell.editCompletionDate.isHidden = true
            cell.widthOfViewOfferButton.constant = 0
            
            cell.widthOfViewOfferButton.constant = 0
//            cell.heightOfViewOfferButton.constant = 0
            cell.viewOfferButton.isHidden = true

            cell.checkApprovalButton.addTarget(self, action: #selector(showApprovalsView(_:)), for: .touchUpInside)
//            cell.qrTypeInfoLabel.layer.cornerRadius = 4
//            cell.qrTypeInfoLabel.layer.masksToBounds = true
            cell.discountRequestTimeLineData = []
            var commonString = String()
            
//            print(indexPath.section,indexPath.row)
            
            if(indexPath.section == 0){
                
                if(indexPath.row > 0){
                    let registration : QR_REGISTRATIONS = self.qrHistoryDataSource.quickregistrations!
                    
                    var commonString = String()
                    
                    let updates : [UpdatedByForProspects] = registration.updateBy!
                    
                    var tempArray : [UpdatedByForProspects] = []
                    
                    for salesPerson in updates{
                        if(salesPerson.oldSalesPerson != nil){
                            tempArray.append(salesPerson)
                        }
                    }
                    
                    let rowCount = indexPath.row-1
                    
                    cell.qrTypeNameLabel.text = "Change Of Sales Person"
                    cell.qrTypeInfoLabel.text = "S"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.black
                    
                    if(indexPath.row == 1){ //(tempArray.count == indexPath.row){
                        
                        if(tempArray.count > 1){
                            let changedSalesPerson = tempArray[rowCount+1]
                            commonString.append(String(format: "Re-Assigned from Super Admin to %@",(changedSalesPerson.oldSalesPerson?.userInfo?.name!)!))
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                            commonString = commonString + "\n" + date
                        }
                        else{
                            let changedSalesPerson = tempArray[rowCount]
                            if(registration.salesPerson?.userInfo != nil){
                                commonString.append(String(format: "Re-Assigned from Super Admin to %@",(registration.salesPerson?.userInfo?.name!)!))
                            }
                            else{
                                commonString.append(String(format: "Re-Assigned from Super Admin to Super Admin"))
                            }
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                            commonString = commonString + "\n" + date
                            
                        }
                        isSuperAdminDone = true
                    }
                    else{
                        if(indexPath.row <= tempArray.count){
                            
                            let changedSalesPerson = tempArray[indexPath.row-1]
                            
                            if(indexPath.row == tempArray.count){
                                
                                let salesPersonName =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                let chanedPerson = registration.salesPerson?.userInfo?.name
                                if(chanedPerson == nil){
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",salesPersonName,"Super Admin"))
                                }
                                else{
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",salesPersonName,chanedPerson!))
                                }
                                let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                            else{
                                
                                let salesPerson = tempArray[indexPath.row]
                                
                                let changedSaleGUyNmae =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                let salesPersonName = RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (salesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                
                                commonString.append(String(format: "Re-Assigned from %@ to %@",changedSaleGUyNmae,salesPersonName))
                                
                                
                                let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                        }
                    }
                    cell.qrDetailsLabel.text = commonString
                    return cell
                }
                else{
                    //registrations
                    let registration : QR_REGISTRATIONS = self.qrHistoryDataSource.quickregistrations!
                    //
                    //                print(registration)
                    //
                    cell.qrTypeInfoLabel.text = "R"
                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: registration.registrationDate!)
                    cell.qrTypeNameLabel.text = String(format: "%@ - %@", "Registration",date)
                    
                    //                cell.dateLabel.text = date
                    cell.heightOfQRDetailsLabel.constant = 0
                }
                return cell
            }
            if(indexPath.section > 0 && indexPath.section < (1+self.qrHistoryDataSource.leads!.count)){
                
                
                let lead = self.qrHistoryDataSource.leads![indexPath.section - 1]
                
                //                let title = self.getTimelineLabel(label: lead.action?.label ?? "")
                
                if(indexPath.row > 0 && (lead.updateBy?.count)! > 1){
                    var commonString = String()
                    
                    let updates : [UpdatedByForProspects] = lead.updateBy!
                    
                    var tempArray : [UpdatedByForProspects] = []
                    
                    for salesPerson in updates{
                        if(salesPerson.oldSalesPerson != nil){
                            tempArray.append(salesPerson)
                        }
                    }
                    
                    let rowCount = indexPath.row-1
                    
                    cell.qrTypeNameLabel.text = "Change Of Sales Person"
                    cell.qrTypeInfoLabel.text = "S"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.black
                    
                    if(indexPath.row == 1){ //(tempArray.count == indexPath.row){
                        
                        if(tempArray.count > 1){
                            let changedSalesPerson = tempArray[rowCount+1]
                            let firstSalesPerson = tempArray[rowCount]
                            if(firstSalesPerson.oldSalesPerson?.userInfo != nil){
                                commonString.append(String(format: "Re-Assigned from %@ to %@",(firstSalesPerson.oldSalesPerson?.userInfo?.name)!,changedSalesPerson.oldSalesPerson!.userInfo!.name!))
                            }else{
                                commonString.append(String(format: "Re-Assigned from Super Admin to %@",changedSalesPerson.oldSalesPerson!.userInfo!.name!))
                            }
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: firstSalesPerson.date!)
                            commonString = commonString + "\n" + date
                        }
                        else{
                            if(isSuperAdminDone){
                                let changedSalesPerson = tempArray[rowCount]
                                if(changedSalesPerson.oldSalesPerson?.userInfo != nil){
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",(changedSalesPerson.oldSalesPerson?.userInfo?.name ?? "Super Admin")!,(lead.salesPerson?.userInfo?.name ?? "Super Admin")!))
                                }
                                else{
                                    commonString.append(String(format: "Re-Assigned from Super Admin to %@",(lead.salesPerson?.userInfo!.name!)!))
                                }
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }else{
                                let changedSalesPerson = tempArray[rowCount]
                                commonString.append(String(format: "Re-Assigned from Super Admin to %@",(lead.salesPerson?.userInfo?.name ?? "Super Admin")))
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                        }
                    }
                    else{
                        if(indexPath.row <= tempArray.count){
                            
                            let changedSalesPerson = tempArray[indexPath.row-1]
                            
                            if(indexPath.row == tempArray.count){
                                
                                let salesPersonName =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                let chanedPerson = lead.salesPerson?.userInfo?.name
                                
                                commonString.append(String(format: "Re-Assigned from %@ to %@",salesPersonName,chanedPerson!))
                                
                            }
                            else{
                                
                                let salesPerson = tempArray[indexPath.row]
                                
                                let changedSaleGUyNmae =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                let salesPersonName = RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (salesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                
                                commonString.append(String(format: "Re-Assigned from %@ to %@",changedSaleGUyNmae,salesPersonName))
                                
                            }
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                            commonString = commonString + "\n" + date
                        }
                    }
                    //                    let updateedBy = lead.updateBy?.last
                    //                    let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                    //                    commonString = commonString + "\n" + date
                    cell.qrDetailsLabel.text = commonString
                    return cell
                }
                else{
                    
                    let lead : QR_HISTORY_OPPORTUNITIES_OR_LEADS = self.qrHistoryDataSource.leads![indexPath.section - 1] //self.qrHistoryDataSource.leads![indexPath.row]
                    
                    cell.qrTypeInfoLabel.text = "L"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "f67823")
                    
                    let title = RRUtilities.sharedInstance.getTimelineLabel(label: lead.action?.label ?? "")
                    
                    //// *** COMMMON TO leads n oppps
                    if(lead.actionInfo?.date != nil){
                        
                        let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: lead.actionInfo!.date!)
                        
                        cell.qrTypeNameLabel.text =  String(format: "%@ - %@", title,date)
                    }
                    else{
                        cell.qrTypeNameLabel.text =  title
                    }
                    //// *** COMMMON
                    
                    let updateedBy = lead.updateBy?.last
                    
                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: updateedBy!.date!)
                    
                    if(lead.actionInfo!.units != nil && (lead.actionInfo!.units!.count > 0))
                    {
                        let unitsInfo = (lead.actionInfo?.units?[0])
                        
                        
                        /*
                         let floor : Floor?
                         let unitNo : Floor?
                         let _id : String?
                         let project : PROJECT?
                         let tower : QR_TOWER?
                         */
                        
                        if(unitsInfo != nil){
                            commonString.append(unitsInfo?.project?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(unitsInfo?.block?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(unitsInfo?.tower?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(String(format: "%d", unitsInfo?.floor?.index ?? 0))
                            commonString.append(" | ")
                            
                            if(unitsInfo?.type != nil){
                                commonString.append(unitsInfo?.type?.name ?? "")
                                commonString.append(" | ")
                            }
                            
                            commonString.append(String(format: "%d(%@)", unitsInfo?.unitNo?.index ?? 0,unitsInfo?.description ?? 0))
                        }
                    }
                    
                    var labelText = String()
                    
                    if(title == "Not Interested"){
                        
                        if(lead.actionInfo?.comment != nil){
                            if(lead.actionInfo!.comment!.count > 0){
                                if(labelText.count > 0){
                                    labelText.append("\n")
                                }
                                labelText.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                            }
                        }
                        labelText = String(format: "%@\n", lead.action!.label!)
                        
                        if((lead.updateBy?.count)! > 0){
                            let updatedBy = lead.updateBy![0]
                            let updatedDate = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updatedBy.date!)
                            labelText.append(contentsOf: updatedDate)
                        }
                        else{
                            let updateedBy = lead.updateBy?.last
                            let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                            labelText.append(contentsOf: date)
                        }
                        cell.qrDetailsLabel.text = labelText
                        
                        return cell
                        
                    }
                    else if(title == "Site Visit"){
                        
                        let actionInfo = lead.actionInfo
                        
                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(lead.actionInfo!.comment!.count > 0){
                                if(commonString.count > 0){
                                    commonString.append("\n")
                                }
                                commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                            }
                        }
                        
                        var driverName = ""
                        var vehicleName = ""
                        
                        if(actionInfo?.driver != nil){
                            if(commonString.count > 0){
                                driverName = String(format: "\nDriver : %@\n", RRUtilities.sharedInstance.model.getDriveNameUsingID(driverID: actionInfo!.driver!))
                            }
                            else{
                                driverName = String(format: "Driver : %@\n", RRUtilities.sharedInstance.model.getDriveNameUsingID(driverID: actionInfo!.driver!))
                            }
                        }
                        if(actionInfo?.vehicle != nil)
                        {
                            vehicleName = String(format: "Vehicle : %@", RRUtilities.sharedInstance.model.getVehicleNameUsingId(vehicleID: actionInfo?.vehicle ?? "") ?? "")
                        }
                        
//                        cell.heightOfApprovalButton.constant = 0
//                        cell.widthOfCheckApprovalButton.constant = 0
//                        cell.checkApprovalButton.isHidden = true
//
//                        cell.widthOfViewOfferButton.constant = 0
//                        cell.heightOfViewOfferButton.constant = 0
//                        cell.viewOfferButton.isHidden = true
//                        cell.leadingOfViewOfferButton.constant = 0
//
//                        cell.heightOfEditCompletionDate.constant = 20
//                        cell.editCompletionDate.isHidden = false
//                        cell.widthOfEditCompletionDate.constant = 200
//                        cell.editCompletionDate.tag = 0
//                        cell.editCompletionDate.removeTarget(nil, action: nil, for: .allEvents)
//                        cell.editCompletionDate.addAction(for: .touchUpInside) { [unowned self] in
//                            self.siteVistActionId = lead._id ?? ""
//                            self.isFromOpportunitites = false
//                            self.showSiteVisitDatePopUp(cell.editCompletionDate)
//                        }
//                        commonString.append(driverName)
//                        commonString.append(vehicleName)
                        
                    }
                    else if(title == "Discount Request"){
                        var shouldHideApprovalButton = false
                        if(lead.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_APPLIED.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Applied"))
                            shouldHideApprovalButton = true
                        }
                        else if(lead.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_PENDING.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Pending"))
                        }
                        else if(lead.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_REJECTED.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Applied"))
                            shouldHideApprovalButton = true
                        }
                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                        
                        if(lead.updateBy?.count ?? 0 > 1){
                            if(!shouldHideApprovalButton){
                                cell.heightOfApprovalButton.constant = 18
                                cell.widthOfCheckApprovalButton.constant = 120
                                cell.checkApprovalButton.isHidden = false
                                let arraySlice = lead.updateBy?.suffix(from: 1)
                                cell.discountRequestTimeLineData = Array(arraySlice!)
                            }
                            else{
                                cell.heightOfApprovalButton.constant = 0
                                cell.widthOfCheckApprovalButton.constant = 0
                                cell.checkApprovalButton.isHidden = true
                            }

//                            cell.heightOfQRDetailsLabel.constant = cell.qrDetailsLabel.intrinsicContentSize.height
//                            cell.heightOfTimeLineTableView.constant = cell.timeLineTableView.contentSize.height
                            
                            if(lead.actionInfo?.fileUrl != nil){
                                cell.viewOfferButton.isHidden = false
                                cell.widthOfViewOfferButton.constant = 90
                                cell.heightOfViewOfferButton.constant = 18
                                cell.leadingOfViewOfferButton.constant = 12
                                if(shouldHideApprovalButton){
                                    cell.leadingOfViewOfferButton.constant = 0
                                }
                                cell.viewOfferButton.addAction { [unowned self] in
                                    self.showOffer(offerUrl: (lead.actionInfo?.fileUrl)!)
                                }
                            }
                            else{
                                cell.viewOfferButton.isHidden = true
                                cell.widthOfViewOfferButton.constant = 0
                                cell.heightOfViewOfferButton.constant = 0
                            }
                        }
                        else{
                            cell.discountRequestTimeLineData = []
                            cell.heightOfApprovalButton.constant = 0
                            cell.widthOfCheckApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            
                            if(lead.actionInfo?.fileUrl != nil){
                                cell.viewOfferButton.isHidden = false
                                cell.widthOfViewOfferButton.constant = 90
                                cell.heightOfViewOfferButton.constant = 18
                                cell.leadingOfViewOfferButton.constant = 0
                                cell.viewOfferButton.addAction { [unowned self] in
                                    self.showOffer(offerUrl: (lead.actionInfo?.fileUrl)!)
                                }
                            }
                            else{
                                cell.viewOfferButton.isHidden = true
                                cell.widthOfViewOfferButton.constant = 0
                                cell.heightOfViewOfferButton.constant = 0
                            }

                        }

                    }
                    else if(title == "Other Task"){
                        //name //status
                        
                        var taskName = ""
                        var taskStatus = ""
                        var taskDescription = ""
                        
                        if(lead.actionInfo?.taskName != nil){
                            taskName = lead.actionInfo!.taskName!
                        }
                        if(lead.actionInfo?.taskStatus != nil){
                            
                            if(lead.actionInfo!.taskStatus == 0){
                                taskStatus = "Open"
                            }
                            else if(lead.actionInfo!.taskStatus == 1){
                                taskStatus = "On Hold"
                            }
                            else if(lead.actionInfo!.taskStatus == 2){
                                taskStatus = "Task Assigned"
                            }
                        }
                        
                        if(lead.actionInfo?.taskDescription != nil)
                        {
                            taskDescription = lead.actionInfo!.taskDescription!
                        }
                        
                        commonString.append(contentsOf: String(format: "Task Name: %@", taskName))
                        commonString.append("\n")
                        if(taskDescription.count > 0){
                            commonString.append(contentsOf: String(format: "Description: %@", taskDescription))
                            //                            commonString.append("\n")
                        }
                        commonString.append(contentsOf: String(format: "Task Status: %@", taskStatus))
                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                    }
                    else if(title == "Offer")
                    {
                        if(lead.actionInfo?.scheme != nil){
                            let schemeName = RRUtilities.sharedInstance.model.getSchemeByID(schemeID: (lead.actionInfo!.scheme!))
                            commonString.append(String(format: "\nScheme Applied: %@", schemeName))
                        }

                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                        
                        if (lead.actionInfo?.fileUrl) != nil{
                            
                            cell.widthOfCheckApprovalButton.constant = 0
                            cell.heightOfApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
//                            cell.checkApprovalButton.setTitle("View Offer", for: .normal)
                            
                            cell.viewOfferButton.isHidden = false
                            cell.heightOfViewOfferButton.constant = 18
                            cell.heightOfViewOfferButton.isActive = true
                            cell.widthOfViewOfferButton.constant = 90
                            cell.heightOfViewOfferButton.constant = 18
                            cell.leadingOfViewOfferButton.constant = 0

                            cell.viewOfferButton.addAction(for: .touchUpInside) { [unowned self] in
                                self.showOffer(offerUrl: (lead.actionInfo?.fileUrl)!)
                            }
//                            cell.checkApprovalButton.tag = 1
                            
                        }
                        else{
                            cell.heightOfApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            cell.checkApprovalButton.setTitle("Check Approval", for: .normal)
                            cell.checkApprovalButton.tag = 0
                            
                            cell.widthOfViewOfferButton.constant = 0
                            cell.heightOfViewOfferButton.constant = 0
                            cell.viewOfferButton.isHidden = true
                        }
                    }
                    else if(title == "Call"){
                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                    }
                    
                    var dateStr = ""
                    if(commonString.count > 0){
                        dateStr = String(format: "\n%@", date)
                    }
                    else{
                        dateStr = date
                    }
                    commonString.append(contentsOf: dateStr)
                    
                    
                    
                    cell.qrDetailsLabel.text = commonString
                    
                    if(lead.actionInfo?.date != nil){  // *** DATE IS COMMON TO ALL
                        cell.dateLabel.text = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr:lead.actionInfo!.date!)
                    }
                    else{
                        cell.dateLabel.text = ""
                    }
                    
                    return cell
                }
                
            }
            if(indexPath.section >= (1+self.qrHistoryDataSource.leads!.count) && indexPath.section < (1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)){
                //                print((1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count))
                cell.qrTypeInfoLabel.text = "O"
                
                let opportunity = self.qrHistoryDataSource.opportunities![indexPath.section - (1+self.qrHistoryDataSource.leads!.count)]
                
                //                let title = self.getTimelineLabel(label: opportunity.action?.label ?? "")
                
                if(indexPath.row > 0 && (opportunity.updateBy?.count)! > 1){
                    var commonString = String()
                    
                    let updates : [UpdatedByForProspects] = opportunity.updateBy!
                    
                    var tempArray : [UpdatedByForProspects] = []
                    
                    for salesPerson in updates{
                        if(salesPerson.oldSalesPerson != nil){
                            tempArray.append(salesPerson)
                        }
                    }
                    
                    let rowCount = indexPath.row-1
                    
                    cell.qrTypeNameLabel.text = "Change Of Sales Person"
                    cell.qrTypeInfoLabel.text = "S"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.black
                    
                    if(indexPath.row == 1){ //(tempArray.count == indexPath.row){
                        
                        if(tempArray.count > 1){
                            let changedSalesPerson = tempArray[rowCount+1]
                            let firstSalesPerson = tempArray[rowCount]
                            if(firstSalesPerson.oldSalesPerson?.userInfo != nil && changedSalesPerson.oldSalesPerson != nil){
                                commonString.append(String(format: "Re-Assigned from %@ to %@",(firstSalesPerson.oldSalesPerson?.userInfo?.name)!,changedSalesPerson.oldSalesPerson!.userInfo!.name!))
                            }else{
                                commonString.append(String(format: "Re-Assigned from Super Admin to %@",changedSalesPerson.oldSalesPerson!.userInfo!.name!))
                            }
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: firstSalesPerson.date!)
                            commonString = commonString + "\n" + date
                        }
                        else{
                            if(isSuperAdminDone){
                                let changedSalesPerson = tempArray[rowCount]
                                commonString.append(String(format: "Re-Assigned from %@ to %@",(changedSalesPerson.oldSalesPerson?.userInfo?.name)!,(opportunity.salesPerson?.userInfo!.name!)!))
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }else{
                                let changedSalesPerson = tempArray[rowCount]
                                commonString.append(String(format: "Re-Assigned from Super Admin to %@",(opportunity.salesPerson?.userInfo!.name!)!))
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                        }
                    }
                    else{
                        if(indexPath.row <= tempArray.count){
                            
                            let changedSalesPerson = tempArray[indexPath.row-1]
                            
                            if(indexPath.row == tempArray.count){
                                
                                let salesPersonName =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                let chanedPerson = opportunity.salesPerson?.userInfo?.name
                                
                                //                                cell.qrDetailsLabel.text = String(format: "Re-Assigned from %@ to %@",salesPersonName,chanedPerson!)
                                commonString.append(String(format: "Re-Assigned from %@ to %@",salesPersonName,chanedPerson!))
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                                
                            }
                            else{
                                
                                let salesPerson = tempArray[indexPath.row]
                                
                                let changedSaleGUyNmae =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                let salesPersonName = RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (salesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                
                                //                                cell.qrDetailsLabel.text = String(format: "Re-Assigned from %@ to %@",salesPersonName,changedSaleGUyNmae)
                                commonString.append(String(format: "Re-Assigned from %@ to %@",changedSaleGUyNmae,salesPersonName))
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                                
                                //                                cell.dateLabel.text = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr:salesPerson.date!)
                                
                            }
                        }
                    }
                    //                    let updateedBy = opportunity.updateBy?.last
                    cell.qrDetailsLabel.text = commonString
                    return cell
                }
                else{
                    
                    cell.qrTypeInfoLabel.text = "O"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "3aa81e")
                    
                    let opportunity : QR_HISTORY_OPPORTUNITIES_OR_LEADS = self.qrHistoryDataSource.opportunities![indexPath.section - (1+self.qrHistoryDataSource.leads!.count)] //self.qrHistoryDataSource.opportunities![indexPath.row]
                    
                    let title = RRUtilities.sharedInstance.getTimelineLabel(label: opportunity.action?.label ?? "")
                    
                    
                    //// *** COMMMON TO leads n oppps
                    if(opportunity.actionInfo?.date != nil){
                        
                        let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: opportunity.actionInfo!.date!)
                        
                        cell.qrTypeNameLabel.text = String(format: "%@ - %@", title,date)
                        
                    }
                    else{
                        cell.qrTypeNameLabel.text = title
                    }
                    //// *** COMMMON
                    let updateedBy = opportunity.updateBy?.last
                    var date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                    
                    if(opportunity.actionInfo!.units != nil && (opportunity.actionInfo!.units!.count > 0))
                    {
                        let unitInfo = (opportunity.actionInfo?.units?[0])
                        
                        /*
                         let floor : Floor?
                         let unitNo : Floor?
                         let _id : String?
                         let project : PROJECT?
                         let tower : QR_TOWER?
                         */
                        if(unitInfo != nil){
                            
                            commonString.append(unitInfo?.project?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(unitInfo?.block?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(unitInfo?.tower?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(String(format: "%d", unitInfo?.floor!.index ?? 0))
                            commonString.append(" | ")
                            
                            if(unitInfo?.type != nil){
                                commonString.append(unitInfo?.type!.name ?? "")
                                commonString.append(" | ")
                            }
                            
                            commonString.append(String(format: "%d(%@)", unitInfo?.unitNo!.index ?? "",unitInfo?.description ?? ""))
                        }
                    }
                    
                    var labelText = String()
                    
                    if(title == "Not Interested"){
                        
                        if(opportunity.actionInfo?.comment != nil){
                            if(opportunity.actionInfo!.comment!.count > 0){
                                if(labelText.count > 0){
                                    labelText.append("\n")
                                }
                                labelText.append(String(format: "Comments : %@", opportunity.actionInfo!.comment!))
                            }
                        }
                        labelText = String(format: "%@\n", opportunity.action!.label!)
                        
                        if((opportunity.updateBy?.count)! > 0){
                            let updatedBy = opportunity.updateBy![0]
                            let updatedDate = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updatedBy.date!)
                            labelText.append(contentsOf: updatedDate)
                        }
                        else{
                            let updateedBy = opportunity.updateBy?.last
                            let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                            labelText.append(contentsOf: date)
                        }
                        cell.qrDetailsLabel.text = labelText
                        
                        return cell
                        
                    }
                    else if(title == "Site Visit"){
                        
                        var driverName = ""
                        var vehicleName = ""
                        
                        let actionInfo = opportunity.actionInfo
                        
                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(actionInfo!.comment!.count > 0){
                                if(commonString.count > 0){
                                    commonString.append("\n")
                                }
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                        
                        if(actionInfo?.driver != nil){
                            if(commonString.count > 0){
                                driverName = String(format: "\nDriver : %@\n", RRUtilities.sharedInstance.model.getDriveNameUsingID(driverID: actionInfo!.driver!))
                            }
                            else{
                                driverName = String(format: "Driver : %@\n", RRUtilities.sharedInstance.model.getDriveNameUsingID(driverID: actionInfo!.driver!))
                            }
                        }
                        if(actionInfo?.vehicle != nil)
                        {
                            vehicleName = String(format: "Vehicle : %@", RRUtilities.sharedInstance.model.getVehicleNameUsingId(vehicleID: actionInfo!.vehicle!) ?? "")
                        }
                        
                        commonString.append(driverName)
                        commonString.append(vehicleName)
                        
                    }
                    else if(title == "Discount Request"){
                        let actionInfo = opportunity.actionInfo
                        var shouldHideApprovalButton = false

                        if(opportunity.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_APPLIED.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Applied"))
                            shouldHideApprovalButton = true
                        }
                        else if(opportunity.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_PENDING.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Pending"))
                        }
                        else if(opportunity.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_REJECTED.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Applied"))
                            shouldHideApprovalButton = true
                        }

                        if(opportunity.actionInfo?.scheme != nil){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            let schemeName = RRUtilities.sharedInstance.model.getSchemeByID(schemeID: (opportunity.actionInfo!.scheme!))
                            commonString.append(String(format: "\nScheme Applied: %@", schemeName))
                        }

                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(actionInfo!.comment!.count > 0){
                                if(commonString.count > 0){
                                    commonString.append("\n")
                                }
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                        if(opportunity.updateBy?.count ?? 0 > 1){
                            if(!shouldHideApprovalButton){
                                cell.heightOfApprovalButton.constant = 18
                                cell.widthOfCheckApprovalButton.constant = 120
                                cell.leadingOfViewOfferButton.constant = 12
                                cell.checkApprovalButton.isHidden = false
                            }
                            else{
                                cell.heightOfApprovalButton.constant = 0
                                cell.widthOfCheckApprovalButton.constant = 0
                                cell.checkApprovalButton.isHidden = true
                            }
                            let arraySlice = opportunity.updateBy?.suffix(from: 1)
                            cell.discountRequestTimeLineData = Array(arraySlice!)
//                            cell.heightOfQRDetailsLabel.constant = cell.qrDetailsLabel.intrinsicContentSize.height
//                            cell.heightOfTimeLineTableView.constant = cell.timeLineTableView.contentSize.height
                            if(opportunity.actionInfo?.fileUrl != nil){
                                cell.viewOfferButton.isHidden = false
                                cell.widthOfViewOfferButton.constant = 90
                                cell.heightOfViewOfferButton.constant = 18
                                cell.leadingOfViewOfferButton.constant = 12
                                if(shouldHideApprovalButton){
                                    cell.leadingOfViewOfferButton.constant = 0
                                }
                                cell.viewOfferButton.addAction { [unowned self] in
                                    self.showOffer(offerUrl: (opportunity.actionInfo?.fileUrl)!)
                                }
                            }
                            else{
                                cell.viewOfferButton.isHidden = true
                                cell.widthOfViewOfferButton.constant = 0
                                cell.heightOfViewOfferButton.constant = 0
                            }
                        }
                        else{
                            cell.discountRequestTimeLineData = []
                            cell.heightOfApprovalButton.constant = 0
                            cell.widthOfCheckApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            
                            if(opportunity.actionInfo?.fileUrl != nil){
                                cell.viewOfferButton.isHidden = false
                                cell.widthOfViewOfferButton.constant = 90
                                cell.heightOfViewOfferButton.constant = 18
                                cell.leadingOfViewOfferButton.constant = 0
                                cell.viewOfferButton.addAction { [unowned self] in
                                    self.showOffer(offerUrl: (opportunity.actionInfo?.fileUrl)!)
                                }
                            }
                            else{
                                cell.viewOfferButton.isHidden = true
                                cell.widthOfViewOfferButton.constant = 0
                                cell.heightOfViewOfferButton.constant = 0
                            }
                        }
                    }
                    else if(title == "Other Task"){
                        //name //status
                        //                        print(opportunity)
                        var taskName = ""
                        var taskStatus = ""
                        var taskDescription = ""
                        
                        let actionInfo = opportunity.actionInfo
                        
                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(actionInfo!.comment!.count > 0){
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                        
                        if(opportunity.actionInfo?.taskName != nil){
                            taskName = opportunity.actionInfo!.taskName!
                        }
                        if(opportunity.actionInfo?.taskStatus != nil){
                            
                            if(opportunity.actionInfo!.taskStatus == 0){
                                taskStatus = "Open"
                            }
                            else if(opportunity.actionInfo!.taskStatus == 1){
                                taskStatus = "On Hold"
                            }
                            else if(opportunity.actionInfo!.taskStatus == 2){
                                taskStatus = "Task Assigned"
                            }
                        }
                        
                        if(opportunity.actionInfo?.taskDescription != nil)
                        {
                            taskDescription = opportunity.actionInfo!.taskDescription!
                        }
                        
                        commonString.append(contentsOf: String(format: "\nTask Name: %@", taskName))
                        commonString.append("\n")
                        if(taskDescription.count > 0){
                            commonString.append(contentsOf: String(format: "Description: %@", taskDescription))
                            //                            commonString.append("\n")
                        }
                        commonString.append(contentsOf: String(format: "Task Status: %@", taskStatus))
                    }
                    else if(title == "Offer")
                    {
                        let actionInfo = opportunity.actionInfo
                        
                        if(opportunity.actionInfo?.scheme != nil){
                            let schemeName = RRUtilities.sharedInstance.model.getSchemeByID(schemeID: (opportunity.actionInfo!.scheme!))
                            commonString.append(String(format: "\nScheme Applied: %@", schemeName))
                        }
                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(actionInfo!.comment!.count > 0){
                                if(commonString.count > 0){
                                    commonString.append("\n")
                                }
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                        if (opportunity.actionInfo?.fileUrl) != nil{
                            
                            cell.widthOfCheckApprovalButton.constant = 0
                            cell.heightOfApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            //                            cell.checkApprovalButton.setTitle("View Offer", for: .normal)
                            
                            cell.widthOfViewOfferButton.constant = 90
                            cell.heightOfViewOfferButton.constant = 18
                            cell.viewOfferButton.isHidden = false
                            cell.leadingOfViewOfferButton.constant = 0
                            cell.viewOfferButton.addAction(for: .touchUpInside) { [unowned self] in
                                self.showOffer(offerUrl: (opportunity.actionInfo?.fileUrl)!)
                            }
//                            cell.checkApprovalButton.tag = 1
                        }
                        else{
                            cell.heightOfApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            cell.checkApprovalButton.setTitle("Check Approval", for: .normal)
                            cell.checkApprovalButton.tag = 0
                            
                            cell.widthOfViewOfferButton.constant = 0
                            cell.heightOfViewOfferButton.constant = 0
                            cell.viewOfferButton.isHidden = true

                        }
                    }
                    else if(title == "Call"){
                        let actionInfo = opportunity.actionInfo
                        
                        if(actionInfo != nil && actionInfo?.comment != nil){
                            //                            commonString.append("\n")
                            if(actionInfo!.comment!.count > 0){
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                    }
                    
                    if((opportunity.updateBy?.count)! > 0){
                        let updatedBy = opportunity.updateBy![0]
                        let updatedDate = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updatedBy.date!)
                        date = updatedDate
                    }
                    else{
                        let updateedBy = opportunity.updateBy?.last
                        let date1 = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                        date = date1
                    }
                    
                    var dateStr = ""
                    if(commonString.count > 0){
                        dateStr = String(format: "\n%@", date)
                    }
                    else{
                        dateStr = date
                    }
                    commonString.append(contentsOf: dateStr)
                    
                    cell.qrDetailsLabel.text = commonString
                    
                    
                    return cell
                    
                }
//                return cell
            }
            //            if(indexPath.section > 0 && indexPath.section <= (self.qrHistoryDataSource.leads!.count + 1))
            //            {
            //
            //                cell.qrTypeInfoLabel.text = "L"
            //
            //                return cell
            //
            //            }
            //            if(indexPath.section > (1+self.qrHistoryDataSource.leads!.count) && indexPath.section < (1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)){
            //
            //                cell.qrTypeInfoLabel.text = "O"
            //
            //                return cell
            //
            //            }
            
            
            return cell
            
        }
        else if(cellType == TabelViewCellType.PaymentSchdule){
            
//            if(tableView.tag == 100){
//
//
//                    let cell : BillingElementsTableViewCell = tableView.dequeueReusableCell(
//                        withIdentifier: "unitCostBreakUpCell",
//                        for: indexPath) as! BillingElementsTableViewCell
//
//                    return cell
//                    //                if(cell.unitRate != nil){
//                    //                    cell.billingElementsTableView.reloadData()
//                    //                }
//                    //                cell.billingElementsTableView.isHidden = false
//                    //                print(cell.billingElementsTableView.contentSize.height)
//                    //                cell.billingElementsTableView.layoutIfNeeded()
//                    //                cell.heightOfBillingTableView.constant = cell.billingElementsTableView.contentSize.height
//
//            }
//            else{
                let cell : PaymentScheduleTableViewCell = tableView.dequeueReusableCell(
                    withIdentifier: "paymentSchedule",
                    for: indexPath) as! PaymentScheduleTableViewCell
                
                let tempInstallment = installments[indexPath.row]
                
                cell.installementNumberLabel.text = tempInstallment.installmentName
                cell.installmentAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,tempInstallment.installmentAmount!)
                cell.installmentDueDateLabel.text = String(format: "Due: %@", RRUtilities.sharedInstance.getDateWithDateFormat(dateStr: tempInstallment.dueDate!, dateFormat: "MMM,yyyy"))
                cell.payByDateLabel.text = String(format: "Pay By: %@", RRUtilities.sharedInstance.getDateWithDateFormat(dateStr: tempInstallment.payDate!, dateFormat: "MMM,yyyy"))
                cell.constructionCostLabel.text = String(format: "Construction: %@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,tempInstallment.constructionAmount ?? 0.00)
                cell.landCostLabel.text = String(format: "Land: %@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,tempInstallment.landAmount ?? 0.00)
                cell.statusLabel.text = (tempInstallment.status == 1) ? "Status: Pending" : "Status: Invoiced"
                cell.installementNumberLabel.superview?.backgroundColor = .white
            
            cell.showBreakupButton.addTarget(self, action: #selector(showBillingElements(_:)), for: .touchUpInside)
            cell.showBreakupButton.tag = indexPath.row
            cell.heightOfBillingTableView.constant = 0
            cell.billingElementsTableView.isHidden = true

                if(selectedPaymentScheduleIndexPath != nil && selectedPaymentScheduleIndexPath.row == indexPath.row){
                    
                    cell.billingElementsTableView.isHidden = false
                    
                    var reqBesDetails : [BILLING_ELEMENT_DETAILS] = []
                    var requiredPbesDetails : [P_BILLING_ELEMENTS] = []
                    
                    let tempBesDetails = self.paymentScheduleUnitRate.bes?.details
                    let tempPBesDetails = self.paymentScheduleUnitRate.pBes?.pDetails
                    
                    let tempInstallment = installments[indexPath.row]
                    
                    if(tempBesDetails != nil && tempBesDetails!.count > 0 && tempInstallment.billings != nil && tempInstallment.billings!.count > 0){
                        for eachBe in tempInstallment.billings!{
//                            print(tempBesDetails!.filter({ $0._id == eachBe.billing}))
                            let elementsToAppend = tempBesDetails!.filter({$0.element!._id == eachBe.billing})
                            var bElementToApeed = elementsToAppend[0]
                            bElementToApeed.element?.percentage = eachBe.percentage
                            bElementToApeed.element?.amount = eachBe.amount
                            reqBesDetails.append(bElementToApeed)
                            //                            reqBesDetails.append(contentsOf: (tempBesDetails!.filter({$0.element!._id == eachBe.billing})))
                        }
                    }
                    
                    if(tempPBesDetails != nil && tempPBesDetails!.count > 0 && tempInstallment.premiumBillings != nil && tempInstallment.premiumBillings!.count > 0){
                        for eacePBE in tempInstallment.premiumBillings!{
                            
                            let elementsToAppend = tempPBesDetails!.filter({$0.pElement!._id == eacePBE.billing})
                            var pbeElementToApeed = elementsToAppend[0]
                            pbeElementToApeed.pElement?.percentage = eacePBE.percentage
                            pbeElementToApeed.pElement?.amount = eacePBE.amount
                            
                            requiredPbesDetails.append(pbeElementToApeed)
                        }
                    }
                    
//                    print(requiredPbesDetails.count)
//                    print(reqBesDetails.count)
                    unitRate.bes?.details = nil
                    unitRate.pBes?.pDetails = nil
                    unitRate.bes?.details = reqBesDetails
                    unitRate.pBes?.pDetails = requiredPbesDetails
                    cell.unitRate = self.unitRate

                    cell.billingElementsTableView.reloadData()
                    cell.billingElementsTableView.layoutIfNeeded()
                    cell.heightOfBillingTableView.constant = cell.billingElementsTableView.contentSize.height
                    cell.showBreakupButton.setTitle("Hide Breakup", for: .normal)
                    cell.billingElementsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
                    cell.hLineView.isHidden = true
                    cell.indicatorImageView.image = UIImage.init(named: "collapse")
                }
                else{
                    if(cell.unitRate != nil){
                        cell.unitRate = nil
                        cell.billingElementsTableView.reloadData()
                    }
                    cell.heightOfBillingTableView.constant = 0
                    cell.billingElementsTableView.isHidden = true
                    cell.showBreakupButton.setTitle("Show Breakup", for: .normal)
                    cell.hLineView.isHidden = false
                    cell.indicatorImageView.image = UIImage.init(named: "expand")
                }
                return cell
//            }
            
            
        
        }
        else if(cellType == TabelViewCellType.HANDOVER_HOSTORY){
            
            let cell : HandOverHistoryTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "itemHistory",
                for: indexPath) as! HandOverHistoryTableViewCell
            
            cell.dateLabel.text = "DATE"
            
            var fromStatusString = ""
            
            if(indexPath.row-1 == -1){
                fromStatusString = HANDOVER_STATUS_TEXT.Handover_Review.rawValue
            }else{
                let fromHistoryItem = self.handOverItemHistory[indexPath.row-1]
                let fromDict = RRUtilities.sharedInstance.getHOStatusAsPerStatus(stattusIndex: Int(fromHistoryItem.status))
                fromStatusString = fromDict["statusString"] as! String
            }
            
            let toHistoryItem = self.handOverItemHistory[indexPath.row]
            
            let toDict = RRUtilities.sharedInstance.getHOStatusAsPerStatus(stattusIndex: Int(toHistoryItem.status))
            
            let historyStr = String(format: "%@ changed from %@ to %@", toHistoryItem.user!,fromStatusString,toDict["statusString"] as! String)
            
            if(indexPath.row-1 == -1){
                cell.dateLabel.text = ""
                cell.dateImageView.isHidden = true
//                cell.heightOfDateLabel.constant = 0
                cell.hoStateLabel.text =  (toDict["shortCut"] as! String)
                cell.handOverStatusHistoryLabel.text = fromStatusString
                cell.hoStateLabel.backgroundColor = toDict["color"] as? UIColor
                cell.vLineView.isHidden = false
            }else{
                cell.dateLabel.text = RRUtilities.sharedInstance.getNotificationViewDate(dateStr: toHistoryItem.modifiedDate!)
                cell.hoStateLabel.backgroundColor = toDict["color"] as? UIColor
                cell.hoStateLabel.text =  (toDict["shortCut"] as! String)
                cell.handOverStatusHistoryLabel.text = historyStr
                cell.dateImageView.isHidden = false
                cell.vLineView.isHidden = false
            }

            if(indexPath.row == handOverItemHistory.count - 1){
                cell.vLineView.isHidden = true
            }
            return cell            
        }
        else{
            let cell : QRHistoryTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "qrHistoryCell",
                for: indexPath) as! QRHistoryTableViewCell
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(cellType == TabelViewCellType.PaymentSchdule){
            
            if(selectedPaymentScheduleIndexPath != nil && selectedPaymentScheduleIndexPath.row == indexPath.row){
                selectedPaymentScheduleIndexPath = nil
                self.tableView.reloadData()
            }
            else{
                selectedPaymentScheduleIndexPath = indexPath
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(cellType == TabelViewCellType.UNIT_COST_BREAKUP){

            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PopUpHeaderView") as! PopUpHeaderView

            if(section == 0){
                headerView.headerTitleLabel.text = String(format: "     %@", "Billing Elements")
            }
            else{
                headerView.headerTitleLabel.text = String(format: "     %@", "Premium Elements")
            }
            headerView.headerTitleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 12)
            headerView.headerTitleLabel.textAlignment = .left
            headerView.headerTitleLabel.textColor = .black
            headerView.subContentView.backgroundColor = .clear
            headerView.headerTitleLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
            headerView.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
            headerView.topConstraintOfLabel.constant = 8
            return headerView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(cellType == TabelViewCellType.UNIT_COST_BREAKUP){
            if(section > 1){
                return 0
            }
            return 35
        }
        return 0
    }
    func showSiteVisitDatePopUp(_ sender : UIButton){
        
        print("showSiteVisitDatePopUp")
//        if(isFromDatePopUp){
//            return
//        }
//        isFromDatePopUp = true
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "datePicker") as! DatePickerViewController
//
//        vc.shouldSetDateLimit = false
//        vc.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 300)
//        vc.delegate = self
//        vc.selectedFieldTag = sender.tag
//
//        fpc.surfaceView.cornerRadius = 6.0
//        fpc.surfaceView.shadowHidden = false
//        fpc.surfaceView.grabberHandleHeight = 0.0
//        fpc.delegate = self
//
//        fpc.set(contentViewController: vc)
//
//        fpc.isRemovalInteractionEnabled = false // Optional: Let it removable by a swipe-down
//
//        vc.datePickerInfoView?.backgroundColor = .white
//        vc.datePickerInfoLabel.text = "Select Completion Date and Time"
//        vc.datePicker.datePickerMode = .date
//        vc.buttonsView.backgroundColor = .white
//        vc.shouldShowTime = true
//        vc.cancelButton.setTitle("CANCEL", for: .normal)
//        vc.doneButton.setTitle("OK", for: .normal)
//
//        self.present(fpc, animated: true, completion: nil)

    }
    func showOffer(offerUrl : String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let offerPreview = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
        offerPreview.isPreViewOffer = true
//        offerPreview.selectedProspect = self.selectedProspect
        
        DispatchQueue.global().async {
            let signedUrl = ServerAPIs.getSingleSingedUrl(url: offerUrl)
            
            offerPreview.previewOfferUrlString = signedUrl

            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: offerPreview)
                navController.modalPresentationStyle = .fullScreen
                navController.navigationBar.isHidden = true
                self.present(navController, animated: true, completion: nil)
            }
        }

        
        
    }
    @objc func showApprovalsView(_ sender: UIButton){
        
        let discountApprovalsController = DiscountApprovalsViewController(nibName: "DiscountApprovalsViewController", bundle: nil)
        discountApprovalsController.approvalType = APPROVAL_TYPES.DISCOUNT_APPROVAL
        discountApprovalsController.isFromProspects = true
        discountApprovalsController.prospectUserName = self.prospectDetails.userName
        self.navigationController?.pushViewController(discountApprovalsController, animated: true)
    }
    @objc func showBillingElements(_ sender: UIButton){
        
        let selectedIndexPath = IndexPath.init(row: sender.tag, section: 0)
        
        if(selectedPaymentScheduleIndexPath != nil && selectedPaymentScheduleIndexPath.row == selectedIndexPath.row){
            selectedPaymentScheduleIndexPath = nil
            self.tableView.reloadData()
        }
        else{
            selectedPaymentScheduleIndexPath = selectedIndexPath
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: selectedIndexPath, at: .top, animated: true)
            }
        }

    }
}
extension UITableView {
    func reloadData(completion: @escaping ()->()) {
        
        UIView.animate(withDuration: 0, animations: {self.reloadData()}, completion: {
            _ in completion()
        })
        
        
//        UIView.animateWithDuration(0, animations: { self.reloadData() })
//        { _ in completion() }
    }
}
