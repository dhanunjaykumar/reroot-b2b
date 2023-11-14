//
//  BlockInfoCollectionViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 14/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class BlockInfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var trailingConstraintOfStatusTypeLabel: NSLayoutConstraint!
    @IBOutlet weak var leadContraintOfStatusTypeLabel: NSLayoutConstraint!
    @IBOutlet var widthConstraintOfBlockCell: NSLayoutConstraint!
    @IBOutlet var mSubContentView: UIView!
    @IBOutlet var mStatusTypeNumberLabel: UILabel!
    @IBOutlet var mStatusTypeLabel: UILabel!
    var stausNumber : Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.mStatusTypeLabel.backgroundColor = UIColor.white
//        self.mStatusTypeNumberLabel.backgroundColor = UIColor.white
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.width = ceil(size.width)
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }


}
