//
//  PersonalViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD
import Qiniu
import SwiftyJSON
import YNSwift
import CRToast

class PersonalViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    var cancelUploadAvatar = false
    var cancelUploadDisposable: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44
        self.avatarImageView.af_setImageWithURL(NSURL(string: Util.currentUser.avatarUrl)!)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                actionSheet.addAction(UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.displayImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)
                }))
                actionSheet.addAction(UIAlertAction(title: "从手机相册选择", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.displayImagePickerForSourceType(UIImagePickerControllerSourceType.SavedPhotosAlbum)
                    
                }))
                actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(actionSheet, animated: true, completion: nil)
            } else {
                self.displayImagePickerForSourceType(UIImagePickerControllerSourceType.SavedPhotosAlbum)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let prompt = UIAlertController(title: "昵称", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                prompt.addTextFieldWithConfigurationHandler({ (tf) -> Void in
                    tf.text = Util.currentUser.nickname
                })
                prompt.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
                prompt.addAction(UIAlertAction(title: "完成", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    let hud = MBProgressHUD.show()
                    let nickname = prompt.textFields!.first!.text!
                    API.changeNickname(Util.currentUser, nickname: nickname).subscribe({ (event) -> Void in
                        switch event {
                        case .Completed:
                            hud.switchToSuccess(duration: 1.0, labelText: "修改成功")
                            Util.currentUser.update(["nickname": nickname])
                            self.tableView.reloadData()
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
                            break
                        case .Next(_):
                            break
                        }
                    })
                }))
               
                self.presentViewController(prompt, animated: true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = Util.currentUser.nickname
            } else if indexPath.row == 1 {
                cell.detailTextLabel?.text = Util.currentUser.account
            }
        }
        return cell
    }
    
    func displayImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType =  sourceType
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.avatarImageView.image = image
        let hud = MBProgressHUD.show(self.tableView)
        hud.mode = MBProgressHUDMode.Determinate
        hud.labelText = "上传头像中"
        hud.detailsLabelText = "轻触取消"
        self.cancelUploadDisposable = API.getQiniuToken().flatMap({ (token) -> Observable<JSON> in
            let upManager = QNUploadManager()
            return Observable.create({ (observer) -> Disposable in
                let option = QNUploadOption(mime: nil, progressHandler: { (key, progress) -> Void in
                    hud.progress = progress
                    }, params: nil, checkCrc: true, cancellationSignal: { () -> Bool in
                        return self.cancelUploadAvatar
                })
                self.cancelUploadAvatar = false
                upManager.putData(UIImageJPEGRepresentation(image, 0.6), key: nil, token: token, complete: { (info, key, resp) -> Void in
                    if resp == nil {
                        observer.onError(NetworkError.Unknown(Int(info.statusCode)))
                    } else {
                        observer.onNext(JSON(resp))
                        observer.onCompleted()
                    }
                    }, option: option)
                return AnonymousDisposable {
                    self.cancelUploadAvatar = true
                }
            })
        }).flatMap({ (json) -> Observable<QiniuImage> in
            return API.createImage(url: json["url"].stringValue, orientation: json["orientation"].stringValue,
                width: json["width"].doubleValue, height: json["height"].doubleValue)
        }).flatMap({ (image) -> Observable<QiniuImage> in
            return API.changeAvatar(Util.currentUser, avatar: image.id!).map({ (bool) -> QiniuImage in
                return image
            })
        }).subscribe(onNext: { (qiniuImage) -> Void in
                Util.currentUser.update(["avatarUrl": qiniuImage.url])
            }, onError: { (e) -> Void in
                hud.hide(true)
            }, onCompleted: { () -> Void in
                hud.switchToSuccess(duration: 1, labelText: "头像设置成功", completionBlock: nil)
            }, onDisposed: { () -> Void in
                if hud.mode != .CustomView {
                    hud.hide(true)
                }
        })

        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tap(sender: UITapGestureRecognizer) {
        self.cancelUploadDisposable?.dispose()
    }
}
