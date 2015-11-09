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
        return API.req(.POST, "/tasks", parameters: ["title": task.title,
            "score": task.score,
            "type": task.type,
            "loop": task.loop,
            "rank": task.rank,
            "pinned": task.pinned ? "true" : "false",
            "deleted": task.deleted ? "true" : "false",
            "created_time": task.createdTime.timeIntervalSince1970 * 1000,
            ]).resp().map { json in
            task.update(["sid": json["id"].intValue])
            return task
        }
    }
    
    class func updateTask(task: Task) -> Observable<Task> {
        return API.req(.PUT, "/tasks/\(task.sid.value!)", parameters: ["rank": task.rank,
            "pinned": task.pinned ? "true" : "false",
            "deleted": task.deleted ? "true" : "false",
            ]).resp().map { _ in
            return task
        }
    }
    
    class func getTasks(user: User, after: NSDate) -> Observable<[Task]> {
        return API.req(.GET, "/users/\(user.sid.value!)/tasks", parameters: ["after": after.timeIntervalSince1970 * 1000]).resp().map { json in
            var tasks = [Task]()
            for (_, subJson) : (String, JSON) in json {
                if let t = Task.getBySid(subJson["id"].intValue) {
                    let modifiedTime = NSDate(timeIntervalSince1970: subJson["modified_time"].doubleValue / 1000)
                    let pinned = subJson["pinned"].boolValue
                    let deleted = subJson["deleted"].boolValue
                    let rank = subJson["rank"].intValue
                    t.update(["modifiedTime": modifiedTime, "pinned": pinned,
                        "deleted": deleted, "rank": rank])
                    tasks.append(t)
                } else {
                    let t = Task()
                    t.createdTime = NSDate(timeIntervalSince1970: subJson["created_time"].doubleValue / 1000)
                    t.sid.value = subJson["id"].intValue
                    t.loop = subJson["loop"].intValue
                    t.modifiedTime = NSDate(timeIntervalSince1970: subJson["modified_time"].doubleValue / 1000)
                    t.pinned = subJson["pinned"].boolValue
                    t.rank = subJson["rank"].intValue
                    t.score = subJson["score"].intValue
                    t.title = subJson["title"].stringValue
                    t.type = subJson["type"].intValue
                    t.userSid.value = subJson["user_id"].intValue
                    t.save()
                    tasks.append(t)
                }
            }
            return tasks
        }
    }
}
