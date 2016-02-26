//
//  AppDelegate.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import CRToast
import RealmSwift
import RxSwift

enum SyncStatus {
    case Synced
    case Syncing
    case Unsynced
    case SyncFailed
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var syncStatus = SyncStatus.Unsynced {
        didSet {
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(Config.Notification.SYNC, object: nil)
        }
    }
    var syncDisposable: Disposable?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
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
        UMOnlineConfig.updateOnlineConfigWithAppkey("5620ffafe0f55a758500000c")
        
        // 通知
        let mySettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        
        // Migrtion
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.enumerate(WishHistory.className()) { oldObject, newObject in
                        let createdTime = oldObject!["createdTime"] as! NSDate
                        newObject!["satisfiedTime"] = createdTime
                    }
                }
        })
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
       
        // MARK: pin
        application.applicationIconBadgeNumber = Task.getPinnedTasksNumOnTheDate(NSDate())
        
        // called BEFORE cancelAllLocalNotifications to avoid schedulling no repeat alarm
        // which has delivered notifications
        TaskAlarm.removeDeliveredAlarms()
        application.cancelAllLocalNotifications()
        Task.scheduleNotifications()
        TaskAlarm.scheduleNotifications()
        self.syncDisposable?.dispose()
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        return
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
        self.autoLogin()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func autoLogin() {
        if let sessionId = Util.sessionId {
            API.loginWithSessionId(sessionId).subscribe { event in
                switch event {
                case .Next(_):
                    break
                case .Error(let error):
                    if let e = error as? APIError {
                        switch e {
                        case.Custom(_, let info, _):
                            Util.sessionId = nil
                            Util.loggedUser = nil
                            CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                        default:
                            self.sync()
                            break
                        }
                    }
                    break
                default:
                    self.sync()
                    break
                }
            }
        }
    }
    
    func sync() {
        self.syncDisposable?.dispose()
        self.syncStatus = SyncStatus.Syncing
        var pullUser: Observable<Table> = Observable.empty()
        if let loggedUser = Util.loggedUser {
            pullUser = API.getUserWithUserSid(loggedUser.sid.value!).map {
                User.getInstance().update(["score": 0]) // 游客账户数据清零
                return $0 as Table
            }
        }
        self.syncDisposable = Task.push().concat(Task.pull()).concat(TaskHistory.push()).concat(TaskHistory.pull())
            .concat(Wish.push()).concat(Wish.pull()).concat(WishHistory.push()).concat(WishHistory.pull())
            .concat(pullUser)
            .subscribe { event in
                switch event {
                case .Completed:
                    self.syncStatus = SyncStatus.Synced
                    break
                case .Error(_):
                    self.syncStatus = SyncStatus.SyncFailed
                    break
                default:
                    break
                }
        }
    }
}

