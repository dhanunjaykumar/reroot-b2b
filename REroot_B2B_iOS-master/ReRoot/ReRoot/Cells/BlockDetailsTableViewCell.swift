//
//  BlockDetailsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 14/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class BlockDetailsTableViewCell: UITableViewCell {

    @IBOutlet var subContentView: UIView!
    @IBOutlet var mTowersInfoLabel: UILabel!
    @IBOutlet var mBlockNameLabel: UILabel!
    @IBOutlet var mCollectionView: CustomCollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tempLayout = UICollectionViewFlowLayout.init()
        tempLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        tempLayout.scrollDirection = .horizontal
        mCollectionView.collectionViewLayout = tempLayout
        
        mCollectionView.register(UINib(nibName: "BlockInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "blockCell")

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
