//
//  SmartImageView.swift
//  yon
//
//  Created by Yoncise on 9/3/15.
//  Copyright (c) 2015 yon. All rights reserved.
//

import UIKit

public class QiniuImageButton: UIButton {
    
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    var maxHeight: CGFloat!
    var maxWidth: CGFloat!
    var minEdge: CGFloat = 60
    public var metaImage: QiniuImage! {
        didSet {
            self.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
            self.setImage(nil, forState: UIControlState.Normal)
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
                self.af_setImageWithURL(self.metaImage.getUrlForMaxWidth(scaledWidth, maxHeight: scaledHeight), forState: UIControlState.Normal, completion: nil)
            }
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                self.heightConstraint = constraint
                self.maxHeight = self.heightConstraint.constant
            } else if constraint.firstAttribute == NSLayoutAttribute.Width {
                self.widthConstraint = constraint
                self.maxWidth = self.widthConstraint.constant
            }
        }
    }

}
