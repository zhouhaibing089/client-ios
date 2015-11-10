//
//  TaskHistory.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class TaskHistory: Table, Bill, Synchronizable {
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
    
    class func getTaskHistories() -> [TaskHistory] {
        let realm = try! Realm()
        return realm.objects(TaskHistory).filter("deleted == false AND canceled == false").map { $0 }
    }
    
    func push() {
        if Util.loggedUser == nil {
            return
        }
        var observable: Observable<TaskHistory>
        if self.sid.value == nil {
            observable = API.createTaskHistory(self)
        } else {
            observable = API.updateTaskHistory(self)
        }
        observable.subscribeCompleted {}
    }
    
    class func push() {
        guard let userSid = Util.loggedUser?.sid.value else {
            return
        }
        let realm = try! Realm()
        let pending = realm.objects(TaskHistory).filter("task.userSid == %@ AND (synchronizedTime < modifiedTime OR synchronizedTime == nil)", userSid)
        pending.asObservable().subscribeNext { p in
            p.push()
        }
    }
    
    class func pull() {
        guard let loggedUser = Util.loggedUser else {
            return
        }
        API.getTaskHistories(loggedUser, after: loggedUser.taskHistoryPullTime ?? NSDate(timeIntervalSince1970: 0)).subscribeNext { taskHistories in
            if taskHistories.count == 0 {
                return
            }
            loggedUser.update(["taskHistoryPullTime": taskHistories.last!.modifiedTime])
            Task.pull()
        }
    }
}