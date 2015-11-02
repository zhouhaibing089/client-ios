//
//  UIColor.swift
//  yon
//
//  Created by Yoncise on 9/7/15.
//  Copyright (c) 2015 yon. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    public convenience init(hexValue: Int, alpha: CGFloat = 1) {
        let red = CGFloat(hexValue >> 16 & 0xff) / 0xff
        let green = CGFloat(hexValue >> 8 & 0xff) / 0xff
        let blue = CGFloat(hexValue & 0xff) / 0xff
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}