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
    
    static var loggedUserSid: Int? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sid = userDefaults.integerForKey("logged_user_sid")
        return sid == 0 ? nil : sid
    }
    
}
