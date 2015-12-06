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
import YNSwift

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
        return realm.objects(WishHistory).filter("wish == %@ AND canceled == False", self).count
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
        return realm.objects(Wish).filter("(userSid == %@ OR userSid == nil) AND (synchronizedTime < modifiedTime OR synchronizedTime == nil)", userSid).toObservable().map({ (t) -> Observable<Table> in
            return t.push().retry(3)
        }).concat()
    }
    
    override class func pull() -> Observable<Table> {
        guard let loggedUser = Util.loggedUser else {
            return empty()
        }
        return generate(0) { index -> Observable<[Wish]> in
            API.getWishes(loggedUser, after: loggedUser.wishPullTime ?? NSDate(timeIntervalSince1970: 0))
        }.takeWhile({ (wishes) -> Bool in
            return wishes.count > 0
        }).flatMap({ (wishes) -> Observable<Wish> in
            loggedUser.update(["wishPullTime": wishes.last!.modifiedTime])
            return wishes.toObservable()
        }).map({ t -> Table in
            return t
        })
    }
    
}