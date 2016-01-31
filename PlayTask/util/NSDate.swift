//
//  NSDate.swift
//  PlayTask
//
//  Created by Yoncise on 11/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation

import Foundation

extension NSDate {
    func beginOfDay() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month,
            NSCalendarUnit.Day, NSCalendarUnit.Hour,
            NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: self)
        let subtract = NSDateComponents()
        subtract.day = 0
        if components.hour < 2 {
            subtract.day = -1
        }
        components.hour = 2
        components.minute = 0
        components.second = 0
        let tmp = cal.dateFromComponents(components)!
        return cal.dateByAddingComponents(subtract, toDate: tmp, options: [])!
    }
    
    func endOfDay() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let add = NSDateComponents()
        add.day = 1
        return cal.dateByAddingComponents(add, toDate: self.beginOfDay(), options: [])!
    }
    
    func beginOfWeek() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components(NSCalendarUnit.Weekday, fromDate: self)
        let subtract = NSDateComponents()
        if components.weekday == 1 {
            subtract.day = -6
        } else {
            subtract.day = 2 - components.weekday
        }
        return cal.dateByAddingComponents(subtract, toDate: self.beginOfDay(), options: [])!
    }
    
    func endOfWeek() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components(NSCalendarUnit.Weekday, fromDate: self)
        let add = NSDateComponents()
        if components.weekday == 1 {
            add.day = 0
        } else {
            add.day = 8 - components.weekday
        }
        return cal.dateByAddingComponents(add, toDate: self.endOfDay(), options: [])!
    }
    
    // real begin without offset
    func beginOfMonth() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month,
            NSCalendarUnit.Day], fromDate: self)
        components.day = 1
        return cal.dateFromComponents(components)!
    }
    
    func endOfMonth() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let add = NSDateComponents()
        add.month = 1
        return cal.dateByAddingComponents(add, toDate: self.beginOfMonth(), options: [])!
    }
    
    func beginOfYear() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month,
            NSCalendarUnit.Day, NSCalendarUnit.Hour,
            NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: self.beginOfDay())
        components.month = 1
        components.day = 1
        return cal.dateFromComponents(components)!
    }
    
    func endOfYear() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let add = NSDateComponents()
        add.year = 1
        return cal.dateByAddingComponents(add, toDate: self.beginOfYear(), options: [])!
    }
    
    func addDay(day: Int) -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let add = NSDateComponents()
        add.day = day
        return cal.dateByAddingComponents(add, toDate: self, options: [])!
    }
    
    func addMonth(month: Int) -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let add = NSDateComponents()
        add.month = month
        return cal.dateByAddingComponents(add, toDate: self, options: [])!
    }
    
    func getComponents() -> NSDateComponents {
        let cal = NSCalendar.currentCalendar()
        return cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Weekday,
            NSCalendarUnit.Day, NSCalendarUnit.Hour,
            NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: self)
    }
    
    func differenceFrom(fromDate: NSDate, unit: NSCalendarUnit = NSCalendarUnit.Day) -> NSDateComponents {
        let cal = NSCalendar.currentCalendar()
        return cal.components(unit, fromDate: fromDate, toDate: self, options: [])
    }
    
    func toReadable() -> String {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(
            [NSCalendarUnit.Year, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute],
            fromDate: self,
            toDate: NSDate(),
            options: []
        )
        let year = components.year
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        if year > 0 {
            return "\(year)年前"
        }
        if day > 0 {
            return "\(day)天前"
        }
        if hour > 0 {
            return "\(hour)小时前"
        }
        if minute > 0 {
            return "\(minute)分钟前"
        }
        return "刚刚"
    }
    
}
