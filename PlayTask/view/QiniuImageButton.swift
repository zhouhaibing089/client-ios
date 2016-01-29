//
//  SmartImageView.swift
//  yon
//
//  Created by Yoncise on 9/3/15.
//  Copyright (c) 2015 yon. All rights reserved.
//

import UIKit
import AlamofireImage

class QiniuImageButton: UIButton {
    
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    var maxHeight: CGFloat!
    var maxWidth: CGFloat!
    var minEdge: CGFloat = 60
    var metaImage: QiniuImage! {
        didSet {
            self.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
            if self.metaImage == nil {
                self.heightConstraint.constant = 0
                self.widthConstraint.constant = 0
            } else {
                let minWidthRatio = self.minEdge / metaImage.height
                let minHeightRatio = self.minEdge / metaImage.width
                let widthRatio = max(self.maxWidth / metaImage.width, minWidthRatio)
                let heightRatio = max(self.maxHeight / metaImage.height, minHeightRatio)
                let ratio = min(heightRatio, widthRatio)
                
                let scaledHeight = ratio * self.metaImage.height
                let scaledWidth = ratio * self.metaImage.width
                self.heightConstraint.constant = CGFloat(min(scaledHeight, maxHeight))
                self.widthConstraint.constant = CGFloat(min(scaledWidth, maxWidth))
                ImageDownloader.defaultInstance.downloadImage(URLRequest: NSURLRequest(URL: NSURL(string: self.metaImage.getUrlForMaxWidth(scaledWidth, maxHeight: scaledHeight))!), completion: { (response) -> Void in
                    if let image = response.result.value {
                        self.setImage(image, forState: UIControlState.Normal)
                    }
                    })
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                self.heightConstraint = constraint as? NSLayoutConstraint
                self.maxHeight = self.heightConstraint.constant
            } else if constraint.firstAttribute == NSLayoutAttribute.Width {
                self.widthConstraint = constraint as? NSLayoutConstraint
                self.maxWidth = self.widthConstraint.constant
            }
        }
    }

}
