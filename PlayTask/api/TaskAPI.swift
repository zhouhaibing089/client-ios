//
//  TaskAPI.swift
//  PlayTask
//
//  Created by Yoncise on 11/8/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

extension API {
    class func createTask(task: Task) -> Observable<Task> {
        return API.req(.POST, "/users/\(task.userSid.value!)/tasks", parameters: [
            "title": task.title,
            "score": task.score,
            "type": task.type,
            "loop": task.loop,
            "rank": task.rank,
            "bronze": task.bronze,
            "pinned": task.pinned ? "true" : "false",
            
            "deleted": task.deleted ? "true" : "false",
            "modified_time": task.modifiedTime.timeIntervalSince1970 * 1000,
            "created_time": task.createdTime.timeIntervalSince1970 * 1000
            ]).map { json in
            task.update(json: json)
            return task
        }
    }
    
    class func updateTask(task: Task) -> Observable<Task> {
        return API.req(.PUT, "/tasks/\(task.sid.value!)", parameters: [
            "rank": task.rank,
            "pinned": task.pinned ? "true" : "false",
            
            "modified_time": task.modifiedTime.timeIntervalSince1970 * 1000,
            "deleted": task.deleted ? "true" : "false",
            ]).map { json in
                task.update(json: json)
                return task
        }
    }
    
    class func getTasks(user: User, after: NSDate) -> Observable<[Task]> {
        return API.req(.GET, "/users/\(user.sid.value!)/tasks", parameters: [
            "after": after.timeIntervalSince1970 * 1000
            ]).map { json in
            var tasks = [Task]()
            for (_, subJson) : (String, JSON) in json {
                if let t = Task.getBySid(subJson["id"].intValue) { // update
                    let pinned = subJson["pinned"].boolValue
                    let rank = subJson["rank"].intValue
                    let bronze = subJson["bronze"].intValue
                    let title = subJson["title"].stringValue
                    
                    t.update(json: subJson, value: ["pinned": pinned, "title": title,
                        "rank": rank, "bronze": bronze])
                    tasks.append(t)
                } else { // new
                    let t = Task(json: subJson)
                    t.loop = subJson["loop"].intValue
                    t.pinned = subJson["pinned"].boolValue
                    t.rank = subJson["rank"].intValue
                    t.score = subJson["score"].intValue
                    t.title = subJson["title"].stringValue
                    t.type = subJson["type"].intValue
                    t.bronze = subJson["bronze"].intValue
                    t.userSid.value = subJson["user_id"].int
                    t.groupSid.value = subJson["group_id"].int

                    t.save()
                    tasks.append(t)
                }
            }
            return tasks
        }
    }
    
    class func createTaskHistory(taskHistory: TaskHistory) -> Observable<TaskHistory> {
        return API.req(.POST, "/tasks/\(taskHistory.task.sid.value!)/task_histories", parameters: [
            "completion_time": taskHistory.completionTime.timeIntervalSince1970 * 1000,
            "canceled": taskHistory.canceled ? "true" : "false",
            
            "deleted": taskHistory.deleted ? "true" : "false",
            "modified_time": taskHistory.modifiedTime.timeIntervalSince1970 * 1000,
            "created_time": taskHistory.createdTime.timeIntervalSince1970 * 1000
            ]).map { json in
            taskHistory.update(json: json)
            return taskHistory
        }
    }
    
    class func updateTaskHistory(taskHistory: TaskHistory) -> Observable<TaskHistory> {
        return API.req(.PUT, "/task_histories/\(taskHistory.sid.value!)", parameters: [
            "completion_time": taskHistory.completionTime.timeIntervalSince1970 * 1000,
            "canceled": taskHistory.canceled ? "true" : "false",
            
            "deleted": taskHistory.deleted ? "true" : "false",
            "modified_time": taskHistory.modifiedTime.timeIntervalSince1970 * 1000
            ]).map { json in
                taskHistory.update(json: json)
                return taskHistory
        }
    }
    
    class func getTaskHistories(user: User, after: NSDate) -> Observable<[TaskHistory]> {
        return API.req(.GET, "/users/\(user.sid.value!)/task_histories", parameters: [
            "after": after.timeIntervalSince1970 * 1000
            ]).map { json in
            var taskHistories = [TaskHistory]()
            for (_, subJson) : (String, JSON) in json {
                if let th = TaskHistory.getBySid(subJson["id"].intValue) {
                    let completionTime = NSDate(timeIntervalSince1970: subJson["completion_time"].doubleValue / 1000)
                    let canceled = subJson["canceled"].boolValue
                    
                    th.update(json: subJson, value: ["completionTime": completionTime, "canceled": canceled])
                    taskHistories.append(th)
                } else {
                    if let t = Task.getBySid(subJson["task_id"].intValue) {
                        let th = TaskHistory(json: subJson)
                        th.completionTime = NSDate(timeIntervalSince1970: subJson["completion_time"].doubleValue / 1000)
                        th.canceled = subJson["canceled"].boolValue
                        th.task = t
                        th.userSid.value = subJson["user_id"].int
                        
                        th.save()
                        taskHistories.append(th)
                    }
                }
            }
            return taskHistories
        }
    }
}
