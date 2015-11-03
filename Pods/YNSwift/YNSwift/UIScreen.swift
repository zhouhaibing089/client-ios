//
//  UIScreen.swift
//  YNSwift
//
//  Created by Yoncise on 11/3/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import UIKit

public extension UIScreen {
    public static var screenScale: CGFloat {
        return UIScreen.mainScreen().scale
    }
    public static var screenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
    public static var screenHeight: CGFloat {
        return UIScreen.mainScreen().bounds.height
    }
}
