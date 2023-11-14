//
//  RegistrationsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 24/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class RegistrationsTableViewCell: UITableViewCell {

    @IBOutlet var callButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
