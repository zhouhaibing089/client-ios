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
        // Do any additional setup after loading the view.
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
        return UITableViewCell()
    }
    
    func update() {
        self.coverImageView.af_setImageWithURL(NSURL(string: self.dungeon.cover)!)
        if let loggedUser = Util.loggedUser {
            if let avatarUrl = NSURL(string: loggedUser.avatarUrl) {
                self.avatarImageView.af_setImageWithURL(avatarUrl)
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
