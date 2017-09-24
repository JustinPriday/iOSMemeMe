//
//  CreateMemeController+ImagePickerDelegate.swift
//  MemeMe
//
//  Created by Justin Priday on 2017/09/24.
//  Copyright © 2017 Justin Priday. All rights reserved.
//

import Foundation
import UIKit

extension CreateMemeController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: UIImagePicker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImage.image = image
            updateImageLayout()
            checkShareAvailable()
        }
        picker.dismiss(animated: true, completion: nil)
        print("Got an image")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User Cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
}
