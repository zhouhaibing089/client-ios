//
//  MemorialCommentDetailTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class MemorialCommentDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var comment: MemorialComment! {
        didSet {
            self.avatarImageView.af_setImageWithURL(NSURL(string: self.comment.fromAvatarUrl)!)
            self.nicknameLabel.text = self.comment.fromNickname
            self.contentLabel.text = self.comment.content
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
