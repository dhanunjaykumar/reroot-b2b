//
//  ProspectTypeCollectionViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 12/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ProspectTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet var widthOfScheduleCountView: NSLayoutConstraint!
    @IBOutlet var subContentView: UIView!
    @IBOutlet var scheduledProspectsCountLabel: UILabel!
    @IBOutlet var scheduleCountInfoView: UIView!
    @IBOutlet var prospectImageView: UIImageView!
    @IBOutlet var prospectsCountLabel: UILabel!
    @IBOutlet var prospectTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scheduleCountInfoView.layer.cornerRadius = widthOfScheduleCountView.constant/2
        subContentView.layer.cornerRadius = 8
        
        scheduleCountInfoView.clipsToBounds = true
        
        scheduleCountInfoView.layer.masksToBounds = false
        scheduleCountInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        scheduleCountInfoView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        scheduleCountInfoView.layer.shadowOpacity = 0.4
        scheduleCountInfoView.layer.shadowRadius = 2.0
        scheduleCountInfoView.layer.shouldRasterize = true
        scheduleCountInfoView.layer.borderColor = UIColor.white.cgColor
        scheduleCountInfoView.layer.shouldRasterize = true
        scheduleCountInfoView.layer.rasterizationScale = UIScreen.main.scale

    }

}
