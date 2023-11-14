//
//  HandOverItemTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 27/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class HandOverItemTableViewCell: UITableViewCell {

    @IBOutlet weak var subContentView: UIView!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var totalMandatoryItemsLabel: UILabel!
    @IBOutlet weak var openMandatoryItemsLabel: UILabel!
    @IBOutlet weak var closedMandatoryItemsLabel: UILabel!
    
    @IBOutlet weak var closedItemsLabel: UILabel!
    @IBOutlet weak var openItemsLabel: UILabel!
    @IBOutlet weak var totalItemsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerStackView.addBackground(color: UIColor.hexStringToUIColor(hex: "f9f9f9"))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
