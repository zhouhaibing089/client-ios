//
//  NewTaskViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import CRToast

class NewTaskViewController: UITableViewController {

    @IBOutlet weak var taskTitleTextField: UITextField!
    
    @IBOutlet weak var taskScoreTextField: UITextField!
    
    @IBOutlet weak var taskTypeSegmentControl: UISegmentedControl!
    
    var onTaskAdded: ((Task) -> Void)?
    
    @IBAction func addTask(sender: UIBarButtonItem) {
        let taskTitle = taskTitleTextField.text
        let taskScore = taskScoreTextField.text
        let taskType = taskTypeSegmentControl.selectedSegmentIndex == 0 ? TaskType.EveryDay : TaskType.EveryWeek
        if taskTitle == "" {
            CRToastManager.showNotificationWithMessage("请输入标题", completionBlock: nil)
            return
        }
        if taskScore == "" {
            CRToastManager.showNotificationWithMessage("请输入成就点数", completionBlock: nil)
            return
        }
        let task = Task(title: taskTitle!, score: Int64(taskScore!)!, type: taskType, deleted: false)
        task.save()
        self.onTaskAdded?(task)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
