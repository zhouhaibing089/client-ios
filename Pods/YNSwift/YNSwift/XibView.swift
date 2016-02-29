//
//  XibView.swift
//  YNSwift
//
//  Created by Yoncise on 12/14/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

public class XibView: UIView {

    public var contentView: UIView!
    public var xibName: String {
        return String(self.dynamicType)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // XCode bug
    // IBdesignable will rendered failed if you don't override this method
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override public func prepareForInterfaceBuilder() {
        self.setup()
    }

    public func setup() {
        self.contentView = NSBundle(forClass: self.dynamicType).loadNibNamed(self.xibName, owner: self, options: nil)[0] as! UIView
        self.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }

}
