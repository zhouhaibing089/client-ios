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

class WishHistory: Table, Bill {
    dynamic var wish: Wish!
    dynamic var satisfiedTime: NSDate!
    dynamic var canceled = false
    
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
        var query = "wish.userSid == "
        if let loggedUser = Util.loggedUser {
            query += "\(loggedUser.sid.value!)"
        } else {
            query += "nil"
        }
        query += " AND deleted == false AND canceled == false"
        return realm.objects(WishHistory).filter(query).map { $0 }
    }
    
    override func push() -> Observable<Table> {
        if Util.loggedUser == nil {
            return empty()
        }
        if self.sid.value == nil {
            return API.createWishHistory(self).map { $0 as Table }
        } else {
            return API.updateWishHistory(self).map { $0 as Table }
        }
    }
    
    override class func push() -> Observable<Table> {
        guard let userSid = Util.loggedUser?.sid.value else {
            return empty()
        }
        let realm = try! Realm()
        var observable: Observable<Table> = empty()
        realm.objects(WishHistory).filter("wish.userSid == %@ AND (synchronizedTime < modifiedTime OR synchronizedTime == nil)", userSid).map {
            observable = observable.concat($0.push().retry(3))
        }
        return observable
        
    }
    
    override class func pull() -> Observable<Table> {
        guard let loggedUser = Util.loggedUser else {
            return empty()
        }
        return create { observer in
            API.getWishHistories(loggedUser, after: loggedUser.wishHistoryPullTime ?? NSDate(timeIntervalSince1970: 0)).flatMap { wishHistories -> Observable<Table> in
                if wishHistories.count == 0 {
                    return empty()
                }
                wishHistories.map {
                    observer.onNext($0)
                }
                loggedUser.update(["wishHistoryPullTime": wishHistories.last!.modifiedTime])
                return WishHistory.pull()
                }.subscribe {
                    observer.on($0)
            }
            return NopDisposable.instance
        }
    }
}