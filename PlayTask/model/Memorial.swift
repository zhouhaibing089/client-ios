//
//  Memorial.swift
//  PlayTask
//
//  Created by Yoncise on 1/20/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON
import YNSwift

enum MemorialStatus: Int {
    case Waiting = 0
    case Approved = 1
    case Rejected = 2
}

class Memorial {
    var id: Int
    var content: String
    var avatarUrl: String
    var createdTime: NSDate
    var image: QiniuImage?
    var nickname: String
    var status: MemorialStatus
    var reason: String?
    var comments: [MemorialComment]
    var userId: Int
    
    init?(json: JSON) {
        self.id = json["id"].intValue
        self.content = json["content"].stringValue
        self.avatarUrl = json["avatar_url"].stringValue
        self.createdTime = NSDate(millisecondsSince1970: json["created_time"].doubleValue)
        if (json["images"].count > 0) {
            self.image = QiniuImage(json: json["images"][0])
        }
        self.nickname = json["nickname"].stringValue
        self.status = MemorialStatus(rawValue: json["status"].intValue) ?? MemorialStatus.Waiting
        self.reason = json["reason"].string
        self.comments = [MemorialComment]()
        for (_, subJson) : (String, JSON) in json["comments"] {
            self.comments.append(MemorialComment(json: subJson)!)
        }
        self.userId = json["user_id"].intValue
        if json["id"].int == nil {
            return nil
        }
    }
}