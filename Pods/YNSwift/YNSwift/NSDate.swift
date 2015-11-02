//
//  NSDate.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation

public extension NSDate {
    public func beginOfDay() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month,
            NSCalendarUnit.Day, NSCalendarUnit.Hour,
            NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return cal.dateFromComponents(components)!
    }
    
    public func endOfDay() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month,
            NSCalendarUnit.Day, NSCalendarUnit.Hour,
            NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return cal.dateFromComponents(components)!
    }
    
    public func beginOfWeek() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components(NSCalendarUnit.Weekday, fromDate: self)
        let substract = NSDateComponents()
        if components.weekday == 1 {
            substract.day = -6
        } else {
            substract.day = 2 - components.weekday
        }
        return cal.dateByAddingComponents(substract, toDate: self.beginOfDay(), options: [])!
    }
    
    public func endOfWeek() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components(NSCalendarUnit.Weekday, fromDate: self)
        let substract = NSDateComponents()
        if components.weekday == 1 {
            substract.day = 0
        } else {
            substract.day = 8 - components.weekday
        }
        return cal.dateByAddingComponents(substract, toDate: self.endOfDay(), options: [])!
    }
}
