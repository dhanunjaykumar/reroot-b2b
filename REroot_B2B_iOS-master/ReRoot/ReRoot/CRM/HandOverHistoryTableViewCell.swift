//
//  HandOverHistoryTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 27/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class HandOverHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var hoStateLabel: UILabel!
    @IBOutlet weak var vLineView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var handOverStatusHistoryLabel: UILabel!
    @IBOutlet weak var dateImageView: UIImageView!
    @IBOutlet weak var heightOfDateLabel: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.hoStateLabel.layer.masksToBounds = true
        self.hoStateLabel.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
