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
    
    static var sessionId: String? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.stringForKey("session_id")
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue, forKey: "session_id")
            userDefaults.synchronize()
        }
    }
    
    static var lastLoggedUserSid: Int {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.integerForKey("last_logged_user_sid")
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue, forKey: "last_logged_user_sid")
            userDefaults.synchronize()
        }
    }
    
    static var loggedUser: User? = User.getUserWithSid(Util.lastLoggedUserSid) {
        didSet {
            if let sid = Util.loggedUser?.sid.value {
                Util.lastLoggedUserSid = sid
            }
        }
    }
    static var currentUser: User {
        return Util.loggedUser ?? User.getInstance()
    }
}
