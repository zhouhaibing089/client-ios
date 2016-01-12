//
//  Dungeon.swift
//  PlayTask
//
//  Created by Yoncise on 1/11/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON
import YNSwift

class Dungeon {
    var title: String
    var maxPlayer: Int
    var currentPlayer: Int
    var beginTime: NSDate
    var endTime: NSDate
    var detail: String
    var volume: Int?
    var cashPledge: Double?
    var bronzePledge: Double?
    var status: Int
    
    init(json: JSON) {
        self.title = json["title"].stringValue
        self.maxPlayer = json["max_player"].intValue
        self.currentPlayer = json["current_player"].intValue
        self.beginTime = NSDate(millisecondsSince1970: json["begin_time"].doubleValue)
        self.endTime = NSDate(millisecondsSince1970: json["end_time"].doubleValue)
        self.detail = json["detail"].stringValue
        self.volume = json["volume"].int
        self.cashPledge = json["cash_pledge"].double
        self.bronzePledge = json["bronze_pledge"].double
        self.status = json["status"].intValue
    }
}