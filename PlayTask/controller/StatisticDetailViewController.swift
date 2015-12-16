//
//  StatisticDetailViewController.swift
//  PlayTask
//
//  Created by Yoncise on 12/11/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import Charts

class StatisticDetailViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var bubbleView: BubbleView! {
        didSet {
            let left =  UISwipeGestureRecognizer(target: self, action: "swipe:")
            left.direction = UISwipeGestureRecognizerDirection.Left
            let right = UISwipeGestureRecognizer(target: self, action: "swipe:")
            right.direction = UISwipeGestureRecognizerDirection.Right
            self.bubbleView.addGestureRecognizer(left)
            self.bubbleView.addGestureRecognizer(right)
        }
    }
    
    func swipe(gesture: UISwipeGestureRecognizer) {
        var index = self.pieChartView.indexForAngle(90)
        let max = self.dataSet.entryCount
        if gesture.direction == UISwipeGestureRecognizerDirection.Right {
            index++
            if index >= max {
                index = 0
            }
        } else if gesture.direction == UISwipeGestureRecognizerDirection.Left {
            index--
            if index < 0 {
                index = max - 1
            }
        }
        self.spintToIndex(index)
    }
    
    @IBOutlet weak var pieWidthConstraint: NSLayoutConstraint!
    var panTimer: NSTimer?
    
    @IBOutlet weak var pieChartView: PieChartView! {
        didSet {
            self.pieChartView.legend.enabled = false
            self.pieChartView.drawSliceTextEnabled = false
            self.pieChartView.descriptionText = ""
            self.pieChartView.highlightPerTapEnabled = true
            let animationDuration = 1.2
            self.pieChartView.animate(xAxisDuration: animationDuration)
            NSTimer.delay(animationDuration) {
                self.spintToIndex(self.pieChartView.indexForAngle(90))
            }
            self.pieChartView.delegate = self
            let gesture = UIPanGestureRecognizer(target: self, action: "pan:")
            gesture.cancelsTouchesInView = false
            self.pieChartView.addGestureRecognizer(gesture)
        }
    }
    
    func pan(gesture: UIGestureRecognizer) {
        self.panTimer?.invalidate()
        if gesture.state == UIGestureRecognizerState.Ended {
            self.panTimer = NSTimer.delay(0.6) {
                self.spintToIndex(self.pieChartView.indexForAngle(90))
            }
        } else if gesture.state == UIGestureRecognizerState.Began {
            self.pieChartView.highlightValue(xIndex: -1, dataSetIndex: 0, callDelegate: false)
        }
    }
    
    
    var dataSet = PieChartDataSet(yVals: [])

    var period = Period.Week
    var type = StatisticType.Income
    // xIndex: (title, count, sum)
    var descriptions = [Int: (String, Int, Int)]()
    var sum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.mainScreen().bounds.height == 480 {
            // 小屏幕手机缩小饼图的尺寸
            self.pieWidthConstraint.constant = 240
        }
        
        // add colors
        self.dataSet.colors.append(UIColor(hexValue: 0xFF5E3A))
        self.dataSet.colors.append(UIColor(hexValue: 0xFF9500))
        self.dataSet.colors.append(UIColor(hexValue: 0xFFDB4C))
        self.dataSet.colors.append(UIColor(hexValue: 0x87FC70))
        self.dataSet.colors.append(UIColor(hexValue: 0x5AC8FB))
        self.dataSet.colors.append(UIColor(hexValue: 0x1AD6FD))
        self.dataSet.colors.append(UIColor(hexValue: 0xC644FC))
        self.dataSet.colors.append(UIColor(hexValue: 0xEF4DB6))
        
        self.dataSet.colors.append(UIColor(hexValue: 0xFF2A68))
        self.dataSet.colors.append(UIColor(hexValue: 0xFF5E3A))
        self.dataSet.colors.append(UIColor(hexValue: 0xFFCD02))
        self.dataSet.colors.append(UIColor(hexValue: 0x0BD318))
        self.dataSet.colors.append(UIColor(hexValue: 0x5AC8FB))
        self.dataSet.colors.append(UIColor(hexValue: 0x1D62F0))
        self.dataSet.colors.append(UIColor(hexValue: 0x5856D6))
        self.dataSet.colors.append(UIColor(hexValue: 0xC643FC))


        self.dataSet.drawValuesEnabled = false
        self.dataSet.sliceSpace = 2
        
        let now = NSDate()
        var begin: NSDate, end: NSDate
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
        }
        var centerText = ""
        switch self.type {
        case .Income:
            centerText += "收入\n"
            var entries = [String: ChartDataEntry]()
            var xVals = [String]()
            let bills = TaskHistory.getTaskHistoriesBetween(begin, and: end)
            bills.map({ bill in
                self.sum += bill.getBillScore()
                if let entry = entries[bill.getBillTitle()] {
                    entry.value += Double(bill.getBillScore())
                    var desc = self.descriptions[entry.xIndex]!
                    desc.1++
                    desc.2 += bill.getBillScore()
                    self.descriptions[entry.xIndex] = desc
                } else {
                    self.descriptions[xVals.count] = (bill.getBillTitle(), 1, bill.getBillScore())
                    entries[bill.getBillTitle()] = ChartDataEntry(value: Double(bill.getBillScore()), xIndex: xVals.count)
                    xVals.append(bill.getBillTitle())
                }
            })
            self.dataSet.clear()
            for (_, entry) in entries {
                self.dataSet.addEntryOrdered(entry)
            }
            self.pieChartView.data = PieChartData(xVals: xVals, dataSet: self.dataSet)
            break
        case .Outcome:
            centerText += "支出\n"
            var entries = [String: ChartDataEntry]()
            var xVals = [String]()
            let bills = WishHistory.getWishHistoriesBetween(begin, and: end)
            bills.map({ bill in
                self.sum += abs(bill.getBillScore())
                if let entry = entries[bill.getBillTitle()] {
                    entry.value += Double(abs(bill.getBillScore()))
                    var desc = self.descriptions[entry.xIndex]!
                    desc.1++
                    desc.2 += abs(bill.getBillScore())
                    self.descriptions[entry.xIndex] = desc
                } else {
                    self.descriptions[xVals.count] = (bill.getBillTitle(), 1, -bill.getBillScore())
                    entries[bill.getBillTitle()] = ChartDataEntry(value: Double(abs(bill.getBillScore())), xIndex: xVals.count)
                    xVals.append(bill.getBillTitle())
                }
            })
            self.dataSet.clear()
            for (_, entry) in entries {
                self.dataSet.addEntryOrdered(entry)
            }
            self.pieChartView.data = PieChartData(xVals: xVals, dataSet: self.dataSet)
            break
        case .Balance:
            centerText += "结余\n"
            var xVals = [String]()
            var entries = [ChartDataEntry(value: 0, xIndex: 0), ChartDataEntry(value: 0, xIndex: 1)]
            self.descriptions[0] = ("收入", 0, 0)
            self.descriptions[1] = ("支出", 0, 0)
            
            var bills = TaskHistory.getTaskHistoriesBetween(begin, and: end).map({ $0 as Bill })
            bills.appendContentsOf(WishHistory.getWishHistoriesBetween(begin, and: end).map({ $0 }))
            bills.map({ bill in
                self.sum += bill.getBillScore()
                if let bill = bill as? TaskHistory {
                    entries[0].value += Double(bill.getBillScore())
                    var desc = self.descriptions[0]!
                    desc.1++
                    desc.2 += abs(bill.getBillScore())
                    self.descriptions[0] = desc
                } else {
                    entries[1].value += Double(abs(bill.getBillScore()))
                    var desc = self.descriptions[1]!
                    desc.1++
                    desc.2 += abs(bill.getBillScore())
                    self.descriptions[1] = desc
                }
            })
            if entries[0].value != 0 {
                self.dataSet.addEntryOrdered(entries[0])
                xVals.append("收入")
            }
            if entries[1].value != 0 {
                self.dataSet.addEntryOrdered(entries[1])
                xVals.append("支出")
            }
            self.pieChartView.data = PieChartData(xVals: xVals, dataSet: self.dataSet)
            break
        }
        if self.sum > 10000 {
            centerText += String(format:"%dk成就", self.sum / 1000)
        } else {
            centerText += "\(self.sum)成就"
        }
        
        let nscenterText = centerText as NSString
        
        let rangeFull = NSMakeRange(0, nscenterText.length)
        let rangeTop = NSMakeRange(0, 3)
        let rangeBottom = NSMakeRange(3, nscenterText.length - 3)
        
        
        let centerAttributedText = NSMutableAttributedString(string: centerText)
    
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        centerAttributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: rangeFull)
        centerAttributedText.addAttributes([
            NSFontAttributeName: UIFont.boldSystemFontOfSize(17),
            NSForegroundColorAttributeName: UIColor(hexValue: 0xbbbbbb)], range: rangeTop)
        centerAttributedText.addAttributes([
            NSForegroundColorAttributeName: UIColor(hexValue: 0x44484a),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(18),
            ], range: rangeBottom)
        self.pieChartView.centerAttributedText = centerAttributedText
        self.updateBubble(self.pieChartView.indexForAngle(90))

    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        self.spintToIndex(entry.xIndex)
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        self.pieChartView.highlightValue(xIndex: self.pieChartView.indexForAngle(90), dataSetIndex: 0, callDelegate: false)
    }
    
    func spintToIndex(index: Int) {
        if index < 0 {
            return
        }
        let rotationAngle = self.pieChartView.rotationAngle
        let angle = self.pieChartView.drawAngles[index]
        let absAngle = self.pieChartView.absoluteAngles[index]
        var offset = 90 - (rotationAngle + absAngle - angle / 2) % 360
        if offset < -180 {
            offset += 360
        }
        self.pieChartView.spin(duration: 0.6, fromAngle: rotationAngle, toAngle: rotationAngle + offset, easingOption: ChartEasingOption.EaseOutBack)
        self.pieChartView.highlightValue(xIndex: index, dataSetIndex: 0, callDelegate: false)
        NSTimer.delay(0.6) { () -> Void in
            self.updateBubble(index)
        }
    }
    
    func updateBubble(index: Int) {
        let desc = self.descriptions[index]!
        var title = "", count = "", sum = ""
        switch self.type {
        case .Income:
            title = desc.0
            count = " 完成\(desc.1)次"
            sum = " 收入\(desc.2)成就"
            break
        case .Outcome:
            title = desc.0
            count = " 消费\(desc.1)次"
            sum = " 花费\(desc.2)成就"
            break
        case .Balance:
            title = desc.0
            sum = " \(desc.2)成就"
            self.bubbleView.contentLabel.text = "\(desc.0)\(desc.2)成就"
            break
        }
        let attributedText = NSMutableAttributedString()
        attributedText.appendAttributedString(NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(17),
            NSForegroundColorAttributeName: UIColor(hexValue: 0x44484a)]))
        attributedText.appendAttributedString(NSAttributedString(string: count, attributes: [NSForegroundColorAttributeName: UIColor(hexValue: 0x44484a)]))
        attributedText.appendAttributedString(NSAttributedString(string: sum, attributes: [NSForegroundColorAttributeName: UIColor(hexValue: 0x44484a)]))
        self.bubbleView.contentLabel.attributedText = attributedText
        self.bubbleView.setNeedsDisplay()
    }

}
