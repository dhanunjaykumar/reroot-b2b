//
//  EditHOTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 27/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class EditHOTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
