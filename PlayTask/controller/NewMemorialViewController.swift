//
//  NewMemorialViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/21/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import YNSwift
import CRToast
import RxSwift
import Qiniu
import SwiftyJSON
import MBProgressHUD

class NewMemorialViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var selectImageButton: UIButton! {
        didSet {
            self.selectImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        }
    }
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var contentTextView: YNTextView!
    
    var dungeon: Dungeon!
    
    var selectedImage: UIImage? {
        didSet {
            if let image = self.selectedImage {
                self.selectImageButton.setImage(image, forState: UIControlState.Normal)
            } else {
                self.selectImageButton.setImage(UIImage(named: "select_image_button"), forState: UIControlState.Normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentTextView.minHeight = 33 * 4 / UIScreen.screenScale
        self.contentTextView.layoutIfNeeded()
        self.tableView.estimatedRowHeight = 44
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var cancelUploadImage = false
    var sendDisposable: Disposable?

    @IBAction func send(sender: UIBarButtonItem) {
        var sendObservable: Observable<Memorial>
        let content = re.sub("\\s+", " ", self.contentTextView.text)
        if contentTextView.text == "" && self.selectedImage == nil {
            return
        }
        let hud = MBProgressHUD.show(self.tableView)

        self.cancelUploadImage = false
        if self.selectedImage != nil {
            hud.mode = .Determinate
            hud.labelText = "上传中"
            hud.detailsLabelText = "轻触取消"
            let uploadImageObservable = API.getQiniuToken().flatMap({ (token) -> Observable<JSON> in
                let upManager = QNUploadManager()
                let option = QNUploadOption(mime: nil, progressHandler: { (key, progress) -> Void in
                    hud.progress = progress
                    }, params: nil, checkCrc: true, cancellationSignal: { () -> Bool in
                        self.cancelUploadImage
                })
                return Observable.create({ (observer) -> Disposable in
                    upManager.putData(UIImageJPEGRepresentation(self.selectedImage!, 0.6), key: nil, token: token, complete: { (info, key, resp) -> Void in
                        if resp == nil {
                            observer.onError(NetworkError.Unknown(Int(info.statusCode)))
                        } else {
                            observer.onNext(JSON(resp))
                            observer.onCompleted()
                        }
                    }, option: option)
                    return AnonymousDisposable {
                        self.cancelUploadImage = true
                    }
                })
            }).flatMap({ (json) -> Observable<QiniuImage> in
                return API.createImage(url: json["url"].stringValue, orientation: json["orientation"].stringValue,
                    width: json["width"].doubleValue, height: json["height"].doubleValue)
            })
            sendObservable = uploadImageObservable.flatMap { (image) -> Observable<Memorial> in
                API.sendMemorial(Util.loggedUser!, dungeon: self.dungeon, content: content, imageIds: [image.id])
            }
        } else {
            sendObservable = API.sendMemorial(Util.loggedUser!, dungeon: self.dungeon, content: content, imageIds: [])
        }
        self.sendDisposable = sendObservable.subscribe(onNext: { (memorial) -> Void in
            
            }, onError: { (e) -> Void in
                hud.hide(true)
            }, onCompleted: { () -> Void in
                hud.switchToSuccess(duration: 1.0, labelText: "发送成功", completionBlock: nil)
            }, onDisposed: { () -> Void in
                hud.hide(true)
        })
    }
    
    @IBAction func selectImage(sender: UIButton) {
        if self.selectedImage != nil {
            self.performSegueWithIdentifier("preview@Main", sender: nil)
            return
        }
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
        
    }
    
    func displayImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType =  sourceType
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.selectedImage = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "preview@Main" {
            let pvc = (segue as! YNSegue).instantiated as! PreviewViewController
            pvc.rawImage = self.selectedImage
            pvc.leftButtonTitle = "删除"
            pvc.onLeftButtonClicked = {
                self.selectedImage = nil
                self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    @IBAction func cancelSend(sender: UITapGestureRecognizer) {
        self.sendDisposable?.dispose()
    }
}
