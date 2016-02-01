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
    
    let commentTemplate = "<span style=\"font-family: '%@'; font-size: %fpx\"><strong>%@</strong>: %@</span>"
    let binaryCommentTemplate = "<span style=\"font-family: '%@'; font-size: %fpx\"><strong>%@</strong> 回复 <strong>%@</strong>: %@</span>"
    
    @IBAction func clicked(sender: UITapGestureRecognizer) {
        self.contentView.backgroundColor = UIColor.lightGrayColor()

        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.contentView.backgroundColor = UIColor.clearColor()
            }, completion: nil)
        self.onClicked?(self.comment)
    }
    var comment: MemorialComment! {
        didSet {
            let fontName = self.contentLabel.font.fontName
            let fontSize = self.contentLabel.font.pointSize
            if let toUserId = self.comment.toUserId {
                self.contentLabel.attributedText = NSAttributedString(html:
                    String(format: binaryCommentTemplate, fontName, fontSize, comment.fromNickname,
                        self.comment.toNickname!, self.comment.content))
            } else {
                self.contentLabel.attributedText = NSAttributedString(html:
                    String(format: commentTemplate, fontName, fontSize, self.comment.fromNickname,
                        self.comment.content))
            }
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel!

}
