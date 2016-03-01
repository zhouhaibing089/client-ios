//
//  DungeonEmbeddedViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/13/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift

class DungeonEmbeddedViewController: UITableViewController, UIWebViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailWebView: UIWebView!
    @IBOutlet weak var coverImageView: UIImageView!
    var dungeon: Dungeon!
    var topInset: CGFloat = 0
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailWebView.delegate = self
        self.detailWebView.scrollView.bounces = false
        self.tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        
        self.update()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // static table view need override this method if you
        // want to calculate cell height automaticly
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.webViewHeightConstraint.constant = self.detailWebView.scrollView.contentSize.height
        self.tableView.reloadData()
    }
    
    func update() {
        self.titleLabel.text = self.dungeon.title
        self.coverImageView.af_setImageWithURL(NSURL(string: self.dungeon.cover)!)
        self.detailWebView.loadHTMLString(self.dungeon.detail!, baseURL: nil)
    }

}
