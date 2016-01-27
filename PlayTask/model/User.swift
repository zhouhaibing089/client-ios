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
}
