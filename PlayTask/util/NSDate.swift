//
//  NSDate.swift
//  PlayTask
//
//  Created by Yoncise on 11/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation

import Foundation

public extension NSDate {
    public func beginOfDay() -> NSDate {
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
    
    public func endOfDay() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let add = NSDateComponents()
        add.day = 1
        return cal.dateByAddingComponents(add, toDate: self.beginOfDay(), options: [])!
    }
    
    public func beginOfWeek() -> NSDate {
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
    
    public func endOfWeek() -> NSDate {
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
}
