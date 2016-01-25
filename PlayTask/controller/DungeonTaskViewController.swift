//
//  DungeonTaskViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/15/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import UIKit
import YNSwift

class DungeonTaskViewController: TaskViewController {
    enum Mode {
        case Task
        case Dungeon
    }
    
    var mode = Mode.Task
    
    var dungeons = [Dungeon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBadge:", name: Config.Notification.BADGE, object: nil)
    }
    
    func updateBadge(notification: NSNotification) {
        let count = Util.loggedUser?.badge.getDungeonsCount() ?? 0
        if count > 0 {
            self.navigationController?.tabBarItem.badgeValue = String(count)
        } else {
            self.navigationController?.tabBarItem.badgeValue = nil
        }
    }
    
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("index@Dungeon", sender: self.dungeons[indexPath.row])
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
        var tmp = [Dungeon]()
        API.getJoinedDungeons(Util.loggedUser!).subscribe { event in
            switch event {
            case .Completed:
                self.dungeons = tmp
                if tmp.count == 0 {
                    self.tableView.hidden = true
                } else {
                    self.tableView.hidden = false
                }
                self.tableView.reloadData()
                break
            case .Error(let e):
                break
            case .Next(let d):
                tmp.append(d)
                break
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.mode == Mode.Task {
            return super.prepareForSegue(segue, sender: sender)
        }
        if segue.identifier == "index@Dungeon" {
            if let segue = segue as? YNSegue {
                if let dvc = segue.instantiated as? DungeonViewController {
                    dvc.dungeon = sender as! Dungeon
                }
            }
        }
    }
}
