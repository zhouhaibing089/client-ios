//
//  MemorialCommentDetailTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class MemorialCommentTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let dateFormatter = NSDateFormatter()
    
    var comment: MemorialComment! {
        didSet {
            self.avatarImageView.af_setImageWithURL(NSURL(string: self.comment.fromAvatarUrl)!)
            self.nicknameLabel.text = self.comment.fromNickname
            
            if self.comment.toNickname != nil {
                let normal = [
                    NSFontAttributeName: self.contentLabel.font
                ]
                let bold = [
                    NSFontAttributeName: UIFont(descriptor: self.contentLabel.font.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold), size: self.contentLabel.font.pointSize)
                ]
                let a = NSMutableAttributedString()
                a.appendAttributedString(NSAttributedString(string: "回复 ", attributes: normal))
                a.appendAttributedString(NSAttributedString(string: self.comment.toNickname!, attributes: bold))
                a.appendAttributedString(NSAttributedString(string: ": \(self.comment.content)", attributes: normal))
                self.contentLabel.attributedText = a
            } else {
                self.contentLabel.text = self.comment.content
            }
            self.timeLabel.text = self.dateFormatter.stringFromDate(self.comment.createdTime)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
