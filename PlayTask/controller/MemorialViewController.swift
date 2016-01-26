//
//  MemorialViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift

class MemorialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentTextView: YNTextView!
    
    var memorial: Memorial!
    var commentToUserId: Int?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.update()
        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memorial.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath) as! MemorialCommentDetailTableViewCell
        cell.comment = self.memorial.comments[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let comment = self.memorial.comments[indexPath.row]
        if comment.fromUserId == Util.currentUser.sid.value! {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                // TODO delete
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
        } else {
            self.commentTextView.hint = "回复 \(comment.fromNickname)："
            self.commentTextView.becomeFirstResponder()
        }
    }
    
    @IBAction func send(sender: UIButton) {
        API.commentMemorial(Util.currentUser, memorialId: self.memorial.id, toUserId: self.commentToUserId, content: self.commentTextView.text).subscribe { (event) -> Void in
            
        }
    }
    
    func update() {
        self.avatarImageView.af_setImageWithURL(NSURL(string: self.memorial.avatarUrl)!)
        self.nicknameLabel.text = self.memorial.nickname
        self.contentLabel.text = self.memorial.content
        if let image = self.memorial.image {
            self.imageView.af_setImageWithURL(NSURL(string: image.url)!)
        }
    }
}
