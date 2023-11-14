//
//  CommonProspectsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 27/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class CommonProspectsTableViewCell: UITableViewCell {

    @IBOutlet var subContentView: UIView!
    @IBOutlet var leadingConstraintOfDetailsView: NSLayoutConstraint!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var widthOfCheckBox: NSLayoutConstraint!
    @IBOutlet var checkBoxImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        widthOfCheckBox.constant = 0
        checkBoxImageView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
