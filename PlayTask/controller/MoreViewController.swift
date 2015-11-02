//
//  MoreViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showSection(section) {
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
            if section == 1 {
                return MobClick.getConfigParams("supportFooter") ?? "如果你觉得软件有用, 不妨..."
            }
            return super.tableView(tableView, titleForFooterInSection: section)
        } else {
            return nil
        }
    }
    
    func showSection(section: Int) -> Bool {
        switch section {
        case 1:
            let showSupport = MobClick.getConfigParams("showSupport") ?? "false"
            return showSupport == "true"
        case 2:
            return Util.loggedUserSid != nil
        case 3:
            return Util.loggedUserSid == nil
        default:
            return true
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.section == 1 {
            cell.textLabel?.text = MobClick.getConfigParams("supportText") ?? "请作者喝杯咖啡"
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
            case 0:
                let supportAlertTitle = MobClick.getConfigParams("supportAlertTitle") ?? "支付宝帐号"
                let supportAlertMessage = MobClick.getConfigParams("supportAlertMessage") ?? "yoncise@qq.com"
                let alert = UIAlertController(title: supportAlertTitle, message: supportAlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "好", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                break
            default:
                break
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("more")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("more")
    }

}
