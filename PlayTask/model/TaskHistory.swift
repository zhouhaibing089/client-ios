//
//  TaskHistory.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift

class TaskHistory: Table, Bill {
    dynamic var completionTime: NSDate!
    dynamic var canceled = false
    dynamic var task: Task!
    
    convenience init(task: Task) {
        self.init()
        self.task = task
        self.completionTime = NSDate()
    }
    
    func getBillTitle() -> String {
        return self.task.title
    }
    
    func getBillScore() -> Int {
        return self.task.score
    }
    
    func getBillTime() -> NSDate {
        return self.completionTime
    }
    
    static func getTaskHistories() -> [TaskHistory] {
        let realm = try! Realm()
        return realm.objects(TaskHistory).filter("deleted = false AND canceled = false").map { $0 }
    }
}