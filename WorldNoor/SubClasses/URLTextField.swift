//
//  URLTextField.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 12/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class URLTextField: UITextField, UITextFieldDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.delegate = self
        // Additional setup if needed
    }
    
    public func isValidURL(_ urlString: String) -> Bool {
        
        // Adjusted URL pattern to optionally include the scheme
        let urlPattern = "^((http|https|ftp)\\://)?([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&%\\$\\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\\:[0-9]+)*(\\/($|[a-zA-Z0-9\\.\\,\\?\\'\\\\\\+&%\\$#\\=~_\\-]+))*$"
        
        // Check if the URL with or without scheme can be opened
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            return matches(pattern: urlPattern, urlString: urlString)
        }
        
        let modifiedURLString = "http://" + urlString
        if let modifiedURL = URL(string: modifiedURLString), UIApplication.shared.canOpenURL(modifiedURL) {
            return matches(pattern: urlPattern, urlString: modifiedURLString)
        }
        return false
    }
    
    // Helper function to check the URL against the regex pattern
    func matches(pattern: String, urlString: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: urlString.utf16.count)
        return regex?.firstMatch(in: urlString, options: [], range: range) != nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
