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
    dynamic var score = 0
    
    static var instance: User?
    
    class func getInstance() -> User {
        if User.instance == nil {
            let realm = try! Realm()
            User.instance = realm.objects(User).first
            if User.instance == nil {
                User.instance = User()
                User.instance?.save()
            }
        }
        return User.instance!
    }
}
