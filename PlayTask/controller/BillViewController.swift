//
//  BillViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class BillViewController: UITableViewController {
    
    var billItems: [Bill]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.billItems = [Bill]()
        let th: [Bill] = TaskHistory.getTaskHistories()
        let wh: [Bill] = WishHistory.getWishHistories()
        self.billItems.appendContentsOf(th)
        self.billItems.appendContentsOf(wh)
        
        self.billItems = self.billItems.sort {
            return $0.getBillTime().compare($1.getBillTime()) == NSComparisonResult.OrderedDescending
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 72

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("bill")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("bill")
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.billItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bill_item", forIndexPath: indexPath) as! BillItemTableViewCell
        
        cell.billItem = self.billItems[indexPath.row]
        cell.layoutIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let billItem = self.billItems[indexPath.row]

            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "仅删除", style: UIAlertActionStyle.Destructive, handler: { _ in
                billItem.delete()
                self.billItems.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }))
            actionSheet.addAction(UIAlertAction(title: "删除并恢复成就", style: UIAlertActionStyle.Default, handler: { _ in
                billItem.cancel()
                billItem.delete()
                self.billItems.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
    }

}
