//
//  ItemHistoryTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 28/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ItemHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vLineView: UIView!
    
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemStateInfoLabel: UILabel!
    @IBOutlet weak var itemStateImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
