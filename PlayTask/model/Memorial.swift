//
//  Memorial.swift
//  PlayTask
//
//  Created by Yoncise on 1/20/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON

class Memorial {
    var content: String
    var avatarUrl: String
    var createdTime: NSDate
    var image: Image
    
    init(json: JSON) {
        self.content = json["content"].stringValue
        self.avatarUrl = json["avatar_url"].stringValue
        self.createdTime = NSDate(millisecondsSince1970: json["created_time"].doubleValue)
        self.image = Image(json: json["images"][0])
    }
}