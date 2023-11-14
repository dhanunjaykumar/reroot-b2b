//
//  OwnerDetailsCollectionViewCell.swift
//  REroot
//
//  Created by Dhanunjay on 13/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class OwnerDetailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var subContentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailIDLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var editDetailsButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var whatsappButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        subContentView.layer.cornerRadius = 8
        
        subContentView.layer.cornerRadius = 5
        subContentView.layer.borderWidth = 2
        subContentView.layer.borderColor = UIColor.clear.cgColor
        subContentView.layer.shadowRadius = 4
        subContentView.layer.masksToBounds = false
        subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        subContentView.layer.shadowRadius = 2
        subContentView.layer.shadowOpacity = 0.3
        
    }

}
