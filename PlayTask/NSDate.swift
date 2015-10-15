//
//  NSDate.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation

extension NSDate {
    func beginOfDay() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month,
            NSCalendarUnit.Day, NSCalendarUnit.Hour,
            NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return cal.dateFromComponents(components)!
    }
    
    func endOfDay() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month,
            NSCalendarUnit.Day, NSCalendarUnit.Hour,
            NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return cal.dateFromComponents(components)!
    }
    
    func beginOfWeek() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        cal.firstWeekday = 2
        let components = cal.components(NSCalendarUnit.Weekday, fromDate: self)
        let substract = NSDateComponents()
        substract.day = 1 - components.weekday
        return cal.dateByAddingComponents(NSDateComponents(), toDate: self.beginOfDay(), options: [])!
    }
    
    func endOfWeek() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        cal.firstWeekday = 2
        let components = cal.components(NSCalendarUnit.Weekday, fromDate: self)
        let substract = NSDateComponents()
        substract.day = 7 - components.weekday
        return cal.dateByAddingComponents(NSDateComponents(), toDate: self.beginOfDay(), options: [])!
    }
}
