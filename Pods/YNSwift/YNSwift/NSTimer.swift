//
//  NSTimer.swift
//  yon
//
//  Created by Yoncise on 9/8/15.
//  Copyright (c) 2015 yon. All rights reserved.
//

import Foundation

public extension NSTimer {
    public class func delay(ti: NSTimeInterval, block: () -> Void) -> NSTimer {
        let fireDate = ti + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0) { _ in
            block()
        }
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
    
    public class func loop(ti: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, ti, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
}