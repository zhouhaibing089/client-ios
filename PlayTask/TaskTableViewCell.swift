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
        let score = Int(self.scoreBarButton.title!)!
        if let history = self.getHistory() {
            history.deleted = !history.deleted
            if !history.deleted {
                self.scoreBarButton.title = "\(score + self.task.score)"
                history.completionTime = NSDate()
            } else {
                self.scoreBarButton.title = "\(score - Int(self.task.score))"
            }
            history.update()
        } else {
            let history = History(id: nil, taskId: self.task.id!, completionTime: NSDate(), deleted: false)
            self.scoreBarButton.title = "\(score + Int(self.task.score))"
            history.save()
        }
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        standardUserDefaults.setInteger(Int(self.scoreBarButton.title!)!, forKey: "score")
        standardUserDefaults.synchronize()
    }
    
    func getHistory() -> History? {
        let now = NSDate()
        if let row = Util.db.pluck(History.SQLite.histories.filter(
            History.SQLite.taskId == self.task.id!
        ).filter(
            History.SQLite.completionTime >= Int64(now.beginOfDay().timeIntervalSince1970)
        ).filter(
            History.SQLite.completionTime <= Int64(now.endOfDay().timeIntervalSince1970)
        )) {
            return History(id: row[History.SQLite.id], taskId: row[History.SQLite.taskId], completionTime: NSDate(timeIntervalSince1970: Double(row[History.SQLite.completionTime])), deleted: row[History.SQLite.deleted])
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
