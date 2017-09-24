//
//  CreateMemeController+Keyboard.swift
//  MemeMe
//
//  Created by Justin Priday on 2017/09/24.
//  Copyright © 2017 Justin Priday. All rights reserved.
//

import Foundation
import UIKit

extension CreateMemeController: UITextFieldDelegate {
    // MARK: UITextFieldDelegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard on return pressed.
        textField.resignFirstResponder()
        return true;
    }
    
    // MARK: Notification Selectors with helpers
    
    func getKeyboardRect(notification: NSNotification) -> CGRect {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue
        return keyboardSize.cgRectValue
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        //Keyboard will change more versatile than on hide and on show observers.
        //This captures keyboard height changes when for instance orientation changes.
        if (getKeyboardRect(notification: notification).origin.y < self.view.frame.height) {
            keyboardHeight.constant = getKeyboardRect(notification: notification).height
        } else {
            keyboardHeight.constant = 0
        }
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }
}
