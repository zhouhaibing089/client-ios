//
//  NewWishViewController.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import CRToast

class NewWishViewController: UITableViewController {


    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var scoreTextField: UITextField!
    
    var onWishAdded: ((Wish) -> Void)?
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addWish(sender: UIBarButtonItem) {
        let title = self.titleTextField.text
        let score = self.scoreTextField.text
        if title == "" {
            CRToastManager.showNotificationWithMessage("请输入标题", completionBlock: nil)
            return
        }
        if score == "" {
            CRToastManager.showNotificationWithMessage("请输入消耗的成就点数", completionBlock: nil)
            return
        }
        let wish = Wish(title: title!, score: Int64(score!)!, deleted: false)
        wish.save()
        self.onWishAdded?(wish)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("new_wish")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("new_wish")
    }
    
}
