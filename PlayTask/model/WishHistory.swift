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
    
    convenience init(wish: Wish) {
        self.init()
        self.wish = wish
    }
    
    func getBillTitle() -> String {
        return self.wish.title
    }
    
    func getBillScore() -> Int {
        return -self.wish.score
    }
    
    func getBillTime() -> NSDate {
        return self.createdTime
    }
    
    class func getWishHistories() -> [WishHistory] {
        let realm = try! Realm()
        return realm.objects(WishHistory).filter("deleted == false").map { $0 }
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