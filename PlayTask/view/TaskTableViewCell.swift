//
//  TaskTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 10/15/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    var task: Task! {
        didSet {
            self.titleLabel.text = self.task.title
            self.scoreLabel.text = "+\(self.task.score)"
            if self.task.loop == 0 {
                self.loopLabel.text = "\(self.task.getCompletedTimes())/∞"
            } else {
                self.loopLabel.text = "\(self.task.getCompletedTimes())/\(self.task.loop)"
            }
            self.completionSwitch.setOn(self.task.isDone(), animated: false)
        }
    }
    
    weak var scoreBarButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var completionSwitch: UISwitch!
    @IBOutlet weak var loopLabel: UILabel!
    
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
        if self.task.isDone() || !sender.on {
            let task = self.task
            self.task = task
            return
        }
        UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.alpha = 0
            }, completion: { _ in
                let task = self.task
                self.task = task
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.alpha = 1

                    }, completion: nil)
        })
    }

}
