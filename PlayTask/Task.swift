//
//  Task.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import SQLite
import UIKit

enum TaskType: Int64 {
    case EveryDay = 0
    case EveryWeek = 1
}

class Task {
    
    struct SQLite {
        static let tasks = Table("tasks")
        static let id = Expression<Int64>("id")
        static let title = Expression<String>("title")
        static let score = Expression<Int64>("score")
        static let type = Expression<Int64>("type")
        static let deleted = Expression<Bool>("deleted")

    }
    
    var id: Int64?
    var title: String
    var score: Int64
    var type: TaskType
    var deleted: Bool
    
    init(title: String, score: Int64, type: TaskType, deleted: Bool) {
        self.title = title
        self.score = score
        self.type = type
        self.deleted = deleted
    }
    
    func save() {
        self.id = try! Util.db.run(Task.SQLite.tasks.insert(
            Task.SQLite.title <- self.title,
            Task.SQLite.score <- self.score,
            Task.SQLite.type <- self.type.rawValue,
            Task.SQLite.deleted <- self.deleted
        ))
    }
    
    func update() {
        try! Util.db.run(Task.SQLite.tasks.filter(Task.SQLite.id == self.id ?? 0).update(
            Task.SQLite.title <- self.title,
            Task.SQLite.score <- self.score,
            Task.SQLite.type <- self.type.rawValue,
            Task.SQLite.deleted <- self.deleted
        ))
    }
    
    class func getTask(taskId: Int64) -> Task? {
        if let t = Util.db.pluck(Task.SQLite.tasks.filter(Task.SQLite.id == taskId)) {
            return Task(title: t[Task.SQLite.title],
                score: t[Task.SQLite.score],
                type: TaskType(rawValue: t[Task.SQLite.type])!,
                deleted: t[Task.SQLite.deleted])
        }
        return nil
    }
    
    class func getTasks() -> [Int64: [Task]] {
        var everyDayTasks = [Task]()
        for task in Util.db.prepare(Task.SQLite.tasks.filter(Task.SQLite.deleted == false).filter(Task.SQLite.type == TaskType.EveryDay.rawValue)) {
            let t = Task(
                title: task[Task.SQLite.title],
                score: task[Task.SQLite.score],
                type: TaskType.init(rawValue: task[Task.SQLite.type])!,
                deleted: task[Task.SQLite.deleted]
            )
            t.id = task[Task.SQLite.id]
            everyDayTasks.append(t)
        }
        everyDayTasks = everyDayTasks.sort {
            return $0.score < $1.score
        }
        var everyWeekTasks = [Task]()
        for task in Util.db.prepare(Task.SQLite.tasks.filter(Task.SQLite.deleted == false).filter(Task.SQLite.type == TaskType.EveryWeek.rawValue)) {
            let t = Task(
                title: task[Task.SQLite.title],
                score: task[Task.SQLite.score],
                type: TaskType.init(rawValue: task[Task.SQLite.type])!,
                deleted: task[Task.SQLite.deleted]
            )
            t.id = task[Task.SQLite.id]
            everyWeekTasks.append(t)
        }
        everyWeekTasks = everyWeekTasks.sort {
            return $0.score < $1.score
        }
        return [TaskType.EveryDay.rawValue: everyDayTasks, TaskType.EveryWeek.rawValue: everyWeekTasks]
    }
    
    class func createTable(db: Connection) {
        try! db.run(Task.SQLite.tasks.create(temporary: false, ifNotExists: true) { t in
            t.column(Task.SQLite.id, primaryKey: PrimaryKey.Autoincrement)
            t.column(Task.SQLite.title)
            t.column(Task.SQLite.score)
            t.column(Task.SQLite.type)
            t.column(Task.SQLite.deleted, defaultValue: false)
        })
    }
}