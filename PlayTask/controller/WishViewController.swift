//
//  WishViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import YNSwift
import DZNEmptyDataSet

class WishViewController: UIViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UITableViewDelegate, UITableViewDataSource {
    
    var wishes: [Wish]!
    
    @IBOutlet weak var bronzeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // 去除 navigation controller 切换时的阴影
        self.navigationController?.view.backgroundColor = UIColor.whiteColor();
        
        // empty dateset
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        var contentInset =  self.navigationController!.navigationBar.frame.height
        contentInset += self.navigationController!.navigationBar.frame.origin.y
        self.tableView.contentInset = UIEdgeInsets(top: contentInset, left: 0, bottom: 0, right: 0)

        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncStatusChanged:", name: Config.Notification.SYNC, object: nil)
    }
    
    func syncStatusChanged(notification: NSNotification) {
        if Util.appDelegate.syncStatus == SyncStatus.Synced {
            self.refresh()
        }
    }

    
    @IBAction func endResort(sender: UITapGestureRecognizer) {
        if self.tableView.editing {
            var i = 0
            for w in self.wishes {
                w.update(["rank": ++i])
            }
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
        
        MobClick.beginLogPageView("wish")

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("wish")
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.wishes.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("wish", forIndexPath: indexPath) as! WishTableViewCell

        cell.wish = self.wishes[indexPath.row]
        cell.layoutIfNeeded()

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let wish = self.wishes[indexPath.row]
        let alert = UIAlertController(title: "满足欲望", message: "确定花费 \(wish.score) 点成就来满足你的欲望?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { _ in
            let wishHistory = WishHistory(wish: wish)
            wishHistory.save()

            let user = Util.currentUser
            user.update(["score": user.score - wish.score])
            self.scoreLabel.text = "\(user.score)"
            if user.score >= 0 {
                self.scoreLabel.textColor = UIColor.blackColor()
            } else {
                self.scoreLabel.textColor = UIColor.redColor()
            }
            if wish.loop == 1 { // 单次欲望满足后删除该欲望
                NSTimer.delay(0.6) {
                    wish.delete()
                    self.wishes.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
            self.tableView.reloadData()
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        })
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction  = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "编辑") { [unowned self] (action, indexPath) -> Void in
            let w = self.wishes[indexPath.row]
            self.performSegueWithIdentifier("new", sender: w)
        }
        editAction.backgroundColor = UIColor.lightGrayColor()
        let deleteAction  = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "删除") { [unowned self] (action, indexPath) -> Void in
            let wish = self.wishes[indexPath.row]
            wish.delete()
            self.wishes.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        return [deleteAction, editAction]

    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let wish = self.wishes[sourceIndexPath.row]
        self.wishes.removeAtIndex(sourceIndexPath.row)
        self.wishes.insert(wish, atIndex: destinationIndexPath.row)
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.editing {
            return UITableViewCellEditingStyle.None
        } else {
            return UITableViewCellEditingStyle.Delete
        }
    }
    
    @IBAction func showMenu(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "新建欲望", style: UIAlertActionStyle.Default, handler: { _ in
            self.performSegueWithIdentifier("new", sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "排序", style: UIAlertActionStyle.Default, handler: { _ in
            self.tableView.setEditing(false, animated: true)
            self.tableView.setEditing(true, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nc = segue.destinationViewController as! UINavigationController
            if let nwvc = nc.viewControllers.first as? NewWishViewController {
                if let w = sender as? Wish { // 编辑模式
                    nwvc.modifiedWish = w
                    nwvc.onWishAdded = { wish in
                        wish.update(["rank": w.rank])
                        w.delete()
                        self.refresh()
                    }
                } else {
                    nwvc.onWishAdded = { wish in
                        self.refresh()
                    }
                }
                
            }
        }
    }
    
    func refresh() {
        self.wishes = Wish.getWishes()
        
        // update
        let user = Util.currentUser
        self.scoreLabel.text = "\(user.score)"
        if user.score >= 0 {
            self.scoreLabel.textColor = UIColor.blackColor()
        } else {
            self.scoreLabel.textColor = UIColor.redColor()
        }
        self.tableView.tableFooterView = nil
        self.bronzeLabel.text = "\(user.bronze)"
        self.tableView.reloadData()
    }
    
    // MARK: - empty dataset
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        self.tableView.tableFooterView = UIView()
        return NSAttributedString(string: "无欲望")
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: UMOnlineConfig.getConfigParams("wishEmptyDescription") ?? "弗洛伊德认为，人的潜意识中储存着很多原始的欲望与冲动")
    }
}
