//
//  DungeonNotification.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON

class DungeonNotification {
    var avatarUrl: String
    var nickname: String
    var memorial: Memorial?
    var memorialComment: MemorialComment?
    var content: String?
    var createdTime: NSDate
    
    init(json: JSON) {
        self.avatarUrl = json["avatar_url"].stringValue
        self.nickname = json["nickname"].stringValue
        self.content = json["content"].string
        self.memorialComment = MemorialComment(json: json["memorial_comment"])
        self.memorial = Memorial(json: json["memorial"])
        self.createdTime = NSDate(millisecondsSince1970: json["created_time"].doubleValue)
    }
}
