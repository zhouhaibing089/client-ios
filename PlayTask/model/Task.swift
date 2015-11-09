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
import RxSwift

enum TaskType: Int {
    case Daily = 0
    case Weekly = 1
    case Normal = 2
}

class Task: Table, Synchronizable {
    dynamic var title = ""
    dynamic var score = 0
    dynamic var type = 0
    dynamic var loop = 1
    dynamic var rank = 0
    dynamic var pinned = false
    let userSid = RealmOptional<Int>()
    
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
    
    func push() {
        guard let userSid = Util.loggedUser?.sid.value else {
            return
        }
        if self.userSid.value == nil {
            self.update(["userSid": userSid])
        }
        var observable: Observable<Task>!
        if self.sid.value == nil {
            observable = API.createTask(self)
        } else {
            observable = API.updateTask(self)
        }
        observable.subscribeNext { t in
            t.update(["synchronizedTime": NSDate()])
        }
    }
    
    class func push() {
        guard let userSid = Util.loggedUser?.sid.value else {
            return
        }
        let realm = try! Realm()
        let pending = realm.objects(Task).filter("(userSid == %@ OR userSid == nil) AND (synchronizedTime < modifiedTime OR synchronizedTime == nil)", userSid)
        pending.asObservable().subscribeNext { t in
            t.push()
        }
    }
    
    class func pull() {
        guard let loggedUser = Util.loggedUser else {
            return
        }
        API.getTasks(loggedUser, after: loggedUser.taskPullTime ?? NSDate(timeIntervalSince1970: 0)).subscribeNext { tasks in
            if tasks.count == 0 {
                return
            }
            let now = NSDate()
            for t in tasks {
                t.update(["synchronizedTime": now])
            }
            loggedUser.update(["taskPullTime": tasks.last!.modifiedTime])
            Task.pull()
        }
    }
}