//
//  Image.swift
//  PlayTask
//
//  Created by Yoncise on 1/21/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON

public class QiniuImage {
    
    public var id: Int?
    public var url: String
    public var width: CGFloat
    public var height: CGFloat
    
    public init(json: JSON) {
        self.id = json["id"].intValue
        self.url = json["url"].stringValue
        self.width = CGFloat(json["width"].doubleValue)
        self.height = CGFloat(json["height"].doubleValue)
    }
    
    public init(url: String, width: CGFloat, height: CGFloat) {
        self.id = nil
        self.url = url
        self.width = width
        self.height = height
    }
    
    public func getUrlForMaxWidth(maxWidth: CGFloat, maxHeight: CGFloat) -> String {
        let maxLongEdge = max(maxWidth, maxHeight)
        let maxShortEdge = min(maxWidth, maxHeight)
        return "\(self.url)?imageView2/0/w/\(Int(maxLongEdge * UIScreen.screenScale))/h/\(Int(maxShortEdge * UIScreen.screenScale))"
    }
    
}
