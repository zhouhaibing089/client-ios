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

class MemorialTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nicknameButton: UIButton!
    
    @IBOutlet weak var memorialImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var reviewStatusLabel: UILabel!
    @IBOutlet weak var commentTableView: UITableView! {
        didSet {
            self.commentTableView.delegate = self
            self.commentTableView.dataSource = self
            self.commentTableView.rowHeight = UITableViewAutomaticDimension
            self.commentTableView.estimatedRowHeight = 44
        }
    }
    
    // memorial id, to user id
    var commentAction: ((Int, Int?) -> Void)!
    
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
    
    @IBAction func comment(sender: UIButton) {
        self.commentAction(self.memorial.id, nil)
    }
    
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
            self.commentTableView.reloadData()
            if let image = self.memorial.image {
                self.memorialImageView.af_setImageWithURL(NSURL(string: image.url)!)
            }
        }
    }

}
