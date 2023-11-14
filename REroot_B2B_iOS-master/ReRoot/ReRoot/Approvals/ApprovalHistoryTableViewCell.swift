//
//  ApprovalHistoryTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 29/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ApprovalHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var tapGuesture: UITapGestureRecognizer!
    @IBOutlet weak var widthOfAudioImageView: NSLayoutConstraint!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var verticalLineView: UIView!
    @IBOutlet weak var statusTypeImageView: UIImageView!
    @IBOutlet weak var approvalDetailsLabel: UILabel!
    @IBOutlet weak var approvalStatusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
