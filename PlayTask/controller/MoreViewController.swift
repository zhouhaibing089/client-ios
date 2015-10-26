//
//  MoreViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {
    
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
