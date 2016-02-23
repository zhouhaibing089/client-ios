//
//  DungeonNotificationTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class DungeonNotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var briefWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var briefLabel: UILabel!
    @IBOutlet weak var briefImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    var notification: DungeonNotification! {
        didSet {
            self.avatarImageView.af_setImageWithURL(NSURL(string: self.notification.avatarUrl)!)
            self.nicknameLabel.text = self.notification.nickname
            if let content = self.notification.content {
                self.contentLabel.text = self.notification.content
            } else if let comment = self.notification.memorialComment {
                let fontSize = self.contentLabel.font.pointSize
                let normal = [
                    NSFontAttributeName: self.contentLabel.font
                ]
                let bold = [
                    NSFontAttributeName: UIFont(descriptor: self.contentLabel.font.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold), size: fontSize)
                ]
                if let toUserId = comment.toUserId {
                    let s = NSMutableAttributedString()
                    let tn = NSAttributedString(string: comment.toNickname!, attributes: bold)
                    s.appendAttributedString(NSAttributedString(string: "回复 ", attributes: normal))
                    s.appendAttributedString(tn)
                    s.appendAttributedString(NSAttributedString(string: ": \(comment.content)", attributes: normal))
                    self.contentLabel.attributedText = s
                } else {
                    self.contentLabel.attributedText = NSAttributedString(string: comment.content)
                }
            }
            self.timeLabel.text = self.notification.createdTime.toReadable()
            if let memorial = self.notification.memorial {
                if let image = memorial.image {
                    self.briefImageView.hidden = false
                    self.briefLabel.hidden = true
                    self.briefImageView.af_setImageWithURL(NSURL(string: image.getUrlForMaxWidth(64, maxHeight: 64))!)
                } else {
                    self.briefImageView.hidden = true
                    self.briefLabel.hidden = false
                    self.briefLabel.text = memorial.content
                }
                self.briefWidthConstraint.constant = 64
            } else {
                self.briefWidthConstraint.constant = 0
            }

            
        }
    }

}
