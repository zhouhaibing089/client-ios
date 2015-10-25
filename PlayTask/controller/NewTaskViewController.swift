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
    
    @IBOutlet weak var taskLoopTextField: UITextField!
    var onTaskAdded: ((Task) -> Void)?
    
    @IBAction func addTask(sender: UIBarButtonItem) {
        let taskTitle = taskTitleTextField.text
        let taskScore = taskScoreTextField.text
        var taskLoop = Int(taskLoopTextField.text!) ?? 1
        let taskType = TaskType(rawValue: taskTypeSegmentControl.selectedSegmentIndex)!
        if taskTitle == "" {
            CRToastManager.showNotificationWithMessage("请输入标题", completionBlock: nil)
            return
        }
        if taskScore == "" {
            CRToastManager.showNotificationWithMessage("请输入成就点数", completionBlock: nil)
            return
        }
        switch taskType {
        case .Daily, .Weekly:
            taskLoop = taskLoop == 0 ? 1 : taskLoop
            break
        default:
            break
        }
        let task = Task(title: taskTitle!, score: Int(taskScore!)!, type: taskType, loop: taskLoop)
        task.save()
        self.onTaskAdded?(task)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("new_task")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("new_task")
    }
}
