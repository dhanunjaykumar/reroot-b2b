//
//  ProspectsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 23/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ProspectsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var rightImageView: UIImageView!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var subContentView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subContentView.layer.cornerRadius = 8
        
        leftImageView.layer.masksToBounds = true
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
