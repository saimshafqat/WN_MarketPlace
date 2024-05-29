//
//  ViewDesignable.swift
//  WorldNoor
//
//  Created by Raza najam on 10/10/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class DesignableImageView: UIImageView { }
@IBDesignable class DesignableButton:UIButton { }
@IBDesignable class DesignableTextField:UITextField { }
@IBDesignable class DesignableView:UIView { }

extension UIView {
    @IBInspectable
    var borderWidth :CGFloat {
        get {
            return layer.borderWidth
        }
        
        set(newBorderWidth){
            layer.borderWidth = newBorderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get{
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) :nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var cornerRadius:CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue != 0
        }
    }
    

    @IBInspectable
    var shadowColor: UIColor? {
        get {
            return (layer.shadowColor != nil) ? UIColor(cgColor: layer.shadowColor!) : nil
        } set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    func addShadow(with color: UIColor) {
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 0.6
        layer.shadowColor = color.cgColor
    }
}
