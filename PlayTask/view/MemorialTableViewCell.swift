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

class MemorialTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nicknameButton: UIButton!
    
    @IBOutlet weak var memorialImageButton: QiniuImageButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var commentView: OAStackView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var onImageClicked: ((QiniuImageButton) -> Void)?
    
    // memorial id, to user id, to nickname
    var commentAction: ((Int, Int?, String?) -> Void)!
    // comment id
    var deleteAction: ((Int) -> Void)!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memorial.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath) as! MemorialCommentTableViewCell
        cell.memorialComment = self.memorial.comments[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let comment = self.memorial.comments[indexPath.row]
        let myUserId = Util.loggedUser!.sid.value
        if comment.fromUserId == myUserId {
            self.deleteAction(comment.id)
        } else {
            self.commentAction(self.memorial.id, comment.fromUserId, comment.fromNickname)
        }
        
    }
    
    @IBAction func comment(sender: UIButton) {
        self.commentAction(self.memorial.id, nil, nil)
    }
    
    var memorial: Memorial! {
        didSet {
            self.contentLabel.text = self.memorial.content
            self.timeLabel.text = self.memorial.createdTime.toReadable()
            self.nicknameButton.setTitle(self.memorial.nickname, forState: UIControlState.Normal)
            self.avatarImageView.af_setImageWithURL(NSURL(string: self.memorial.avatarUrl)!)
//            switch self.memorial.status {
//            case .Waiting:
//                self.reviewStatusLabel.text = "待审核"
//                break
//            case .Approved:
//                self.reviewStatusLabel.text = "审核通过"
//                break
//            case .Rejected:
//                self.reviewStatusLabel.text = "审核未通过：\(self.memorial.reason ?? "")"
//                break
//            }
            
            self.memorialImageButton.metaImage = self.memorial.image
            
            for m in self.memorial.comments {
                var v = MemorialCommentView()
                v.setup()
                v.contentLabel.text = "\(m.content) \(m.content)\(m.content)\(m.content)"
                self.commentView.addArrangedSubview(v)
            }
        }
    }
    @IBAction func preview(sender: QiniuImageButton) {
        self.onImageClicked?(sender)
    }
}
