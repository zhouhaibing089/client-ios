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
            let fontSize = self.contentLabel.font.pointSize
            let normal = [
                NSFontAttributeName: self.contentLabel.font
            ]
            let bold = [
                NSFontAttributeName: UIFont(descriptor: self.contentLabel.font.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold), size: fontSize)
            ]
            if let toUserId = self.comment.toUserId {
                let s = NSMutableAttributedString()
                let fn = NSAttributedString(string: comment.fromNickname, attributes: bold)
                let tn = NSAttributedString(string: comment.fromNickname, attributes: bold)
                s.appendAttributedString(fn)
                s.appendAttributedString(NSAttributedString(string: " 回复 ", attributes: normal))
                s.appendAttributedString(tn)
                s.appendAttributedString(NSAttributedString(string: ": \(self.comment.content)", attributes: normal))
                self.contentLabel.attributedText = s
            } else {
                let s = NSMutableAttributedString()
                let fn = NSAttributedString(string: comment.fromNickname, attributes: bold)
                s.appendAttributedString(fn)
                s.appendAttributedString(NSAttributedString(string: ": " + self.comment.content))
                self.contentLabel.attributedText = s
            }
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel!

}
