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
            self.completionSwitch.setOn(self.task.isDone(), animated: false)
        }
    }
    
    weak var scoreBarButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var completionSwitch: UISwitch!
    
    @IBAction func toggle(sender: UISwitch) {
        var score = Int(self.scoreBarButton.title!)!
        self.task.setDone(sender.on)
        UIView.performWithoutAnimation {
            self.scoreBarButton.title = "\(score)"
        }
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        standardUserDefaults.setInteger(Int(self.scoreBarButton.title!)!, forKey: "score")
        standardUserDefaults.synchronize()
    }

}
