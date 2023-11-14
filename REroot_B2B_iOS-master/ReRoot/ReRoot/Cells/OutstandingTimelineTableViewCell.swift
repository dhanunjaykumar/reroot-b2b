//
//  OutstandingTimelineTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 20/11/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class OutstandingTimelineTableViewCell: UITableViewCell {

    @IBOutlet weak var followDetailsInfoLabel: UILabel!
    @IBOutlet weak var verticalLineView: UIView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var modeImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
