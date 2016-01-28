//
//  DungeonTaskTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/15/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class DungeonTaskTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainStatusLabel: UILabel!
    @IBOutlet weak var subStatusButton: UIButton!
    @IBOutlet weak var badgeView: UIView!
    var dungeon: Dungeon! {
        didSet {
            self.update()
        }
    }
    
    weak var timer: NSTimer?
    
    func update() {
        self.badgeView.hidden = Util.currentUser.badge.getCountByDungeonId(self.dungeon.id) == 0
        
        self.titleLabel.text = self.dungeon.title
        self.subStatusButton.enabled = false
        self.subStatusButton.hidden = false
        switch self.dungeon.status {
        case .Joined:
            let now = NSDate()
            switch now.compare(self.dungeon.startTime) {
            case .OrderedAscending:
                self.mainStatusLabel.text = "副本重置"
                
                timer?.invalidate()
                timer = NSTimer.loop(1, handler: { (timer) -> Void in
                    let countDown = self.dungeon.startTime.differenceFrom(NSDate(), unit: [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second])
                    if countDown.second < 0 {
                        timer.invalidate()
                        self.update()
                        return
                    }
                    UIView.performWithoutAnimation({ () -> Void in
                        self.subStatusButton.setTitle(String(format: "%d:%02d:%02d", countDown.hour, countDown.minute, countDown.second), forState: UIControlState.Disabled)
                        self.subStatusButton.layoutIfNeeded()
                    })
                })
            case .OrderedDescending:
                switch now.compare(self.dungeon.finishTime) {
                case .OrderedAscending:
                    self.mainStatusLabel.text = "副本开启"
                    timer?.invalidate()
                    timer = NSTimer.loop(1, handler: { (timer) -> Void in
                        let countDown = self.dungeon.finishTime.differenceFrom(NSDate(), unit: [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second])
                        if countDown.second < 0 {
                            timer.invalidate()
                            self.update()
                            return
                        }
                        UIView.performWithoutAnimation({ () -> Void in
                            self.subStatusButton.setTitle(String(format: "%d:%02d:%02d", countDown.hour, countDown.minute, countDown.second), forState: UIControlState.Disabled)
                            self.subStatusButton.layoutIfNeeded()
                        })
                    })
                    
                default:
                    self.mainStatusLabel.text = "待审核"
                    self.subStatusButton.hidden = true
                    break
                }
            default:
                break
            }
            break
        case .Failed:
            self.mainStatusLabel.text = "副本失败"
            self.subStatusButton.enabled = true
            self.subStatusButton.setTitle("申诉", forState: UIControlState.Normal)
            break
        case .SettlingPledge:
            self.mainStatusLabel.text = "副本成功"
            self.subStatusButton.setTitle("押金返还中", forState: UIControlState.Disabled)
            break
        case .SettlingReward:
            self.mainStatusLabel.text = "结算中"
            self.subStatusButton.setTitle("奖励发放中", forState: UIControlState.Disabled)
        case .Success:
            self.mainStatusLabel.text = "副本成功"
            self.subStatusButton.enabled = true
            self.subStatusButton.setTitle("详情", forState: UIControlState.Normal)
            break
        default:
            break
        }
    }

}
