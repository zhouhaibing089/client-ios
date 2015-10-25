//
//  WishHistory.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift

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
    
}