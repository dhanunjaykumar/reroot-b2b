//
//  RegInfoTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class RegInfoTableViewCell: UITableViewCell {

    @IBOutlet var prospectIdLabel: UILabel!
    @IBOutlet var customerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
