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
    
    var tasks: [Int: [Task]]!

    @IBAction func changeTaskType(sender: UISegmentedControl) {
        self.tableView.reloadData()
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
        
        self.tasks = Task.getTasks()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func didBecomeActive(notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        
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
        return (self.tasks[self.taskType.rawValue]?.count)!
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("task", forIndexPath: indexPath) as! TaskTableViewCell
        
        cell.task = self.tasks[self.taskType.rawValue]![indexPath.row]
        cell.scoreBarButton = self.scoreBarButton

        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let task = self.tasks[self.taskType.rawValue]![indexPath.row]
            task.delete()
            self.tasks[self.taskType.rawValue]?.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nc = segue.destinationViewController as! UINavigationController
            if let ntvc = nc.viewControllers.first as? NewTaskViewController {
                ntvc.onTaskAdded = { task in
                    self.tasks[task.type]?.append(task)
                    self.tasks[task.type] = self.tasks[task.type]?.sort {
                        return $0.score < $1.score
                    }
                    self.taskTypeSegmentControl.selectedSegmentIndex = task.type
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

}
