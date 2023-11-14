//
//  SingleUnitCollectionViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/08/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class SingleUnitCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var unitApprovedStatusLabel: UILabel!
    @IBOutlet weak var unitStatusLabel: UILabel!
    @IBOutlet weak var premiumUnitImageView: UIImageView!
    @IBOutlet weak var landOwnerLabel: UILabel!
    @IBOutlet weak var heightOfUnitIndexLabel: NSLayoutConstraint!
    @IBOutlet weak var unitImageView: UIImageView!
    @IBOutlet weak var widthOfCell: NSLayoutConstraint!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var unitIndexLabel: UILabel!
    @IBOutlet weak var floorNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        landOwnerLabel.layer.masksToBounds = true
        landOwnerLabel.layer.cornerRadius = 4.0
        unitStatusLabel.layer.masksToBounds = true
        unitStatusLabel.layer.cornerRadius = 4.0
        unitStatusLabel.backgroundColor = landOwnerLabel.backgroundColor
        // Initialization code
    }

}
