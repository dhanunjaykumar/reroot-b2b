//
//  HomeMenuTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 04/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class HomeMenuTableViewCell: UITableViewCell {
    
    @IBOutlet var subContentView: UIView!
    @IBOutlet var menuImageView: UIImageView!
    @IBOutlet var menuTitleLabel: UILabel!
    @IBOutlet var menuSubTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subContentView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
