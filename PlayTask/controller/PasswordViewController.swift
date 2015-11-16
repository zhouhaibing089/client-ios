//
//  PasswordViewController.swift
//  PlayTask
//
//  Created by Yoncise on 11/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit
import CRToast
import YNSwift
import MBProgressHUD

class PasswordViewController: UITableViewController {

    @IBOutlet weak var oldPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBAction func changePassword(sender: UIButton) {
        let oldPassword = self.oldPasswordTextField.text!
        let newPassword = self.newPasswordTextField.text!
        let confirmPassword = self.confirmPasswordTextField.text!
        
        if oldPassword == "" {
            CRToastManager.showNotificationWithMessage("请输入原密码", completionBlock: nil)
            return
        }
        if newPassword == "" {
            CRToastManager.showNotificationWithMessage("请输入新密码", completionBlock: nil)
            return
        }
        if newPassword != confirmPassword {
            CRToastManager.showNotificationWithMessage("两次输入的密码不匹配", completionBlock: nil)
            return
        }
        let hud = MBProgressHUD.show()
        API.changePassword(Util.loggedUser!, oldPassword: oldPassword, newPassword: newPassword).subscribe { event in
            switch event {
            case .Next(_):
                hud.switchToSuccess(duration: 1, labelText: " 修改成功") {
                    self.navigationController?.popViewControllerAnimated(true)
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
