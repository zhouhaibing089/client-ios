//
//  RegisterViewController.swift
//  PlayTask
//
//  Created by Yoncise on 11/3/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import YNSwift
import CRToast
import MBProgressHUD

class RegisterViewController: UITableViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBAction func register(sender: UIButton) {
        let account = self.accountTextField.text!
        let email = self.accountTextField.text!
        let password = self.passwordTextField.text!
        let confirmPassword = self.confirmPasswordTextField.text!
        if account == "" {
            CRToastManager.showNotificationWithMessage("请输入用户名", completionBlock: nil)
            return
        }
        if email == "" {
            CRToastManager.showNotificationWithMessage("请输入邮箱", completionBlock: nil)
            return
        }
        if password == "" {
            CRToastManager.showNotificationWithMessage("请输入密码", completionBlock: nil)
            return
        }
        if confirmPassword != password {
            CRToastManager.showNotificationWithMessage("两次输入的密码不匹配", completionBlock: nil)
            return
        }
        API.registerWithAccount(account, email: email, password: password).subscribe { event in
            switch event {
            case .Next(let user):
                break
            case .Error(let error):
                CRToastManager.showNotificationWithMessage("error", completionBlock: nil)
                break
            default:
                break
            }
        }
    }

}
