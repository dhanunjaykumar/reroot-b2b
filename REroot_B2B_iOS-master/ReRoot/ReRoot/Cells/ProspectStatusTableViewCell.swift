//
//  ProspectStatusTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ProspectStatusTableViewCell: UITableViewCell {

    @IBOutlet var statusTypeImageView: UIImageView!
    @IBOutlet var statusTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
