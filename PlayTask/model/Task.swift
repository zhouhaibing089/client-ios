//
//  Task.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift
import YNSwift

enum TaskType: Int {
    case Daily = 0
    case Weekly = 1
    case Normal = 2
}

class Task: Table {
    dynamic var title = ""
    dynamic var score = 0
    dynamic var type = 0
    dynamic var loop = 1
    dynamic var rank = 0
    dynamic var pinned = false
    
    convenience init(title: String, score: Int, type: TaskType, loop: Int) {
        self.init()
        self.title = title
        self.score = score
        self.type = type.rawValue
        self.loop = loop
    }
    
    class func getTasks() -> [Int: [Task]] {
        let realm = try! Realm()
        let dailyTasks = realm.objects(Task).filter("deleted == false AND type == %@", TaskType.Daily.rawValue).sorted("rank").map { $0 }
        let weeklyTasks = realm.objects(Task).filter("deleted == false AND type == %@", TaskType.Weekly.rawValue).sorted("rank").map { $0 }
        let normalTasks = realm.objects(Task).filter("deleted == false AND type == %@", TaskType.Normal.rawValue).sorted("rank").map { $0 }
        return [TaskType.Daily.rawValue: dailyTasks, TaskType.Weekly.rawValue: weeklyTasks, TaskType.Normal.rawValue: normalTasks]
    }
    
    func isDone() -> Bool {
        return self.loop != 0 && self.loop == self.getCompletedTimes()
    }
    
    func setDone(done: Bool) {
        if (done) {
            if let th = self.getHistory() {
                th.update(["canceled": false, "deleted": false, "completionTime": NSDate()])
            } else {
                let th = TaskHistory(task: self)
                th.save()
            }
        } else {
            self.undo()
        }
    }
    
    func undo() {
        if let th = self.getLastHistory(false) {
            th.update(["canceled": true])
        }
    }
    
    func getHistory() -> TaskHistory? {
        if !self.isDone() {
            return self.getLastHistory(true)
        }
        return self.getLastHistory(false)
    }
    
    func getCompletedTimes() -> Int {
        let realm = try! Realm()
        let now = NSDate()
        var begin = NSDate(timeIntervalSince1970: 0)
        var end = now
        if self.type == TaskType.Daily.rawValue {
            begin = now.beginOfDay()
            end = now.endOfDay()
        } else if self.type == TaskType.Weekly.rawValue {
            begin = now.beginOfWeek()
            end = now.endOfDay()
        }
        return realm.objects(TaskHistory).filter("task == %@ AND canceled == false AND completionTime >= %@ AND completionTime <= %@", self, begin, end).count
    }
    
    func getLastHistory(canceled: Bool) -> TaskHistory? {
        let realm = try! Realm()
        let now = NSDate()
        var begin = NSDate(timeIntervalSince1970: 0)
        var end = now
        if self.type == TaskType.Daily.rawValue {
            begin = now.beginOfDay()
            end = now.endOfDay()
        } else if self.type == TaskType.Weekly.rawValue {
            begin = now.beginOfWeek()
            end = now.endOfDay()
        }

        var query = "task == %@ AND completionTime >= %@ AND completionTime <= %@";
        if (canceled) {
            query += " AND canceled == true";
        } else {
            query += " AND canceled == false";
        }
        let taskHistories = realm.objects(TaskHistory).filter(query, self, begin, end).sorted("completionTime")

        return taskHistories.first;
    }
    
    class func getPinnedTasksNumOnTheDate(day: NSDate) -> Int {
        let tasks = Task.getTasks()
        var count = 0
        let onCurrentDay = day.beginOfDay() == NSDate().beginOfDay()
        for t in tasks[TaskType.Daily.rawValue]! {
            if onCurrentDay { // 当天
                if t.pinned && !t.isDone() {
                    count++
                }
            } else {
                if t.pinned {
                    count++
                }
            }
        }
        let onCurrentWeek = day.beginOfWeek() == NSDate().beginOfWeek()
        for t in tasks[TaskType.Weekly.rawValue]! {
            if onCurrentWeek { // 当周
                if t.pinned && !t.isDone() {
                    count++
                }
            } else {
                if t.pinned {
                    count++
                }
            }
        }
        for t in tasks[TaskType.Normal.rawValue]! {
            if t.pinned && !t.isDone() {
                count++
            }
        }
        return count
    }
    
    class func scheduleNotification() {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate().endOfDay().dateByAddingTimeInterval(1)
        localNotification.applicationIconBadgeNumber = Task.getPinnedTasksNumOnTheDate(localNotification.fireDate!)
        let application = UIApplication.sharedApplication()
        application.cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}