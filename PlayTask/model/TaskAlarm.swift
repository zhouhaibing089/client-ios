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
    
    dynamic var vibration = true
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
}
