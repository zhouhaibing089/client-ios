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
            static var ROOT = "http://127.0.0.1:8080/playtask/v1"
        #else
            static let ROOT = "http://api.yon.im/playtask/v1"
        #endif
    }
    class Notification {
        static let SYNC = "sync"
        static let BADGE = "badge"
        static let ALIPAY_DUNGEON = "alipay_dungeon"
    }
    
    static let LOAD_THRESHOLD = 20
}

