//
//  DiscountRequestTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 13/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class DiscountRequestTableViewCell: UITableViewCell {

    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var discountAmountLabel: UILabel!
    @IBOutlet var discountTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
