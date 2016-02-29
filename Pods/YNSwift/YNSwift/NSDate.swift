//
//  NSDate.swift
//  YNSwift
//
//  Created by Yoncise on 1/11/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation

public extension NSDate {
    public var millisecondsSince1970: Double {
        get {
            return self.timeIntervalSince1970 * 1000
        }
    }
        
    public convenience init(millisecondsSince1970: Double) {
        self.init(timeIntervalSince1970: millisecondsSince1970 / 1000)
    }
}