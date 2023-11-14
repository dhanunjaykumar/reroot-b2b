//
//  ProspectsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 23/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ProspectsTableViewCell: UITableViewCell {

    @IBOutlet weak var bottomOfSubContentView: NSLayoutConstraint!
    @IBOutlet var leadingConstraintOfTitleLabel: NSLayoutConstraint!
    @IBOutlet var widthOfBGView: NSLayoutConstraint!
    @IBOutlet var approvalTypeBGView: UIView!
    @IBOutlet var approvalTypeView: UIView!
    @IBOutlet var approvalTypeLabel: UILabel!
    @IBOutlet var widthConstraintOfLeftImageView: NSLayoutConstraint!
    @IBOutlet var heightOfProspectsCountLabel: NSLayoutConstraint!
    @IBOutlet var prospectsCountLabel: UILabel!
    @IBOutlet var heightOfLeftImageView: NSLayoutConstraint!
    @IBOutlet var heightOfSubContentView: NSLayoutConstraint!
    @IBOutlet var widthOfRightImage: NSLayoutConstraint!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var rightImageView: UIImageView!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var subContentView: UIView!
    
    @IBOutlet var widthOfApprovalsCountLabel: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subContentView.layer.cornerRadius = 8
        widthOfApprovalsCountLabel.constant = 0
        prospectsCountLabel.isHidden = true
        leftImageView.layer.masksToBounds = true
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 8
        widthOfBGView.constant = 0
        approvalTypeBGView.isHidden = true
        leadingConstraintOfTitleLabel.constant = 60
        approvalTypeBGView.layer.cornerRadius = 8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
