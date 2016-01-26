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
    var content: String
    var memorial: Memorial
    
    init(json: JSON) {
        self.avatarUrl = json["from_user"]["avatar_url"].stringValue
        self.nickname = json["from_user"]["nickname"].stringValue
        self.content = json["content"].stringValue
        self.memorial = Memorial(json: json["memorial"])
    }
}
