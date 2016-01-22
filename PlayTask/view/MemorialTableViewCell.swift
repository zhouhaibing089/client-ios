//
//  MemorialTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/22/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift
import AlamofireImage

class MemorialTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nicknameButton: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var reviewStatusLabel: UILabel!
    
    var memorial: Memorial! {
        didSet {
            self.contentLabel.text = self.memorial.content
            self.nicknameButton.setTitle(self.memorial.nickname, forState: UIControlState.Normal)
            self.avatarImageView.af_setImageWithURL(NSURL(string: self.memorial.avatarUrl)!)
            switch self.memorial.status {
            case .Waiting:
                self.reviewStatusLabel.text = "待审核"
                break
            case .Approved:
                self.reviewStatusLabel.text = "审核通过"
                break
            case .Rejected:
                self.reviewStatusLabel.text = "审核未通过：\(self.memorial.reason ?? "")"
                break
            }
        }
    }

}
