//
//  ApprovalBillingTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 29/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ApprovalBillingTableViewCell: UITableViewCell {

    @IBOutlet weak var discountInfoView: UIView!
    @IBOutlet weak var heightConstraintOfDiscountView: NSLayoutConstraint!
    @IBOutlet weak var areaInfoView: UIView!
    @IBOutlet weak var billingElementTypeLabel: UILabel!
    @IBOutlet weak var currentRateLabel: UILabel!
    @IBOutlet weak var discountPercentLabel: UILabel!
    @IBOutlet weak var discoutnAmountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var revisedAmountLabel: UILabel!
    @IBOutlet weak var areaQtyLabel: UILabel!
    @IBOutlet weak var pricingTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
