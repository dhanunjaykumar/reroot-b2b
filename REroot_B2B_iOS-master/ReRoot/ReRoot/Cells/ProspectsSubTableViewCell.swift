//
//  ProspectsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 19/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ProspectsSubTableViewCell: UITableViewCell {

    @IBOutlet var subContentView: UIView!
    @IBOutlet var prospectCountLabel: UILabel!
    @IBOutlet var prospectTypeLabel: UILabel!
    @IBOutlet var mImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subContentView.layer.cornerRadius = 8
        
        mImageView.layer.masksToBounds = true
        mImageView.clipsToBounds = true
        mImageView.layer.cornerRadius = 8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
