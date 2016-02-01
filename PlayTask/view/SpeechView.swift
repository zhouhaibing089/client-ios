//
//  SpeechView.swift
//  PlayTask
//
//  Created by Yoncise on 2/1/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

@IBDesignable
class SpeechView: UIView {
    
    enum Edge {
        case Top
        case Left
        case Bottom
        case Right
    }
    
    enum Position {
        case Leading
        case Center
        case Trailing
    }
    
    var edge = Edge.Top
    var position = Position.Leading
    @IBInspectable
    var positionOffset: CGFloat = 0
    @IBInspectable
    var pointerSize: CGSize = CGSizeMake(12, 6 * 1.732)
    @IBInspectable
    var borderRadius: CGFloat = 0
    @IBInspectable
    var color: UIColor = UIColor.lightGrayColor()

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        self.color.setFill()
        self.color.setStroke()
        
        // speech rect origin and size
        var x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = self.bounds.width, height: CGFloat = self.bounds.size.height
        
        // pointer rect
        var pointerRect = CGRectZero
        pointerRect.size = self.pointerSize
        switch self.edge {
        case .Top:
            y = self.pointerSize.height
            height -= y
            switch self.position {
            case .Leading:
                break
            case .Center:
                pointerRect.origin.x = (self.bounds.width - self.pointerSize.width) / 2
                break
            case .Trailing:
                pointerRect.origin.x = self.bounds.width - self.pointerSize.width
                break
            }
            pointerRect.origin.x += self.positionOffset
            break
        case .Left:
            x = self.pointerSize.width
            width -= x
            switch self.position {
            case .Leading:
                break
            case .Center:
                pointerRect.origin.y = (self.bounds.height - self.pointerSize.height) / 2
                break
            case .Trailing:
                pointerRect.origin.y = self.bounds.height - self.pointerSize.height
                break
            }
            pointerRect.origin.y += self.positionOffset
            break
        case .Bottom:
            height -= self.pointerSize.height
            pointerRect.origin.y = height
            switch self.position {
            case .Leading:
                break
            case .Center:
                pointerRect.origin.x = (self.bounds.width - self.pointerSize.width) / 2
                break
            case .Trailing:
                pointerRect.origin.x = self.bounds.width - self.pointerSize.width
                break
            }
            pointerRect.origin.x += self.positionOffset
            break
        case .Right:
            width -= self.pointerSize.width
            pointerRect.origin.x = width
            switch self.position {
            case .Leading:
                break
            case .Center:
                pointerRect.origin.y = (self.bounds.height - self.pointerSize.height) / 2
                break
            case .Trailing:
                pointerRect.origin.y = self.bounds.height - self.pointerSize.height
                break
            }
            pointerRect.origin.y += self.positionOffset
            break
        }
        let border = CGRectMake(x, y, width, height)
        let borderPath = UIBezierPath(roundedRect: border, cornerRadius: self.borderRadius)
        borderPath.fill()
        borderPath.stroke()
        
        let pointerPath = UIBezierPath()
        switch self.edge {
        case .Top:
            pointerPath.moveToPoint(pointerRect.bottomLeft())
            pointerPath.addLineToPoint(pointerRect.topCenter())
            pointerPath.addLineToPoint(pointerRect.bottomRight())
            break
        case .Left:
            pointerPath.moveToPoint(pointerRect.bottomRight())
            pointerPath.addLineToPoint(pointerRect.centerLeft())
            pointerPath.addLineToPoint(pointerRect.topRight())
            break
        case .Bottom:
            pointerPath.moveToPoint(pointerRect.topLeft())
            pointerPath.addLineToPoint(pointerRect.bottomCenter())
            pointerPath.addLineToPoint(pointerRect.topRight())
            break
        case .Right:
            pointerPath.moveToPoint(pointerRect.topLeft())
            pointerPath.addLineToPoint(pointerRect.centerRight())
            pointerPath.addLineToPoint(pointerRect.bottomLeft())
            break
        }
        pointerPath.closePath()
        pointerPath.fill()
    }
}

extension CGRect {
    func topLeft() -> CGPoint {
        return CGPoint(x: self.origin.x, y: self.origin.y)
    }
    
    func topCenter() -> CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y)
    }
    
    func topRight() -> CGPoint {
        return CGPoint(x: self.origin.x + self.width, y: self.origin.y)
    }
    
    func centerLeft() -> CGPoint {
        return CGPoint(x: self.origin.x, y: self.origin.y + self.height / 2)

    }
    
    func centerRight() -> CGPoint {
        return CGPoint(x: self.origin.x + self.width, y: self.origin.y + self.height / 2)

    }
    
    func bottomLeft() -> CGPoint {
        return CGPoint(x: self.origin.x, y: self.origin.y + self.height)

    }
    
    func bottomCenter() -> CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y + self.height)

    }
    
    func bottomRight() -> CGPoint {
        return CGPoint(x: self.origin.x + self.width, y: self.origin.y +  self.height)

    }
}
