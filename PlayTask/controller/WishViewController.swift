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
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let wish = self.wishes[indexPath.row]
            wish.delete()
            self.wishes.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nc = segue.destinationViewController as! UINavigationController
            if let nwvc = nc.viewControllers.first as? NewWishViewController {
                nwvc.onWishAdded = { wish in
                    self.wishes.append(wish)
                    self.wishes = self.wishes.sort {
                        return $0.score < $1.score
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
}