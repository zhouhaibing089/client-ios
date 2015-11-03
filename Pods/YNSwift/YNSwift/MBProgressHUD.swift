//
//  MBProgressHUD.swift
//  yon
//
//  Created by Yoncise on 9/7/15.
//  Copyright (c) 2015 yon. All rights reserved.
//

import Foundation
import MBProgressHUD

public extension MBProgressHUD {
    public func switchToSuccess(duration duration: NSTimeInterval?, labelText: String? = nil, completionBlock: (() -> Void)? = nil) {
        self.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
        self.mode = MBProgressHUDMode.CustomView
        self.labelText = labelText
        self.detailsLabelText = nil
        if let duration = duration {
            self.hide(true, afterDelay: duration)
        }
        self.completionBlock = completionBlock
    }
    
    public class func show() -> MBProgressHUD! {
        if let window = UIApplication.sharedApplication().delegate?.window {
            return MBProgressHUD.showHUDAddedTo(window, animated: true)
        }
        return nil
    }
}
