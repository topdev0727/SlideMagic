//
//  RoundBorderImageView.swift
//  SlideMagic
//
//  Created by RX on 4/4/19.
//  Copyright © 2019 JZ. All rights reserved.
//

import UIKit

@IBDesignable class RoundBorderImageView: UIImageView {

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let color = newValue else { return }
            layer.borderColor = color.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }

}
