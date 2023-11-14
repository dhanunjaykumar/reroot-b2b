//
//  ProspectDetailsCollectionViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 7/19/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ProspectDetailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var widthOfStackView: NSLayoutConstraint!
    @IBOutlet weak var widthOfSubContentView: NSLayoutConstraint!
    
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
