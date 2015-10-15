//
//  AppDelegate.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import SQLite
import CRToast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var db: Connection!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // 创建 sqlite
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dbPath: String! = userDefaults.stringForKey("db_path")
        
        if dbPath == nil {
            let path = NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory, .UserDomainMask, true
                ).first!
            dbPath = "\(path)/db.sqlite3"
            userDefaults.setObject(dbPath, forKey: "dp_path")
            userDefaults.synchronize()
            
            self.db = try! Connection(dbPath)
            
            // 创建表
            Task.createTable(self.db)
            History.createTable(self.db)
        } else {
            self.db = try! Connection(dbPath)
        }
        
        // 配置 CRToast
        let defaultOptions: [NSObject: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
            kCRToastAnimationInTypeKey: CRToastAnimationType.Spring.rawValue,
            kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastAnimationOutTypeKey: CRToastAnimationType.Spring.rawValue,
            kCRToastNotificationPresentationTypeKey: CRToastPresentationType.Cover.rawValue,
            kCRToastInteractionRespondersKey: [CRToastInteractionResponder(interactionType: CRToastInteractionType.Tap, automaticallyDismiss: true, block: { _ in
                return
            })]
        ]
        CRToastManager.setDefaultOptions(defaultOptions)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

