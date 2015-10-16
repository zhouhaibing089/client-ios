//
//  TaskTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import SQLite

class TaskTableViewCell: UITableViewCell {
    
    var task: Task! {
        didSet {
            self.titleLabel.text = self.task.title
            self.scoreLabel.text = "+\(self.task.score)"
            if let history = self.getHistory() {
                self.completionSwitch.setOn(!history.deleted, animated: false)
            } else {
                self.completionSwitch.setOn(false, animated: false)
            }
        }
    }
    
    weak var scoreBarButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var completionSwitch: UISwitch!
    
    @IBAction func toggle(sender: UISwitch) {
        var score = Int(self.scoreBarButton.title!)!
        if let history = self.getHistory() {
            history.deleted = !history.deleted
            if !history.deleted {
                score += Int(self.task.score)
                history.completionTime = NSDate()
            } else {
                score -= Int(self.task.score)
            }
            history.update()
        } else {
            let history = TaskHistory(task: self.task, completionTime: NSDate(), deleted: false)
            score += Int(self.task.score)
            history.save()
        }
        UIView.performWithoutAnimation {
            self.scoreBarButton.title = "\(score)"
        }
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        standardUserDefaults.setInteger(Int(self.scoreBarButton.title!)!, forKey: "score")
        standardUserDefaults.synchronize()
    }
    
    func getHistory() -> TaskHistory? {
        let now = NSDate()
        if let row = Util.db.pluck(TaskHistory.SQLite.histories.filter(
            TaskHistory.SQLite.taskId == self.task.id!
        ).filter(
            TaskHistory.SQLite.completionTime >= Int64(now.beginOfDay().timeIntervalSince1970)
        ).filter(
            TaskHistory.SQLite.completionTime <= Int64(now.endOfDay().timeIntervalSince1970)
        )) {
            let h = TaskHistory(task: self.task, completionTime: NSDate(timeIntervalSince1970: Double(row[TaskHistory.SQLite.completionTime])), deleted: row[TaskHistory.SQLite.deleted])
            h.id = row[TaskHistory.SQLite.id]
            return h
        } else {
            return nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
