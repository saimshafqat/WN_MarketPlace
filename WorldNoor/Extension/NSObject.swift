//
//  NSObject.swift
//  kalam
//
//  Created by mac on 17/10/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import AVFoundation

extension Int {
    var boolValue: Bool { return self != 0 }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
    
    var appDelegate : AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}


public extension UILabel {

    @IBInspectable var localizedText: String? {
        get {
            return text
        }
        set {
            self.text = newValue?.localized()
        }
    }
    
    
    func rotateForTextAligment(languageMain : String = ""){
        if languageMain.count == 0 {
            let langCode = UserDefaultsUtility.get(with: .Lang) as? String ?? .emptyString
            if langCode == "العربية" || langCode == "فارسی" || langCode == "اردو" || langCode == "ਪੰਜਾਬੀ" {
                self.textAlignment = .right
                
            }else {
                self.textAlignment = .left
            }
        }else {
            if languageMain == "العربية" || languageMain == "فارسی" || languageMain == "اردو" || languageMain == "ਪੰਜਾਬੀ" {
                self.textAlignment = .right
                
            }else {
                self.textAlignment = .left
            }
        }
        
    }
    

}

public extension UITextView {
    func rotateForTextAligment(){
        
        let langCode = UserDefaultsUtility.get(with: .Lang) as? String ?? .emptyString
        if langCode == "العربية" || langCode == "فارسی" || langCode == "اردو"  || langCode == "ਪੰਜਾਬੀ" {
            self.textAlignment = .right
            
        }else {
            self.textAlignment = .left
        }
    }
}
public extension UITextField {
    func rotateForTextAligment(){
        
        let langCode = UserDefaults.standard.value(forKey: "Lang")  as! String
        if langCode == "العربية" || langCode == "فارسی" || langCode == "اردو"  || langCode == "ਪੰਜਾਬੀ" {
            self.textAlignment = .right
            
        }else {
            self.textAlignment = .left
        }
    }
    func setLeftPaddingPoints(_ amount:CGFloat){
           let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
           self.leftView = paddingView
           self.leftViewMode = .always
       }
}



extension UIFont {

    func with(weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: weight)
    }
}
extension UIButton {
    func makeFontDynamic(_ textStyle:UIFont.TextStyle, weight:UIFont.Weight? = nil, enableDynamicFont:Bool = true){
        var font = UIFont.preferredFont(forTextStyle: textStyle)
        if let fweight = weight {
            font = font.with(weight: fweight)
        }
        self.titleLabel?.font = font
        if(enableDynamicFont){
            self.titleLabel?.adjustsFontForContentSizeCategory = true
        }else{
            self.titleLabel?.adjustsFontForContentSizeCategory = false
        }
    }
    
    func makeFontDynamicBody(){
        let headlineFont = UIFont.preferredFont(forTextStyle: .body)
        self.titleLabel?.font = headlineFont
        self.titleLabel?.adjustsFontForContentSizeCategory = true
    }


    func leftImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: image.size.width/1.50)
//        self.tintColor = UIColor.white
    }
    
    func rightImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 8, left: image.size.width/2, bottom: 8, right: 8)
        self.tintColor = UIColor.white
    }
    
    func setAttributedButtonText(firstText: String, firstColor: UIColor, secondText: String, secondColor: UIColor) {
        let att = NSMutableAttributedString(string: firstText + " " + secondText)
        att.addAttribute(NSAttributedString.Key.foregroundColor, value: firstColor, range: NSRange(location: 0, length: firstText.count))
        att.addAttribute(NSAttributedString.Key.foregroundColor, value: secondColor, range: NSRange(location: secondText.count, length: secondText.count+1))
        self.setAttributedTitle(att, for: .normal)
    }
}
public extension UIButton {
    
    func roundButton(cornerRadius:Float) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
    }

    func underlineButton() {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
    func rotateForTextAligment(){
        
        let langCode = UserDefaults.standard.value(forKey: "Lang")  as! String
        if langCode == "العربية" || langCode == "فارسی" || langCode == "اردو"  || langCode == "ਪੰਜਾਬੀ" {
            self.contentHorizontalAlignment = .right
            
        }else {
            self.contentHorizontalAlignment = .left
        }
    }
    
    func roundButton(){
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
    
    
    @IBInspectable var localizedText: String? {
        get {
            return self.title(for: .normal)
        }
        set {
            let titleText = localizedText?.localized()
            self.setTitle(titleText, for: .normal)
        }
    }
}



public extension UITextField {
    func paddingTop(padding: CGFloat) {
        self.textRect(forBounds: bounds).inset(by: UIEdgeInsets(top: padding, left: 0, bottom: 0, right: 0))
        self.editingRect(forBounds: bounds).inset(by: UIEdgeInsets(top: padding, left: 0, bottom: 0, right: 0))
        self.placeholderRect(forBounds: bounds).inset(by: UIEdgeInsets(top: padding, left: 0, bottom: 0, right: 0))
    }
    
    func paddingBottom(padding: CGFloat) {
        self.textRect(forBounds: bounds).inset(by: UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0))
        self.editingRect(forBounds: bounds).inset(by: UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0))
        self.placeholderRect(forBounds: bounds).inset(by: UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0))
    }
    
    func paddingLeft(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func paddingRight(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }

    @IBInspectable var placeHolderText: String? {
        get {
            return self.placeholder
        }
        set {
            self.placeholder = placeHolderText?.localized()
        }
    }
    
    
    
        @IBInspectable var placeholderColor: UIColor {
            get {
                return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
            }
            set {
                guard let attributedPlaceholder = attributedPlaceholder else { return }
                let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
                self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
            }
        }
    
    func rotateForLanguage(){
        
        let langCode = UserDefaults.standard.value(forKey: "Lang")  as! String
        if langCode == "العربية" || langCode == "فارسی" || langCode == "اردو" || langCode == "ਪੰਜਾਬੀ" {
            self.textAlignment = .right
            
        }else {
            self.textAlignment = .left
        }
    }

}
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}
