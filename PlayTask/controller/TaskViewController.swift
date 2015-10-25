//
//  TaskViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController, UIToolbarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scoreBarButton: UIBarButtonItem!
    @IBOutlet weak var taskTypeSegmentControl: UISegmentedControl!
    
    var hairline: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var taskType: TaskType {
        return TaskType(rawValue: self.taskTypeSegmentControl.selectedSegmentIndex)!
    }
    
    // [0: doing, 1: done]
    var tasks = [[Int: [Task]](), [Int: [Task]]()]
    
    var showDone = false

    @IBAction func changeTaskType(sender: UISegmentedControl) {
        self.refresh()
    }
    @IBAction func showDone(sender: UIButton) {
        self.showDone = !self.showDone
        UIView.performWithoutAnimation {
            if self.showDone {
                sender.setTitle("显示未完成的任务", forState: UIControlState.Normal)
            } else {
                sender.setTitle("显示已完成的任务", forState: UIControlState.Normal)
            }
            sender.layoutIfNeeded()
        }
        self.refresh()

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
        self.tableView.contentInset = UIEdgeInsets(top: self.toolbar.frame.height, left: 0, bottom: 0, right: 0)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func didBecomeActive(notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
        
        let user = User.getInstance()
        UIView.performWithoutAnimation {
            self.scoreBarButton.title = "\(user.score)"
        }
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
        return (self.getCurrentTasks()[self.taskType.rawValue]?.count)!
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("task", forIndexPath: indexPath) as! TaskTableViewCell
        if self.showDone {
            cell.mode = TaskTableViewCell.Mode.Done
        } else {
            cell.mode = TaskTableViewCell.Mode.Normal
        }
        cell.task = self.getCurrentTasks()[self.taskType.rawValue]![indexPath.row]
        cell.scoreBarButton = self.scoreBarButton

        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nc = segue.destinationViewController as! UINavigationController
            if let ntvc = nc.viewControllers.first as? NewTaskViewController {
                ntvc.onTaskAdded = { task in
                    self.taskTypeSegmentControl.selectedSegmentIndex = task.type
                    self.refresh()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let sortAction  = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "排序") { (action, indexPath) -> Void in
        }
        sortAction.backgroundColor = UIColor.lightGrayColor()
        let deleteAction  = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "删除") { [unowned self] (action, indexPath) -> Void in
            var currentTasks = self.getCurrentTasks()
            let task = currentTasks[self.taskType.rawValue]![indexPath.row]
            task.delete()
            currentTasks[self.taskType.rawValue]?.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
        }
        return [deleteAction, sortAction]
    }
    
    func getCurrentTasks() -> [Int: [Task]] {
        if self.showDone {
            return self.tasks[1]
        }
        return self.tasks[0]
    }

    func refresh() {
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
        self.tableView.reloadData()
    }
}
