//
//  YNSegue.swift
//  YNSwift
//
//  Created by Yoncise on 1/8/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

public class YNSegue: UIStoryboardSegue {
    var source: UIViewController
    public var instantiated: UIViewController
    
    class func instantiateViewControllerWithIdentifier(identifier: String) -> UIViewController {
        let info = identifier.componentsSeparatedByString("@")
        let storyboardId = info[0]
        let storyboardName = info[1]
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        if storyboardId.characters.count == 0 {
            return storyboard.instantiateInitialViewController()!
        } else {
            return storyboard.instantiateViewControllerWithIdentifier(storyboardId)
        }
    }
    
    override init(identifier: String!, source: UIViewController, destination: UIViewController) {
        self.source = source
        self.instantiated = YNSegue.instantiateViewControllerWithIdentifier(identifier)
        super.init(identifier: identifier, source: source, destination: destination)
    }
}

