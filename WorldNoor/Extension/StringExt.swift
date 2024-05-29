//
//  StringExt.swift
//  WorldNoor
//
//  Created by Raza najam on 1/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    static var emptyString: String {
        return ""
    }
    
    var encodeURL: String {
        return self.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    func encodeUrl() -> String {
        return self.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
    }
        
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var convertToColour: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if #available(iOS 13, *) {
            guard let int = Scanner(string: hex).scanInt32(representation: .hexadecimal) else {return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)}
            let a, r, g, b: Int32
            switch hex.count {
            case 3:     (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)  // RGB (12-bit)
            case 6:     (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)                    // RGB (24-bit)
            case 8:     (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)       // ARGB (32-bit)
            default:    (a, r, g, b) = (255, 0, 0, 0)
            }
            return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
        } else {
            var int = UInt32()
            Scanner(string: hex).scanHexInt32(&int)
            let a, r, g, b: UInt32
            switch hex.count {
            case 3:     (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)  // RGB (12-bit)
            case 6:     (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)                    // RGB (24-bit)
            case 8:     (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)       // ARGB (32-bit)
            default:    (a, r, g, b) = (255, 0, 0, 0)
            }
            return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
        }
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
               
            }
        }
        return nil
    }
}

extension String {
    func dateConvert()-> Date{
        if let timeResult = Double(self) {
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            return date
        }
        
        return Date()
    }
    func isValidForUrl()->Bool{
        if(self.hasPrefix("http") || self.hasPrefix("https")){
            return true
        }
        return false
    }
    
    func customDateFormat(time:String, format:String)->String {
        if time == "" || format == ""{
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: time)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMM. dd, yyyy  hh:mm a"
        
        if dt == nil {
            return ""
        }
        return dateFormatter.string(from: dt!)
    }
    
    
    func newDateFormat(time:String, format:String)->String {
        if time == "" || format == ""{
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: time)
        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        dateFormatter.dateFormat = "hh:mm a"
        if dt == nil {
            return ""
        }
        return dateFormatter.string(from: dt!)
    }
    
    func chatDateFormat(time: String, format: String) -> String {
        if time.isEmpty || format.isEmpty {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: time) {
            dateFormatter.timeZone = TimeZone.current
            
            let currentDate = Date()
            let isCurrentDate = Calendar.current.isDate(date, inSameDayAs: currentDate)
            
            dateFormatter.dateFormat = isCurrentDate ? "hh:mma" : "d MMM 'at' h:mma"
            return dateFormatter.string(from: date)
        }
        
        return ""
    }

    func mpChatListDateFormat(format:String)->String {
        if self == "" || format == ""{
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        if dt == nil {
            return ""
        }
        return dateFormatter.string(from: dt!)
    }
    
    func addDecimalPoints(decimalPoint:String = "0")-> String{
        let str =  String(format: "%." + decimalPoint + "f", Double(self)!)
        return str
    }
    
    func widthOfString() -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: 15.0)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)], context: nil)
        return ceil(boundingBox.width)
    }
    
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func heightString(withConstrainedWidth width: CGFloat , font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: self)
    }
    
    func timeAgoString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.date(from: self) else {
            return nil // return nil if date conversion fails
        }
        
        // Current date
        let currentDate = Date()

        // Calculate time difference
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: currentDate)

        // Extract components
        if let years = components.year, years > 0 {
            return "\(years) year\(years > 1 ? "s" : "") ago"
        } else if let months = components.month, months > 0 {
            return "\(months) month\(months > 1 ? "s" : "") ago"
        } else if let days = components.day, days > 0 {
            return "\(days) day\(days > 1 ? "s" : "") ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "") ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
        } else if let seconds = components.second, seconds > 0 {
            return "\(seconds) second\(seconds > 1 ? "s" : "") ago"
        } else {
            return "Just now"
        }
    }

}

//extension UILabel {
//
//    func setLineHeight(lineHeight: CGFloat, labelWidth: CGFloat) -> CGFloat {
//        let text = self.text
//        if let text = text {
//            let attributeString = NSMutableAttributedString(string: text)
//            let style = NSMutableParagraphStyle()
//
//            style.lineSpacing = lineHeight
//            attributeString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, text.characters.count))
//            self.attributedText = attributeString
//            return self.sizeThatFits(CGSize(width: labelWidth, height: 20)).height
//        }
//        return 0
//    }
//}


extension String {
    
    func attributedStringWithColor(_ strings: [String], color: UIColor? = nil, characterSpacing: UInt? = nil, font: UIFont? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            // let range = (self as NSString).range(of: string)
            let range = self.range(of: string)
            if let range {
                let nsRange = NSRange(range, in: self)
                if color != nil {
                    attributedString.addAttribute(.foregroundColor, value: color as Any, range: nsRange)
                }
                if font != nil {
                    attributedString.addAttribute(.font, value: font as Any, range: nsRange)
                }
            }
        }
        guard let characterSpacing = characterSpacing else { return attributedString }
        attributedString.addAttribute(.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
}
