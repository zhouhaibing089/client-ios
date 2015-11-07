//
//  Table.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift

class Table: Object {
    dynamic var id = ""
    let sid = RealmOptional<Int>()
    dynamic var deleted = false
    dynamic var createdTime: NSDate!
    dynamic var modifiedTime: NSDate!
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func save() {
        let realm = try! Realm()
        try! realm.write {
            self.id = NSUUID().UUIDString
            self.createdTime = NSDate()
            self.modifiedTime = self.createdTime
            realm.add(self)
        }
    }
    
    func update(var value: [String: AnyObject]) {
        let realm = try! Realm()
        try! realm.write {
            value["id"] = self.id
            realm.create(self.dynamicType.self, value: value, update: true)
        }
    }
    
    func delete() {
        let realm = try! Realm()
        try! realm.write {
            self.deleted = true
        }
    }
}
