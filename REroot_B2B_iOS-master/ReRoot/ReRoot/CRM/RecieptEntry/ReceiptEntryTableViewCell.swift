//
//  ReceiptEntryTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 18/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ReceiptEntryTableViewCell: UITableViewCell {

    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var projectNameAndUnitNameLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var customerNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        amountLabel.layer.borderWidth = 1
        amountLabel.layer.borderColor = UIColor.red.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
