//
//  UnitInfoView.swift
//  REroot
//
//  Created by Dhanunjay on 19/11/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class UnitInfoView: UIView {

    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "UnitInfoView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
