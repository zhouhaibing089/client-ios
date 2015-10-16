//
//  BillItem.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import SQLite

class BillItem {
    
    var score: Int64
    var title: String
    var modifiedTime: NSDate
    var deleted: Bool
    
    init(score: Int64, title: String, modifiedTime: NSDate, deleted: Bool) {
        self.score = score
        self.title = title
        self.modifiedTime = modifiedTime
        self.deleted = deleted
    }
    
    class func getBillItems() -> [BillItem] {
        var billItems = [BillItem]()
        let th: [BillItem] = TaskHistory.getHistories()
        let wh: [BillItem] = WishHistory.getHistories()
        billItems.appendContentsOf(th)
        billItems.appendContentsOf(wh)
        return billItems.sort {
            return $0.modifiedTime.compare($1.modifiedTime) == NSComparisonResult.OrderedDescending
        }
    }
    
    func update() {
        
    }

}
