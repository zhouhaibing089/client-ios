//
//  DungeonListViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/12/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class DungeonListViewController: UIViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var dungeons = [Dungeon]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.refresh()
        
        // pull to refresh
        let tableViewController = UITableViewController()
        tableViewController.tableView = self.tableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableViewController.refreshControl = refreshControl
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dungeons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dungeon", forIndexPath: indexPath) as! DungeonTableViewCell
        cell.dungeon = self.dungeons[indexPath.row]
        cell.selectionStyle = .None
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dungeon = self.dungeons[indexPath.row]
        self.performSegueWithIdentifier("detail", sender: dungeon)
    }

    func refresh(sender: UIRefreshControl? = nil) {
        var tmp = [Dungeon]()
        API.getDungeons().subscribe { event in
            switch event {
            case .Completed:
                self.dungeons = tmp
                sender?.endRefreshing()
                self.tableView.reloadData()
                break
            case .Error(_):
                sender?.endRefreshing()
                break
            case .Next(let d):
                tmp.append(d)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail" {
            if let ddvc = segue.destinationViewController as? DungeonDetailViewController {
                ddvc.dungeon = sender as! Dungeon
            }
        }
    }
    
    // MARK: - Empty Data Set
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "无副本")
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}
