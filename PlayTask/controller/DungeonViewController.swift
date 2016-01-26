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

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageAlertButton: UIButton!
    
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
        return cell
    }
    
    func update() {
        self.coverImageView.af_setImageWithURL(NSURL(string: self.dungeon.cover)!)
        if let loggedUser = Util.loggedUser {
            if let avatarUrl = NSURL(string: loggedUser.avatarUrl) {
                self.avatarImageView.af_setImageWithURL(avatarUrl)
            }
        }
        let messageCount = Util.currentUser.badge.getCountByDungeonId(self.dungeon.id)
        if messageCount > 0 {
            self.messageAlertButton.setTitle(String(format: "您有%d条新消息", messageCount), forState: UIControlState.Normal)
            self.messageAlertButton.hidden = false
        } else {
            self.messageAlertButton.hidden = true
        }
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
