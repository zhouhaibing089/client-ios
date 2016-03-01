//
//  DungeonDetailViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/13/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import CRToast
import SwiftyJSON
import YNSwift

class DungeonDetailViewController: UIViewController {
    
    var dungeon: Dungeon!

    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var pledgeLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "alipayDungeon:", name: Config.Notification.ALIPAY_DUNGEON, object: nil)
        self.update()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedded" {
            if let devc = segue.destinationViewController as? DungeonEmbeddedViewController {
                devc.dungeon = self.dungeon
                if let naviFrame = self.navigationController?.navigationBar.frame {
                    devc.topInset = naviFrame.origin.y + naviFrame.size.height
                }
            }
        }
    }
    
    func update() {
        let pledge: Int = Int(max(self.dungeon.cashPledge!, self.dungeon.bronzePledge!))
        var unit = "铜币"
        if self.dungeon.cashPledge > 0 {
            unit = "元"
        }
        // 押金
        self.pledgeLabel.text = String(format: "%d%@", pledge, unit)
        // 人数
        self.playerLabel.text = String(format: "%d/%d", self.dungeon.currentPlayer, self.dungeon.maxPlayer!)
        switch self.dungeon.status {
        case .Joined:
            self.joinButton.enabled = false
            self.joinButton.alpha = 0.5
            break
        default:
            self.joinButton.enabled = true
            self.joinButton.alpha = 1
            break
        }
    }

    @IBAction func join(sender: UIButton) {
        if self.dungeon.cashPledge == 0 {
            let alert = UIAlertController(title: "支付押金", message: self.dungeon.payDescription, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "支付", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                API.joinDungeon(Util.loggedUser!, dungeon: self.dungeon,
                    zone: NSTimeZone.defaultTimeZone().name).subscribe({ (event) -> Void in
                    switch event {
                    case .Next(let dungeon):
                        // update dungeon list's original dungeon
                        // so this view will show correctly if user entered from dungeon list again
                        self.dungeon.currentPlayer = dungeon.currentPlayer
                        self.dungeon.status = dungeon.status
                        self.dungeon = dungeon
                        break
                    case .Completed:
                        self.update()
                        break
                    case .Error(let error):
                        if let error = error as? APIError {
                            switch error {
                            case .Custom(_, let info, _):
                                CRToastManager.showNotificationWithMessage(info, completionBlock: nil)
                                break
                            default:
                                break
                            }
                        }
                        break
                    }
                })
                return
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        let actionSheet = UIAlertController(title: "支付押金", message: self.dungeon.payDescription, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "支付宝", style: UIAlertActionStyle.Default, handler: { [unowned self] (action) -> Void in
            API.createOrder(self.dungeon.id, zone: NSTimeZone.localTimeZone().name).subscribe { event in
                switch event {
                case .Next(let n):
                    AlipaySDK.defaultService().payOrder(n, fromScheme: "playtask", callback: { (result) -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(Config.Notification.ALIPAY_DUNGEON, object: result)
                    })
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
                    break
                case .Completed:
                    break
                }
            }
            return
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Handle alipay order message
    func alipayDungeon(notification: NSNotification) {
        if let result = notification.object as? NSDictionary {
            let json = JSON(result)
            let resultStatus = json["resultStatus"].intValue
            let result = json["result"].stringValue
            if resultStatus == 9000 && result.containsString("success=\"true\"") {
                self.dungeon.status = DungeonStatus.Joined
                self.dungeon.currentPlayer++
                self.update()
            }
        }
    }
}
