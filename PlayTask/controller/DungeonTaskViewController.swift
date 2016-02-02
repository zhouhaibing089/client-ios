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
import JSBadgeView

class DungeonTaskViewController: TaskViewController {
    enum Mode {
        case Task
        case Dungeon
    }
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    var mode = Mode.Task
    
    var dungeons = [[Dungeon]]()
    var badgeView: JSBadgeView!
    
    var previousSelectedSegment = -1
    var currentSelectedSegment = 0
    
    var refreshControl: UIRefreshControl!
    var refreshTableViewController: UITableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.badgeView = JSBadgeView(parentView: self.taskTypeSegmentControl.superview!, alignment: JSBadgeViewAlignment.TopRight)
        self.badgeView.badgePositionAdjustment = CGPoint(x: -12, y: 8)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBadge:", name: Config.Notification.BADGE, object: nil)
        
        // pull to refresh
        self.refreshTableViewController = UITableViewController()
        self.refreshTableViewController.tableView = self.tableView
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func updateBadge(notification: NSNotification) {
        let count = Util.loggedUser?.badge.getDungeonsCount() ?? 0
        if count > 0 {
            self.navigationController?.tabBarItem.badgeValue = String(count)
            self.badgeView.badgeText = String(count)
        } else {
            self.navigationController?.tabBarItem.badgeValue = nil
            self.badgeView.badgeText = nil
        }
    }
    
    override func changeTaskType(sender: UISegmentedControl) {
        // record previour select segment index
        self.previousSelectedSegment = self.currentSelectedSegment
        self.currentSelectedSegment = sender.selectedSegmentIndex
        if sender.selectedSegmentIndex == 3 {
            self.mode = Mode.Dungeon
            self.tableView.allowsSelection = true
            self.tableView.hidden = false
            // enable refresh control
            self.refreshTableViewController.refreshControl = self.refreshControl
            if Util.loggedUser == nil {
                // not loged in
                self.performSegueWithIdentifier("login@Main", sender: nil)
                return
            }
            self.refreshControl.beginRefreshing()
            self.refresh(self.refreshControl)
        } else {
            self.refreshTableViewController.refreshControl = nil
            self.tableView.allowsSelection = false
            self.mode = Mode.Task
        }
        super.changeTaskType(sender)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.mode == Mode.Task {
            return super.numberOfSectionsInTableView(tableView)
        }
        return self.dungeons.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.mode == Mode.Task {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        return self.self.dungeons[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.mode == Mode.Task {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("dungeon") as! DungeonTaskTableViewCell
        cell.dungeon = self.dungeons[indexPath.section][indexPath.row]
        cell.layoutIfNeeded() // for iOS 8 UILabel to be right
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
        self.performSegueWithIdentifier("index@Dungeon", sender: self.dungeons[indexPath.section][indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        if self.mode == Mode.Task {
            return refreshControl.endRefreshing()
        }
        if Util.loggedUser == nil {
            // not logged in, switch to first segment
            self.taskTypeSegmentControl.selectedSegmentIndex = 0
            self.changeTaskType(self.taskTypeSegmentControl)
            return
        }
        var tmp = [Dungeon]()
        API.getJoinedDungeons(Util.currentUser).subscribe { event in
            switch event {
            case .Completed:
                self.dungeons = [tmp]
                self.tableView.reloadData()
                refreshControl.endRefreshing()
                break
            case .Error(let e):
                refreshControl.endRefreshing()
                break
            case .Next(let d):
                tmp.append(d)
                break
            }
        }
    }
    
    func load() {
        if self.loadIndicator.isAnimating() || self.refreshControl.refreshing {
            return
        }
        if let before = self.dungeons.last?.last?.createdTime {
            self.loadIndicator.startAnimating()
            var tmp = [Dungeon]()
            API.getJoinedDungeons(Util.currentUser, before: before).subscribe { event in
                switch event {
                case .Completed:
                    self.dungeons.append(tmp)
                    self.tableView.reloadData()
                    self.loadIndicator.stopAnimating()
                    break
                case .Error(let e):
                    self.loadIndicator.stopAnimating()
                    break
                case .Next(let d):
                    tmp.append(d)
                    break
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.mode == Mode.Task {
            return
        }
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
        if offset > 0 && maxOffset - offset < 44 {
            // scroll down and reached bottom
            self.load()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.mode == Mode.Task {
            return super.prepareForSegue(segue, sender: sender)
        }
        if let segue = segue as? YNSegue {
            if segue.identifier == "index@Dungeon" {
                if let dvc = segue.instantiated as? DungeonViewController {
                    dvc.dungeon = sender as! Dungeon
                }
            } else if segue.identifier == "login@Main" {
                let navigationController = segue.instantiated as! UINavigationController
                if let lvc = navigationController.viewControllers.first as? LoginViewController {
                    lvc.onResult = { logged in
                        if !logged {
                            // canceled log in, swith to previous segment
                            self.taskTypeSegmentControl.selectedSegmentIndex = self.previousSelectedSegment
                            self.changeTaskType(self.taskTypeSegmentControl)
                        }
                    }
                }
            }
        }
    }
}
