//
//  Memorial.swift
//  PlayTask
//
//  Created by Yoncise on 1/20/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON

enum MemorialStatus: Int {
    case Waiting = 0
    case Approved = 1
    case Rejected = 2
}

class Memorial {
    var content: String
    var avatarUrl: String
    var createdTime: NSDate
    var image: Image
    var nickname: String
    var status: MemorialStatus
    var reason: String?
    
    init(json: JSON) {
        self.content = json["content"].stringValue
        self.avatarUrl = json["avatar_url"].stringValue
        self.createdTime = NSDate(millisecondsSince1970: json["created_time"].doubleValue)
        self.image = Image(json: json["images"][0])
        self.nickname = json["nickname"].stringValue
        self.status = MemorialStatus(rawValue: json["status"].intValue) ?? MemorialStatus.Waiting
        self.reason = json["reason"].string
    }
}