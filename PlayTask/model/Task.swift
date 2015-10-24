//
//  Task.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift

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
    
    convenience init(title: String, score: Int, type: TaskType) {
        self.init()
        self.title = title
        self.score = score
        self.type = type.rawValue
    }
    
    static func getTasks() -> [Int: [Task]] {
        let realm = try! Realm()
        let dailyTasks = realm.objects(Task).filter("deleted = false AND type = %@", TaskType.Daily.rawValue).map { $0 }
        let weeklyTasks = realm.objects(Task).filter("deleted = false AND type = %@", TaskType.Weekly.rawValue).map { $0 }
        let normalTasks = realm.objects(Task).filter("deleted = false AND type = %@", TaskType.Normal.rawValue).map { $0 }
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
        return realm.objects(TaskHistory).filter("canceled = false AND completionTime >= %@ AND completionTime <= %@", begin, end).count
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

        var query = "task = %@ AND completionTime >= %@ AND completionTime <= %@";
        if (canceled) {
            query += " AND canceled = true";
        } else {
            query += " AND canceled = false";
        }
        let taskHistories = realm.objects(TaskHistory).filter(query, self, begin, end).sorted("completionTime")

        return taskHistories.first;
    }
}