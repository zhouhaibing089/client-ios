//
//  WalletViewController.swift
//  PlayTask
//
//  Created by Yoncise on 4/28/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class WalletViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.row == 0 {
            if let user = Util.loggedUser {
                cell.detailTextLabel?.text = String(format: "%d.%d%d", user.balance / 100, user.balance % 100 / 10, user.balance % 10)
            } else {
                cell.detailTextLabel?.text = "0.00"
            }
        }
        return cell
    }

}
