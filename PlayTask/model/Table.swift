//
//  Table.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Table: Object {
    dynamic var id = ""
    dynamic var deleted = false
    dynamic var createdTime: NSDate!
    dynamic var modifiedTime: NSDate!
    let sid = RealmOptional<Int>()
    dynamic var synchronizedTime: NSDate?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(json: JSON) {
        self.init()
        self.sid.value = json["id"].intValue
        self.createdTime = NSDate(timeIntervalSince1970: json["created_time"].doubleValue / 1000)
        self.modifiedTime = NSDate(timeIntervalSince1970: json["modified_time"].doubleValue / 1000)
        self.deleted = json["deleted"].boolValue
        self.synchronizedTime = NSDate()
    }
    
    func save() {
        let realm = try! Realm()
        try! realm.write {
            self.id = NSUUID().UUIDString
            self.createdTime = self.createdTime ?? NSDate()
            self.modifiedTime = self.modifiedTime ?? self.createdTime
            realm.add(self)
        }
        self.sync()
    }
    
    func update(var value: [String: AnyObject]) {
        let realm = try! Realm()
        try! realm.write {
            value["id"] = self.id
            value["modifiedTime"] = value["modifiedTime"] ?? NSDate()
            realm.create(self.dynamicType.self, value: value, update: true)
        }
        self.sync()
    }
    
    func update(json json: JSON) {
        let realm = try! Realm()
        try! realm.write {
            self.sid.value = json["id"].intValue
            self.modifiedTime = NSDate(timeIntervalSince1970: json["modified_time"].doubleValue / 1000)
            self.deleted = json["deleted"].boolValue
            self.synchronizedTime = NSDate()
        }
    }
    
    func sync() {
        if let syncTime = self.synchronizedTime {
            if self.modifiedTime.compare(syncTime) == .OrderedAscending {
                return
            }
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
