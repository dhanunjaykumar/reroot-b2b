//
//  ImagePickerManager.swift
//  REroot
//
//  Created by Dhanunjay on 13/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import Foundation
import UIKit
import AWSS3
import Alamofire


public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?,imageName : String?)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        self.pickerController.allowsEditing = false
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
//        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
//            alertController.addAction(action)
//        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    public func takePhoto(from sourceView: UIView) {
        self.pickerController.sourceType = UIImagePickerController.SourceType.camera
        self.presentationController?.present(self.pickerController, animated: true)
    }
    public func takeFromPhotos(from sourceView: UIView) {
        self.pickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.presentationController?.present(self.pickerController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?,imageURL : String?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image, imageName: imageURL)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil,imageURL: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var imageName : String!
        if #available(iOS 11.0, *) {
            if(info[UIImagePickerController.InfoKey.imageURL] != nil){
                let imagePath : URL = (info[UIImagePickerController.InfoKey.imageURL] as! URL)
                print(imagePath)
                print(imagePath.lastPathComponent)
                imageName = imagePath.lastPathComponent
            }

        } else {
            // Fallback on earlier versions
        }
        
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil,imageURL: nil)
        }
//        let fileUrl = Foundation.URL(string: filePath)
        
//        self.uploadImage(image: image,imageName: imageName)
        self.pickerController(picker, didSelect: image,imageURL: imageName)
    }
    
}

extension ImagePicker: UINavigationControllerDelegate {
    
}

