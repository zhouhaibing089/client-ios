//
//  Util.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import UIKit
import SQLite

class Util {
    static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static let application = UIApplication.sharedApplication()
    static var db: Connection {
        return Util.appDelegate.db
    }
    
}
