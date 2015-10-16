//
//  Wish.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import SQLite

class Wish {
    struct SQLite {
        static let wishes = Table("wishes")
        static let id = Expression<Int64>("id")
        static let title = Expression<String>("title")
        static let score = Expression<Int64>("score")
        static let deleted = Expression<Bool>("deleted")
    }
    
    var id: Int64?
    var title: String
    var score: Int64
    var deleted: Bool
    
    init(title: String, score: Int64, deleted: Bool) {
        self.title = title
        self.score = score
        self.deleted = deleted
    }
    
    func save() {
        self.id = try! Util.db.run(Wish.SQLite.wishes.insert(
            Wish.SQLite.title <- self.title,
            Wish.SQLite.score <- self.score,
            Wish.SQLite.deleted <- self.deleted
        ))
    }
    
    func update() {
        try! Util.db.run(Wish.SQLite.wishes.filter(Wish.SQLite.id == self.id ?? 0).update(
            Wish.SQLite.title <- self.title,
            Wish.SQLite.score <- self.score,
            Wish.SQLite.deleted <- self.deleted
        ))
    }
    
    class func getWishes() -> [Wish] {
        var wishes = [Wish]()
        for row in Util.db.prepare(Wish.SQLite.wishes.filter(Wish.SQLite.deleted == false)) {
            let w = Wish(title: row[Wish.SQLite.title], score: row[Wish.SQLite.score],
                deleted: row[Wish.SQLite.deleted])
            w.id = row[Wish.SQLite.id]
            wishes.append(w)
        }
        return wishes
    }
    
    class func createTable(db: Connection) {
        try! db.run(Wish.SQLite.wishes.create(temporary: false, ifNotExists: true) { t in
            t.column(Wish.SQLite.id, primaryKey: PrimaryKey.Autoincrement)
            t.column(Wish.SQLite.title)
            t.column(Wish.SQLite.score)
            t.column(Wish.SQLite.deleted, defaultValue: false)
        })
    }
}
