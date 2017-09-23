//
//  ViewController.swift
//  MemeMe
//
//  Created by Justin Priday on 2017/09/22.
//  Copyright © 2017 Justin Priday. All rights reserved.
//

import UIKit

class CreateMemeController: UIViewController, UINavigationControllerDelegate
    , UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -1]
    
    let memePlaceholderTextAttributes:[NSAttributedStringKey:Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "Impact", size: 40)!,
        .strokeWidth: -1]
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var memeImageAspectConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shareButton: UIBarButtonItem?
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
    
    // MARK: UIViewController Delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.center
        topTextField.attributedPlaceholder = NSAttributedString(string:"TOP",attributes:memePlaceholderTextAttributes)
        topTextField.delegate = self
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = NSTextAlignment.center
        bottomTextField.attributedPlaceholder = NSAttributedString(string:"BOTTOM",attributes:memePlaceholderTextAttributes)
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        checkShareAvailable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Implemented to force Meme text to be 10% of image height, this will match image generated.
        imageContainer.layoutSubviews()
        topTextHeightConstraint.constant = (memeImage.frame.size.height * 0.15)
        bottomTextHeightConstraint.constant = (memeImage.frame.size.height * 0.15)
        topTextField.font = UIFont(name: "Impact", size: memeImage.frame.size.height * 0.1)!
        bottomTextField.font = UIFont(name: "Impact", size: memeImage.frame.size.height * 0.1)!
        topTextField.layoutIfNeeded()
        bottomTextField.layoutIfNeeded()
    }
    
    //MARK: IBActions
    @IBAction func sharePressed(_ sender: Any) {
        let memeObject = MemeImage.init(original: memeImage.image, topText: topTextField.text!, bottomText: bottomTextField.text!)
        let image: UIImage = memeObject.getMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivityType?, completed:Bool, returnedItems:[Any]?, error: Error?) in
            controller.dismiss(animated: true, completion: nil)
            if (completed) {
                self.memeImage.image = nil
                self.topTextField.text = ""
                self.bottomTextField.text = ""
                self.checkShareAvailable()
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(controller, animated: true, completion: nil)

    
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func cameraImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func memeTextChanged(_ sender: Any) {
        checkShareAvailable()
    }
    
    
    // MARK: Class Methods
    
    func updateImageLayout() {
        var aspect:CGFloat = 1.0
        if let imageSize = memeImage.image?.size {
            aspect = (imageSize.width) / (imageSize.height)
        }
        memeImageAspectConstraint = memeImageAspectConstraint.setMultiplier(multiplier: aspect)
        
        memeImage.setNeedsUpdateConstraints()
        memeImage.layoutIfNeeded()
    }
    
    func checkShareAvailable() {
        if let shareButton = shareButton {
            shareButton.isEnabled = false
            if (memeImage.image != nil) {
                if (((topTextField.text?.characters.count)! > 0) || ((bottomTextField.text?.characters.count)! > 0)) {
                    shareButton.isEnabled = true
                }
            }
        }
    }
    
    // MARK: UITextFieldDelegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
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
    
    // MARK: Notification Selectors with helpers
    
    func getKeyboardRect(notification: NSNotification) -> CGRect {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue
        return keyboardSize.cgRectValue
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        if (getKeyboardRect(notification: notification).origin.y < self.view.frame.height) {
            keyboardHeight.constant = getKeyboardRect(notification: notification).height
        } else {
            keyboardHeight.constant = 0
        }
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }

    // MARK: Observer Subscription Managers
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_ :)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    
}

