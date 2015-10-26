//
//  TaskTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    enum Mode {
        case Normal
        case Done
    }
    
    var mode = Mode.Normal
    
    var task: Task! {
        didSet {
            self.titleLabel.text = self.task.title
            self.scoreLabel.text = "+\(self.task.score)"
            let completedTimes = self.task.getCompletedTimes()
            if self.task.loop == 0 {
                self.loopLabel.text = "\(completedTimes)/∞"
            } else {
                self.loopLabel.text = "\(completedTimes)/\(self.task.loop)"
            }
            switch self.mode {
            case .Normal:
                self.completionSwitch.setOn(self.task.isDone(), animated: false)
                self.titleLabel.textColor = UIColor.blackColor()
                break
            case .Done:
                if completedTimes == 0 {
                    self.completionSwitch.setOn(false, animated: false)
                    self.titleLabel.textColor = UIColor.blackColor()
                } else {
                    self.titleLabel.textColor = UIColor.lightGrayColor()
                    self.completionSwitch.setOn(true, animated: false)
                }
                break
            }
            if self.task.pinned {
                self.pinButton.setImage(UIImage(named: "pin_checked"), forState: UIControlState.Normal)
            } else {
                self.pinButton.setImage(UIImage(named: "pin_unchecked"), forState: UIControlState.Normal)
            }
        }
    }
        
    weak var scoreBarButton: UIBarButtonItem!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var completionSwitch: UISwitch!
    @IBOutlet weak var loopLabel: UILabel!
    
    @IBAction func pin(sender: UIButton) {
        self.task.update(["pinned": !self.task.pinned])
        let task = self.task
        self.task = task
    }
    
    @IBAction func toggle(sender: UISwitch) {
        let user = User.getInstance()
        if sender.on {
            user.update(["score": user.score + self.task.score])
        } else {
            user.update(["score": user.score - self.task.score])
        }
        self.task.setDone(sender.on)
        UIView.performWithoutAnimation {
            self.scoreBarButton.title = "\(user.score)"
        }
        let task = self.task
        self.task = task
    }

}
