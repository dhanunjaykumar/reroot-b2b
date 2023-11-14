//
//  ColorCollectionViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 12/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var subContentView: UIView!
    
    @IBOutlet var widthOfSubContentView: NSLayoutConstraint!
    @IBOutlet var statusTitleLabel: UILabel!
    @IBOutlet var statusColorIndicatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
