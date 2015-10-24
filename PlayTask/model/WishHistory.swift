//
//  WishHistory.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import SQLite

class WishHistory: BillItem {
    struct SQLite {
        static let histories = Table("wish_histories")
        static let id = Expression<Int64>("id")
        static let wishId = Expression<Int64>("wish_id")
        static let deleted = Expression<Bool>("deleted")
        static let createdTime = Expression<Int64>("created_time")
        static let modifiedTime = Expression<Int64>("modifiedTime")
    }
    
    var id: Int64?
    var wishId: Int64
    var createdTime: NSDate
    
    init(wish: Wish, createdTime: NSDate, deleted: Bool) {
        self.wishId = wish.id!
        self.createdTime = createdTime
        super.init(score: -wish.score, title: wish.title, modifiedTime: createdTime, deleted: deleted)
    }
    
    func save() {
        self.id = try! Util.db.run(WishHistory.SQLite.histories.insert(
            WishHistory.SQLite.wishId <- self.wishId,
            WishHistory.SQLite.deleted <- self.deleted,
            WishHistory.SQLite.createdTime <- Int64(self.createdTime.timeIntervalSince1970),
            WishHistory.SQLite.modifiedTime <- Int64(NSDate().timeIntervalSince1970)
        ))
    }
    
    override func update() {
        try! Util.db.run(WishHistory.SQLite.histories.filter(WishHistory.SQLite.id == self.id!).update(
            WishHistory.SQLite.wishId <- self.wishId,
            WishHistory.SQLite.deleted <- self.deleted,
            WishHistory.SQLite.modifiedTime <- Int64(NSDate().timeIntervalSince1970)
        ))
    }
    
    class func getHistories() -> [WishHistory] {
        var histories = [WishHistory]()
        for row in Util.db.prepare(WishHistory.SQLite.histories.join(Wish.SQLite.wishes, on: WishHistory.SQLite.wishId == Wish.SQLite.wishes[Wish.SQLite.id]).filter(WishHistory.SQLite.histories[WishHistory.SQLite.deleted] == false)) {
            let wish = Wish(title: row[Wish.SQLite.title],
                score: row[Wish.SQLite.score],
                deleted: row[Wish.SQLite.wishes[Wish.SQLite.deleted]])
            wish.id = row[Wish.SQLite.wishes[Wish.SQLite.id]]
            let h = WishHistory(wish: wish,
                createdTime: NSDate(timeIntervalSince1970: Double(row[WishHistory.SQLite.createdTime])),
                deleted: row[WishHistory.SQLite.histories[WishHistory.SQLite.deleted]])
            h.id = row[WishHistory.SQLite.histories[WishHistory.SQLite.id]]
            histories.append(h)
        }
        return histories
    }
    
    class func createTable(db: Connection) {
        try! db.run(WishHistory.SQLite.histories.create(temporary: false, ifNotExists: true) { t in
            t.column(WishHistory.SQLite.id, primaryKey: PrimaryKey.Autoincrement)
            t.column(WishHistory.SQLite.wishId)
            t.column(WishHistory.SQLite.deleted, defaultValue: false)
            t.column(WishHistory.SQLite.createdTime)
            t.column(WishHistory.SQLite.modifiedTime)
        })
    }

}