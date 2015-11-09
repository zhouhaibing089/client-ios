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
    dynamic var deleted = false
    dynamic var createdTime: NSDate!
    dynamic var modifiedTime: NSDate!
    let sid = RealmOptional<Int>()
    dynamic var synchronizedTime: NSDate!
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func save() {
        let realm = try! Realm()
        try! realm.write {
            self.id = NSUUID().UUIDString
            self.createdTime = self.createdTime ?? NSDate()
            self.modifiedTime = self.modifiedTime ?? self.createdTime
            realm.add(self)
        }
        if let sync = self as? Synchronizable {
            sync.push()
        }
    }
    
    func update(var value: [String: AnyObject]) {
        let realm = try! Realm()
        try! realm.write {
            value["id"] = self.id
            value["modifiedTime"] = NSDate()
            realm.create(self.dynamicType.self, value: value, update: true)
        }
        if let sync = self as? Synchronizable {
            sync.push()
        }
    }
    
    func delete() {
        let realm = try! Realm()
        try! realm.write {
            self.deleted = true
        }
    }
    
    class func getBySid(sid: Int) -> Self? {
        let realm = try! Realm()
        let r = realm.objects(self).filter("sid == %@", sid).first
        return r
    }
}
