//
//  ButtonView.swift
//  ReRoot
//
//  Created by Dhanunjay on 16/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ButtonView: UIView {

    @IBOutlet var mCenterLabelForPopUp: UILabel!
    
    @IBOutlet var subView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var mTitleLabel: UILabel!
    @IBOutlet var mImageView: UIImageView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ButtonView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    
//    override init(frame: CGRect) { //for using custom view in code
//        super.init(frame: frame)
//        commonInit()
//    }
//    required init?(coder aDecoder: NSCoder) { //for using custom view in IB
//        super.init(coder: aDecoder)
//        commonInit()
//    }
//
//    private func commonInit(){
//        Bundle.main.loadNibNamed("ButtonView", owner: self, options: nil)
//        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
