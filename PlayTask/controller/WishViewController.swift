//
//  WishViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class WishViewController: UITableViewController {

    @IBOutlet weak var scoreBarButton: UIBarButtonItem!
    
    var wishes: [Wish]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.wishes = Wish.getWishes()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
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
        
        let user = User.getInstance()
        UIView.performWithoutAnimation {
            self.scoreBarButton.title = "\(user.score)"
        }
        
        MobClick.beginLogPageView("wish")

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

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let wish = self.wishes[indexPath.row]
        let alert = UIAlertController(title: "满足欲望", message: "确定花费 \(wish.score) 点成就来满足你的欲望?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { _ in
            let wishHistory = WishHistory(wish: wish)
            wishHistory.save()

            let user = User.getInstance()
            user.update(["score": user.score - wish.score])
            UIView.performWithoutAnimation {
                self.scoreBarButton.title = "\(user.score)"
            }
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
        let sortAction  = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "排序") { [unowned self] (action, indexPath) -> Void in
            self.tableView.setEditing(false, animated: true)
            self.tableView.setEditing(true, animated: true)
        }
        sortAction.backgroundColor = UIColor.lightGrayColor()
        let deleteAction  = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "删除") { [unowned self] (action, indexPath) -> Void in
            let wish = self.wishes[indexPath.row]
            wish.delete()
            self.wishes.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        return [deleteAction, sortAction]

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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nc = segue.destinationViewController as! UINavigationController
            if let nwvc = nc.viewControllers.first as? NewWishViewController {
                nwvc.onWishAdded = { wish in
                    self.wishes.insert(wish, atIndex: 0)
                    self.tableView.reloadData()
                }
            }
        }
    }
}
