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
    @IBOutlet weak var loopSegmentControl: UISegmentedControl!
    
    var onWishAdded: ((Wish) -> Void)?
    var modifiedWish: Wish?
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let w = self.modifiedWish {
            self.titleTextField.text = w.title
            self.scoreTextField.text = "\(w.score)"
            self.loopSegmentControl.selectedSegmentIndex = w.loop == 0 ? 1 : 0
            self.navigationItem.title = "编辑欲望"
        }
    }
    
    @IBAction func addWish(sender: UIBarButtonItem) {
        let title = self.titleTextField.text!
        let score = self.scoreTextField.text!
        if title == "" {
            CRToastManager.showNotificationWithMessage("请输入标题", completionBlock: nil)
            return
        }
        if score == "" {
            CRToastManager.showNotificationWithMessage("请输入消耗的成就点数", completionBlock: nil)
            return
        }
        if Int(score) == nil {
            CRToastManager.showNotificationWithMessage("请输入合理的成就点数（不支持小数）", completionBlock: nil)
            return
        }
        let loop = self.loopSegmentControl.selectedSegmentIndex == 0 ? 1 : 0
        let wish = Wish(title: title, score: Int(score)!, loop: loop)
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
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return MobClick.getConfigParams("newWishGuide")
    }
    
}
