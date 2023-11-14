//
//  PaymentScheduleTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 18/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class PaymentScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var hLineView: UIView!
    @IBOutlet weak var showBreakupButton: UIButton!
    @IBOutlet weak var heightOfBillingTableView: NSLayoutConstraint!
    @IBOutlet weak var billingElementsTableView: ContentSizeTableView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var constructionCostLabel: UILabel!
    @IBOutlet weak var landCostLabel: UILabel!
    @IBOutlet weak var payByDateLabel: UILabel!
    @IBOutlet weak var installmentAmountLabel: UILabel!
    @IBOutlet weak var installmentDueDateLabel: UILabel!
    @IBOutlet weak var installementNumberLabel: UILabel!
    var unitRate : UNIT_RATE!
    var selectedUnitStatus : UNIT_STATUS!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let nib3 = UINib(nibName: "BillingElementsTableViewCell", bundle: nil)
        billingElementsTableView.register(nib3, forCellReuseIdentifier: "unitCostBreakUpCell")
        billingElementsTableView.tag = 101
        
        let headerNib = UINib.init(nibName: "PopUpHeaderView", bundle: Bundle.main)
        billingElementsTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "PopUpHeaderView")

        billingElementsTableView.delegate = self
        billingElementsTableView.dataSource = self
        
        self.billingElementsTableView.tableFooterView = UIView()
        
        billingElementsTableView.estimatedRowHeight = 200
        billingElementsTableView.estimatedSectionHeaderHeight = 35
        billingElementsTableView.rowHeight = UITableView.automaticDimension
//        billingElementsTableView.estimatedSectionFooterHeight = 0

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

//extension PaymentScheduleTableViewCell{
//    func setTableViewDataSourceDelegate<D:UITableViewDelegate & UITableViewDataSource>(_ dataSourceDelegate: D,forRow : Int){
//        billingElementsTableView.delegate = dataSourceDelegate
//        billingElementsTableView.dataSource = dataSourceDelegate
//
//        billingElementsTableView.reloadData()
//    }
//}
extension PaymentScheduleTableViewCell : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if(unitRate != nil && (unitRate.pBes?.pDetails?.count) ?? 0 > 0){
            return (unitRate.pBes?.pDetails?.count ?? 0) + 1
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if(section == 0){
            return unitRate?.bes?.details?.count ?? 0
        }
        else if(section >= 1){
            if(((unitRate?.pBes?.pDetails?.count ?? 0)) > 0){
                let pElemetns : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![section-1])!
                return pElemetns.details?.count ?? 0
            }
            return 0
        }else{
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

            cell.premiumAmountView.isHidden = true
            cell.heightOfPremiumAmountView.constant = 0
            cell.amountIncludingTaxesView.isHidden = true
            cell.heightOfPremiumAmountIncludingTaxesView1.constant = 0
            
            cell.revisedTaxAmountTitleLabel.text = "Installment Amount"
            cell.taxAmountTitleLabel.text = "Installment Percentage"

            let element : BILLING_ELEMENT_DETAILS = (unitRate.bes?.details![indexPath.row])!

            cell.elementNameLabel.text = String(format: "%@", element.name!)
            cell.rateLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.elementRate!)
            cell.areaOrQtyLabel.text = String(format: "%d", element.qty!)
            cell.pricingTypeLabel.text = element.pricingType

            cell.taxesAmountLabel.text = String(format: "%.2f %%",element.element!.percentage!)
            cell.revisedTaxesAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.element!.amount!)

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
            cell.subContentView.layoutIfNeeded()
        }
        else{ //Premium billing elements

            //                let pElemetns : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![section])!
            //                return pElemetns.details?.count ?? 0

            if(indexPath.row == 0){
                cell.heightOfPermiumInfoView.constant = 40
                cell.premiumViewInfo.isHidden = false
            }
            else{
                cell.heightOfPermiumInfoView.constant = 0
                cell.premiumViewInfo.isHidden = true
            }

            cell.premiumAmountView.isHidden = true
            cell.heightOfPremiumAmountView.constant = 0
            cell.amountIncludingTaxesView.isHidden = true
            cell.heightOfPremiumAmountIncludingTaxesView1.constant = 0
            
            cell.revisedTaxAmountTitleLabel.text = "Installment Amount"
            cell.taxAmountTitleLabel.text = "Installment Percentage"


            let tempElement : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![indexPath.section-1])!

