//
//  File.swift
//  WorldNoor
//
//  Created by Raza najam on 10/31/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation

extension String    {
    
    func utcToLocal(inputformat: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputformat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = inputformat
        
            return dateFormatter.string(from: date)
        }
        return self
    }
    
    func returnDateString(inputformat: String ) -> Date {
           
           if self.count == 0 {
               return Date()
           }
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = inputformat
           
           let dateMain = dateFormatter.date(from: self)

        
        if dateMain == nil {
            return Date()
        }
        return dateMain!
           
       }
    
    
    func changeDateString(inputformat: String , outputformat: String ) -> String {
           
        
           if self.count == 0 {
               return ""
           }
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = inputformat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
           let dateMain = dateFormatter.date(from: self)
            dateFormatter.dateFormat = outputformat
        

        
           
        return dateFormatter.string(from: dateMain!)
           
       }
}
