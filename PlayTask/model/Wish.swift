//
//  Wish.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class Wish: Table {
    dynamic var title = ""
    dynamic var score = 0
    dynamic var rank = 0
    dynamic var loop = 0
    
    let userSid = RealmOptional<Int>()
    
    convenience init(title: String, score: Int, loop: Int) {
        self.init()
        self.title = title
        self.score = score
        self.loop = loop
    }
    
    class func getWishes() -> [Wish] {
        let realm = try! Realm()
        var query = "userSid == "
        if let loggedUser = Util.loggedUser {
            query += "\(loggedUser.sid.value!)"
        } else {
            query += "nil"
        }
        query += " AND deleted == false"
        return realm.objects(Wish).filter(query).sorted("rank").map { $0 }
    }
    
    func getSatisfiedTimes() -> Int {
        let realm = try! Realm()
        return realm.objects(WishHistory).filter("wish == %@ AND deleted == false", self).count
    }
    
    override func push() -> Observable<Table> {
        guard let userSid = Util.loggedUser?.sid.value else {
            return empty()
        }
        if self.userSid.value == nil {
            self.update(["userSid": userSid])
        }
        if self.sid.value == nil {
            return API.createWish(self).map { $0 as Table }
        } else {
            return API.updateWish(self).map { $0 as Table }
        }
    }
    
    override class func push() -> Observable<Table> {
        guard let userSid = Util.loggedUser?.sid.value else {
            return empty()
        }
        let realm = try! Realm()
        var observable: Observable<Table> = empty()
        realm.objects(Wish).filter("(userSid == %@ OR userSid == nil) AND (synchronizedTime < modifiedTime OR synchronizedTime == nil)", userSid).map {
            observable = observable.concat($0.push().retry(3))
        }
        return observable
    }
    
    override class func pull() -> Observable<Table> {
        guard let loggedUser = Util.loggedUser else {
            return empty()
        }
        return create { observer in
            API.getWishes(loggedUser, after: loggedUser.wishPullTime ?? NSDate(timeIntervalSince1970: 0)).flatMap { wishes -> Observable<Table> in
                if wishes.count == 0 {
                    return empty()
                }
                wishes.map {
                    observer.onNext($0)
                }
                loggedUser.update(["wishPullTime": wishes.last!.modifiedTime])
                return Wish.pull()
                }.subscribe {
                    observer.on($0)
            }
            return NopDisposable.instance
        }
    }
    
}