//
//  BalanceDetailViewController.swift
//  PlayTask
//
//  Created by Yoncise on 4/28/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class BalanceDetailViewController: UITableViewController {
    
    var balanceDetails = [[BalanceDetail]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44
        self.refresh()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.balanceDetails.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.balanceDetails[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("balance_detail", forIndexPath: indexPath) as! BalanceDetailTableViewCell
        cell.balanceDetail = self.balanceDetails[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func refresh() {
        var details = [BalanceDetail]()
        API.getBalanceDetailsOfUser(Util.loggedUser!.sid.value!, before: nil).subscribe(APISubscriber(onNext: { (n: BalanceDetail) in
            details.append(n)
            }, onCompleted: {
                self.balanceDetails.append(details)
                self.update()
        }))
    }
    
    func update() {
        self.tableView.reloadData()
    }

}
