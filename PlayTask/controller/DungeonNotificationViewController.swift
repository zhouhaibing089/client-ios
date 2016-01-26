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
        self.refresh()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func refresh() {
        var dns = [DungeonNotification]()
        API.getDungeonNotifications(Util.currentUser, dungeonId: self.dungeon.id).subscribe({ event in
            switch event {
            case .Completed:
                self.notifications.append(dns)
                self.tableView.reloadData()
                break
            case .Next(let dn):
                dns.append(dn)
                break
            case .Error(let t):
                break
            }
        })
    }
    
}
