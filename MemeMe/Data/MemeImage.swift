//
//  MemeImage.swift
//  MemeMe
//
//  Created by Justin Priday on 2017/09/23.
//  Copyright © 2017 Justin Priday. All rights reserved.
//

import Foundation
import UIKit

struct MemeImage {
    var originalImage : UIImage!
    var topText : String
    var bottomText : String
    
    init(original inOriginal : UIImage!,topText inTopText : String, bottomText inBottomText: String) {
        originalImage = inOriginal
        topText = inTopText
        bottomText = inBottomText
    }
    
    func getMemedImage() -> UIImage! {
        if (originalImage != nil) {
            UIGraphicsBeginImageContext(originalImage.size)
            originalImage.draw(at: CGPoint.init(x: 0, y: 0))
            
            let drawLabel: UILabel = UILabel()
            
            let memeAttributes:[NSAttributedStringKey:Any] = [
                .strokeColor: UIColor.black,
                .foregroundColor: UIColor.white,
                .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: (originalImage.size.height * 0.1))!,
                .strokeWidth: -1]
            
            drawLabel.textAlignment = NSTextAlignment.center
            drawLabel.adjustsFontSizeToFitWidth = true
            
            if (topText.characters.count > 0) {
                let drawRect: CGRect = CGRect.init(x: 0, y: (originalImage.size.height * 0.05), width: originalImage.size.width, height: (originalImage.size.height * 0.1))
                drawLabel.attributedText = NSAttributedString(string: topText, attributes: memeAttributes)
                drawLabel.drawText(in: drawRect)
            }
            
            if (bottomText.characters.count > 0) {
                let drawRect: CGRect = CGRect.init(x: 0, y: (originalImage.size.height * 0.85), width: originalImage.size.width, height: (originalImage.size.height * 0.1))
                drawLabel.attributedText = NSAttributedString(string: bottomText, attributes: memeAttributes)
                drawLabel.drawText(in: drawRect)
            }
            
            let returnImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            return returnImage
        }
        
        return nil
    }
    
}

