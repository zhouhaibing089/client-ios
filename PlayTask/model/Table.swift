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
import RxSwift

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
        self.createdTime = NSDate(millisecondsSince1970: json["created_time"].doubleValue)
        self.modifiedTime = NSDate(millisecondsSince1970: json["modified_time"].doubleValue)
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
    
    /// Update self according to value
    func update(var value: [String: AnyObject]) {
        let realm = try! Realm()
        try! realm.write {
            value["id"] = self.id
            value["modifiedTime"] = value["modifiedTime"] ?? NSDate()
            realm.create(self.dynamicType, value: value, update: true)
        }
        if Util.appDelegate.syncStatus != SyncStatus.Syncing {
            Util.appDelegate.syncStatus = SyncStatus.Unsynced
        }
    }
    
    /// Updated from standalone object which has same primarykey as an object in realm
    func update() {
        let realm = try! Realm()
        try! realm.write {
            self.modifiedTime = NSDate()
            realm.add(self, update: true)
        }
        if Util.appDelegate.syncStatus != SyncStatus.Syncing {
            Util.appDelegate.syncStatus = SyncStatus.Unsynced
        }
    }

    
    /// Updated common data from json returned by server
    func update(json json: JSON) {
        var value = [String: AnyObject]()
        value["sid"] = json["id"].intValue
        value["modifiedTime"] = NSDate(millisecondsSince1970: json["modified_time"].doubleValue)
        value["deleted"] = json["deleted"].boolValue
        value["synchronizedTime"] = NSDate()
        self.update(value)
    }
    
    
    func sync() {
        if let syncTime = self.synchronizedTime {
            if self.modifiedTime.compare(syncTime) != .OrderedDescending {
                return
            }
        }
        self.push().retry(3).subscribeNext { _ in
            let realm = try! Realm()
            try! realm.write {
                self.synchronizedTime = NSDate()
            }
        }
    }
    
    func delete() {
        self.update(["deleted": true])
    }
    
    class func getBySid(sid: Int) -> Self? {
        let realm = try! Realm()
        let r = realm.objects(self).filter("sid == %@", sid).first
        return r
    }
    
    class func getById<T: Table>(type: T.Type, id: String) -> T? {
        let realm = try! Realm()
        return realm.objectForPrimaryKey(type, key: id)
    }
    
    func push() -> Observable<Table> {
        return Observable.empty()
    }
    
    class func push() -> Observable<Table> {
        return Observable.empty()
    }
    
    class func pull() -> Observable<Table> {
        return Observable.empty()
    }
}