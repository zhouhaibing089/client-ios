//
//  DungeonViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/20/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift
import RxSwift

class DungeonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var dungeonTitleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            self.avatarImageView.layer.borderWidth = 2
            self.avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
            let outerBorder = CALayer()
            let outerBorderWidth = 1 / UIScreen.screenScale
            outerBorder.frame = CGRectMake(-outerBorderWidth, -outerBorderWidth, self.avatarImageView.frame.width + 2 * outerBorderWidth, self.avatarImageView.frame.height + 2 * outerBorderWidth)
            outerBorder.borderColor = UIColor.grayColor().CGColor
            outerBorder.borderWidth = outerBorderWidth
            self.avatarImageView.layer.addSublayer(outerBorder)
        }
    }
    @IBOutlet weak var messageAlertButton: UIButton!
    @IBOutlet weak var coverWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentView: UIView! {
        didSet {
            self.commentView.hidden = true
        }
    }
    @IBOutlet weak var commentTextView: YNTextView!
    
    var memorials = [[Memorial]]()
    var dungeon: Dungeon!
    
    // 当前发送的评论的元信息
    var commentMemorialId: Int!
    var commentToUserId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.update()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        // pull to refresh
        let tableViewController = UITableViewController()
        tableViewController.tableView = self.tableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableViewController.refreshControl = refreshControl
        refreshControl.beginRefreshing()
        self.refresh(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return memorials.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memorials[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memorial", forIndexPath: indexPath) as! MemorialTableViewCell
        cell.memorial = self.memorials[indexPath.section][indexPath.row]
        cell.commentAction = { [unowned self] (memorialId, toUserId, toNickname) in
            self.commentView.hidden = false
            self.commentTextView.becomeFirstResponder()
            self.commentMemorialId = memorialId
            self.commentToUserId = toUserId
            if toUserId != nil {
                self.commentTextView.hint = String(format: "回复%@：", toNickname!)
            }
        }
        cell.deleteAction = { [unowned self] (commentId) in
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                // TODO delete
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
            
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func update() {
        // cover image
        self.coverImageView.af_setImageWithURL(NSURL(string: self.dungeon.cover)!)
        if let loggedUser = Util.loggedUser {
            if let avatarUrl = NSURL(string: loggedUser.avatarUrl) {
                self.avatarImageView.af_setImageWithURL(avatarUrl)
            }
        }
        
        // message alert
        let messageCount = Util.currentUser.badge.getCountByDungeonId(self.dungeon.id)
        if messageCount > 0 {
            self.messageAlertButton.setTitle(String(format: "您有%d条新消息", messageCount), forState: UIControlState.Normal)
            self.messageAlertButton.hidden = false
        } else {
            self.messageAlertButton.hidden = true
        }
        
        // dungeon title
        self.dungeonTitleLabel.text = self.dungeon.title
        
        // table header view header
        let tableHeaderView = self.tableView.tableHeaderView!
        tableHeaderView.bounds.size.width = self.view.bounds.width
        
        // cover has a relative constraint, which will cause systemLayoutSizeFittingSize get wrong size
        // because table header view doesn't have width constraint
        // see: http://stackoverflow.com/questions/27064070/auto-layout-with-relative-constraints-not-affecting-systemlayoutsizefittingsize
        // in a world, cover depends on table header view's width, however (image view dones't have instinct size neither),
        // table header view doesn's have a width constraint, so systemLayoutSizeFittingSize is confused.
        self.coverWidthConstraint.constant = self.view.bounds.width
        
        //self.tableView.tableHeaderView = nil
        tableHeaderView.layoutIfNeeded()
        let size = tableHeaderView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        tableHeaderView.frame.size.height = size.height
        self.tableView.tableHeaderView = tableHeaderView
        
        self.tableView.reloadData()
    }
    
    func refresh(sender: UIRefreshControl? = nil) {
        var tmp = [Memorial]()
        API.getMemorials(self.dungeon).subscribe { (event) -> Void in
            switch event {
            case .Next(let m):
                tmp.append(m)
                break
            case .Completed:
                self.memorials.append(tmp)
                self.update()
                sender?.endRefreshing()
                break
            case .Error(let e):
                sender?.endRefreshing()
                break
            }
        }
    }
    
    @IBAction func sendComment(sender: UIButton) {
        API.commentMemorial(Util.loggedUser!, memorialId: self.commentMemorialId,
            toUserId: self.commentToUserId, content: self.commentTextView.text).subscribe({ event in
                switch event {
                case .Next(let c):
                    break
                case .Completed:
                    break
                case .Error(let e):
                    break
                }
            })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nvc = segue.destinationViewController as! UINavigationController
            if let nmvc = nvc.viewControllers.first as? NewMemorialViewController {
                nmvc.dungeon = self.dungeon
            }
        } else if segue.identifier == "notification" {
            if let dnvc = segue.destinationViewController as? DungeonNotificationViewController {
                dnvc.dungeon = self.dungeon
            }
        }
    }

}
