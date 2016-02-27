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
            if let alarm = self.task.getAlarm() {
                self.loopLabel.text? += String(format: ", %02d:%02d", alarm.hour, alarm.minute)
            }
            switch self.mode {
            case .Normal:
                if self.task.isDone() {
                    self.completeButton.setImage(UIImage(named: "on"), forState: UIControlState.Normal)
                } else {
                    self.completeButton.setImage(UIImage(named: "off"), forState: UIControlState.Normal)
                }
                self.titleLabel.textColor = UIColor.blackColor()
                break
            case .Done:
                if completedTimes == 0 {
                    self.completeButton.setImage(UIImage(named: "off"), forState: UIControlState.Normal)
                    self.titleLabel.textColor = UIColor.blackColor()
                } else {
                    self.titleLabel.textColor = UIColor.lightGrayColor()
                    self.completeButton.setImage(UIImage(named: "on"), forState: UIControlState.Normal)
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
        
    weak var userScoreLabel: UILabel!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var loopLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    @IBAction func pin(sender: UIButton) {
        self.task.update(["pinned": !self.task.pinned])
        let task = self.task
        self.task = task
    }
    
    @IBAction func toggle(sender: UIButton) {
        let user = Util.currentUser
        let completedTimesBefore = self.task.getCompletedTimes()
        if self.task.isDone() { // 任务已完成
            user.update(["score": user.score - self.task.score])
            self.task.setDone(false)
            self.completeButton.setImage(UIImage(named: "off"), forState: UIControlState.Normal)
        } else {
            switch self.mode {
            case .Normal:
                // 正常模式下
                user.update(["score": user.score + self.task.score])
                self.task.setDone(true)
                self.completeButton.setImage(UIImage(named: "on"), forState: UIControlState.Normal)
                break
            case .Done:
                // 完成模式下
                if completedTimesBefore > 0 { // 完成过一次
                    user.update(["score": user.score - self.task.score])
                    self.task.setDone(false)
                    self.completeButton.setImage(UIImage(named: "off"), forState: UIControlState.Normal)
                } else { // 一次都没完成过
                    user.update(["score": user.score + self.task.score])
                    self.task.setDone(true)
                    self.completeButton.setImage(UIImage(named: "on"), forState: UIControlState.Normal)
                }
                break
            }
        }
        
        let updateWithAnimation: (Bool) -> Void = { animated in
            if animated {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    sender.alpha = 0
                    }, completion: { _ in
                        let task = self.task
                        self.task = task
                        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            sender.alpha = 1
                            }, completion: nil)
                })
            } else {
                let task = self.task
                self.task = task
            }
        }
        let completedTimesAfter = self.task.getCompletedTimes()
        switch self.mode {
        case .Normal:
            let animated = !(completedTimesAfter == self.task.loop || completedTimesAfter == 0 || (completedTimesBefore == self.task.loop && self.task.loop != 0))
            updateWithAnimation(animated)
            break
        case .Done:
            let animated = !(completedTimesAfter == self.task.loop || completedTimesAfter == 0 || completedTimesBefore == 0)
            updateWithAnimation(animated)
            break
        }
    
        self.userScoreLabel.text = "\(user.score)"
        if user.score >= 0 {
            self.userScoreLabel.textColor = UIColor.blackColor()
        } else {
            self.userScoreLabel.textColor = UIColor.redColor()
        }
    }

}
