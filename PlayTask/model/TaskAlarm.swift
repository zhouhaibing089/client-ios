//
//  TaskAlarm.swift
//  PlayTask
//
//  Created by Yoncise on 2/25/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import RealmSwift

class TaskAlarm: Table {
    dynamic var task: Task!
    
    dynamic var hour: Int = 0
    dynamic var minute: Int = 0
    
    dynamic var sunday = false
    dynamic var monday = false
    dynamic var tuesday = false
    dynamic var wednesday = false
    dynamic var thursday = false
    dynamic var friday = false
    dynamic var saturday = false
    
    dynamic var sound = true
    dynamic var label: String = ""
    
    class func getAlarmForTask(task: Task) -> TaskAlarm? {
        let realm = try! Realm()
        return realm.objects(TaskAlarm).filter("task == %@", task).first
    }
    
    func setDay(day: Int, on: Bool) {
        if self.realm == nil {
            switch day {
            case 0:
                self.sunday = on
                break
            case 1:
                self.monday = on
                break
            case 2:
                self.tuesday = on
                break
            case 3:
                self.wednesday = on
                break
            case 4:
                self.thursday = on
                break
            case 5:
                self.friday = on
                break
            case 6:
                self.saturday = on
                break
            default: break
            }
        } else {
            try! self.realm!.write({ () -> Void in
                switch day {
                case 0:
                    self.sunday = on
                    break
                case 1:
                    self.monday = on
                    break
                case 2:
                    self.tuesday = on
                    break
                case 3:
                    self.wednesday = on
                    break
                case 4:
                    self.thursday = on
                    break
                case 5:
                    self.friday = on
                    break
                case 6:
                    self.saturday = on
                    break
                default: break
                }
            })
            
        }
    }
    
    func getDay(day: Int) -> Bool {
        switch day {
        case 0:
            return self.sunday
        case 1:
            return self.monday
        case 2:
            return self.tuesday
        case 3:
            return self.wednesday
        case 4:
            return self.thursday
        case 5:
            return self.friday
        case 6:
            return self.saturday
        default:
            return false
        }
    }
    
    class func scheduleNotifications() {
        let realm = try! Realm()
        let alarms = realm.objects(TaskAlarm).filter("(task.userSid == %@ OR task.userSid == nil) AND task.deleted == false AND deleted == false", Util.currentUser.sid.value ?? -1).filter { (alarm) -> Bool in
            // 不是普通任务或者是未完成的普通任务
            return alarm.task.type != TaskType.Normal.rawValue || !alarm.task.isDone()
        }
        for a in alarms {
            a.schedule()
        }
        return
    }
    
    /// remove delivered no repeat alarms
    class func removeDeliveredAlarms() {
        let realm = try! Realm()
        let alarms = realm.objects(TaskAlarm).filter("deleted == false", Util.currentUser.sid.value ?? -1)
        for a in alarms {
            var noRepeat = true
            for i in 0...6 {
                if !a.getDay(i) {
                    noRepeat = false
                    break
                }
            }
            if noRepeat && a.getLocalNotification() == nil {
                a.delete()
            }
        }
    }
    
    func cancelLocalNotification() {
        if let n = self.getLocalNotification() {
            let application = UIApplication.sharedApplication()
            application.cancelLocalNotification(n)
        }
    }
    
    func schedule() {
        let application = UIApplication.sharedApplication()
        let nowComponents = NSDate().getComponents()
        var fireDates = [NSDate]()
        let cal = NSCalendar.currentCalendar()
        for i in 0...6 { // generate firedates
            let on = self.getDay(i)
            if !on {
                continue
            }
            // weekday 1...7. so, minus 1
            let weekday = nowComponents.weekday - 1
            var components: NSDateComponents
            if i > weekday { // later
                components = cal.dateByAddingUnit(.Day, value: i - weekday, toDate: NSDate(), options: [])!.getComponents()
            } else if i < weekday { // earlier
                components = cal.dateByAddingUnit(.Day, value: 7 - (weekday - i), toDate: NSDate(), options: [])!.getComponents()
            } else {
                if nowComponents.hour > self.hour || (nowComponents.hour == self.hour && nowComponents.minute >= self.minute) {
                    // same day but earlier
                    components = cal.dateByAddingUnit(.Day, value: 7, toDate: NSDate(), options: [])!.getComponents()
                } else {
                    components = NSDate().getComponents()
                }
            }
            components.hour = self.hour
            components.minute = self.minute
            components.second = 0
            fireDates.append(cal.dateFromComponents(components)!)
        }
        
        var repeatInterval = NSCalendarUnit.WeekOfYear
        if fireDates.count == 0 {
            // no repeat
            var components: NSDateComponents
            if nowComponents.hour > self.hour || (nowComponents.hour == self.hour && nowComponents.minute >= self.minute) {
                // earlier
                components = cal.dateByAddingUnit(.Day, value: 7, toDate: NSDate(), options: [])!.getComponents()
            } else {
                components = NSDate().getComponents()
            }
            components.hour = self.hour
            components.minute = self.minute
            components.second = 0
            fireDates.append(cal.dateFromComponents(components)!)
            repeatInterval = NSCalendarUnit(rawValue: 0)
        }
        for fd in fireDates { // schedule notification
            let notification = UILocalNotification()
            notification.fireDate = fd
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.repeatInterval = repeatInterval
            notification.alertBody = self.label
            notification.userInfo = ["task_alarm_id": self.id]
            if self.sound {
                notification.soundName = "Radar.aif"
            }
            application.scheduleLocalNotification(notification)
        }
    }
    
    func getLocalNotification() -> UILocalNotification? {
        let application = UIApplication.sharedApplication()
        for n in application.scheduledLocalNotifications ?? [] {
            if let id = n.userInfo?["task_alarm_id"] as? String {
                if id == self.id {
                    return n
                }
            }
        }
        return nil
    }
    
    /// delete and cancel scheduled local notification
    override func delete() {
        super.delete()
        self.cancelLocalNotification()
    }
}
