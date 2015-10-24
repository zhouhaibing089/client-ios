//
//  Bill.swift
//  PlayTask
//
//  Created by Yoncise on 10/24/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation

@objc protocol Bill {
    func getBillTitle() -> String
    func getBillScore() -> Int
    func getBillTime() -> NSDate
    func delete()
}