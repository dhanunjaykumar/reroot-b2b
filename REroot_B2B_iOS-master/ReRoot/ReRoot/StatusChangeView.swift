//
//  StatusChangeView.swift
//  REroot
//
//  Created by Dhanunjay on 29/01/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class StatusChangeView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var salesPersonViewHeight: NSLayoutConstraint!
    @IBOutlet var salesPersonView: UIView!
    @IBOutlet var HLineView: UIView!
    @IBOutlet var currentStatusLabel: UILabel!
    @IBOutlet var salesPersonNameLabel: UILabel!
    @IBOutlet var salesPersonChangeButton: UIButton!
    @IBOutlet var statusChangeButton: UIButton!
    @IBOutlet var subContentView: UIView!
    @IBOutlet var statusChangeView: UIView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "StatusChangeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
