//
//  ContentSizeTableView.swift
//  REroot
//
//  Created by Dhanunjay on 7/1/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ContentSizeTableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
//        print(contentSize.height)
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

}
