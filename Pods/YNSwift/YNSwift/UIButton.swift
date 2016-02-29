//
//  UIButton.swift
//  YNSwift
//
//  Created by Yoncise on 1/29/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import AlamofireImage

public extension UIButton {
    public func af_setImageWithURL(url: String, forState: UIControlState, completion: ImageDownloader.CompletionHandler?) {
        ImageDownloader.defaultInstance.downloadImage(URLRequest: NSURLRequest(URL: NSURL(string: url)!)) { (response) -> Void in
            if let image = response.result.value {
                self.setImage(image, forState: forState)
            }
            completion?(response)
        }
    }
}
