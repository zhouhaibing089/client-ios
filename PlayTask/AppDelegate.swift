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
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var db: Connection!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.sqlite2Realm()
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
        
        // 友盟统计
        MobClick.startWithAppkey("5620ffafe0f55a758500000c")
        MobClick.updateOnlineConfig()
        
        // 通知
        let mySettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        
        // Migrtion
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
        })
        
        if let sessionId = Util.sessionId {
            API.loginWithSessionId(sessionId).subscribeError({ error in
                if let e = error as? APIError {
                    switch e {
                    case.Custom(_, let info, _):
                        Util.sessionId = nil
                        Util.loggedUser = nil
                        CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                    default:
                        break
                    }
                }
            })
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        UIApplication.sharedApplication().applicationIconBadgeNumber = Task.getPinnedTasksNumOnTheDate(NSDate())
        Task.scheduleNotification()
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
        self.synchronize()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func synchronize() {
        Task.push().concat(Task.pull()).concat(TaskHistory.push()).concat(TaskHistory.pull())
            .concat(Wish.push()).concat(Wish.pull()).concat(WishHistory.push()).concat(WishHistory.pull())
            .subscribeCompleted {}
    }


    func sqlite2Realm() {
        // 创建 sqlite
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        let dbPath = "\(path)/db.sqlite3"
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            return
        }
        
        self.db = try! Connection(dbPath)
        
        struct SQL {
            static let deleted = Expression<Bool>("deleted")
            static let createdTime = Expression<Int64>("createdTime")
            static let modifiedTime = Expression<Int64>("modifiedTime")
        }
        
        struct TaskSQLite {
            static let tasks = SQLite.Table("tasks")
            static let id = Expression<Int64>("id")
            static let title = Expression<String>("title")
            static let score = Expression<Int64>("score")
            static let type = Expression<Int64>("type")

        }
        
        struct TaskHistorySQLite {
            static let histories = SQLite.Table("task_histories")
            static let id = Expression<Int64>("id")
            static let taskId = Expression<Int64>("task_id")
            static let completionTime = Expression<Int64>("completion_time")
        }
        
        struct WishSQLite {
            static let wishes = SQLite.Table("wishes")
            static let id = Expression<Int64>("id")
            static let title = Expression<String>("title")
            static let score = Expression<Int64>("score")
        }
        
        struct WishHistorySQLite {
            static let histories = SQLite.Table("wish_histories")
            static let id = Expression<Int64>("id")
            static let wishId = Expression<Int64>("wish_id")
            static let createdTime = Expression<Int64>("created_time")
        }
        
        let realm = try! Realm()
        // TODO: 新版本上线后数据前几这里要配 version
        
        try! realm.write {
            realm.deleteAll()
        }
        
        // 迁移任务数据表
        for task in db.prepare(TaskSQLite.tasks) {
            let t = Task()
            t.title = task[TaskSQLite.title]
            t.score = Int(task[TaskSQLite.score])
            t.type = Int(task[TaskSQLite.type])
            t.deleted = task[SQL.deleted]
            t.createdTime = NSDate(timeIntervalSince1970: Double(task[SQL.createdTime]))
            t.modifiedTime = NSDate(timeIntervalSince1970: Double(task[SQL.modifiedTime]))
            t.loop = 1
            t.id = NSUUID().UUIDString
            try! realm.write {
                realm.add(t)
            }
            for history in db.prepare(TaskHistorySQLite.histories.filter(TaskHistorySQLite.taskId == task[TaskSQLite.id])) {
                let h = TaskHistory()
                h.task = t
                h.completionTime = NSDate(timeIntervalSince1970: Double(history[TaskHistorySQLite.completionTime]))
                h.deleted = history[SQL.deleted]
                h.createdTime = NSDate(timeIntervalSince1970: Double(history[SQL.createdTime]))
                h.modifiedTime = NSDate(timeIntervalSince1970: Double(history[SQL.modifiedTime]))
                h.canceled = h.deleted
                h.id = NSUUID().UUIDString
                try! realm.write {
                    realm.add(h)
                }
            }
        }
        
        // 迁移欲望数据表
        for wish in db.prepare(WishSQLite.wishes) {
            let w = Wish()
            w.title = wish[WishSQLite.title]
            w.score = Int(wish[WishSQLite.score])
            w.deleted = wish[SQL.deleted]
            w.createdTime = NSDate(timeIntervalSince1970: Double(wish[SQL.createdTime]))
            w.modifiedTime = NSDate(timeIntervalSince1970: Double(wish[SQL.modifiedTime]))
            w.id = NSUUID().UUIDString
            try! realm.write {
                realm.add(w)
            }
            for history in db.prepare(WishHistorySQLite.histories.filter(WishHistorySQLite.wishId == wish[WishSQLite.id])) {
                let h = WishHistory()
                h.wish = w
                h.deleted = history[SQL.deleted]
                h.createdTime = NSDate(timeIntervalSince1970: Double(history[WishHistorySQLite.createdTime]))
                h.modifiedTime = NSDate(timeIntervalSince1970: Double(history[SQL.modifiedTime]))
                h.id = NSUUID().UUIDString
                try! realm.write {
                    realm.add(h)
                }
            }
        }
        
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        let score = standardUserDefaults.integerForKey("score")
        
        Util.currentUser.update(["score": score])
        
        try! fileManager.moveItemAtPath(dbPath, toPath: "\(path)/db_backup.sqlite3")
    }
}

