//
//  TextViewExt.swift
//  WorldNoor
//
//  Created by Raza najam on 11/22/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

extension UITextView {
    var numberOfCurrentlyDisplayedLines: Int {
        let size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        return Int(((size.height - layoutMargins.top - layoutMargins.bottom) / font!.lineHeight))
    }
    
    
    //    func rotateForTextAligment(){
    //
    //        let langCode = UserDefaults.standard.value(forKey: "Lang")  as! String
    //        if langCode == "العربية" || langCode == "فارسی" || langCode == "اردو"  || langCode == "ਪੰਜਾਬੀ" {
    //            self.contentHorizontalAlignment = .right
    //
    //        }else {
    //            self.contentHorizontalAlignment = .left
    //        }
    //    }
    
    
    func rotateForLanguage(){
        
        let langCode = UserDefaults.standard.value(forKey: "Lang")  as! String
        if langCode == "العربية" || langCode == "فارسی" || langCode == "اردو"  || langCode == "ਪੰਜਾਬੀ"{
            self.textAlignment = .right
            
        }else {
            self.textAlignment = .left
        }
    }
    
    func dynamicSubheadRegular15(){
        //self.dynamicPreferredFont(fontStyle: .subheadline)
        self.font = UIFont.preferredFont(withTextStyle: .subheadline, maxSize: 21.0)
        self.adjustsFontForContentSizeCategory = true
    }
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    func alignTextVerticallyInContainer() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.contentInset.top = topCorrect
    }
    
    func centerText() {
        let a = UITextView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height))
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let text = NSAttributedString(string: self.text,
                                      attributes: [NSAttributedString.Key.paragraphStyle:style])
        a.attributedText = text
    }
    
    func getHeightFrame(_ textView: UITextView) -> CGRect{
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        return newFrame
    }
    
    func numberOfLines(textView: UITextView) -> Int {
        let layoutManager = textView.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
    
    func heightForText(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let nsString = NSString(string: text)
        let boundingRect = nsString.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingRect.height)
    }
    
    func addPadding(_ padding: CGFloat) {
        textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func addBorder() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 8.0
        addPadding(8)
    }
    
    func setBorderColorWhileEditing() {
        NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification, object: self, queue: .main) { [weak self] _ in
            self?.layer.borderColor = UIColor.blueColor.cgColor
        }
        
        NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: self, queue: .main) { [weak self] _ in
            self?.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func addPlaceholder(_ placeholder: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = self.font
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 12, y: 8)
        placeholderLabel.textColor = UIColor.placeholderText
        placeholderLabel.tag = 101
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }
    
    func updatePlaceholder() {
        if let placeholderLabel = self.viewWithTag(101) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
    func removePlaceholder() {
        if let placeholderLabel = self.viewWithTag(101) {
            placeholderLabel.removeFromSuperview()
        }
    }
}
