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
import YNSwift

final class TaskHistory: Table, Bill {
    dynamic var completionTime: NSDate!
    dynamic var canceled = false
    dynamic var task: Task!
    
    let userSid = RealmOptional<Int>()
    
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
    
    func getBronze() -> Int {
        return self.task.bronze
    }
    
    func cancel() {
        self.update(["canceled": true])
        var user = User.getInstance()
        if let userSid = self.task.userSid.value {
            user = User.getBySid(userSid)!
        }
        user.update(["score": user.score - self.task.score])
    }
    
    class func getTaskHistories() -> [TaskHistory] {
        let realm = try! Realm()

        var query = "userSid == "
        if let loggedUser = Util.loggedUser {
            query += "\(loggedUser.sid.value!)"
        } else {
            query += "nil"
        }
        query += " AND deleted == false AND canceled == false"
        return realm.objects(TaskHistory).filter(query).map { $0 }
    }
    
    override func push() -> Observable<Table> {
        guard let userSid = Util.loggedUser?.sid.value else {
            return empty()
        }
        if self.userSid.value == nil {
            self.update(["userSid": userSid])
        }
        if self.sid.value == nil {
            return API.createTaskHistory(self).map { $0 as Table }
        } else {
            return API.updateTaskHistory(self).map { $0 as Table }
        }
    }
    
    override class func push() -> Observable<Table> {
        guard let userSid = Util.loggedUser?.sid.value else {
            return empty()
        }
        return deferred({ _ -> Observable<Table> in
            let realm = try! Realm()
            return realm.objects(TaskHistory).filter("(userSid == nil OR userSid == %@) AND (synchronizedTime < modifiedTime OR synchronizedTime == nil)", userSid).toObservable().map({ (t) -> Observable<Table> in
                return t.push().retry(3)
            }).concat()
        })

    }

    override class func pull() -> Observable<Table> {
        guard let loggedUser = Util.loggedUser else {
            return empty()
        }
        return generate(0) { index -> Observable<[TaskHistory]> in
            API.getTaskHistories(loggedUser, after: loggedUser.taskHistoryPullTime ?? NSDate(timeIntervalSince1970: 0))
        }.takeWhile({ (taskHistories) -> Bool in
            return taskHistories.count > 0
        }).flatMap({ (taskHistories) -> Observable<TaskHistory> in
            loggedUser.update(["taskHistoryPullTime": taskHistories.last!.modifiedTime])
            return taskHistories.toObservable()
        }).map({ t -> Table in
            return t
        })
    }
}