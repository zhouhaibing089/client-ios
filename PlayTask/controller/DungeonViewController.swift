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
import DZNEmptyDataSet

class DungeonViewController: UIViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
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
            let topBorder = CALayer()
            topBorder.backgroundColor = UIColor.lightGrayColor().CGColor
            topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.commentView.frame), 1 / UIScreen.screenScale)
            self.commentView.layer.addSublayer(topBorder)
        }
    }
    @IBOutlet weak var commentIndicator: UIActivityIndicatorView!
    @IBOutlet weak var commentTextView: YNTextView! {
        didSet {
            self.commentTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.commentTextView.layer.borderWidth = 1 / UIScreen.screenScale
            self.commentTextView.maxHeight = 33 * 8 / UIScreen.screenScale
        }
    }
    @IBOutlet weak var titleButton: UIButton!
    
    var memorials = [[Memorial]]()
    var dungeon: Dungeon!
    
    // 当前发送的评论的元信息
    var commentMemorial: Memorial!
    var commentToUserId: Int?
    var commentIndexPath: NSIndexPath!
    
    var refreshControl: UIRefreshControl!
    
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
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableViewController.refreshControl = self.refreshControl
        self.refreshControl.beginRefreshing()
        self.refresh(self.refreshControl)
        
        // empty data set
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
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
        cell.commentAction = { [unowned self] (memorial, toUserId, toNickname) in
            self.commentView.hidden = false
            self.commentTextView.becomeFirstResponder()
            if self.commentMemorial?.id != memorial.id || self.commentToUserId != toUserId {
                // 这次评论和上次评论的对象不一样时, 清空已输入的内容
                self.commentTextView.text = ""
            }
            self.commentMemorial = memorial
            self.commentToUserId = toUserId
            self.commentIndexPath = indexPath
            if toUserId != nil {
                self.commentTextView.hint = String(format: "回复%@：", toNickname!)
            }
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        cell.deleteAction = { [unowned self] (commentId) in
            self.closeCommentView()
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                // TODO delete
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
            
        }
        cell.onImageClicked = { [unowned self] qiniuImageButton in
            self.performSegueWithIdentifier("preview@Main", sender: qiniuImageButton)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if !self.commentIndicator.isAnimating() {
            self.closeCommentView()
        }
        
    }
    
    @IBAction func sendComment(sender: UIButton) {
        sender.hidden = true
        self.commentIndicator.startAnimating()
        API.commentMemorial(Util.loggedUser!, memorialId: self.commentMemorial.id,
            toUserId: self.commentToUserId, content: self.commentTextView.text).subscribe({ event in
                switch event {
                case .Next(let c):
                    self.commentMemorial.comments.append(c)
                    break
                case .Completed:
                    self.tableView.reloadRowsAtIndexPaths([self.commentIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.commentIndicator.stopAnimating()
                    sender.hidden = false
                    self.commentTextView.text = ""
                    self.closeCommentView()
                    break
                case .Error(let e):
                    self.commentIndicator.stopAnimating()
                    sender.hidden = false
                    break
                }
            })
    }
    
    func closeCommentView() {
        self.view.endEditing(true)
        self.commentView.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nvc = segue.destinationViewController as! UINavigationController
            if let nmvc = nvc.viewControllers.first as? NewMemorialViewController {
                nmvc.dungeon = self.dungeon
                nmvc.onNewMemorial = { [unowned self] memorial in
                    self.memorials.insert([memorial], atIndex: 0)
                    self.update()
                }
            }
        } else if segue.identifier == "notification" {
            if let dnvc = segue.destinationViewController as? DungeonNotificationViewController {
                dnvc.dungeon = self.dungeon
            }
        } else if segue.identifier == "preview@Main" {
            let s = segue as! YNSegue
            if let pvc = s.instantiated as? PreviewViewController {
                let qiniuImageButton = sender as! QiniuImageButton
                pvc.rawImage = qiniuImageButton.imageForState(UIControlState.Normal)
                pvc.imageUrl = qiniuImageButton.metaImage.url
            }
        }
    }
    
    // MARK: - refresh
    func refresh(sender: UIRefreshControl? = nil) {
        var tmp = [Memorial]()
        API.getMemorials(self.dungeon, all: self.scope == Scope.All).subscribe { (event) -> Void in
            switch event {
            case .Next(let m):
                tmp.append(m)
                break
            case .Completed:
                self.memorials = [tmp]
                self.update()
                sender?.endRefreshing()
                break
            case .Error(let e):
                sender?.endRefreshing()
                break
            }
        }
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
        
        tableHeaderView.layoutIfNeeded()
        let size = tableHeaderView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        tableHeaderView.frame.size.height = size.height
        self.tableView.tableHeaderView = tableHeaderView
        
        // title
        switch self.scope {
        case .Group:
            UIView.performWithoutAnimation({ () -> Void in
                self.titleButton.setTitle(String(format: "本组(%d) ▾", self.dungeon.currentPlayer), forState: UIControlState.Normal)
                self.titleButton.layoutIfNeeded()
            })
            break
        case .All:
            UIView.performWithoutAnimation({ () -> Void in
                self.titleButton.setTitle("全部 ▾", forState: UIControlState.Normal)
                self.titleButton.layoutIfNeeded()
            })
            break
        }
        
        self.tableView.reloadData()
    }
    
    func load() {
        if self.loadIndicator.isAnimating() {
            return
        }
        if let before = self.memorials.last?.last?.createdTime {
            self.loadIndicator.startAnimating()
            var tmp = [Memorial]()
            API.getMemorials(self.dungeon, all: self.scope == Scope.All, before: before).subscribe { event in
                switch (event) {
                case .Next(let m):
                    tmp.append(m)
                    break
                case .Error(let e):
                    self.loadIndicator.stopAnimating()
                    break
                case .Completed:
                    self.memorials.append(tmp)
                    self.update()
                    self.loadIndicator.stopAnimating()
                    break
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
        if offset > 0 && maxOffset - offset < 44 {
            self.load()
        }
    }

    // MARK: - empty data set
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "无内容")
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return self.tableView.tableHeaderView!.frame.size.height * 2 / 3;
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // MARK: - Switch scope
    
    enum Scope {
        case Group
        case All
    }
    
    var scope = Scope.Group {
        didSet {
            self.refresh(self.refreshControl)
        }
    }
    
    @IBAction func switchScope(sender: UIButton) {
        var actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "看全部", style: UIAlertActionStyle.Default, handler: { [unowned self] (action) -> Void in
            self.scope = Scope.All
        }))
        actionSheet.addAction(UIAlertAction(title: "只看本组", style: UIAlertActionStyle.Default, handler: { [unowned self] (action) -> Void in
            self.scope = Scope.Group
            
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}
