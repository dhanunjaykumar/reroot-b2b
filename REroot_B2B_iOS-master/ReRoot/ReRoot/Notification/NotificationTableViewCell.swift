//
//  NotificationTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 28/02/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet var prospectTypeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var typeIndicator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        typeIndicator.layer.cornerRadius = 15
        prospectTypeLabel?.layer.masksToBounds = true
        prospectTypeLabel.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
