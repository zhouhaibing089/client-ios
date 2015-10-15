//
//  History.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import SQLite
import UIKit

class History {
    
    struct SQLite {
        static let histories = Table("histories")
        static let id = Expression<Int64>("id")
        static let taskId = Expression<Int64>("task_id")
        static let completionTime = Expression<Int64>("completion_time")
        static let deleted = Expression<Bool>("deleted")
    }
    
    var id: Int64?
    var taskId: Int64
    var completionTime: NSDate
    var deleted: Bool
    
    init(id: Int64?, taskId: Int64, completionTime: NSDate, deleted: Bool) {
        self.id = id
        self.taskId = taskId
        self.completionTime = completionTime
        self.deleted = deleted
    }
    
    func save() {
        try! Util.db.run(History.SQLite.histories.insert(
            History.SQLite.taskId <- self.taskId,
            History.SQLite.completionTime <- Int64(self.completionTime.timeIntervalSince1970),
            History.SQLite.deleted <- self.deleted
        ))
    }
    
    func update() {
        try! Util.db.run(History.SQLite.histories.filter(History.SQLite.id == self.id ?? 0).update(
            History.SQLite.taskId <- self.taskId,
            History.SQLite.completionTime <- Int64(self.completionTime.timeIntervalSince1970),
            History.SQLite.deleted <- self.deleted
        ))
    }
    
    class func createTable(db: Connection) {
        try! db.run(History.SQLite.histories.create(temporary: false, ifNotExists: true) { t in
            t.column(History.SQLite.id, primaryKey: PrimaryKey.Autoincrement)
            t.column(History.SQLite.taskId)
            t.column(History.SQLite.completionTime)
            t.column(History.SQLite.deleted, defaultValue: false)
        })
    }
}
