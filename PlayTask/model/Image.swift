//
//  Image.swift
//  PlayTask
//
//  Created by Yoncise on 1/21/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON

class Image {
    
    var id: Int
    var url: String
    var width: Double
    var height: Double
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.url = json["url"].stringValue
        self.width = json["width"].doubleValue
        self.height = json["height"].doubleValue
    }
    
}
