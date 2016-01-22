//
//  DungeonViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/20/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class DungeonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var memorials = [[Memorial]]()
    var dungeon: Dungeon!
    
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
        return cell
    }
    
    func update() {
        self.coverImageView.af_setImageWithURL(NSURL(string: self.dungeon.cover)!)
        if let loggedUser = Util.loggedUser {
            if let avatarUrl = NSURL(string: loggedUser.avatarUrl) {
                self.avatarImageView.af_setImageWithURL(avatarUrl)
            }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "new" {
            let nvc = segue.destinationViewController as! UINavigationController
            if let nmvc = nvc.viewControllers.first as? NewMemorialViewController {
                nmvc.dungeon = self.dungeon
            }
        }
    }

}
