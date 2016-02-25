//
//  TaskAlarmRepeatViewController.swift
//  PlayTask
//
//  Created by Yoncise on 2/25/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class TaskAlarmRepeatViewController: UITableViewController {
    
    var tmpAlarm: TaskAlarm!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tmpAlarm.setDay(indexPath.row, on: !self.tmpAlarm.getDay(indexPath.row))
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if self.tmpAlarm.getDay(indexPath.row) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }

}
