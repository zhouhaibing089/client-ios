//
//  Config.swift
//  PlayTask
//
//  Created by Yoncise on 11/3/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation

class Config {
    class API {
        #if DEBUG
            static var ROOT = "http://192.168.1.101:8080/playtask/v1"
        #else
            static let ROOT = "http://api.yon.im/playtask/v1"
        #endif
    }
    class Notification {
        static let SYNC = "sync"
        static let BADGE = "badge"
    }
}

