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
    
    static var instance: User?
    
    convenience init(account: String, email: String, sid: Int) {
        self.init()
        self.account = account
        self.email = email
        self.sid.value = sid
    }
    
    class func getInstance() -> User {
        if User.instance == nil {
            User.instance = User.getUserWithSid(0)
            if User.instance == nil {
                User.instance = User()
                // sid 为 0 表示是游客
                User.instance?.sid.value = 0
                User.instance?.save()
            }
        }
        return User.instance!
    }
    
    class func getUserWithSid(sid: Int) -> User? {
        let realm = try! Realm()
        return realm.objects(User).filter("sid == %@", sid).first
    }
}
