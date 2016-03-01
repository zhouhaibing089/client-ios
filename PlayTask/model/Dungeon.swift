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
    case SettlingPledge = 3
    case SettlingReward = 4
    case Success = 5
}

/// 这个类即代表服务器上的 Dungeon 也代表服务器上的 Dungeon Instance
/// optional 的属性表示只属于其中一种的, 非 optional 的表示
/// 两者都有的属性
class Dungeon {
    var id: Int // 永远是 dungeon 的 id, 而不是 dungeon instance
    var title: String
    var maxPlayer: Int?
    var className: String?
    var currentPlayer: Int
    var startTime: NSDate?
    var finishTime: NSDate?
    var detail: String?
    var volume: Int?
    var cashPledge: Double?
    var bronzePledge: Double?
    var status: DungeonStatus
    var cover: String
    var target: Int
    var progress: Int?
    var utc: Bool // start_time, finish_time, 是 utc 还是 local
    var createdTime: NSDate // 可能是 dungeon 也可能是 dungeon instance 的
    var report: String? // 副本成功的详情描述
    var payDescription: String? // 副本支付说明
    
    init(json: JSON) {
        self.id = json["dungeon_id"].int ?? json["id"].intValue
        self.title = json["title"].stringValue
        self.maxPlayer = json["max_player"].int
        self.currentPlayer = json["current_player"].intValue
        self.detail = json["detail"].string
        self.volume = json["volume"].int
        self.cashPledge = json["cash_pledge"].double
        self.bronzePledge = json["bronze_pledge"].double
        self.status = DungeonStatus(rawValue: json["status"].intValue) ?? DungeonStatus.Unknown
        self.cover = json["cover"].stringValue
        self.target = json["target"].intValue
        self.progress = json["progress"].int
        self.utc = json["utc"].boolValue
        self.className = json["class_name"].string
        if utc {
            self.startTime = NSDate(millisecondsSince1970: json["start_time"].doubleValue)
            self.finishTime = NSDate(millisecondsSince1970: json["finish_time"].doubleValue)
        } else {
            let offset = Double(NSTimeZone.localTimeZone().secondsFromGMT * 1000)
            self.startTime = NSDate(millisecondsSince1970: json["start_time"].doubleValue - offset)
            self.finishTime = NSDate(millisecondsSince1970: json["finish_time"].doubleValue - offset)
        }
        self.createdTime = NSDate(millisecondsSince1970: json["created_time"].doubleValue)
        self.report = json["report"].string
        self.payDescription = json["pay_description"].string
    }
}