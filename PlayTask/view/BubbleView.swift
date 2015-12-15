//
//  BubbleView.swift
//  PlayTask
//
//  Created by Yoncise on 12/14/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import YNSwift

@IBDesignable
class BubbleView: XibView {

    @IBOutlet weak var contentLabel: UILabel!
    
    var triangleLength: CGFloat = 12
    
    override var xibName: String {
        return "Bubble"
    }
    
    override func setup() {
        super.setup()
        self.contentView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
        self.triangleLength = 12
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let topLeft = CGPoint(x: rect.origin.x, y: rect.origin.y)
        
        let edgeRect = CGRect(x: topLeft.x, y: topLeft.y + self.triangleLength, width: rect.size.width, height: rect.size.height - self.triangleLength)
        let edge = UIBezierPath(roundedRect: edgeRect, cornerRadius: 3)
        UIColor(hexValue: 0xdddddd).setStroke()
        UIColor.whiteColor().setFill()
        edge.stroke()
        edge.fill()
        
        let triangle = UIBezierPath()
        triangle.moveToPoint(CGPoint(x: topLeft.x + rect.size.width / 2 - self.triangleLength / 2, y: topLeft.y + self.triangleLength))
        triangle.addLineToPoint(CGPoint(x: topLeft.x + rect.size.width / 2, y: topLeft.y + self.triangleLength - self.triangleLength / 2 * 1.732))
        triangle.addLineToPoint(CGPoint(x: topLeft.x + rect.size.width / 2 + self.triangleLength / 2, y: topLeft.y + self.triangleLength))
        triangle.stroke()
        
        triangle.closePath()
        triangle.fill()
    }

}
