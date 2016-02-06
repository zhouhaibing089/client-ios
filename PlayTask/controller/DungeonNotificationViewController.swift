//
//  DungeonNotificationViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class DungeonNotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var notifications = [[DungeonNotification]]()
    
    var dungeon: Dungeon!

    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 44
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pull to refresh
        let tableViewController = UITableViewController()
        tableViewController.tableView = self.tableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableViewController.refreshControl = refreshControl
        refreshControl.beginRefreshing()
        self.refresh(refreshControl)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.notifications.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dn = self.notifications[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("notification", forIndexPath: indexPath) as! DungeonNotificationTableViewCell
        cell.notification = dn
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dn = self.notifications[indexPath.section][indexPath.row]
        if dn.memorial != nil {
            self.performSegueWithIdentifier("memorial", sender: dn)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func refresh(sender: UIRefreshControl) {
        var dns = [DungeonNotification]()
        API.getDungeonNotifications(Util.currentUser, dungeonId: self.dungeon.id).subscribe({ event in
            switch event {
            case .Completed:
                self.notifications = [dns]
                self.tableView.reloadData()
                sender.endRefreshing()
                break
            case .Next(let dn):
                dns.append(dn)
                break
            case .Error(let t):
                sender.endRefreshing()
                break
            }
        })
    }
    
    func load() {
        if self.loadIndicator.isAnimating() {
            return
        }
        if let before = self.notifications.last?.last?.createdTime {
            self.loadIndicator.startAnimating()
            var tmp = [DungeonNotification]()
            API.getDungeonNotifications(Util.currentUser, dungeonId: self.dungeon.id, before: before).subscribe { event in
                switch (event) {
                case .Next(let n):
                    tmp.append(n)
                    break
                case .Error(let e):
                    self.loadIndicator.stopAnimating()
                    break
                case .Completed:
                    self.notifications.append(tmp)
                    self.loadIndicator.stopAnimating()
                    self.tableView.reloadData()
                    break
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
        if offset > 0 && maxOffset - offset < 44 {
            // scroll down and reached bottom
            self.load()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "memorial" {
            if let mvc = segue.destinationViewController as? MemorialViewController {
                mvc.memorial = (sender as! DungeonNotification).memorial
            }
        }
    }
}