//            print(tempElement)

            //                cell.topConstraintOfSubContentView.constant = 1
            //                cell.bottomConstraintOfSubContentView.constant = 0

            let element : PREMIUM_BILLING_ELEMENT_DETAILS = tempElement.details![indexPath.row]

            cell.elementNameLabel.text = String(format: "%@", element.name!)
            cell.rateLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.elementRate!)
            cell.areaOrQtyLabel.text = String(format: "%d", element.qty!)
            cell.pricingTypeLabel.text = element.pricingType

            if(element.discountedRate == 0 || element.discountedPercent == 0){
                cell.discountInfoView.isHidden = true
                cell.heightOfDiscountView.constant = 0
            }
            else{
                cell.discountInfoView.isHidden = false
                cell.heightOfDiscountView.constant = 40
            }

            cell.amountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.totalElementRate!)
            cell.revisedAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,element.finalRate!)

            cell.taxesAmountLabel.text = String(format: "%.2f %%",(tempElement.pElement?.percentage)!)
            cell.revisedTaxesAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,(tempElement.pElement?.amount)!)

            let pElemetns : P_BILLING_ELEMENTS = (unitRate.pBes?.pDetails![indexPath.section-1])!
            let counter = pElemetns.details?.count ?? 0
            cell.premiumCompnentLabel.text = tempElement.pElement?.name
            
            if(indexPath.row == counter-1){
                // show pElement details

                let pElement = tempElement.pElement

                cell.taxesAmountLabel.text = String(format: "%.2f %%",pElement!.percentage!)
                cell.revisedTaxesAmountLabel.text = String(format: "%@ %.2f", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,pElement!.amount!)

                let amountStr = String(format: "%.2f", (Double(pElement!.pCost!)))
                let finalAmountStr = String(format: "%.2f", (Double(pElement!.finalPcost!)))
//
                if(selectedUnitStatus == UNIT_STATUS.VACANT || selectedUnitStatus == UNIT_STATUS.RESERVED || selectedUnitStatus == UNIT_STATUS.BLOCKED){
                    cell.premiumAmoutLabel.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,amountStr.count > 0 ? amountStr : "--")
                    cell.premiumRevisedAmountLabel.text = "--"
                }
                else{
                    cell.premiumAmoutLabel.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,amountStr.count > 0 ? amountStr : "--")
                    cell.premiumRevisedAmountLabel.text = String(format: "%@ %@", RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,finalAmountStr.count > 0 ? finalAmountStr : "--")
                }

                cell.premiumAmountView.isHidden = false
                cell.heightOfPremiumAmountView.constant = 40

//                cell.taxesInfoView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
                cell.premiumAmountView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
//                cell.amountIncludingTaxesView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")

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
//                cell.taxesInfoView.isHidden  = true
//                cell.heightOfTaxView.constant = 0
//                cell.amountIncludingTaxesView.isHidden = true
//                cell.heightOfPremiumAmountIncludingTaxesView1.constant = 0
//                cell.premiumAmountView.isHidden = true
//                cell.heightOfPremiumAmountView.constant = 0
//
//                cell.discountInfoView.isHidden = true
//                cell.heightOfDiscountView.constant = 0
            }
        }
        return cell

    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        if(cellType == TabelViewCellType.PaymentSchdule){
        
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
//        }
//        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if(cellType == TabelViewCellType.PaymentSchdule){
//            if(section > 1){
//                return 0
//            }
            return 35
//        }
//        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.heightOfBillingTableView.constant = self.billingElementsTableView.contentSize.height
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.heightOfBillingTableView.constant = self.billingElementsTableView.contentSize.height
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.heightOfBillingTableView.constant = self.billingElementsTableView.contentSize.height
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.heightOfBillingTableView.constant = self.billingElementsTableView.contentSize.height
    }

}
