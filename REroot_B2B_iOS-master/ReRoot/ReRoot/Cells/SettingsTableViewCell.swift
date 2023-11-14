//
//  SettingsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/08/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet var enableSwitch: UISwitch!
    @IBOutlet var subTitleLbel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    @IBAction func enableSetting(_ sender: Any) {
//
//    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
