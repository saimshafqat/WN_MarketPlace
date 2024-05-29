//
//  Localizable.swift
//  WorldNoor
//
//  Created by apple on 10/8/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func localized() -> String {
        
        if self.count == 0 {
            return ""
        }
        
        var languageCode = "en"        
        let langCode = UserDefaults.standard.value(forKey: "Lang")  as! String
        if langCode == "العربية" {
            languageCode = "ar"
        }else  if langCode == "bahasa Indonesia" {
            languageCode = "id"
        }else  if langCode == "Türk" {
            languageCode = "tr"
        }else  if langCode == "Italiana" {
            languageCode = "it"
        }else  if langCode == "русский" {
            languageCode = "ru"
        }else  if langCode == "فارسی" {
            languageCode = "fa"
        }else  if langCode == "Española" {
            languageCode = "es"
        }else  if langCode == "Soomaali" {
            languageCode = "so"
        }else  if langCode == "日本人" {
            languageCode = "ja"
        }else  if langCode == "Française" {
            languageCode = "fr"
        }else  if langCode == "বাংলা" {
            languageCode = "bn"
        }else  if langCode == "Azərbaycan" {
            languageCode = "az"
        }else  if langCode == "Deutsche" {
            languageCode = "de-DE"
        }else  if langCode == "اردو" {
            languageCode = "ur"
        }else  if langCode == "ਪੰਜਾਬੀ" {
            languageCode = "pa"
        }else  if langCode == "తెలుగు" {
            languageCode = "te"
        }else  if langCode == "தமிழ்" {
            languageCode = "ta"
        }else  if langCode == "سنڌي" {
            languageCode = "sd"
        }else  if langCode == "Português" {
            languageCode = "pt"
        }else  if langCode == "Pilipino" {
            languageCode = "fil"
        }else  if langCode == "dansk" {
            languageCode = "da"
        }else  if langCode == "հայերեն" {
            languageCode = "hy"
        }else  if langCode == "हिंदी" {
            languageCode = "hi"
        }else{
            languageCode = "en"
        }
        
        
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        if path == nil {
            return self
        }
        
        
        
        let bundle = Bundle(path: path!)
        
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
