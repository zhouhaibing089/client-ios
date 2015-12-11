//
//  StatisticTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 12/8/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import Charts

class StatisticTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var title: String!
    var average: Double?
    var sum: Int?
    var time: NSDate?
    
    var data: LineChartData! {
        didSet {
            var average: Double = 0
            if let dataSet = self.data.dataSets.first as? LineChartDataSet {
                dataSet.colors = [UIColor.whiteColor()]
                dataSet.circleRadius = 2
                dataSet.circleColors = [UIColor.whiteColor()]
                dataSet.drawFilledEnabled = true
                dataSet.fillColor = UIColor.whiteColor()
                dataSet.fillAlpha = 0.1
                average = dataSet.average
            }
            // 1. you set the customAxisMax and customAxisMin on both left and right of the y-axis.
            // 2. you set the customAxisMax and customAxisMax before you set the .data of the chart view.
            // 3. you set both x and y-axis' startAtZeroEnabled to false. And you set startAtZeroEnabled before you set the .data of the chart view.
            // http://stackoverflow.com/questions/31389081/in-ios-charts-how-to-set-the-maximum-value-for-y-axis
            let leftAxis = self.lineChartView.leftAxis
            leftAxis.resetCustomAxisMax()
            leftAxis.resetCustomAxisMin()
            leftAxis.startAtZeroEnabled = self.data.yValCount == 0

            self.data.setDrawValues(false)
            self.lineChartView.data = self.data
            self.lineChartView.chartXMax
            
            let min = floor(leftAxis.axisMinimum)
            let max = ceil(leftAxis.axisMaximum)
            
            leftAxis.customAxisMax = max
            leftAxis.customAxisMin = min
            
            self.lineChartView.leftAxis.removeAllLimitLines()
            if self.data.yValCount == 0 {
                let topLimitLine = ChartLimitLine(limit: max)
                topLimitLine.lineColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
                topLimitLine.valueTextColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
                topLimitLine.lineWidth = 1
                let bottomLimitLine = ChartLimitLine(limit: 0)
                bottomLimitLine.lineColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
                bottomLimitLine.valueTextColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
                bottomLimitLine.lineWidth = 1
                
                leftAxis.addLimitLine(topLimitLine)
                leftAxis.addLimitLine(bottomLimitLine)
            } else {
                let topLimitLine = ChartLimitLine(limit: max, label: String(format: "%.0f", max))
                topLimitLine.labelPosition = .RightBottom
                topLimitLine.valueTextColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
                topLimitLine.lineColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
                topLimitLine.lineWidth = 1
                let bottomLimitLine = ChartLimitLine(limit: min, label: String(format: "%.0f", min))
                bottomLimitLine.lineColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
                bottomLimitLine.valueTextColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
                bottomLimitLine.lineWidth = 1
                let averageLimitLine = ChartLimitLine(limit: average)
                averageLimitLine.lineColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
                averageLimitLine.lineDashLengths = [2]
                averageLimitLine.lineWidth = 1
                
                leftAxis.addLimitLine(topLimitLine)
                leftAxis.addLimitLine(bottomLimitLine)
                leftAxis.addLimitLine(averageLimitLine)
            }
            self.lineChartView.notifyDataSetChanged()
        }
    }
    
    @IBOutlet weak var gradientView: UIView! {
        didSet {
            self.gradientView.layer.cornerRadius = 4
            self.gradientView.clipsToBounds = true
        }
    }

    @IBOutlet weak var lineChartView: LineChartView! {
        didSet {
            self.lineChartView.backgroundColor = UIColor.clearColor()
            self.lineChartView.gridBackgroundColor = UIColor.clearColor()
            self.lineChartView.legend.enabled = false
            self.lineChartView.descriptionText = ""
            self.lineChartView.userInteractionEnabled = false
            self.lineChartView.noDataText = ""
            self.lineChartView.infoTextColor = UIColor(hexValue: 0xffffff, alpha: 0.9)
            
            let xAxis = self.lineChartView.xAxis
            xAxis.drawGridLinesEnabled = false
            xAxis.labelPosition = .Bottom
            xAxis.drawAxisLineEnabled = false
            xAxis.labelTextColor = UIColor.whiteColor()
            xAxis.avoidFirstLastClippingEnabled = true
            let rightAxis = self.lineChartView.rightAxis
            rightAxis.enabled = false
            let leftAxis = self.lineChartView.leftAxis
            leftAxis.enabled = false
            leftAxis.spaceTop = 0.8
            leftAxis.spaceBottom = 0.8
        }
    }
    
    func update() {
        self.titleLabel.text = self.title
        if let average = self.average {
            self.averageLabel.text = String(format: "日平均值：%.2f", average)
        } else {
            self.averageLabel.text = "日平均值：--"
        }
        if let sum = self.sum {
            self.sumLabel.text = "\(sum) 成就"
        } else {
            self.sumLabel.text = ""
        }
        if let time = self.time {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "今天 HH:mm"
            self.timeLabel.text = dateFormatter.stringFromDate(time)
        } else {
            self.timeLabel.text = ""
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let gradient = self.gradientView.layer.sublayers?[0] as? CAGradientLayer {
            gradient.frame = self.gradientView.bounds
        } else {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = self.gradientView.bounds
            gradient.colors = [UIColor(hexValue: 0x1ad6fd).CGColor, UIColor(hexValue: 0x1d62f0).CGColor]
            self.gradientView.layer.insertSublayer(gradient, atIndex: 0)
        }
    }

}
