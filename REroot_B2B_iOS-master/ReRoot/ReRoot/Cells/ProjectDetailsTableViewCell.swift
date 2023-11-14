//
//  ProjectDetailsTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 11/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class ProjectDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var collectionViewHolder: UIView!
    @IBOutlet weak var overLayImageView: UIImageView!
    @IBOutlet weak var mSubContentView: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mCollectinView: CustomCollectionView!
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
        
        collectionViewHolder.layer.cornerRadius = 8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
