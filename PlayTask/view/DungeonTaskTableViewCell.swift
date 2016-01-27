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
            self.badgeView.hidden = Util.currentUser.badge.getCountByDungeonId(self.dungeon.id) == 0
            
            self.titleLabel.text = self.dungeon.title
            self.subStatusButton.enabled = false
            switch self.dungeon.status {
            case .Joined:
                let now = NSDate()
                switch now.compare(self.dungeon.startTime) {
                case .OrderedAscending:
                    self.mainStatusLabel.text = "副本重置"
                    NSTimer.loop(1, handler: { (timer) -> Void in
                        let countDown = self.dungeon.startTime.differenceFrom(NSDate(), unit: [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second])
                        if countDown.second < 0 {
                            timer.invalidate()
                            // TODO: update
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
                        NSTimer.loop(1, handler: { (timer) -> Void in
                            let countDown = self.dungeon.finishTime.differenceFrom(NSDate(), unit: [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second])
                            if countDown.second < 0 {
                                timer.invalidate()
                                // TODO: refresh
                                return
                            }
                            UIView.performWithoutAnimation({ () -> Void in
                                self.subStatusButton.setTitle(String(format: "%d:%02d:%02d", countDown.hour, countDown.minute, countDown.second), forState: UIControlState.Disabled)
                                self.subStatusButton.layoutIfNeeded()
                            })
                        })
                        
                    default:
                        /// TODO: refresh
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
            case .Appealing:
                self.mainStatusLabel.text = "副本失败"
                self.subStatusButton.setTitle("申诉中", forState: UIControlState.Normal)
                break
            case .Settling:
                self.mainStatusLabel.text = "押金返还中"
                self.subStatusButton.hidden = true
                break
            case .Success:
                self.mainStatusLabel.text = "副本成功"
                break
            default:
                break
            }
        }
    }

}
