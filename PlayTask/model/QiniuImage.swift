//
//  Image.swift
//  PlayTask
//
//  Created by Yoncise on 1/21/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON
import YNSwift

class QiniuImage {
    
    var id: Int
    var url: String
    var width: CGFloat
    var height: CGFloat
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.url = json["url"].stringValue
        self.width = CGFloat(json["width"].doubleValue)
        self.height = CGFloat(json["height"].doubleValue)
    }
    
    func getUrlForMaxWidth(maxWidth: CGFloat, maxHeight: CGFloat) -> String {
        let maxLongEdge = max(maxWidth, maxHeight)
        let maxShortEdge = min(maxWidth, maxHeight)
        return "\(self.url)?imageView2/0/w/\(Int(maxLongEdge * UIScreen.screenScale))/h/\(Int(maxShortEdge * UIScreen.screenScale))"
    }
    
}
