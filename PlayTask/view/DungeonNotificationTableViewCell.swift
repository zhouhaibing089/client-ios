//
//  DungeonNotificationTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class DungeonNotificationTableViewCell: UITableViewCell {
    
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
            self.contentLabel.text = self.notification.message
            if let image = self.notification.memorial.image {
                self.briefImageView.hidden = false
                self.briefLabel.hidden = true
                self.briefImageView.af_setImageWithURL(NSURL(string: image.url)!)
            } else {
                self.briefImageView.hidden = true
                self.briefLabel.hidden = false
                self.briefLabel.text = self.notification.memorial.content
            }
            
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
