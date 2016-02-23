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
    @IBOutlet var deleteButton: UIButton!
    
    var onImageClicked: ((QiniuImageButton) -> Void)?
    
    // memorial id, from memorial comment id, to nickname
    var commentAction: ((Memorial, Int?, String?) -> Void)!
    // memorial id
    var deleteMemorialAction: ((Int) -> Void)!
    var deleteMemorialCommentAction: ((Int) -> Void)!

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
            
            self.deleteButton.hidden = self.memorial.userId != (Util.currentUser.sid.value ?? -1)
            
            self.memorialImageButton.metaImage = self.memorial.image
            
            // clear comments
            self.commentView.subviews.forEach { (view) -> () in
                self.commentView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            // reuse commentView arranged view
            let vc = self.commentView.arrangedSubviews.count
            let cc = self.memorial.comments.count
            if vc < cc {
                for _ in vc...(cc - 1) {
                    let v = MemorialCommentView()
                    v.setup()
                    self.commentView.addArrangedSubview(v)
                }
            }
            for (i, v) in self.commentView.arrangedSubviews.enumerate() {
                v.hidden = i >= cc
            }
            for (i, m) in self.memorial.comments.enumerate() {
                let v = self.commentView.arrangedSubviews[i] as! MemorialCommentView
                v.comment = m
                v.onClicked = { [unowned self] comment in
                    let myUserId = Util.loggedUser!.sid.value
                    if comment.fromUserId == myUserId {
                        self.deleteMemorialCommentAction(comment.id)
                    } else {
                        self.commentAction(self.memorial, comment.id, comment.fromNickname)
                    }
                }
            }
        }
    }
    @IBAction func preview(sender: QiniuImageButton) {
        self.onImageClicked?(sender)
    }
    @IBAction func deleteMemorial(sender: UIButton) {
        self.deleteMemorialAction(self.memorial.id)
    }
}
