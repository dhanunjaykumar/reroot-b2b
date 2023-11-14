//
//  ReservationTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ReservationTableViewCell: UITableViewCell {

    @IBOutlet var subContentView: UIView!
    @IBOutlet var queuePositionLabel: UILabel!
    @IBOutlet var reservedByLabel: UILabel!
    @IBOutlet var toDateLabel: UILabel!
    @IBOutlet var fromDateLabel: UILabel!
    @IBOutlet var reservationHolderNameLabel: UILabel!
    
    @IBOutlet var revokeButton: UIButton!
    
    @IBOutlet weak var addReceiptButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        queuePositionLabel.layer.masksToBounds = true
        queuePositionLabel.layer.cornerRadius = 8

        subContentView.layer.cornerRadius = 8
        addReceiptButton.layer.cornerRadius = 8
        addReceiptButton.layer.borderColor = UIColor.lightGray.cgColor
        addReceiptButton.layer.borderWidth = 0.6
//        revokeButton.layer.cornerRadius = 8
        
        
        subContentView.layer.cornerRadius = 4
        subContentView.layer.borderWidth = 2
        subContentView.layer.borderColor = UIColor.clear.cgColor
        subContentView.layer.shadowRadius = 4
        subContentView.layer.masksToBounds = false
        subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        subContentView.layer.shadowRadius = 2
        subContentView.layer.shadowOpacity = 0.3

//        revokeButton.layer.cornerRadius = 8
//        revokeButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        if #available(iOS 11.0, *){
//            revokeButton.clipsToBounds = false
            revokeButton.layer.cornerRadius = 5
            revokeButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }else{
        }


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
