//
//  Synchronizable.swift
//  PlayTask
//
//  Created by Yoncise on 11/9/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation

@objc protocol Synchronizable {
    func push()
    static func push()
    static func pull()
}