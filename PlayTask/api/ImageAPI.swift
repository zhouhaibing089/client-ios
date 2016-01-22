//
//  ImageAPI.swift
//  PlayTask
//
//  Created by Yoncise on 1/22/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import RxSwift

extension API {
    class func getQiniuToken() -> Observable<String> {
        return API.req(.POST, "/qiniu_tokens").map({ (json) -> String in
            return json.stringValue
        })
    }
    
    class func createImage(url url: String, orientation: String,
        width: Double, height: Double) -> Observable<Image> {
        return API.req(.POST, "/images", parameters: [
            "url": url,
            "orientation": orientation,
            "width": width,
            "height": height
            ]).map({ (json) -> Image in
                return Image(json: json)
            })
    }
}
