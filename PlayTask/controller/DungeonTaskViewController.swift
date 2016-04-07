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
import CRToast

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
            self.tableView.hidden = false
            // enable refresh control
            self.refreshTableViewController.refreshControl = self.refreshControl
            if Util.loggedUser == nil {
                // not loged in
                self.performSegueWithIdentifier("login@Main", sender: nil)
                return
            }
            self.refresh()
        } else {
            self.refreshTableViewController.refreshControl = nil
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
        cell.onSubStatusButtonClicked = { [unowned self] dungeon in
            if dungeon.status == .Failed {
            }
            switch dungeon.status {
            case .Failed:
                self.performSegueWithIdentifier("complain", sender: dungeon)
                break
            case .Success:
                let alert = UIAlertController(title: "详情", message: dungeon.report, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                break
            default:
                break
            }
        }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.mode == Mode.Task {
            return super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
        self.performSegueWithIdentifier("index@Dungeon", sender: self.dungeons[indexPath.section][indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.mode == Mode.Task {
            return super.prepareForSegue(segue, sender: sender)
        }
        if segue.identifier == "complain" {
            if let cvc = segue.destinationViewController as? ComplainViewController {
                cvc.dungeon = sender as! Dungeon
            }
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
    
    override func showMenu(sender: UIBarButtonItem) {
        if self.mode == Mode.Task {
            return super.showMenu(sender)
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "新建任务", style: UIAlertActionStyle.Default, handler: { _ in
            self.performSegueWithIdentifier("new", sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "加入副本", style: UIAlertActionStyle.Default, handler: { _ in
            if Util.loggedUser != nil {
                self.performSegueWithIdentifier("dungeon", sender: nil)
            } else {
                self.performSegueWithIdentifier("login@Main", sender: nil)
            }

        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    // MARK: - refresh load update
    override func refresh() {
        if self.mode == Mode.Task {
            return super.refresh()
        }
        self.loadIndicator.startAnimating()
        self.refresh(self.refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        // Make ui response as quick as possible
        self.update()
        if self.mode == Mode.Task {
            refreshControl.endRefreshing()
            return
        }
        if Util.loggedUser == nil {
            self.loadIndicator.stopAnimating()
            // not logged in, switch to first segment
            self.taskTypeSegmentControl.selectedSegmentIndex = 0
            self.changeTaskType(self.taskTypeSegmentControl)
            return
        }
        var tmp = [Dungeon]()
        // reload empty dataset upon switch task type
        self.tableView.reloadEmptyDataSet()
        _ = API.getJoinedDungeons(Util.currentUser, closed: self.showDone).subscribe { event in
            switch event {
            case .Completed:
                self.dungeons = [tmp]
                self.update()
                refreshControl.endRefreshing()
                self.loadIndicator.stopAnimating()
                break
            case .Error(let e):
                if let error = e as? APIError {
                    switch error {
                    case .Custom(_, let info, _):
                        CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                        break
                    default:
                        break
                    }
                }
                self.loadIndicator.stopAnimating()
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
        if self.dungeons.last?.count < Config.LOAD_THRESHOLD {
            return
        }
        
        if let before = self.dungeons.last?.last?.createdTime {
            self.loadIndicator.startAnimating()
            var tmp = [Dungeon]()
            _ = API.getJoinedDungeons(Util.currentUser, closed: self.showDone, before: before).subscribe { event in
                switch event {
                case .Completed:
                    self.dungeons.append(tmp)
                    self.update()
                    self.loadIndicator.stopAnimating()
                    break
                case .Error(_):
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

    // MARK: - empty dataset
    override func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if self.mode == Mode.Task {
            return super.titleForEmptyDataSet(scrollView)
        }
        self.tableView.tableFooterView = UIView()
        if self.showDone {
            return NSAttributedString(string: "无完结副本")
        } else {
            return NSAttributedString(string: "无副本")
        }
    }
    
    override func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if self.mode == Mode.Task {
            return super.descriptionForEmptyDataSet(scrollView)
        }
        return NSAttributedString(string: "点击右上角的 \"+\" 加入副本")
    }
}
