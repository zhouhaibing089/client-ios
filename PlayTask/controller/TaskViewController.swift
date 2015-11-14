//
//  TaskViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController, UIToolbarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var scoreBarButton: UIBarButtonItem!
    @IBOutlet weak var taskTypeSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var showDoneButton: UIButton! {
        didSet {
            self.showDoneButton.tintColor = UIColor.grayColor()
        }
    }
    var hairline: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var taskType: TaskType {
        return TaskType(rawValue: self.taskTypeSegmentControl.selectedSegmentIndex)!
    }
    
    // [0: doing, 1: done]
    var tasks = [[Int: [Task]](), [Int: [Task]]()]
    
    // 由于 swift 的奇葩语法, 当你做了改变数组的长度的操作时, swift 会 copy 一份, 导致你的操作不会在原对象上生效
    // http://stackoverflow.com/questions/24081009/is-there-a-reason-that-swift-array-assignment-is-inconsistent-neither-a-referen
    var currentTasks: [Task] {
        get {
            if self.showDone {
                return self.tasks[1][self.taskType.rawValue]!
            }
            return self.tasks[0][self.taskType.rawValue]!
        }
    }
    
    var showDone = false

    @IBAction func changeTaskType(sender: UISegmentedControl) {
        self.refresh()
    }
    @IBAction func showDone(sender: UIButton) {
        self.showDone = !self.showDone
        if self.showDone {
            sender.tintColor = self.view.tintColor
        } else {
            sender.tintColor = UIColor.grayColor()
        }
        self.refresh()

    }
    
    @IBAction func endResort(sender: UITapGestureRecognizer) {
        if self.tableView.editing {
            var i = 0
            for t in self.currentTasks {
                t.update(["rank": ++i])
            }
            self.tableView.setEditing(false, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbar.delegate = self
        let navigationBar = self.navigationController!.navigationBar
        for parent in navigationBar.subviews {
            for childView in parent.subviews {
                if let imageView = childView as? UIImageView {
                    if childView.frame.size.width == navigationBar.frame.size.width && childView.frame.size.height <= 1.0  {
                        self.hairline = imageView
                        break
                    }
                }
            }
        }
        
        self.navigationController?.view.backgroundColor = UIColor.whiteColor();
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsets(top: self.toolbar.frame.height + self.toolbar.frame.origin.y, left: 0, bottom: 0, right: 0)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncStatusChanged:", name: Config.Notification.SYNC, object: nil)
    }

    func syncStatusChanged(notification: NSNotification) {
        if Util.appDelegate.syncStatus == SyncStatus.Synced {
            self.refresh()
        }
    }

    func didBecomeActive(notification: NSNotification) {
        self.refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
        
        MobClick.beginLogPageView("task")
        self.hairline.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("task")
        self.hairline.hidden = false
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.currentTasks.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("task", forIndexPath: indexPath) as! TaskTableViewCell
        if self.showDone {
            cell.mode = TaskTableViewCell.Mode.Done
        } else {
            cell.mode = TaskTableViewCell.Mode.Normal
        }
        cell.task = self.currentTasks[indexPath.row]
        cell.scoreBarButton = self.scoreBarButton
        cell.layoutIfNeeded() // for iOS 8 UILabel to be right
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nc = segue.destinationViewController as! UINavigationController
            if let ntvc = nc.viewControllers.first as? NewTaskViewController {
                if let t = sender as? Task { // 编辑模式
                    ntvc.modifiedTask = t
                    ntvc.onTaskAdded = { task in
                        task.update(["rank": t.rank, "pinned": t.pinned])
                        t.delete()
                        self.refresh()
                    }
                } else {
                    ntvc.defaultTaskType = self.taskType
                    ntvc.onTaskAdded = { task in
                        self.taskTypeSegmentControl.selectedSegmentIndex = task.type
                        self.refresh()
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction  = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "编辑") { [unowned self] (action, indexPath) -> Void in
            let t = self.currentTasks[indexPath.row]
            self.performSegueWithIdentifier("new", sender: t)
        }
        editAction.backgroundColor = UIColor.lightGrayColor()
        let deleteAction  = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "删除") { [unowned self] (action, indexPath) -> Void in
            var currentTasks = self.currentTasks
            let task = currentTasks[indexPath.row]
            task.delete()
            if self.showDone {
                self.tasks[1][self.taskType.rawValue]?.removeAtIndex(indexPath.row)
            } else {
                self.tasks[0][self.taskType.rawValue]?.removeAtIndex(indexPath.row)
            }
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        return [deleteAction, editAction]
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        var tasks = self.currentTasks
        let t = tasks[sourceIndexPath.row]
        tasks.removeAtIndex(sourceIndexPath.row)
        tasks.insert(t, atIndex: destinationIndexPath.row)
        
        if self.showDone {
            self.tasks[1][self.taskType.rawValue] = tasks
        } else {
            self.tasks[0][self.taskType.rawValue] = tasks
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.editing {
            return UITableViewCellEditingStyle.None
        } else {
            return UITableViewCellEditingStyle.Delete
        }
    }
    @IBAction func showMenu(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "新建任务", style: UIAlertActionStyle.Default, handler: { _ in
            self.performSegueWithIdentifier("new", sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "排序", style: UIAlertActionStyle.Default, handler: { _ in
            self.tableView.setEditing(false, animated: true)
            self.tableView.setEditing(true, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

    func refresh() {
        let user = Util.currentUser
        UIView.performWithoutAnimation {
            self.scoreBarButton.title = "\(user.score)"
        }
        for (type, tasks) in Task.getTasks() {
            self.tasks[0][type] = [Task]()
            self.tasks[1][type] = [Task]()
            for t in tasks {
                if t.isDone() {
                    self.tasks[1][type]?.append(t)
                } else {
                    self.tasks[0][type]?.append(t)
                    if t.getCompletedTimes() > 0 {
                        self.tasks[1][type]?.append(t)
                    }
                }
            }
        }
        if self.currentTasks.count == 0 {
            self.tableView.hidden = true
            if self.showDone {
                self.tipsLabel.text = MobClick.getConfigParams("taskDoneTips") ?? "已完成的任务"
            } else {
                self.tipsLabel.text = MobClick.getConfigParams("taskUndoneTips") ?? "没有未完成的任务"
            }
        } else {
            self.tableView.hidden = false
        }
        self.tableView.reloadData()
    }
}
