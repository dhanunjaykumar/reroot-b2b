//
//  FilterTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 23/04/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    @IBOutlet var checkBoxImageView: UIImageView!
    @IBOutlet var filterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
