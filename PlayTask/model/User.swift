//
//  User.swift
//  PlayTask
//
//  Created by Yoncise on 10/25/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift

class User: Table {
    dynamic var account = ""
    dynamic var email = ""
    dynamic var score = 0
    dynamic var bronze = 0
    
    dynamic var taskPullTime: NSDate!
    dynamic var taskHistoryPullTime: NSDate!
    dynamic var wishPullTime: NSDate!
    dynamic var wishHistoryPullTime: NSDate!

    
    static var instance: User?
    
    convenience init(account: String, email: String, sid: Int) {
        self.init()
        self.account = account
        self.email = email
        self.sid.value = sid
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
}
