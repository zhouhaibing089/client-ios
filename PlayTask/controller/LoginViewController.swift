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
    
    // true logged in, false in otherwise
    var onResult: ((Bool) -> Void)?

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.onResult?(false)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func forgetPassword(sender: UIButton) {
        let alert = UIAlertController(title: "忘记密码？", message: UMOnlineConfig.getConfigParams("forgetPassword") ?? "暂时还没有实现该功能, 麻烦您关注微信公众号 PlayTask 并联系客服来找回密码, 抱歉!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "好", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
        _ = API.loginWithAccount(account, password: password, deviceToken: Util.deviceToken).subscribe { event in
            switch event {
            case .Next(_):
                Util.appDelegate.sync()
                hud.switchToSuccess(duration: 1, labelText: "登录成功") {
                    self.onResult?(true)
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
