//
//  MemorialComment.swift
//  PlayTask
//
//  Created by Yoncise on 1/24/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON

class MemorialComment {
    var fromUserId: Int
    var fromNickname: String
    var toUserId: Int?
    var toNickname: String?
    var content: String
    var memorialId: Int
    
    init(json: JSON) {
        self.fromUserId = json["from_user_id"].intValue
        self.toUserId = json["to_user_id"].int
        self.content = json["content"].stringValue
        self.fromNickname = json["from_nickname"].stringValue
        self.toNickname = json["to_nickname"].string
        self.memorialId = json["memorial_id"].intValue
    }
}