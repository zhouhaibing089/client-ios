//
//  MemorialCommentView.swift
//  PlayTask
//
//  Created by Yoncise on 1/27/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift

class MemorialCommentView: XibView {
    
    override var xibName: String {
        return "MemorialComment"
    }
    
    var onClicked: ((MemorialComment) -> Void)?
    
    let commentTemplate = "<strong>%@</strong>：%@"
    let binaryCommentTemplate = "<strong>%@</strong> 回复 <strong>%@</strong>：%@"
    
    @IBAction func clicked(sender: UITapGestureRecognizer) {
        self.contentView.backgroundColor = UIColor.lightGrayColor()

        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.contentView.backgroundColor = UIColor.clearColor()
            }, completion: nil)
        self.onClicked?(self.comment)
    }
    var comment: MemorialComment! {
        didSet {
            if let toUserId = self.comment.toUserId {
                self.contentLabel.attributedText = NSAttributedString(html:
                    String(format: binaryCommentTemplate, self.comment.fromNickname,
                        self.comment.toNickname!, self.comment.content))
            } else {
                self.contentLabel.attributedText = NSAttributedString(html:
                    String(format: commentTemplate, self.comment.fromNickname,
                        self.comment.content))
            }
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel!

}
