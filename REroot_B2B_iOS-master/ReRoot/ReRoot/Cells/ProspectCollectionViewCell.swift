//
//  ProspectCollectionViewCell.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 13/02/20.
//  Copyright © 2020 ReRoot. All rights reserved.
//

import UIKit

class ProspectCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var subContentView: UIView!
    @IBOutlet weak var expiredCountLabel: UILabel!
    @IBOutlet weak var expiredCountView: UIView!
    @IBOutlet weak var prospectInfoButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prospectInfoButton.layer.cornerRadius = 12
        prospectInfoButton.layer.borderWidth = 1.0

        
        expiredCountView.layer.cornerRadius = 12
        expiredCountLabel.layer.cornerRadius = 12
//        subContentView.layer.cornerRadius = 8
        
        expiredCountView.clipsToBounds = true
//
        expiredCountView.layer.masksToBounds = false
        expiredCountView.layer.shadowColor = UIColor.lightGray.cgColor
        expiredCountView.layer.shadowOffset = CGSize(width: 0, height: 0)

        expiredCountView.layer.shadowOpacity = 0.4
        expiredCountView.layer.shadowRadius = 2.0
        expiredCountView.layer.borderColor = UIColor.white.cgColor
        expiredCountView.layer.shouldRasterize = true
        expiredCountView.layer.rasterizationScale = UIScreen.main.scale

        
        subContentView.bringSubviewToFront(expiredCountView)
        // Initialization code
    }
}
