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
import SwiftyJSON
import DZNEmptyDataSet
import CRToast

class DungeonViewController: UIViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet var newBarButton: UIBarButtonItem!
    @IBOutlet var moreBarButton: UIBarButtonItem!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dungeonTitleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            self.avatarImageView.layer.borderWidth = 2
            self.avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
            let outerBorder = CALayer()
            let outerBorderWidth = 1 / UIScreen.screenScale
            outerBorder.frame = CGRectMake(-outerBorderWidth, -outerBorderWidth, self.avatarImageView.frame.width + 2 * outerBorderWidth, self.avatarImageView.frame.height + 2 * outerBorderWidth)
            outerBorder.borderColor = UIColor.lightGrayColor().CGColor
            outerBorder.borderWidth = outerBorderWidth
            self.avatarImageView.layer.addSublayer(outerBorder)
            // allow user to click to view self
            self.avatarImageView.userInteractionEnabled = true
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
    @IBOutlet weak var titleButton: UIButton! {
        didSet {
            self.titleButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
        }
    }
    
    var memorials = [[Memorial]]()
    var dungeon: Dungeon!
    
    // 当前发送的评论的元信息
    var commentMemorial: Memorial!
    var toMemorialCommentId: Int?
    var commentIndexPath: NSIndexPath!
    
    var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        // pull to refresh
        let tableViewController = UITableViewController()
        tableViewController.tableView = self.tableView
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(DungeonViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        cell.commentAction = { [weak self] (memorial, toMemorialCommentId, toNickname) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.commentView.hidden = false
            weakSelf.commentTextView.becomeFirstResponder()
            if weakSelf.commentMemorial?.id != memorial.id || weakSelf.toMemorialCommentId != toMemorialCommentId {
                // 这次评论和上次评论的对象不一样时, 清空已输入的内容
                weakSelf.commentTextView.text = ""
            }
            weakSelf.commentMemorial = memorial
            weakSelf.toMemorialCommentId = toMemorialCommentId
            weakSelf.commentIndexPath = indexPath
            if toMemorialCommentId != nil {
                weakSelf.commentTextView.hint = String(format: "回复%@：", toNickname!)
            }
            weakSelf.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        // 删除 memorial
        cell.deleteMemorialAction = { [weak self, cell] (memorialId) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.closeCommentView()
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                _ = API.deleteMemorial(cell.memorial).subscribe({ (event) -> Void in
                    switch event {
                    case .Completed:
                        break
                    case .Error(_):
                        break
                    case .Next(_):
                        break
                    }
                })
                weakSelf.memorials[indexPath.section].removeAtIndex(indexPath.row)
                weakSelf.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                NSTimer.delay(0.5) {
                    // update indexPath
                    weakSelf.tableView.reloadData()
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            weakSelf.presentViewController(actionSheet, animated: true, completion: nil)
            
        }
        // 删除评论
        cell.deleteMemorialCommentAction = { [weak self, cell] (commentId) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.closeCommentView()
            let actionSheet = UIAlertController(title: nil, message: "删除评论", preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                _ = API.deleteMemorialComment(commentId).subscribe({ (event) -> Void in
                    switch event {
                    case .Completed:
                        break
                    case .Error(_):
                        break
                    case .Next(_):
                        break
                    }
                })
                cell.memorial.comments = cell.memorial.comments.filter { $0.id != commentId }
                weakSelf.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            weakSelf.presentViewController(actionSheet, animated: true, completion: nil)
            
        }
        cell.onImageClicked = { [weak self] qiniuImageButton in
            self?.performSegueWithIdentifier("preview@Main", sender: qiniuImageButton)
        }
        cell.onNicknameClicked = { [weak self] userId, nickname in
            self?.performSegueWithIdentifier("others_dungeon", sender: ["user_id": userId, "nickname": nickname])
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
        if self.commentTextView.text == "" {
            return
        }
        sender.hidden = true
        self.commentIndicator.startAnimating()
        _ = API.commentMemorial(Util.loggedUser!, memorialId: self.commentMemorial.id,
            toMemorialCommentId: self.toMemorialCommentId, content: self.commentTextView.text, fromDungeonId: self.dungeon.id).subscribe({ event in
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
                    if let error = e as? APIError {
                        switch error {
                        case .Custom(_, let info, _):
                            CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                            break
                        default:
                            break
                        }
                    }
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
                if let qiniuImageButton = sender as? QiniuImageButton {
                    pvc.rawImage = qiniuImageButton.imageForState(UIControlState.Normal)
                    pvc.imageUrl = qiniuImageButton.metaImage?.url
                } else {
                    pvc.rawImage = self.avatarImageView.image
                    pvc.imageUrl = Util.currentUser.avatarUrl
                }
            }
        } else if segue.identifier == "others_dungeon" {
            if let dvc = segue.destinationViewController as? DungeonViewController {
                dvc.dungeon = self.dungeon
                let json = JSON(sender as! NSDictionary)
                if let userId = json["user_id"].int, let nickname = json["nickname"].string {
                    if userId == Util.currentUser.sid.value {
                        dvc.scope = Scope.Myself
                    } else {
                        dvc.scope = Scope.Personal(userId, nickname)
                    }
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "others_dungeon" {
            // triggered by Storyboard
            return !(sender is UIButton)
        }
        return true
    }
    
    // MARK: - refresh
    func refresh(sender: UIRefreshControl? = nil) {
        var tmp = [Memorial]()
        var observable: Observable<Memorial> = Observable.empty()
        switch self.scope {
        case .All:
            observable = API.getMemorials(self.dungeon, all: true)
            break
        case .Group:
            observable = API.getMemorials(self.dungeon, all: false)
            break
        case .Myself:
            observable = API.getMemorialsOfUser(Util.currentUser.sid.value!, inDungeon: self.dungeon)
            break
        case .Personal(let userId, _):
            observable = API.getMemorialsOfUser(userId, inDungeon: self.dungeon)
            break
        }
        _ = observable.subscribe { (event) -> Void in
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
                if let error = e as? APIError {
                    switch error {
                    case .Custom(_, let info, _):
                        CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                        break
                    default:
                        break
                    }
                }
                sender?.endRefreshing()
                break
            }
        }
    }
    
    func update() {
        // avatar
        if let loggedUser = Util.loggedUser {
            let qiniuImage = QiniuImage(url: loggedUser.avatarUrl, width: 512, height: 512)
            let size = self.avatarImageView.bounds.size.height
            if let avatarUrl = NSURL(string: qiniuImage.getUrlForMaxWidth(size, maxHeight: size)) {
                self.avatarImageView.af_setImageWithURL(avatarUrl)
            }
        }
        
        switch self.scope {
        case .All, .Group:
            // message alert
            let messageCount = Util.currentUser.badge.getCountByDungeonId(self.dungeon.id)
            if messageCount > 0 {
                self.messageAlertButton.setTitle(String(format: "您有%d条新消息", messageCount), forState: UIControlState.Normal)
                self.messageAlertButton.hidden = false
            } else {
                self.messageAlertButton.hidden = true
            }
            // bar button
            self.navigationItem.rightBarButtonItems = [self.newBarButton]
            break
        case .Myself:
            self.navigationItem.rightBarButtonItems = [self.moreBarButton]
            self.messageAlertButton.hidden = true
        case .Personal(_, _):
            self.navigationItem.rightBarButtonItems = []
            self.messageAlertButton.hidden = true
            break
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
        
        // cover image
        let coverWidth = self.coverImageView.frame.width
        let coverHeight = self.coverImageView.frame.height
        let cover = QiniuImage(url: self.dungeon.cover, width: coverWidth, height: coverHeight)
        self.coverImageView.af_setImageWithURL(NSURL(string: cover.getUrlForMaxWidth(coverWidth, maxHeight: coverHeight))!)
        
        
        // title
        self.updateTitle()
        
        self.tableView.reloadData()
    }
    
    func updateTitle() {
        self.titleButton.enabled = true
        switch self.scope {
        case .Group:
            UIView.performWithoutAnimation({ () -> Void in
                if self.dungeon.status != DungeonStatus.Joined {
                    // 只有副本状态正常的时候才可以查看所有人的 memorial
                    self.titleButton.setTitle(String(format: "本组(%d)", self.dungeon.currentPlayer), forState: UIControlState.Normal)
                } else {
                    self.titleButton.setTitle(String(format: "本组(%d) ▾", self.dungeon.currentPlayer), forState: UIControlState.Normal)
                }
                self.titleButton.layoutIfNeeded()
            })
            break
        case .All:
            UIView.performWithoutAnimation({ () -> Void in
                self.titleButton.setTitle("全部 ▾", forState: UIControlState.Normal)
                self.titleButton.layoutIfNeeded()
            })
            break
        case .Myself:
            self.titleButton.enabled = false
            UIView.performWithoutAnimation({ () -> Void in
                self.titleButton.setTitle(Util.currentUser.nickname, forState: UIControlState.Normal)
                self.titleButton.layoutIfNeeded()
            })
            break
        case .Personal(_, let nickname):
            self.titleButton.enabled = false
            UIView.performWithoutAnimation({ () -> Void in
                self.titleButton.setTitle(nickname, forState: UIControlState.Normal)
                self.titleButton.layoutIfNeeded()
            })
            break
        }
    }
    
    func load() {
        if self.loadIndicator.isAnimating() {
            return
        }
        if self.memorials.last?.count < Config.LOAD_THRESHOLD {
            return
        }
        if let before = self.memorials.last?.last?.createdTime {
            self.loadIndicator.startAnimating()
            var tmp = [Memorial]()
            var observable: Observable<Memorial> = Observable.empty()
            switch self.scope {
            case .All:
                observable = API.getMemorials(self.dungeon, all: true, before: before)
                break
            case .Group:
                observable = API.getMemorials(self.dungeon, all: false, before: before)
                break
            case .Myself:
                observable = API.getMemorialsOfUser(Util.currentUser.sid.value!, inDungeon: self.dungeon, before: before)
                break
            case .Personal(let userId, _):
                observable = API.getMemorialsOfUser(userId, inDungeon: self.dungeon, before: before)
                break
            }
            _ = observable.subscribe { event in
                switch (event) {
                case .Next(let m):
                    tmp.append(m)
                    break
                case .Error(_):
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
        return self.tableView.tableHeaderView!.frame.size.height * 1 / 2;
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // MARK: - Switch scope
    
    enum Scope {
        case Myself
        case Personal(Int, String)
        case Group
        case All
    }
    
    var scope = Scope.Group {
        didSet {
            self.refresh(self.refreshControl)
            // make ui response as quick as possible
            self.updateTitle()
        }
    }
    
    @IBAction func switchScope(sender: UIButton) {
        if self.dungeon.status != DungeonStatus.Joined {
            // 只有副本状态正常的时候才可以查看所有人的状态
            return
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "看全部", style: UIAlertActionStyle.Default, handler: { [weak self] (action) -> Void in
            self?.scope = Scope.All
        }))
        actionSheet.addAction(UIAlertAction(title: "只看本组", style: UIAlertActionStyle.Default, handler: { [weak self] (action) -> Void in
            self?.scope = Scope.Group
            
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func more(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "消息列表", style: UIAlertActionStyle.Default, handler: { [weak self] (action) -> Void in
            self?.performSegueWithIdentifier("notification", sender: sender)
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func viewMyself(sender: UITapGestureRecognizer) {
        switch scope {
        case .Myself:
            self.performSegueWithIdentifier("preview@Main", sender: "avatar")
            break
        default:
            self.performSegueWithIdentifier("others_dungeon", sender: ["user_id": Util.currentUser.sid.value!, "nickname": Util.currentUser.nickname])
            break
        }
    }
}
