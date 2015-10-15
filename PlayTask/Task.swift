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
        static let tasks = Table("users")
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
    
    init(id: Int64?, title: String, score: Int64, type: TaskType, deleted: Bool) {
        self.id = id
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
    
    class func getTasks() -> [Int64: [Task]] {
        var everyDayTasks = [Task]()
        for task in Util.db.prepare(Task.SQLite.tasks.filter(Task.SQLite.deleted == false).filter(Task.SQLite.type == TaskType.EveryDay.rawValue)) {
            everyDayTasks.append(Task(
                id: task[Task.SQLite.id],
                title: task[Task.SQLite.title],
                score: task[Task.SQLite.score],
                type: TaskType.init(rawValue: task[Task.SQLite.type])!,
                deleted: task[Task.SQLite.deleted]
            ))
        }
        var everyWeekTasks = [Task]()
        for task in Util.db.prepare(Task.SQLite.tasks.filter(Task.SQLite.deleted == false).filter(Task.SQLite.type == TaskType.EveryWeek.rawValue)) {
            everyWeekTasks.append(Task(
                id: task[Task.SQLite.id],
                title: task[Task.SQLite.title],
                score: task[Task.SQLite.score],
                type: TaskType.init(rawValue: task[Task.SQLite.type])!,
                deleted: task[Task.SQLite.deleted]
            ))
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