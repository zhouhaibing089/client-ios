//
//  TaskAlarmLabelViewController.swift
//  PlayTask
//
//  Created by Yoncise on 2/25/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class TaskAlarmLabelViewController: UITableViewController {
    
    var tmpAlarm: TaskAlarm!
    
    @IBOutlet var labelTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTextField.text = self.tmpAlarm.label
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.labelTextField.becomeFirstResponder()
    }

    @IBAction func save(sender: UIBarButtonItem) {
        self.tmpAlarm.label = self.labelTextField.text!
        self.navigationController?.popViewControllerAnimated(true)
    }
}
