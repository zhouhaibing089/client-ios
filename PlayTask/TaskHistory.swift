//
//  TaskHistory.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import SQLite
import UIKit

class TaskHistory: BillItem {
    
    struct SQLite {
        static let histories = Table("task_histories")
        static let id = Expression<Int64>("id")
        static let taskId = Expression<Int64>("task_id")
        static let completionTime = Expression<Int64>("completion_time")
        static let deleted = Expression<Bool>("deleted")

    }
    
    var id: Int64?
    var taskId: Int64
    var completionTime: NSDate
        
    init(task: Task, completionTime: NSDate, deleted: Bool) {
        self.taskId = task.id!
        self.completionTime = completionTime
        super.init(score: task.score, title: task.title, modifiedTime: completionTime, deleted: deleted)
    }
    
    func save() {
        self.id = try! Util.db.run(TaskHistory.SQLite.histories.insert(
            TaskHistory.SQLite.taskId <- self.taskId,
            TaskHistory.SQLite.completionTime <- Int64(self.completionTime.timeIntervalSince1970),
            TaskHistory.SQLite.deleted <- self.deleted
        ))
    }
    
    func update() {
        try! Util.db.run(TaskHistory.SQLite.histories.filter(TaskHistory.SQLite.id == self.id ?? 0).update(
            TaskHistory.SQLite.taskId <- self.taskId,
            TaskHistory.SQLite.completionTime <- Int64(self.completionTime.timeIntervalSince1970),
            TaskHistory.SQLite.deleted <- self.deleted
        ))
    }
    
    class func getHistories() -> [TaskHistory] {
        var histories = [TaskHistory]()
        for row in Util.db.prepare(TaskHistory.SQLite.histories.join(Task.SQLite.tasks, on: TaskHistory.SQLite.taskId == Task.SQLite.tasks[Task.SQLite.id]).filter(TaskHistory.SQLite.histories[TaskHistory.SQLite.deleted] == false)) {
            let task = Task(title: row[Task.SQLite.title],
                score: row[Task.SQLite.score],
                type: TaskType(rawValue: row[Task.SQLite.type])!,
                deleted: row[Task.SQLite.tasks[Task.SQLite.deleted]])
            task.id = row[Task.SQLite.tasks[Task.SQLite.id]]
            let h = TaskHistory(task: task,
                completionTime: NSDate(timeIntervalSince1970: Double(row[TaskHistory.SQLite.completionTime])),
                deleted: row[TaskHistory.SQLite.histories[TaskHistory.SQLite.deleted]])
            histories.append(h)
        }
        return histories
    }
    
    class func createTable(db: Connection) {
        try! db.run(TaskHistory.SQLite.histories.create(temporary: false, ifNotExists: true) { t in
            t.column(TaskHistory.SQLite.id, primaryKey: PrimaryKey.Autoincrement)
            t.column(TaskHistory.SQLite.taskId)
            t.column(TaskHistory.SQLite.completionTime)
            t.column(TaskHistory.SQLite.deleted, defaultValue: false)
        })
    }
}
