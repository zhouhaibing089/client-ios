//
//  BillViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class BillViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var monthSelector: UIView! {
        didSet {
            let hairLine = CALayer()
            hairLine.frame = CGRect(x: self.monthSelector.bounds.origin.x, y: self.monthSelector.bounds.origin.y + self.monthSelector.bounds.height - 1, width: self.monthSelector.bounds.width, height: 1)
            hairLine.backgroundColor = UIColor.lightGrayColor().CGColor
            self.monthSelector.layer.addSublayer(hairLine)
        }
    }
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var prevMonthButton: UIButton!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBAction func prevMonth(sender: UIButton) {
        self.selectedMonth = self.selectedMonth.addMonth(-1)
    }
    @IBAction func nextMonth(sender: UIButton) {
        self.selectedMonth = self.selectedMonth.addMonth(1)
    }

    @IBOutlet weak var tableView: UITableView!
    var billItems: [[Bill]]!
    
    let monthMap = [
        1: "一", 2: "二", 3: "三", 4: "四", 5: "五", 6: "六",
        7: "七", 8: "八", 9: "九", 10: "十", 11: "十一", 12: "十二"
        
    ]
    var selectedMonth: NSDate! {
        didSet {
            let month = self.selectedMonth.getComponents().month
            let year = self.selectedMonth.getComponents().year
            let currentYear = NSDate().getComponents().year
            let currentMonth = NSDate().getComponents().month
            self.nextMonthButton.enabled = !(year == currentYear && month == currentMonth)
            if year == currentYear {
                self.monthLabel.text = "\(self.monthMap[month]!)月"
            } else {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy年M月"
                self.monthLabel.text = formatter.stringFromDate(self.selectedMonth)
            }
            self.refresh()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedMonth = NSDate().beginOfMonth()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.billItems.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.billItems[section].count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bill_item", forIndexPath: indexPath) as! BillItemTableViewCell
        
        cell.billItem = self.billItems[indexPath.section][indexPath.row]
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let billItem = self.billItems[indexPath.section][indexPath.row]

            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "仅删除", style: UIAlertActionStyle.Destructive, handler: { _ in
                billItem.delete()
                self.billItems[indexPath.section].removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }))
            if billItem.getBronze() == 0 {
                actionSheet.addAction(UIAlertAction(title: "删除并恢复成就", style: UIAlertActionStyle.Default, handler: { _ in
                    billItem.cancel()
                    billItem.delete()
                    self.billItems[indexPath.section].removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }))
            }
            actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    let weekday = [
        1: "日",
        2: "一",
        3: "二",
        4: "三",
        5: "四",
        6: "五",
        7: "六"
    ]
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let component = self.billItems[section].first?.getBillTime().getComponents() {
            return "\(component.day)日 - 星期\(self.weekday[component.weekday]!)"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel?.textColor = UIColor.grayColor()
        header.textLabel?.font = UIFont.systemFontOfSize(15)
        header.textLabel?.frame = header.frame
    }
    
    func refresh() {
        self.billItems = [[Bill]]()
        var bills = [Bill]()
        let th: [Bill] = TaskHistory.getTaskHistoriesBetween(self.selectedMonth, and: self.selectedMonth.endOfMonth()).map({ $0 })
        let wh: [Bill] = WishHistory.getWishHistoriesBetween(self.selectedMonth, and: self.selectedMonth.endOfMonth()).map({ $0 })
        bills.appendContentsOf(th)
        bills.appendContentsOf(wh)
        
        bills = bills.sort {
            return $0.getBillTime().compare($1.getBillTime()) == NSComparisonResult.OrderedDescending
        }
        var currentDay = 0
        _ = bills.map { bill in
            let day = bill.getBillTime().getComponents().day
            if day != currentDay {
                let count = self.billItems.count
                self.billItems.append([Bill]())
                self.billItems[count].append(bill)
                currentDay = day
            } else {
                self.billItems[self.billItems.count - 1].append(bill)
            }
        }
        self.tableView.reloadData()
    }

}
