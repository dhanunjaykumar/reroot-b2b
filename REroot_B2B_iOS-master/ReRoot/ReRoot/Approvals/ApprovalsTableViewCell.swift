//
//  ApprovalsTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 26/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ApprovalsTableViewCell: UITableViewCell {
    
    @IBOutlet var dateInfoView: UIView!
    @IBOutlet var subContentView: UIView!
    @IBOutlet var unitInfoLabel: UILabel!
    @IBOutlet var byWhomLabel : UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        subContentView.layer.cornerRadius = 8
        dateInfoView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
