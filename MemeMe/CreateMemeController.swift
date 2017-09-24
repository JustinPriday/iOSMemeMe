//
//  ViewController.swift
//  MemeMe
//
//  Created by Justin Priday on 2017/09/22.
//  Copyright © 2017 Justin Priday. All rights reserved.
//

import UIKit

class CreateMemeController: UIViewController {
    
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
        
        //Text Editor setup. Moved to method following review feedback
        configure(textField: topTextField, withText: "TOP")
        configure(textField: bottomTextField, withText: "BOTTOM")
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
                self.saveMeme()
                self.memeImage.image = nil
                self.topTextField.text = ""
                self.bottomTextField.text = ""
                self.checkShareAvailable()
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func getImageButtonPressed(_ sender: UIBarButtonItem) {
        if (sender == cameraButton) {
            captureImage(fromSource: .camera)
        } else {
            captureImage(fromSource: .photoLibrary)
        }
    }
    
    @IBAction func memeTextChanged(_ sender: Any) {
        checkShareAvailable()
    }
    
    // MARK: Class Methods
    
    func configure(textField: UITextField, withText: String) {
        //Configure a text field to be a meme text textfield, takes a place holder text as input
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.attributedPlaceholder = NSAttributedString(string:withText,attributes:memePlaceholderTextAttributes)
        textField.delegate = self
    }
    
    func updateImageLayout() {
        //Changes Image View Aspect Ratio to Image Aspect Ratio.
        var aspect:CGFloat = 1.0
        if let imageSize = memeImage.image?.size {
            aspect = (imageSize.width) / (imageSize.height)
        }
        memeImageAspectConstraint = memeImageAspectConstraint.setMultiplier(multiplier: aspect)
        
        memeImage.setNeedsUpdateConstraints()
        memeImage.layoutIfNeeded()
    }
    
    func checkShareAvailable() {
        //Enables the share button if there is a meme to share.
        if let shareButton = shareButton {
            shareButton.isEnabled = false
            if (memeImage.image != nil) {
                if (((topTextField.text?.characters.count)! > 0) || ((bottomTextField.text?.characters.count)! > 0)) {
                    shareButton.isEnabled = true
                }
            }
        }
    }
    
    func saveMeme() {
        //Save the meme to a globally available Array.
        if ((memeImage.image != nil) && (topTextField.text != nil) && (bottomTextField.text != nil)
            && ((topTextField.text!.count > 0) || (bottomTextField.text!.count > 0))) {
            let meme = MemeImage(original: memeImage.image, topText: topTextField.text!, bottomText: bottomTextField.text!)
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
        }
    }
    
    func captureImage(fromSource: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = fromSource
        self.present(pickerController, animated: true, completion: nil)
    }

    // MARK: Observer Subscription Managers
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_ :)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }

}

