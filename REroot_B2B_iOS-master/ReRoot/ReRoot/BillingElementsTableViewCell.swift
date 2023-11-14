//
//  BillingElementsTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 01/06/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class BillingElementsTableViewCell: UITableViewCell {

    @IBOutlet weak var premiumUnitImageView: UIImageView!
    @IBOutlet weak var bottomOfPremiumRevisedAmt1: NSLayoutConstraint!
    @IBOutlet weak var bottomOfPremiumRevisedAmt: NSLayoutConstraint!
    //    @IBOutlet weak var ratesStackView: UIStackView!
//    @IBOutlet weak var parentStackView: UIStackView!
//    @IBOutlet weak var premiumStackView: UIStackView!
    
    @IBOutlet weak var revisedTaxAmountTitleLabel: UILabel!
    @IBOutlet weak var taxAmountTitleLabel: UILabel!
    @IBOutlet weak var heightOfDiscountView: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfPermiumInfoView: NSLayoutConstraint!
    @IBOutlet weak var premiumViewInfo: UIView!
    @IBOutlet weak var premiumCompnentLabel: UILabel!
    
//    @IBOutlet weak var bottomConstraintOfSubContentView: NSLayoutConstraint!
//    @IBOutlet weak var topConstraintOfSubContentView: NSLayoutConstraint!
    @IBOutlet weak var subContentView: UIView!
    @IBOutlet weak var discountInfoView: UIView!
//    @IBOutlet weak var taxesStackView: UIStackView!
//    @IBOutlet weak var premiumAmountStackView: UIStackView!
//    @IBOutlet weak var amountStackView: UIStackView!
//    @IBOutlet weak var amountIncludingTaxesStackView: UIStackView!
    
    @IBOutlet weak var premiumAmoutLabel: UILabel!
    @IBOutlet weak var premiumRevisedAmountLabel: UILabel!
    
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var elementNameLabel: UILabel!
    
    @IBOutlet weak var areaOrQtyLabel: UILabel!
    @IBOutlet weak var pricingTypeLabel: UILabel!
    
    @IBOutlet weak var discountAmountLabel: UILabel!
    @IBOutlet weak var discountPercentageLabel: UILabel!
    
//    @IBOutlet weak var areaPriceStackView: UIStackView!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var revisedAmountLabel: UILabel!
    
    @IBOutlet weak var revisedTaxesAmountLabel: UILabel!
    @IBOutlet weak var taxesAmountLabel: UILabel!
    
    @IBOutlet weak var revisedAmountIncludingTaxesLabl: UILabel!
    @IBOutlet weak var amountIncludingTaxesLabel: UILabel!

    @IBOutlet weak var taxesInfoView: UIView!
    @IBOutlet weak var heightOfTaxView: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfPremiumAmountView: NSLayoutConstraint!
    @IBOutlet weak var premiumAmountView: UIView!
    
    @IBOutlet weak var heightOfPremiumAmountIncludingTaxesView1: NSLayoutConstraint!
    @IBOutlet weak var heightOfPremiumAmountIncludingTaxesView: NSLayoutConstraint!
    @IBOutlet weak var amountIncludingTaxesView: UIView!
    
    @IBOutlet weak var parentOfBillingViews: UIView!
    @IBOutlet weak var billingElementNameView: UIView!
    //    @IBOutlet weak var stackViewHolder: UIView!
    @IBOutlet weak var heightOfAmountView: NSLayoutConstraint!
    @IBOutlet weak var amountView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        subContentView.layer.cornerRadius = 8
        premiumViewInfo.layer.cornerRadius = 8
        parentOfBillingViews.layer.cornerRadius = 8
        
        if #available(iOS 11.0, *) {
            
            billingElementNameView.clipsToBounds = true
            billingElementNameView.layer.cornerRadius = 8
            billingElementNameView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

            amountIncludingTaxesView.clipsToBounds = true
            amountIncludingTaxesView.layer.cornerRadius = 8
            amountIncludingTaxesView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
