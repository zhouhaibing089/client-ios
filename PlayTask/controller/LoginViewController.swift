//
//  LoginViewController.swift
//  PlayTask
//
//  Created by Yoncise on 11/2/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class LoginViewController: UITableViewController {

    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
