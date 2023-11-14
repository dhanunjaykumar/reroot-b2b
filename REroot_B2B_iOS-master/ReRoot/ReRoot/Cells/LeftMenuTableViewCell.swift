//
//  LeftMenuTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class LeftMenuTableViewCell: UITableViewCell {

//    @IBOutlet weak var menuTitleLabel: UILabel!
//    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var mLeftMenuTitleLabel: UILabel!
    @IBOutlet var mImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
