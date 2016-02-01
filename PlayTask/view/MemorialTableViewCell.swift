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
import OAStackView

class MemorialTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nicknameButton: UIButton!
    
    @IBOutlet weak var memorialImageButton: QiniuImageButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var commentView: OAStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var onImageClicked: ((QiniuImageButton) -> Void)?
    
    // memorial id, to user id, to nickname
    var commentAction: ((Memorial, Int?, String?) -> Void)!
    // comment id
    var deleteAction: ((Int) -> Void)!

    @IBAction func comment(sender: UIButton) {
        self.commentAction(self.memorial, nil, nil)
    }
    
    var memorial: Memorial! {
        didSet {
            self.contentLabel.text = self.memorial.content
            self.timeLabel.text = self.memorial.createdTime.toReadable()
            self.nicknameButton.setTitle(self.memorial.nickname, forState: UIControlState.Normal)
            self.avatarImageView.af_setImageWithURL(NSURL(string: self.memorial.avatarUrl)!)
            switch self.memorial.status {
            case .Waiting:
                self.statusLabel.text = "待审核"
                break
            case .Approved:
                self.statusLabel.text = "审核通过"
                break
            case .Rejected:
                self.statusLabel.text = "审核未通过：\(self.memorial.reason ?? "")"
                break
            }
            
            self.memorialImageButton.metaImage = self.memorial.image
            
            // clear comments
            self.commentView.subviews.forEach { (view) -> () in
                self.commentView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            for m in self.memorial.comments {
                let v = MemorialCommentView()
                v.setup()
                v.comment = m
                v.onClicked = { [unowned self] comment in
                    let myUserId = Util.loggedUser!.sid.value
                    if comment.fromUserId == myUserId {
                        self.deleteAction(comment.id)
                    } else {
                        self.commentAction(self.memorial, comment.fromUserId, comment.fromNickname)
                    }
                }
                self.commentView.addArrangedSubview(v)
            }
        }
    }
    @IBAction func preview(sender: QiniuImageButton) {
        self.onImageClicked?(sender)
    }
}
