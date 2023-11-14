//
//  SingleUnitCollectionViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/08/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class SingleUnitCollectionViewCell: UICollectionViewCell {

    @IBOutlet var heightOfUnitIndexLabel: NSLayoutConstraint!
    @IBOutlet var unitImageView: UIImageView!
    @IBOutlet var widthOfCell: NSLayoutConstraint!
    @IBOutlet var subView: UIView!
    @IBOutlet var unitIndexLabel: UILabel!
    @IBOutlet var floorNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
