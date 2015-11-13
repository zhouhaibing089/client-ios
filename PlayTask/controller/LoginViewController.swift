//
//  LoginViewController.swift
//  PlayTask
//
//  Created by Yoncise on 11/2/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import CRToast
import YNSwift
import MBProgressHUD

class LoginViewController: UITableViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func login(sender: UIButton) {
        let account = self.accountTextField.text!
        let password = self.passwordTextField.text!
        
        if account == "" {
            CRToastManager.showNotificationWithMessage("请输入用户名 或 邮箱", completionBlock: nil)
            return
        }
        if password == "" {
            CRToastManager.showNotificationWithMessage("请输入密码", completionBlock: nil)
            return
        }
        let hud = MBProgressHUD.show()
        API.loginWithAccount(account, password: password).subscribe { event in
            switch event {
            case .Next(_):
                Util.appDelegate.synchronize()
                hud.switchToSuccess(duration: 1, labelText: "登录成功") {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
                break
            case .Error(let error):
                hud.hide(true)
                guard let e = error as? APIError else {
                    break
                }
                switch e {
                case .Custom(_, let info, _):
                    CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                    break
                default:
                    break
                }
                break
            default:
                break
            }
        }
    }
}
