//
//  FIlCollectionViewCell.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 07/02/21.
//  Copyright © 2021 ReRoot. All rights reserved.
//

import UIKit

class FIlCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = String(describing: FIlCollectionViewCell.self)

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    func update(with file: File) {
      nameLabel.text = file.name

        if #available(iOS 13.0, *) {
            file.generateThumbnail { [weak self] image in
              DispatchQueue.main.async {
                self?.thumbnailImageView.image = image
              }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
