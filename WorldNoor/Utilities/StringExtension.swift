//
//  StringExtension.swift
//  WorldNoor
//
//  Created by swift on 09/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
extension String {
    func coloredAndClickableAttributedString(substringToColor: String, secondSubstringToColor: String? = nil, linkColor: UIColor = .blue) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        func addAttributes(to substring: String, range: NSRange) {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: linkColor,
                .link: "\(substring)" 
            ]
            attributedString.addAttributes(attributes, range: range)
        }
        
        if let range = self.range(of: substringToColor) {
            let nsRange = NSRange(range, in: self)
            addAttributes(to: substringToColor, range: nsRange)
        }
        
        if let secondString = secondSubstringToColor, let range = self.range(of: secondString) {
            let nsRange = NSRange(range, in: self)
            addAttributes(to: secondSubstringToColor!, range: nsRange)
        }
        
        return attributedString
    }
}
