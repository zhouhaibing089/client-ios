//
//  DungeonEmbeddedViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/13/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift

class DungeonEmbeddedViewController: UITableViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    var dungeon: Dungeon!
    var topInset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        
        self.update()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func update() {
        self.coverImageView.af_setImageWithURL(NSURL(string: self.dungeon.cover)!)
        self.detailLabel.attributedText = NSAttributedString(html: self.dungeon.detail)
    }

}
