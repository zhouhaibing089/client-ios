//
//  BalanceDetail.swift
//  PlayTask
//
//  Created by Yoncise on 4/29/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON
import YNSwift

enum BalanceDetailStatus: Int {
    case Unknown = -1
    case Normal = 0
    case Processing = 1
    case Failed = 2
    case Success = 3
}


class BalanceDetail {
    var title: String
    var status: BalanceDetailStatus
    var createdTime: NSDate
    var amount: Int
    
    var amountStr: String {
        return String(format: "%d.%d%d", self.amount / 100, self.amount % 100 / 10, self.amount % 10)
    }
    
    init(json: JSON) {
        self.title = json["title"].stringValue
        self.status = BalanceDetailStatus(rawValue: json["status"].intValue) ?? BalanceDetailStatus.Unknown
        self.createdTime = NSDate(millisecondsSince1970: json["created_time"].doubleValue)
        self.amount = json["amount"].intValue
    }
}
