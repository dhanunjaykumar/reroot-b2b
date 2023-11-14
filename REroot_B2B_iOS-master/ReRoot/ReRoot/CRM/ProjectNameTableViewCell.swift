//
//  ProjectNameTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 21/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ProjectNameTableViewCell: UITableViewCell {

    @IBOutlet weak var widthOfImageView: NSLayoutConstraint!
    @IBOutlet weak var redioButtonImageView: UIImageView!
    @IBOutlet weak var bottomConstraintOfStatusLabel: NSLayoutConstraint!
    @IBOutlet weak var heightOfUnitStatusLabel: NSLayoutConstraint!
    @IBOutlet weak var unitStatusLabel: UILabel!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var widthOfRightLabel: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
