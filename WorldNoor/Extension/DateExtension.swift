//
//  DateExtension.swift
//
//
//  Created by apple on 10/16/18.
//  Copyright © 2018 
//

import Foundation



extension Date {
  func isSameDate(_ comparisonDate: Date) -> Bool {
    let order = Calendar.current.compare(self, to: comparisonDate, toGranularity: .day)
    return order == .orderedSame
  }

  func isBeforeDate(_ comparisonDate: Date) -> Bool {
    let order = Calendar.current.compare(self, to: comparisonDate, toGranularity: .day)
    return order == .orderedAscending
  }

  func isAfterDate(_ comparisonDate: Date) -> Bool {
    let order = Calendar.current.compare(self, to: comparisonDate, toGranularity: .day)
    return order == .orderedDescending
  }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func serverTimeFormatShort()-> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm"
        let currentTime = format.string(from: date)
        return currentTime
    }
    func serverTimeFormat()-> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let currentTime = format.string(from: date)
        return currentTime
    }
    
}


extension Date {
    
    func dateString(_ format: String = "MMM-dd-YYYY, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
   
    
    func dateStringNew(_ format: String = "MMM-dd-YYYY, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func customString(format: String = "MMM-dd-YYYY, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingYears(_ dYears: Int) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    
    func dateByAddingHours(_ dHours: Int) -> Date {

        var dateComponents = DateComponents()
        dateComponents.hour = dHours
        
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    func dateByAddingMonth(_ dMonth: Int) -> Date {
           
           var dateComponents = DateComponents()
           dateComponents.month = dMonth
           
           return Calendar.current.date(byAdding: dateComponents, to: self)!
       }
    
    
    
    func startOfMonth() -> Int {
        
        let weekday = Calendar.current.component(.weekday, from: Calendar.current.startOfMonth(self))
        return (weekday - 1)
    }
    
    func numberOfWeeksInMonth() -> Int? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // 2 == Monday
    
        // First monday in month:
        var comps = DateComponents(year: Int(self.dateString("YYYY")), month: Int(self.dateString("MM")),
        weekday: calendar.firstWeekday, weekdayOrdinal: 1)
        guard let first = calendar.date(from: comps)  else {
        return nil
        }
    
        // Last monday in month:
        comps.weekdayOrdinal = -1
        guard let last = calendar.date(from: comps)  else {
        return nil
        }
    
        // Difference in weeks:
        let weeks = calendar.dateComponents([.weekOfMonth], from: first, to: last)
        return weeks.weekOfMonth! + 1
    }
    
    func findDifferecnce(recent: Date, previous: Date) -> (month: Int?, week: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let week = Calendar.current.dateComponents([.weekOfYear], from: previous, to: recent).weekOfYear
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

         return (month: month, week: week, day: day, hour: hour, minute: minute, second: second)
    }
}

extension Calendar {
    
    func dayOfWeek(_ date: Date) -> Int {
        var dayOfWeek = self.component(.weekday, from: date) + 1 - self.firstWeekday
        
        if dayOfWeek <= 0 {
            dayOfWeek += 7
        }
        
        return dayOfWeek
    }
    
    func daysOfMonth(_ date: Date) -> Int {
        
        let range = self.range(of: .day, in: .month, for: date)!
        return range.count
    }
    func startOfWeek(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(day: -self.dayOfWeek(date) + 1), to: date)!
    }
    
    func endOfWeek(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(day: 6), to: self.startOfWeek(date))!
    }
    
    func startOfMonth(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: date))!
    }
    
    func endOfMonth(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(date))!
    }
    
    func startOfQuarter(_ date: Date) -> Date {
        let quarter = (self.component(.month, from: date) - 1) / 3 + 1
        return self.date(from: DateComponents(year: self.component(.year, from: date), month: (quarter - 1) * 3 + 1))!
    }
    
    func endOfQuarter(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(month: 3, day: -1), to: self.startOfQuarter(date))!
    }
    
    func startOfYear(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year], from: date))!
    }
    
    func endOfYear(_ date: Date) -> Date {
        return self.date(from: DateComponents(year: self.component(.year, from: date), month: 12, day: 31))!
    }

    
}



