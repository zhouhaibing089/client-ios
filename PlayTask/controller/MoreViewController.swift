//
//  MoreViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import MBProgressHUD
import YNSwift
import AlamofireImage

class MoreViewController: UITableViewController {
    @IBOutlet weak var syncStatusLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBAction func sync(sender: UIButton) {
        if Util.appDelegate.syncStatus != SyncStatus.Syncing {
            Util.appDelegate.sync()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showSection(section) {
            #if DEBUG
                // 开发者选项
                if section == 0 {
                    return 4
                }
            #endif
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.showSection(section) {
            return super.tableView(tableView, heightForFooterInSection: section)
        } else {
            return CGFloat.min
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.showSection(section) {
            return super.tableView(tableView, heightForHeaderInSection: section)
        } else {
            return CGFloat.min
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if self.showSection(section) {
            if section == 0 {
                return UMOnlineConfig.getConfigParams("feedbackFooterTitle") ?? "关注微信公众号 PlayTask 进行反馈可及时收到回复"
            }
            if section == 3 {
                let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
                return super.tableView(tableView, titleForFooterInSection: section)! + " \(version)"
            }
            return super.tableView(tableView, titleForFooterInSection: section)
        } else {
            return nil
        }
    }
    
    func showSection(section: Int) -> Bool {
        switch section {
        case 1:
            return Util.loggedUser != nil
        case 2:
            return Util.loggedUser == nil
        case 3:
            let showSupport = UMOnlineConfig.getConfigParams("showSupport") ?? "false"
            return showSupport == "true"
        default:
            return true
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.section == 3 {
            cell.textLabel?.text = UMOnlineConfig.getConfigParams("supportText") ?? "请作者喝养乐多"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                Util.application.openURL(NSURL(string: "itms-apps://itunes.apple.com/cn/app/id1050090187?&mt=8")!)
                break
            case 1:
                Util.application.openURL(NSURL(string: "http://www.yon.im/help")!)
                break
            case 2:
                Util.application.openURL(NSURL(string: "http://www.yon.im/feedback")!)
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 2:
                let hud = MBProgressHUD.show()
                Util.appDelegate.syncDisposable?.dispose()
                API.logoutWithSessionId(Util.sessionId!).subscribe { event in
                    switch event {
                    case .Next(_):
                        self.tableView.reloadData()
                        // 清除 Alarm
                        Util.application.cancelAllLocalNotifications()
                        hud.switchToSuccess(duration: 1, labelText: "退出成功")
                        break
                    default:
                        hud.hide(true)
                        break
                    }
                }
                break
            default:
                break
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                let supportAlertTitle = UMOnlineConfig.getConfigParams("supportAlertTitle") ?? "支付宝帐号"
                let supportAlertMessage = UMOnlineConfig.getConfigParams("supportAlertMessage") ?? "playtask@qq.com"
                let alert = UIAlertController(title: supportAlertTitle, message: supportAlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "好", style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "复制", style: UIAlertActionStyle.Default, handler: { _ in
                    let pasteboard = UIPasteboard.generalPasteboard()
                    pasteboard.string = supportAlertMessage
                }))

                self.presentViewController(alert, animated: true, completion: nil)
                break
            default:
                break
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.whiteColor();
        // estimatedRowHeight is REQUIRED, otherwise cell will get shrinked when clicked
        self.tableView.estimatedRowHeight = 44
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncStatusChanged:", name: Config.Notification.SYNC, object: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func syncStatusChanged(notification: NSNotification!) {
        switch Util.appDelegate.syncStatus {
        case .Synced:
            self.syncStatusLabel.text = "已同步"
        case .SyncFailed:
            self.syncStatusLabel.text = "同步出错"
        case .Syncing:
            self.syncStatusLabel.text = "同步中"
        case .Unsynced:
            self.syncStatusLabel.text = "待同步"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        MobClick.beginLogPageView("more")
        self.nicknameLabel.text = Util.currentUser.nickname
        self.avatarImageView.af_setImageWithURL(NSURL(string: Util.currentUser.avatarUrl)!)
        self.syncStatusChanged(nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("more")
    }

}
