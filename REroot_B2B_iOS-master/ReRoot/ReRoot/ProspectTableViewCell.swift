//
//  ProspectTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 13/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ProspectTableViewCell: UITableViewCell {

    @IBOutlet var subContentView: UIView!
    @IBOutlet var checkBoxImageView: UIImageView!
    @IBOutlet var widthOfImageView: NSLayoutConstraint!
    @IBOutlet var whatsappButton: UIButton!
    @IBOutlet var prospectTypeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var projectNameLabel: UILabel!
    @IBOutlet var salesPersonAndTimeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var heightOfDateLabel: NSLayoutConstraint!
    @IBOutlet var callButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        prospectTypeLabel.layer.masksToBounds = true
        prospectTypeLabel.layer.cornerRadius = 2

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
