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

final class TaskHistory: Table, Bill {
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
    
    override func push() -> Observable<Table> {
        if Util.loggedUser == nil {
            return empty()
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
        let realm = try! Realm()
        var observable: Observable<Table> = empty()
        realm.objects(TaskHistory).filter("task.userSid == %@ AND (synchronizedTime < modifiedTime OR synchronizedTime == nil)", userSid).map {
            observable = observable.concat($0.push().retry(3))
        }
        return observable

    }
    
    override class func pull() -> Observable<Table> {
        guard let loggedUser = Util.loggedUser else {
            return empty()
        }
        return create { observer in
            API.getTaskHistories(loggedUser, after: loggedUser.taskHistoryPullTime ?? NSDate(timeIntervalSince1970: 0)).flatMap { taskHistories -> Observable<Table> in
                if taskHistories.count == 0 {
                    return empty()
                }
                taskHistories.map {
                    observer.onNext($0)
                }
                loggedUser.update(["taskHistoryPullTime": taskHistories.last!.modifiedTime])
                return TaskHistory.pull()
            }.subscribe {
                observer.on($0)
            }
            return NopDisposable.instance
        }
    }
}