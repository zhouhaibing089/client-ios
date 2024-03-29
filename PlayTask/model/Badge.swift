//
//  Badge.swift
//  PlayTask
//
//  Created by Yoncise on 1/25/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON

class Badge {
    private var dungeons: [String: JSON]
    
    init(json: JSON) {
        self.dungeons = json["dungeons"].dictionaryValue
    }
    
    init() {
        self.dungeons = [String: JSON]()
    }
    
    func getDungeonsCount() -> Int {
        var count = 0
        for (_, json) in self.dungeons {
            count += json.intValue
        }
        return count
    }
    
    func getCountByDungeonId(dungeonId: Int) -> Int {
        return self.dungeons[String(dungeonId)]?.intValue ?? 0
    }
    
    func setDungeon(dungeon: Dungeon, count: Int) {
        self.dungeons[String(dungeon.id)] = JSON(0)
        NSNotificationCenter.defaultCenter().postNotificationName(Config.Notification.BADGE, object: nil)
    }
    
}