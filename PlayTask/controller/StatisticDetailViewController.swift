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
        if gesture.state == UIGestureRecognizerState.Ended {
            NSTimer.delay(0.6) {
                self.spintToIndex(self.pieChartView.indexForAngle(90))
            }
        } else if gesture.state == UIGestureRecognizerState.Began {
            self.pieChartView.highlightValue(xIndex: -1, dataSetIndex: 0, callDelegate: false)
        }
    }
    
    
    var dataSet = PieChartDataSet(yVals: [])

    var period = Period.Week
    var type = StatisticType.Income
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add colors
        self.dataSet.colors.appendContentsOf(ChartColorTemplates.vordiplom())
        self.dataSet.colors.appendContentsOf(ChartColorTemplates.joyful())
        self.dataSet.colors.appendContentsOf(ChartColorTemplates.colorful())
        self.dataSet.colors.appendContentsOf(ChartColorTemplates.liberty())
        self.dataSet.colors.appendContentsOf(ChartColorTemplates.pastel())
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
        switch self.type {
        case .Income:
            var entries = [String: ChartDataEntry]()
            var xVals = [String]()
            let bills = TaskHistory.getTaskHistoriesBetween(begin, and: end)
            bills.map({ bill in
                if let entry = entries[bill.getBillTitle()] {
                    entry.value += Double(bill.getBillScore())
                } else {
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
            break
        case .Balance:
            break
        }
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        self.spintToIndex(entry.xIndex)
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        self.pieChartView.highlightValue(xIndex: self.pieChartView.indexForAngle(90), dataSetIndex: 0, callDelegate: false)
    }
    
    func spintToIndex(index: Int) {
        let rotationAngle = self.pieChartView.rotationAngle
        let angle = self.pieChartView.drawAngles[index]
        let absAngle = self.pieChartView.absoluteAngles[index]
        var offset = 90 - (rotationAngle + absAngle - angle / 2) % 360
        if offset < -180 {
            offset += 360
        }
        self.pieChartView.spin(duration: 0.6, fromAngle: rotationAngle, toAngle: rotationAngle + offset, easingOption: ChartEasingOption.EaseOutBack)
        self.pieChartView.highlightValue(xIndex: index, dataSetIndex: 0, callDelegate: false)
    }

}
