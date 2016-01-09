//
//  WishHistory.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import YNSwift

class WishHistory: Table, Bill {
    dynamic var wish: Wish!
    dynamic var satisfiedTime: NSDate!
    dynamic var canceled = false
    
    let userSid = RealmOptional<Int>()
    
    convenience init(wish: Wish) {
        self.init()
        self.wish = wish
        self.satisfiedTime = NSDate()
    }
    
    func getBillTitle() -> String {
        return self.wish.title
    }
    
    func getBillScore() -> Int {
        return -self.wish.score
    }
    
    func getBillTime() -> NSDate {
        return self.satisfiedTime
    }
    
    func getBronze() -> Int {
        return 0
    }
    
    func cancel() {
        self.update(["canceled": true])
        var user = User.getInstance()
        if let userSid = self.wish.userSid.value {
            user = User.getBySid(userSid)!
        }
        user.update(["score": user.score + self.wish.score])
        if self.wish.loop == 1 { // 单次欲望撤销后恢复欲望
            self.wish.update(["deleted": false])
        }
    }
    
    class func getWishHistories() -> [WishHistory] {
        let realm = try! Realm()
        var query = "userSid == "
        if let loggedUser = Util.loggedUser {
            query += "\(loggedUser.sid.value!)"
        } else {
            query += "nil"
        }
        query += " AND deleted == false AND canceled == false"
        return realm.objects(WishHistory).filter(query).map { $0 }
    }
    
    class func getWishHistoriesBetween(begin: NSDate, and end: NSDate) -> Results<WishHistory> {
        let realm = try! Realm()
        var query = "userSid == "
        if let loggedUser = Util.loggedUser {
            query += "\(loggedUser.sid.value!)"
        } else {
            query += "nil"
        }
        query += " AND deleted == false AND canceled == false AND satisfiedTime BETWEEN {%@, %@}"
        return realm.objects(WishHistory).filter(query, begin, end).sorted("satisfiedTime")
    }
    
    override func push() -> Observable<Table> {
        guard let userSid = Util.loggedUser?.sid.value else {
            return Observable.empty()
        }
        if self.userSid.value == nil {
            self.update(["userSid": userSid])
        }
        if self.sid.value == nil {
            return API.createWishHistory(self).map { $0 as Table }
        } else {
            return API.updateWishHistory(self).map { $0 as Table }
        }
    }
    
    override class func push() -> Observable<Table> {
        guard let userSid = Util.loggedUser?.sid.value else {
            return Observable.empty()
        }
        return Observable.deferred({ _ -> Observable<Table> in
            let realm = try! Realm()
            return realm.objects(WishHistory).filter("(userSid == nil OR userSid == %@) AND (synchronizedTime < modifiedTime OR synchronizedTime == nil)", userSid).toObservable().map({ (t) -> Observable<Table> in
                return t.push().retry(3)
            }).concat()
        })
        
    }
    
    override class func pull() -> Observable<Table> {
        guard let loggedUser = Util.loggedUser else {
            return Observable.empty()
        }
        return Observable.generate(0) { index -> Observable<[WishHistory]> in
            API.getWishHistories(loggedUser, after: loggedUser.wishHistoryPullTime ?? NSDate(timeIntervalSince1970: 0))
        }.takeWhile({ (wishHistories) -> Bool in
            return wishHistories.count > 0
        }).flatMap({ (wishHistories) -> Observable<WishHistory> in
            loggedUser.update(["wishHistoryPullTime": wishHistories.last!.modifiedTime])
            return wishHistories.toObservable()
        }).map({ t -> Table in
            return t
        })
    }
}