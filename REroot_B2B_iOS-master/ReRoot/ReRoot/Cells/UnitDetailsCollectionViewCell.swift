//
//  UnitDetailsCollectionViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 26/01/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class UnitDetailsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var unitApprovedStatusLabel: UILabel!
    @IBOutlet weak var unitStatusLabel: UILabel!
    @IBOutlet weak var premiumUnitImageView: UIImageView!
    @IBOutlet weak var bottomOfSubView: NSLayoutConstraint!
    @IBOutlet weak var landOwnerLabel: UILabel!
    @IBOutlet weak var unitCellWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var unitImageView: UIImageView!
    @IBOutlet weak var unitNumberLabel: UILabel!
    @IBOutlet weak var subView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        landOwnerLabel.layer.masksToBounds = true
        landOwnerLabel.layer.cornerRadius = 4.0
        unitStatusLabel.layer.masksToBounds = true
        unitStatusLabel.layer.cornerRadius = 4
        unitApprovedStatusLabel.layer.masksToBounds = true
        unitApprovedStatusLabel.layer.cornerRadius = 4

        
//        if #available(iOS 11.0, *) {
////            unitStatusLabel.clipsToBounds = true
//            unitStatusLabel.layer.cornerRadius = 8
//            unitStatusLabel.layer.maskedCorners = [.layerMaxXMaxYCorner]
//
//            unitStatusLabel.layer.cornerRadius = 4
//
//            unitStatusLabel.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner]
//        } else {
//            // Fallback on earlier versions
//        }

        
//        unitStatusLabel.layer.cornerRadius =
        // Initialization code
    }

}
