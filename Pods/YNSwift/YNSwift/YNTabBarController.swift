//
//  YNTabBarController.swift
//  PlayTask
//
//  Created by Yoncise on 1/9/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

public class YNTabBarController: UITabBarController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        for viewController in self.viewControllers! {
            // Get storyboard name
            guard let restorationIdentifier = viewController.restorationIdentifier else {
                return
            }
            // Ensure that view controller is an instance of navigation controller
            guard let viewController = viewController as? UINavigationController else {
                return
            }
            // Load storyboard
            let storyboard = UIStoryboard(name: restorationIdentifier, bundle: nil)
            if let initialViewController = storyboard.instantiateInitialViewController() {
                viewController.pushViewController(initialViewController, animated: false)
            }
        }
    }

}
