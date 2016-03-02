//
//  MemorialViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift
import CRToast

class MemorialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sendIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentTextView: YNTextView! {
        didSet {
            self.commentTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.commentTextView.layer.borderWidth = 1 / UIScreen.screenScale
            self.commentTextView.maxHeight = 33 * 8 / UIScreen.screenScale
            self.commentTextView.layer.cornerRadius = 2
        }
    }
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet weak var imageButton: QiniuImageButton!
    @IBOutlet weak var commentView: UIView! {
        didSet {
            let topBorder = CALayer()
            topBorder.backgroundColor = UIColor.lightGrayColor().CGColor
            topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.commentView.frame), 1 / UIScreen.screenScale)
            self.commentView.layer.addSublayer(topBorder)
        }
    }
    
    var memorial: Memorial!
    var fromDungeonId: Int!
    var toMemorialCommentId: Int?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.update()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memorial.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath) as! MemorialCommentTableViewCell
        cell.comment = self.memorial.comments[indexPath.row]
        cell.selectionStyle = .None
        cell.layoutIfNeeded() // for iOS 8 UILabel to be right
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? MemorialCommentTableViewCell
        cell?.flash()
        let comment = self.memorial.comments[indexPath.row]
        if comment.fromUserId == Util.currentUser.sid.value! {
            let actionSheet = UIAlertController(title: nil, message: "删除评论", preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive, handler: { [unowned self](action) -> Void in
                _ = API.deleteMemorialComment(comment.id).subscribe({ (event) -> Void in
                    switch event {
                    case .Error(_):
                        break
                    case .Next(_):
                        break
                    case .Completed:
                        break
                    }
                })
                self.memorial.comments.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                NSTimer.delay(0.5) {
                    // update indexPath
                    self.tableView.reloadData()
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
        } else {
            self.commentTextView.hint = "回复 \(comment.fromNickname)："
            self.toMemorialCommentId = comment.id
            self.commentTextView.text = ""
            self.commentTextView.becomeFirstResponder()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.endComment(false)
    }
    
    @IBAction func send(sender: UIButton) {
        if self.commentTextView.text == "" {
            return
        }
        self.sendIndicator.startAnimating()
        sender.hidden = true
        _ = API.commentMemorial(Util.currentUser, memorialId: self.memorial.id, toMemorialCommentId: self.toMemorialCommentId, content: self.commentTextView.text, fromDungeonId: self.fromDungeonId).subscribe { (event) -> Void in
            switch event {
            case .Completed:
                self.tableView.reloadData()
                self.sendIndicator.stopAnimating()
                self.endComment(true)
                sender.hidden = false
                break
            case .Error(let e):
                if let error = e as? APIError {
                    switch error {
                    case .Custom(_, let info, _):
                        CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                        break
                    default:
                        break
                    }
                }
                self.sendIndicator.stopAnimating()
                sender.hidden = false
                break
            case .Next(let c):
                self.memorial.comments.append(c)
                break
            }
        }
    }
    
    @IBAction func preview(sender: QiniuImageButton) {
        self.performSegueWithIdentifier("preview@Main", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "preview@Main" {
            let segue = segue as! YNSegue
            if let pvc = segue.instantiated as? PreviewViewController {
                pvc.rawImage = (sender as! UIButton).imageForState(UIControlState.Normal)
                pvc.imageUrl = self.memorial.image?.url
            }
        }
    }
    
    func endComment(clean: Bool) {
        self.commentTextView.endEditing(true)
        if clean {
            self.commentTextView.text = ""
        }
        if self.commentTextView.text == "" {
            self.commentTextView.hint = "评论"
            self.toMemorialCommentId = nil
        }
    }
    
    @IBAction func deleteMemorial(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive, handler: { [unowned self] (action) -> Void in
            _ = API.deleteMemorial(self.memorial).subscribe({ (event) -> Void in
                switch event {
                case .Error(_):
                    break
                case .Next(_):
                    break
                case .Completed:
                    break
                }
            })
            self.navigationController?.popViewControllerAnimated(true)
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func update() {
        self.deleteButton.hidden = (self.memorial.userId != Util.currentUser.sid.value ?? -1)
        self.avatarImageView.af_setImageWithURL(NSURL(string: self.memorial.avatarUrl)!)
        self.nicknameLabel.text = self.memorial.nickname
        self.contentLabel.text = self.memorial.content
        self.imageButton.metaImage = self.memorial.image
        self.timeLabel.text = self.memorial.createdTime.toReadable()
        
        // update table head, call AFTER set imageButton's metaImage
        let tableHeaderView = self.tableView.tableHeaderView!
        tableHeaderView.bounds.size.width = self.view.bounds.width
        tableHeaderView.layoutIfNeeded()
        let size = tableHeaderView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        tableHeaderView.frame.size.height = size.height
        self.tableView.tableHeaderView = tableHeaderView
    }
}
