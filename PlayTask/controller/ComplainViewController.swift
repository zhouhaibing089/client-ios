//
//  ComplainViewController.swift
//  PlayTask
//
//  Created by Yoncise on 2/28/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift
import CRToast
import MBProgressHUD

class ComplainViewController: UITableViewController {
    
    var dungeon: Dungeon!

    @IBOutlet var contentTextView: YNTextView! {
        didSet {
            self.contentTextView.minHeight = 33 * 8 / UIScreen.screenScale
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.contentTextView.becomeFirstResponder()
    }
    
    @IBAction func send(sender: UIBarButtonItem) {
        let content = self.contentTextView.text
        if content == "" {
            return
        }
        let hud = MBProgressHUD.show()
        API.complain(self.dungeon, content: content).subscribe { (event) -> Void in
            switch event {
            case .Completed:
                hud.switchToSuccess(duration: 1, labelText: "发送成功", completionBlock: { [unowned self] in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                break
            case .Next(let n):
                break
            case .Error(let e):
                if let error = e as? APIError {
                    switch error {
                    case .Custom(_, let info, _):
                        CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                        break
                    default:
                        break
                    }
                }
                hud.hide(true)
            }
        }
        
    }
}
