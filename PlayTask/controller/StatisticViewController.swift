//
//  StatisticViewController.swift
//  PlayTask
//
//  Created by Yoncise on 12/8/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class StatisticViewController: UIViewController, UIToolbarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var hairline: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var periodSegmentControl: UISegmentedControl!
    var period: Period {
        get {
            return Period(rawValue: self.periodSegmentControl.selectedSegmentIndex)!
        }
    }
    
    @IBAction func changePeriod(sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbar.delegate = self
        let navigationBar = self.navigationController!.navigationBar
        for parent in navigationBar.subviews {
            for childView in parent.subviews {
                if let imageView = childView as? UIImageView {
                    if childView.frame.size.width == navigationBar.frame.size.width && childView.frame.size.height <= 1.0  {
                        self.hairline = imageView
                        break
                    }
                }
            }
        }
        // iOS bug, remove navigation grey block on right of navigation bar
        self.navigationController?.view.backgroundColor = UIColor.whiteColor();
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        self.tableView.contentInset = UIEdgeInsets(top: self.toolbar.frame.height + self.toolbar.frame.origin.y + 4, left: 0, bottom: 0, right: 0)


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MobClick.beginLogPageView("statistic")
        self.hairline.hidden = true
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("statistic")
        self.hairline.hidden = false
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("line_chart", forIndexPath: indexPath) as! StatisticTableViewCell
        switch indexPath.row {
        case 0:
            cell.title = "收入"
            cell.data = self.getData(.Income)
            cell.average = self.getAverage(.Income)
            cell.sum = self.getSum(.Income)
            cell.time = self.getTime(.Income)
            break
        case 1:
            cell.title = "支出"
            cell.data = self.getData(.Outcome)
            cell.average = self.getAverage(.Outcome)
            cell.sum = self.getSum(.Outcome)
            cell.time = self.getTime(.Outcome)
            break
        case 2:
            cell.title = "结余"
            cell.data = self.getData(.Balance)
            cell.average = self.getAverage(.Balance)
            cell.sum = self.getSum(.Balance)
            cell.time = self.getTime(.Balance)
        default:
            break
        }
        cell.update()
        return cell
    }
    
    func getData(statisticType: StatisticType) -> LineChartData {
        let now = NSDate()
        let nowComp = now.getComponents()
        var begin: NSDate
        var end: NSDate
        switch self.period {
        case .Day:
            begin = now.beginOfDay()
            end = now.endOfDay()
            break
        case .Week:
            begin = now.beginOfDay().addDay(-6)
            end = now.endOfDay()
            break
        case .Month:
            begin = now.beginOfDay().addDay(-30)
            end = now.endOfDay()
            break
        case .Year:
            begin = now.beginOfYear()
            end = now.endOfYear()
            break
        }
        var bills: [Bill]
        switch statisticType {
        case .Income:
            bills = TaskHistory.getTaskHistoriesBetween(begin, and: end).filter("task.score > 0").map { $0 as Bill }
            break
        case .Outcome:
            bills = WishHistory.getWishHistoriesBetween(begin, and: end).map({ $0 })
            break
        case .Balance:
            bills = TaskHistory.getTaskHistoriesBetween(begin, and: end).filter("task.score > 0").map({ $0 })
            bills.appendContentsOf(WishHistory.getWishHistoriesBetween(begin, and: end).map({ $0 }))
            break
        }
        switch self.period {
        case .Day:
            let dataSet = LineChartDataSet(yVals: [])
            var entries = [Int: ChartDataEntry]()
            var xVars = [String]()
            for index in 0...23 {
                xVars.append("\((index + 2) % 24)")
            }
            xVars.append("2")
            bills.map({ (bill) in
                var index = bill.getBillTime().getComponents().hour - 2
                if bill.getBillTime().getComponents().day != begin.getComponents().day {
                    // 第二天
                    index += 24
                }
                let score = statisticType == StatisticType.Outcome ? abs(bill.getBillScore()) : bill.getBillScore()
                if let entry = entries[index] {
                    entry.value += Double(score)
                } else {
                    entries[index] = ChartDataEntry(value: Double(score), xIndex: index)
                }
            })
            // 因为 ios-charts 的 bug, notifyDataSetChanged 对于负值的 sum 的计算有
            // 问题, 所以借助 dict 来添加 entry
            for (_, entry) in entries {
                dataSet.addEntryOrdered(entry)
            }
            return LineChartData(xVals: xVars, dataSet: dataSet)
        case .Week:
            let dataSet = LineChartDataSet(yVals: [])
            var entries = [Int: ChartDataEntry]()
            var xVars = [String]()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d"
            for index in 0...6 {
                xVars.append(dateFormatter.stringFromDate(now.addDay(index - 6)))
            }
            bills.map({ (bill) in
                let index = 6 - end.differenceFrom(bill.getBillTime()).day
                let score = statisticType == StatisticType.Outcome ? abs(bill.getBillScore()) : bill.getBillScore()
                if let entry = entries[index] {
                    entry.value += Double(score)
                } else {
                    entries[index] = ChartDataEntry(value: Double(score), xIndex: index)
                }
            })
            for (_, entry) in entries {
                dataSet.addEntryOrdered(entry)
            }
            return LineChartData(xVals: xVars, dataSet: dataSet)
        case .Month:
            let dataSet = LineChartDataSet(yVals: [])
            var entries = [Int: ChartDataEntry]()
            var xVars = [String]()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d"
            for index in 0...30 {
                xVars.append(dateFormatter.stringFromDate(now.addDay(index - 30)))
            }
            bills.map({ (bill) in
                let index = 30 - end.differenceFrom(bill.getBillTime()).day
                let score = statisticType == StatisticType.Outcome ? abs(bill.getBillScore()) : bill.getBillScore()
                if let entry = entries[index] {
                    entry.value += Double(score)
                } else {
                    entries[index] = ChartDataEntry(value: Double(score), xIndex: index)
                }
                
            })
            for (_, entry) in entries {
                dataSet.addEntryOrdered(entry)
            }
            return LineChartData(xVals: xVars, dataSet: dataSet)
        case .Year:
            let dataSet = LineChartDataSet(yVals: [])
            var entries = [Int: ChartDataEntry]()
            var xVars = [String]()
            for index in 1...12 {
                xVars.append("\(index)月")
            }
            bills.map({ (bill) in
                var index = bill.getBillTime().getComponents().month - 1
                if begin.getComponents().year != bill.getBillTime().getComponents().year {
                    // 第二年 1 月 1 日 2 点前的数据
                    index += 11
                }
                let score = statisticType == StatisticType.Outcome ? abs(bill.getBillScore()) : bill.getBillScore()
                if let entry = entries[index] {
                    entry.value += Double(score)
                } else {
                    entries[index] = ChartDataEntry(value: Double(score), xIndex: index)
                }
                
            })
            for (_, entry) in entries {
                dataSet.addEntryOrdered(entry)
            }
            return LineChartData(xVals: xVars, dataSet: dataSet)
        }
    }
    
    func getAverage(statisticType: StatisticType) -> Double? {
        let now = NSDate()
        var begin: NSDate
        var end: NSDate
        switch self.period {
        case .Day, .Week:
            begin = now.beginOfDay().addDay(-6)
            end = now.endOfDay().addDay(-1)
            break
        case .Month:
            begin = now.beginOfDay().addDay(-30)
            end = now.endOfDay().addDay(-1)
            break
        case .Year:
            begin = now.beginOfYear()
            end = now.endOfDay().addDay(-1)
            break
        }
        var sum: Double = 0
        var bills: [Bill]
        switch statisticType {
        case .Income:
            bills = TaskHistory.getTaskHistoriesBetween(begin, and: end).filter("task.score > 0").map({ $0 })
            bills.map({ sum += Double($0.getBillScore()) })
            break
        case .Outcome:
            bills = WishHistory.getWishHistoriesBetween(begin, and: end).map({ $0 })
            bills.map({ sum += Double(abs($0.getBillScore())) })
            break
        case .Balance:
            bills = TaskHistory.getTaskHistoriesBetween(begin, and: end).filter("task.score > 0").map({ $0 })
            bills.appendContentsOf(WishHistory.getWishHistoriesBetween(begin, and: end).map({ $0 }))
            bills.map({ sum += Double($0.getBillScore()) })
            break
        }
        if let firstDay = bills.first?.getBillTime() {
            return sum / Double(end.differenceFrom(firstDay).day + 1)
        }
        return nil
    }
    
    func getSum(statisticType: StatisticType) -> Int? {
        if self.period != Period.Day {
            return nil
        }
        let begin = NSDate().beginOfDay()
        let end = NSDate().endOfDay()
        var sum = 0
        switch statisticType {
        case .Income:
            let bills = TaskHistory.getTaskHistoriesBetween(begin, and: end).filter("task.score > 0").map({ $0 })
            if bills.count == 0 {
                return nil
            }
            bills.map({ sum += $0.getBillScore() })
            break
        case .Outcome:
            let bills = WishHistory.getWishHistoriesBetween(begin, and: end).map({ $0 })
            if bills.count == 0 {
                return nil
            }
            bills.map({ sum += abs($0.getBillScore()) })
            break
        default:
            var bills: [Bill] = TaskHistory.getTaskHistoriesBetween(begin, and: end).filter("task.score > 0").map({ $0 })
            bills.appendContentsOf(WishHistory.getWishHistoriesBetween(begin, and: end).map({ $0 }))
            if bills.count == 0 {
                return nil
            }
            bills.map({ sum += $0.getBillScore() })
            break
        }
        return sum
    }
    
    func getTime(statisticType: StatisticType) -> NSDate? {
        if self.period != Period.Day {
            return nil
        }
        let begin = NSDate().beginOfDay()
        let end = NSDate().endOfDay()
        switch statisticType {
        case .Income:
            return TaskHistory.getTaskHistoriesBetween(begin, and: end).filter("task.score > 0").last?.getBillTime()
        case .Outcome:
            return WishHistory.getWishHistoriesBetween(begin, and: end).last?.getBillTime()
        default:
            let th = TaskHistory.getTaskHistoriesBetween(begin, and: end).filter("task.score > 0").last?.getBillTime()
            let wh = WishHistory.getWishHistoriesBetween(begin, and: end).last?.getBillTime()
            if let th = th, wh = wh {
                switch th.compare(wh) {
                case .OrderedAscending:
                    return wh
                default:
                    return th
                }
            } else {
                return th ?? wh
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! StatisticTableViewCell
        if cell.data != nil && cell.data.yValCount > 0 {
            self.performSegueWithIdentifier("detail", sender: indexPath.row)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail" {
            if let sdvc = segue.destinationViewController as? StatisticDetailViewController {
                sdvc.type = StatisticType(rawValue: sender as! Int)!
                sdvc.period = self.period
            }
        }
    }

}
