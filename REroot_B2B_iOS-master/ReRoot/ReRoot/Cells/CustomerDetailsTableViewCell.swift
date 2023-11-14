//
//  CustomerDetailsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 25/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class CustomerDetailsTableViewCell: UITableViewCell {

    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
