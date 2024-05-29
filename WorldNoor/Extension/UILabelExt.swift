//
//  UILabelExt.swift
//  WorldNoor
//
//  Created by Raza najam on 10/31/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

extension UILabel {
    func addImage(imageName: String, afterLabel bolAfterLabel: Bool = false)
    {
        let attachment: NSTextAttachment = NSTextAttachment()
        let myImage = UIImage(named: imageName)
        attachment.bounds = CGRect(x: 10, y: (self.font.capHeight - myImage!.size.height).rounded() / 2, width: myImage!.size.width, height: myImage!.size.height)
        attachment.image = myImage
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        if (bolAfterLabel)
        {
            if let someText = self.text {
                if someText != "" {
                    let strLabelText: NSMutableAttributedString = NSMutableAttributedString(string: someText)
                    strLabelText.append(attachmentString)
                    self.attributedText = strLabelText
                }
            }else {
                self.removeImage()
            }
        }
        else
        {
            let strLabelText: NSAttributedString = NSAttributedString(string: self.text!)
            let mutableAttachmentString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }
    
    func set(text: String, symbolName: String, fontSize: CGFloat = 11, symbolSize: CGFloat = 16, symbolColor: UIColor = .lightGray) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: symbolName)?.withTintColor(symbolColor)
        imageAttachment.bounds = CGRect(origin: .init(x: 0, y: -4), size: CGSize(width: symbolSize, height: symbolSize))

        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " " + text))
        self.attributedText = fullString
        self.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    func removeImage()
    {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
    
    func makeFontDynamicBody(){
        let headlineFont = UIFont.preferredFont(forTextStyle: .body)
        self.font = headlineFont
        self.adjustsFontForContentSizeCategory = true
    }
    
    func makeFontCaption(){
        let subheadFont = UIFont.preferredFont(forTextStyle: .caption2)
        self.font = subheadFont
        self.adjustsFontForContentSizeCategory = true
    }
    
    func makeFontDynamicHeading(){
        let subheadFont = UIFont.preferredFont(forTextStyle: .headline)
        self.font = subheadFont
        self.adjustsFontForContentSizeCategory = true
    }
    func makeFontDynamicSubHeading(){
//        let subheadFont = UIFont.preferredFont(forTextStyle: .caption2)
        let subheadFont = UIFont.preferredFont(forTextStyle: .body)
        self.font = subheadFont
        self.adjustsFontForContentSizeCategory = true
    }
    
    func dynamicPreferredFont(fontStyle: UIFont.TextStyle){
        let preferredFont = UIFont.preferredFont(forTextStyle: fontStyle)
        self.font = preferredFont
        self.adjustsFontForContentSizeCategory = true
        self.baselineAdjustment = .alignCenters
        //self.maximumContentSizeCategory = .accessibilityLarge
    }
    
    /*
     Large Title 34 Regular
     Title 1     28 Regular
     Title 2     22 Regular
     Title 3     20 Regular
     Headline    17 Semi-Bold
     Body        17 Regular
     Callout     16 Regular
     Subhead     15 Regular
     Footnote    13 Regular
     Caption 1   12 Regular
     Caption 2   11 Regular
     */
    
    
    ///Large Title 34 Regular
    func dynamicLargeTitleRegular34(){
        //self.dynamicPreferredFont(fontStyle: .largeTitle)
        self.font = UIFont.preferredFont(withTextStyle: .largeTitle, maxSize: 40.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Title 1     28 Regular
    func dynamicTitle1Regular28(){
        //.self.dynamicPreferredFont(fontStyle: .title1)
        self.font = UIFont.preferredFont(withTextStyle: .title1, maxSize: 34.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Title 2     22 Regular
    func dynamicTitle2Regular22(){
        //self.dynamicPreferredFont(fontStyle: .title2)
        self.font = UIFont.preferredFont(withTextStyle: .title2, maxSize: 28.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Title 3     20 Regular
    func dynamicTitle3Regular20(){
        //self.dynamicPreferredFont(fontStyle: .title3)
        self.font = UIFont.preferredFont(withTextStyle: .title3, maxSize: 26.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Title 3     20 Regular
    func dynamicTitle3Bold20(){
        //self.dynamicPreferredFont(fontStyle: .title3)
        self.font = UIFont.preferredFontWithBoldTrait(withTextStyle: .title3, maxSize: 26.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Title 3     20 Regular
    func dynamicTitle3Bold20WithoutClip(){
        //self.dynamicPreferredFont(fontStyle: .title3)
        self.font = UIFont.preferredFontWithBoldTrait(withTextStyle: .title3, maxSize: 26.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = false
    }
    ///Headline    17 Semi-Bold
    func dynamicHeadlineSemiBold17(){
        //self.dynamicPreferredFont(fontStyle: .headline)
        self.font = UIFont.preferredFont(withTextStyle: .headline, maxSize: 23.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Body        17 Regular
    func dynamicBodyRegular17(){
        //self.dynamicPreferredFont(fontStyle: .body)
        self.font = UIFont.preferredFont(withTextStyle: .body, maxSize: 23.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    
    
    
    func dynamicHeading(sizeFont : CGFloat){
        //self.dynamicPreferredFont(fontStyle: .headline)
        self.font = UIFont.preferredFont(withTextStyle: .headline, maxSize: sizeFont)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    
    func dynamicBody(sizeFont : CGFloat){
        //self.dynamicPreferredFont(fontStyle: .body)
        self.font = UIFont.preferredFont(withTextStyle: .body, maxSize: sizeFont)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    
    ///Body        17 Regular
    func dynamicBodyRegular17WithoutClip(){
        //self.dynamicPreferredFont(fontStyle: .body)
        self.font = UIFont.preferredFont(withTextStyle: .body, maxSize: 18.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = false
    }
    ///Callout     16 Regular
    func dynamicCalloutRegular16(){
        //self.dynamicPreferredFont(fontStyle: .callout)
        self.font = UIFont.preferredFont(withTextStyle: .callout, maxSize: 22.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Subhead     15 Regular
    func dynamicSubheadRegular15(){
        //self.dynamicPreferredFont(fontStyle: .subheadline)
        self.font = UIFont.preferredFont(withTextStyle: .subheadline, maxSize: 21.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Footnote    13 Regular
    func dynamicFootnoteRegular13(){
        //self.dynamicPreferredFont(fontStyle: .footnote)
        self.font = UIFont.preferredFont(withTextStyle: .footnote, maxSize: 19.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Caption 1   12 Regular
    func dynamicCaption1Regular12(){
        //self.dynamicPreferredFont(fontStyle: .caption1)
        self.font = UIFont.preferredFont(withTextStyle: .caption1, maxSize: 18.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Caption 1   12 Regular
    func dynamicCaption1Bold12(){
        //self.dynamicPreferredFont(fontStyle: .caption1)
        self.font = UIFont.preferredFontWithBoldTrait(withTextStyle: .caption1, maxSize: 16.0)
        //self.font = UIFont.preferredFont(withTextStyle: .caption1, maxSize: 18.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    ///Caption 2   11 Regular
    func dynamicCaption2Regular11(){
        //self.dynamicPreferredFont(fontStyle: .caption2)
        self.font = UIFont.preferredFont(withTextStyle: .caption2, maxSize: 17.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
    
    func dynamicCaption2Bold11(){
        //self.dynamicPreferredFont(fontStyle: .caption2)
        self.font = UIFont.preferredFontWithBoldTrait(withTextStyle: .caption2, maxSize: 16.0)
        //self.font = UIFont.preferredFont(withTextStyle: .caption2, maxSize: 14.0)
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = true
    }
}

extension UIFont {
    
    static func preferredFont(withTextStyle textStyle: UIFont.TextStyle, maxSize: CGFloat) -> UIFont {
        // Get the descriptor
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        
        // Return a font with the minimum size
        return UIFont(descriptor: fontDescriptor, size: min(fontDescriptor.pointSize, maxSize))
    }
    
    static func preferredFontWithBoldTrait(withTextStyle textStyle: UIFont.TextStyle, maxSize: CGFloat) -> UIFont {
        // Get the descriptor
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        fontDescriptor.withSymbolicTraits(.traitBold)
        
        // Return a font with the minimum size
        return UIFont(descriptor: fontDescriptor, size: min(fontDescriptor.pointSize, maxSize))
    }
    
//    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
//        let metrics = UIFontMetrics(forTextStyle: style)
//        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
//        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
//        desc.withSymbolicTraits(.traitBold)
//        return metrics.scaledFont(for: font)
//    }
    
}
