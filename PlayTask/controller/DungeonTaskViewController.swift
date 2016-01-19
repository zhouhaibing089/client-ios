//
//  DungeonTaskViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/15/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import UIKit

class DungeonTaskViewController: TaskViewController {
    enum Mode {
        case Task
        case Dungeon
    }
    
    var mode = Mode.Task
    
    var dungeons = [Dungeon]()
    
    override func changeTaskType(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 3 {
            self.mode = Mode.Dungeon
            self.tableView.allowsSelection = true
        } else {
            self.tableView.allowsSelection = false
            self.mode = Mode.Task
        }
        super.changeTaskType(sender)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.mode == Mode.Task {
            return super.numberOfSectionsInTableView(tableView)
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.mode == Mode.Task {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        return self.self.dungeons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.mode == Mode.Task {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("dungeon") as! DungeonTaskTableViewCell
        cell.dungeon = self.dungeons[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if self.mode == Mode.Task {
            return super.tableView(tableView, editActionsForRowAtIndexPath: indexPath)
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.mode == Mode.Task {
            return super.tableView(tableView, editingStyleForRowAtIndexPath: indexPath)
        }
        return UITableViewCellEditingStyle.None
    }
    
    override func showMenu(sender: UIBarButtonItem) {
        if self.mode == Mode.Task {
            return super.showMenu(sender)
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "新建任务", style: UIAlertActionStyle.Default, handler: { _ in
            self.performSegueWithIdentifier("new", sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "加入副本", style: UIAlertActionStyle.Default, handler: { _ in
            self.performSegueWithIdentifier("dungeon", sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func refresh() {
        if self.mode == Mode.Task {
            return super.refresh()
        }
        self.dungeons.removeAll()
        API.getJoinedDungeons(Util.loggedUser!).subscribe { event in
            switch event {
            case .Completed:
                self.tableView.reloadData()
                break
            case .Error(let e):
                break
            case .Next(let d):
                self.dungeons.append(d)
                break
            }
        }
    }
}
