//
//  Wish.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RealmSwift

class Wish: Table {
    dynamic var title = ""
    dynamic var score = 0
    
    convenience init(title: String, score: Int) {
        self.init()
        self.title = title
        self.score = score
    }
    
    class func getWishes() -> [Wish] {
        let realm = try! Realm()
        return realm.objects(Wish).filter("deleted == false").map { $0 }
    }
}