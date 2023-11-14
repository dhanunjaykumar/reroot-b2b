//
//  PopOverTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 17/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class PopOverTableViewCell: UITableViewCell {

    @IBOutlet weak var leadingOfSubView: NSLayoutConstraint!

    @IBOutlet var leadingOfTitleLabel: NSLayoutConstraint!
    @IBOutlet var widthOfImageHolderView: NSLayoutConstraint!
    @IBOutlet var roundedView: UIView!
    @IBOutlet var widthOfImageView: NSLayoutConstraint!
    @IBOutlet var mTitleLabel: UILabel!
    @IBOutlet var mImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        roundedView.layer.cornerRadius = 5
        roundedView.backgroundColor = UIColor.green
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
