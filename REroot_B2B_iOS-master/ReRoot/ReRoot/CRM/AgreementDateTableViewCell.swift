//
//  AgreementDateTableViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 08/06/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class AgreementDateTableViewCell: UITableViewCell {

    @IBOutlet weak var agreementTypeLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let calendar = UIImageView.init(image: UIImage.init(named: "calendar"))
        calendar.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        calendar.contentMode = .center
        dateTextField.rightView = calendar
        dateTextField.rightViewMode = .always

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
