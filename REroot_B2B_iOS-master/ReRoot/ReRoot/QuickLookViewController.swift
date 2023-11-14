//
//  QuickLookViewController.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 07/02/21.
//  Copyright © 2021 ReRoot. All rights reserved.
//

import UIKit
import QuickLook

class QuickLookViewController: UIViewController {

    weak var tappedCell: FIlCollectionViewCell?

    let files = File.loadFiles()

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: "FIlCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "FileCell")

        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    @IBAction func back(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension QuickLookViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      files.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath) as? FIlCollectionViewCell else {
            return UICollectionViewCell()
        }
        
      cell.update(with: files[indexPath.row])
      return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      collectionView.deselectItem(at: indexPath, animated: true)
      let quickLookViewController = QLPreviewController()
      quickLookViewController.dataSource = self
      quickLookViewController.delegate = self
      tappedCell = collectionView.cellForItem(at: indexPath) as? FIlCollectionViewCell
      quickLookViewController.currentPreviewItemIndex = indexPath.row
      present(quickLookViewController, animated: true)
    }

    
}
// MARK: - QLPreviewControllerDataSource
extension QuickLookViewController: QLPreviewControllerDataSource {
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    files.count
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    files[index]
  }
}

// MARK: - QLPreviewControllerDelegate
extension QuickLookViewController: QLPreviewControllerDelegate {
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
