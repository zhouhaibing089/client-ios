//
//  User.swift
//  PlayTask
//
//  Created by Yoncise on 10/25/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class User: Table {
    dynamic var account = ""
    dynamic var email = ""
    dynamic var score = 0
    dynamic var bronze = 0
    dynamic var nickname = ""
    dynamic var balance = 0
    
    let groups = List<Group>()
    
    dynamic var taskPullTime: NSDate!
    dynamic var taskHistoryPullTime: NSDate!
    dynamic var wishPullTime: NSDate!
    dynamic var wishHistoryPullTime: NSDate!
    
    dynamic var avatarUrl = ""
    
    static var instance: User?
    
    var badge: Badge = Badge() {
        didSet {
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(Config.Notification.BADGE, object: nil)
        }
    }
    
    convenience init(json: JSON) {
        self.init()
        self.account = json["account"].stringValue
        self.email = json["email"].stringValue
        self.sid.value = json["id"].intValue
        self.avatarUrl = json["avatar_url"].stringValue
        self.nickname = json["nickname"].stringValue
    }
    
    override func update(json json: JSON) {
        super.update(json: json)
        var value = [String: AnyObject]()
        Util.currentUser.badge = Badge(json: json["badge"])
        //  创建 Group
        var groups = [Group]()
        for (_, subJson) in json["groups"] {
            if let group = Group.getBySid(subJson["id"].intValue) {
                group.update(json: subJson)
                groups.append(group)
            } else {
                let g = Group(json: subJson)
                g.name = subJson["name"].stringValue
                g.save()
                groups.append(g)
            }
        }
        value["groups"] = groups
        value["score"] = json["score"].intValue
        value["bronze"] = json["bronze"].intValue
        value["avatarUrl"] = json["avatar_url"].stringValue
        value["nickname"] = json["nickname"].stringValue
        value["balance"] = json["balance"].intValue
        
        self.update(value)
    }
    
    override static func ignoredProperties() -> [String] {
        return ["badge"]
    }
    
    class func getInstance() -> User {
        if User.instance == nil {
            let realm = try! Realm()
            User.instance = realm.objects(User).filter("sid == nil").first
            if User.instance == nil {
                User.instance = User()
                User.instance?.save()
            }
        }
        return User.instance!
    }
    
    func getGroupIds() -> [Int] {
        return self.groups.map { $0.sid.value! }
    }
}

class Group: Table {
    dynamic var name = ""
    
    override func update(json json: JSON) {
        super.update(json: json)
        self.update(["name": json["name"].stringValue])
    }
}
