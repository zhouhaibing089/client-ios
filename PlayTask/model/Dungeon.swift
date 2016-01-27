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

enum DungeonStatus: Int {
    case Unknown = -1
    case Open = 0
    case Joined = 1
    case Failed = 2
    case Appealing = 3
    case Settling = 4
    case Success = 5
}

class Dungeon {
    var id: Int
    var title: String
    var maxPlayer: Int
    var currentPlayer: Int
    var startTime: NSDate
    var finishTime: NSDate
    var detail: String
    var volume: Int?
    var cashPledge: Double
    var bronzePledge: Double
    var status: DungeonStatus
    var cover: String
    var target: Int
    var progress: Int
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.title = json["title"].stringValue
        self.maxPlayer = json["max_player"].intValue
        self.currentPlayer = json["current_player"].intValue
        self.startTime = NSDate(millisecondsSince1970: json["start_time"].doubleValue)
        self.finishTime = NSDate(millisecondsSince1970: json["finish_time"].doubleValue)
        self.detail = json["detail"].stringValue
        self.volume = json["volume"].int
        self.cashPledge = json["cash_pledge"].doubleValue
        self.bronzePledge = json["bronze_pledge"].doubleValue
        self.status = DungeonStatus(rawValue: json["status"].intValue) ?? DungeonStatus.Unknown
        self.cover = json["cover"].stringValue
        self.target = json["target"].intValue
        self.progress = json["progress"].intValue
    }
}