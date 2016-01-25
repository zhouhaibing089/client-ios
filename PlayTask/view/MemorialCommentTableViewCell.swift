//
//  MemorialCommentTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/24/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift

class MemorialCommentTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var commentLabel: UILabel!
    
    let commentTemplate = "<strong>%@</strong>：%@"
    let binaryCommentTemplate = "<strong>%@</strong> 回复 <strong>%@</strong>：%@"

    
    var memorialComment: MemorialComment! {
        didSet {
            if let toUserId = self.memorialComment.toUserId {
                self.commentLabel.attributedText = NSAttributedString(html:
                    String(format: binaryCommentTemplate, self.memorialComment.fromNickname,
                    self.memorialComment.toNickname!, self.memorialComment.content))
            } else {
                self.commentLabel.attributedText = NSAttributedString(html:
                    String(format: commentTemplate, self.memorialComment.fromNickname,
                        self.memorialComment.content))
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
