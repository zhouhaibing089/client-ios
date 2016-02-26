//
//  TaskAlarmViewController.swift
//  PlayTask
//
//  Created by Yoncise on 2/25/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class TaskAlarmViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var task: Task!
    var taskAlarm: TaskAlarm?
    
    // used to store data temporarily
    var tmpAlarm: TaskAlarm!
    
    @IBOutlet var soundSwitch: UISwitch!
    
    @IBOutlet var timePicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44
        self.timePicker.dataSource = self
        self.timePicker.delegate = self
        
        self.refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.update()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.min
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let ta = self.taskAlarm {
            if !ta.deleted && ta.getLocalNotification() != nil {
                return 3
            }
        }
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 24 : 60
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.tmpAlarm.hour = row
        } else {
            self.tmpAlarm.minute = row
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                // repeat
                let weekdays = self.tmpAlarm.monday && self.tmpAlarm.tuesday && self.tmpAlarm.wednesday && self.tmpAlarm.thursday && self.tmpAlarm.friday
                let everyday = weekdays && self.tmpAlarm.sunday && self.tmpAlarm.saturday
                if everyday {
                    cell.detailTextLabel?.text = "每天"
                } else if weekdays && !self.tmpAlarm.sunday && !self.tmpAlarm.saturday {
                    cell.detailTextLabel?.text = "工作日"
                } else {
                    var detail = ""
                    if self.tmpAlarm.sunday {
                        detail += " 周日"
                    }
                    if self.tmpAlarm.monday {
                        detail += " 周一"
                    }
                    if self.tmpAlarm.tuesday {
                        detail += " 周二"
                    }
                    if self.tmpAlarm.wednesday {
                        detail += " 周三"
                    }
                    if self.tmpAlarm.thursday {
                        detail += " 周四"
                    }
                    if self.tmpAlarm.friday {
                        detail += " 周五"
                    }
                    if self.tmpAlarm.saturday {
                        detail += " 周六"
                    }
                    if detail == "" {
                        cell.detailTextLabel?.text = "从不"
                    } else {
                        cell.detailTextLabel?.text = detail
                    }
                }
            }
            if indexPath.row == 1 {
                cell.detailTextLabel?.text = self.tmpAlarm.label
            }
        }
        return cell
    }
    
    // MARK: - refresh
    func refresh() {
        self.taskAlarm = TaskAlarm.getAlarmForTask(self.task)
        self.tmpAlarm = TaskAlarm()
        
        if self.taskAlarm != nil {
            let alarm = self.taskAlarm!
            
            self.tmpAlarm.task = alarm.task
            
            self.tmpAlarm.hour = alarm.hour
            self.tmpAlarm.minute = alarm.minute
            
            self.tmpAlarm.sunday = alarm.sunday
            self.tmpAlarm.monday = alarm.monday
            self.tmpAlarm.tuesday = alarm.tuesday
            self.tmpAlarm.wednesday = alarm.wednesday
            self.tmpAlarm.thursday = alarm.thursday
            self.tmpAlarm.friday = alarm.friday
            self.tmpAlarm.saturday = alarm.saturday
            
            self.tmpAlarm.sound = alarm.sound
            self.tmpAlarm.label = alarm.label
            
        } else {
            self.tmpAlarm = TaskAlarm()
            self.tmpAlarm.task = self.task
            self.tmpAlarm.label = self.task.title
            let nowComponents = NSDate().getComponents()
            self.tmpAlarm.hour = nowComponents.hour
            self.tmpAlarm.minute = nowComponents.minute
            if self.task.type == TaskType.Daily.rawValue {
                // daily task repeat everyday by default
                self.tmpAlarm.sunday = true
                self.tmpAlarm.monday = true
                self.tmpAlarm.tuesday = true
                self.tmpAlarm.wednesday = true
                self.tmpAlarm.thursday = true
                self.tmpAlarm.friday = true
                self.tmpAlarm.saturday = true
            }
        }
        
        self.update()
    }
    
    func update() {
        self.timePicker.selectRow(self.tmpAlarm.hour, inComponent: 0, animated: false)
        self.timePicker.selectRow(self.tmpAlarm.minute, inComponent: 1, animated: false)
        self.soundSwitch.setOn(self.tmpAlarm.sound, animated: false)
        self.tableView.reloadData()
    }

    @IBAction func save(sender: UIBarButtonItem) {
        if self.taskAlarm != nil {
            self.tmpAlarm.id = self.taskAlarm!.id
            self.tmpAlarm.update()
        } else {
            self.tmpAlarm.save()
        }
        // 取消已经 schduled 的 notification
        self.tmpAlarm.cancelLocalNotification()
        self.tmpAlarm.schedule()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func soundChange(sender: UISwitch) {
        self.tmpAlarm.sound = sender.on
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "repeat" {
            if let tarvc = segue.destinationViewController as? TaskAlarmRepeatViewController {
                tarvc.tmpAlarm = self.tmpAlarm
            }
        } else if segue.identifier == "label" {
            if let talvc = segue.destinationViewController as? TaskAlarmLabelViewController {
                talvc.tmpAlarm = self.tmpAlarm
            }
        }
    }
    @IBAction func deleteAlarm(sender: UIButton? = nil) {
        self.taskAlarm?.delete()
        self.tmpAlarm.cancelLocalNotification()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            self.deleteAlarm()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
