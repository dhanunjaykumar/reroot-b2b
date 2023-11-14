//
//  CallsTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 29/01/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class CallsTableViewCell: UITableViewCell {

    @IBOutlet var widthOfCheckBoxImage: NSLayoutConstraint!
    @IBOutlet var subView: UIView!
    @IBOutlet var leadingConstraintOfDetailsView: NSLayoutConstraint!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var whatsappButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var checkBoxImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxImageView.isHidden = true
        widthOfCheckBoxImage.constant = 0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
