//
//  DeveloperViewController.swift
//  PlayTask
//
//  Created by Yoncise on 2/28/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class DeveloperViewController: UITableViewController {
    
    @IBOutlet var apiRootTextField: UITextField! {
        didSet {
            self.apiRootTextField.text = Config.API.ROOT
        }
    }
        
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        #if DEBUG
            Config.API.ROOT = self.apiRootTextField.text!
        #endif
    }
}
