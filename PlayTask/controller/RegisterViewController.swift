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
import RxSwift
import MBProgressHUD

class RegisterViewController: UITableViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBAction func register(sender: UIButton) {
        let account = self.accountTextField.text!
        let email = self.emailTextField.text!
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
        let hud = MBProgressHUD.show()
        
        // Xcode bug, 直接将这个 closure 传给 flatMap 函数, 编译不通过报错
        let login: (User) -> Observable<Bool> = { user in
            hud.switchToSuccess(duration: nil, labelText: "注册成功")
            return API.loginWithAccount(account, password: password, deviceToken: Util.deviceToken)
        }
        _ = API.registerWithAccount(account, email: email, password: password).flatMap(login).subscribe { event in
            switch event {
            case .Next(_):
                Util.appDelegate.sync()
                hud.hide(true)
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
