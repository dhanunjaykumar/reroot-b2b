//
//  QuickLookCollectionViewController.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 07/02/21.
//  Copyright © 2021 ReRoot. All rights reserved.
//

import UIKit
import QuickLook

private let reuseIdentifier = "Cell"

class QuickLookCollectionViewController: UICollectionViewController {
    
    weak var tappedCell: FIlCollectionViewCell?

    let files = File.loadFiles()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let nib = UINib(nibName: "FIlCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "FileCell")
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      files.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//      guard let cell = collectionView.dequeueReusableCell(
//        withReuseIdentifier: FileCell.reuseIdentifier,
//        for: indexPath) as? FileCell
//        else {
//          return UICollectionViewCell()
//      }
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath) as? FIlCollectionViewCell else {
            return UICollectionViewCell()
        }
        
      cell.update(with: files[indexPath.row])
      return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//      collectionView.deselectItem(at: indexPath, animated: true)
//      let quickLookViewController = QLPreviewController()
//      quickLookViewController.dataSource = self
//      quickLookViewController.delegate = self
//      tappedCell = collectionView.cellForItem(at: indexPath) as? FileCell
//      quickLookViewController.currentPreviewItemIndex = indexPath.row
//      present(quickLookViewController, animated: true)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
// MARK: - QLPreviewControllerDataSource
extension QuickLookCollectionViewController: QLPreviewControllerDataSource {
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    files.count
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    files[index]
  }
}

// MARK: - QLPreviewControllerDelegate
extension QuickLookCollectionViewController: QLPreviewControllerDelegate {
  func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
    tappedCell?.thumbnailImageView
  }

    @available(iOS 13.0, *)
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
    .updateContents
  }

  func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
    guard let file = previewItem as? File else { return }
    DispatchQueue.main.async {
      self.tappedCell?.update(with: file)
    }
  }
}
