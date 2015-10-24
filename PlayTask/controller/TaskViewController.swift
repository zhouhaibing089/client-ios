//
//  TaskViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class TaskViewController: UITableViewController {
    
    @IBOutlet weak var scoreBarButton: UIBarButtonItem!
    @IBOutlet weak var taskTypeSegmentControl: UISegmentedControl!
    
    var taskType: TaskType {
        return TaskType(rawValue: self.taskTypeSegmentControl.selectedSegmentIndex)!
    }
    
    var tasks: [Int: [Task]]!

    @IBAction func changeTaskType(sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "任务"
        
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
        
        UIView.performWithoutAnimation {
            let standardUserDefaults = NSUserDefaults.standardUserDefaults()
            let score = standardUserDefaults.integerForKey("score")
            self.scoreBarButton.title = "\(score)"
        }
        MobClick.beginLogPageView("task")

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("task")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.tasks[self.taskType.rawValue]?.count)!
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("task", forIndexPath: indexPath) as! TaskTableViewCell
        
        cell.task = self.tasks[self.taskType.rawValue]![indexPath.row]
        cell.scoreBarButton = self.scoreBarButton

        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

}
