//
//  ProjectDetailsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 11/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ProjectDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet var overLayImageView: UIImageView!
    @IBOutlet var mSubContentView: UIView!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var projectNameLabel: UILabel!
    @IBOutlet var mImageView: UIImageView!
    @IBOutlet var mCollectinView: CustomCollectionView!
    var mStatusDictArray : Array<STAT> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mSubContentView.layer.cornerRadius = 8.0
        mImageView.layer.cornerRadius = 8.0
        self.mCollectinView.layer.cornerRadius = 8.0
        
        mCollectinView.register(UINib(nibName: "BlockInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "blockCell")
        
        let tempLayout = UICollectionViewFlowLayout.init()
        tempLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        tempLayout.scrollDirection = .horizontal
        mCollectinView.collectionViewLayout = tempLayout
        
        overLayImageView.layer.cornerRadius = 8.0

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
