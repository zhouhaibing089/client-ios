//
//  WishViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import YNSwift

class WishViewController: UITableViewController {

    @IBOutlet weak var scoreBarButton: UIBarButtonItem!
    
    var wishes: [Wish]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncStatusChanged:", name: Config.Notification.SYNC, object: nil)
    }
    
    func syncStatusChanged(notification: NSNotification) {
        self.refresh()
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
        
        let user = Util.currentUser
        UIView.performWithoutAnimation {
            self.scoreBarButton.title = "\(user.score)"
        }
        
        self.refresh()
        
        MobClick.beginLogPageView("wish")

    }
    
    func refresh() {
        self.wishes = Wish.getWishes()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("wish")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.wishes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("wish", forIndexPath: indexPath) as! WishTableViewCell

        cell.wish = self.wishes[indexPath.row]
        cell.layoutIfNeeded()

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let wish = self.wishes[indexPath.row]
        let alert = UIAlertController(title: "满足欲望", message: "确定花费 \(wish.score) 点成就来满足你的欲望?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { _ in
            let wishHistory = WishHistory(wish: wish)
            wishHistory.save()

            let user = Util.currentUser
            user.update(["score": user.score - wish.score])
            UIView.performWithoutAnimation {
                self.scoreBarButton.title = "\(user.score)"
            }
            if wish.loop == 1 { // 单次欲望满足后删除该欲望
                NSTimer.delay(1) {
                    wish.delete()
                    self.wishes.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
            self.tableView.reloadData()
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        })
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        return super.tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
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
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let wish = self.wishes[sourceIndexPath.row]
        self.wishes.removeAtIndex(sourceIndexPath.row)
        self.wishes.insert(wish, atIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
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
                        self.wishes.insert(wish, atIndex: 0)
                        self.tableView.reloadData()
                    }
                }
                
            }
        }
    }
}
