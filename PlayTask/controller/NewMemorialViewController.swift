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

class NewMemorialViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func send(sender: UIBarButtonItem) {
        var uploadImageObservable: Observable<Image> = Observable.empty()
        if self.selectedImage != nil {
            uploadImageObservable = API.getQiniuToken().flatMap({ (token) -> Observable<JSON> in
                let upManager = QNUploadManager()
                
                return Observable.create({ (observer) -> Disposable in
                    upManager.putData(UIImageJPEGRepresentation(self.selectedImage!, 0.6), key: nil, token: token, complete: { (info, key, resp) -> Void in
                        if resp == nil {
                            observer.onError(NetworkError.Unknown(Int(info.statusCode)))
                        } else {
                            observer.onNext(JSON(resp))
                            observer.onCompleted()
                        }
                    }, option: nil)
                    return AnonymousDisposable {
                        // TODO cancel upload
                    }
                })
            }).flatMap({ (json) -> Observable<Image> in
                return API.createImage(url: json["url"].stringValue, orientation: json["orientation"].stringValue,
                    width: json["width"].doubleValue, height: json["height"].doubleValue)
            })
        }
        
        let content = self.contentTextView.text
        uploadImageObservable.flatMap { (image) -> Observable<Memorial> in
            API.sendMemorial(Util.loggedUser!, dungeon: self.dungeon, content: content, imageIds: [image.id])
        }.subscribe { (event) -> Void in
            switch event {
            case .Completed:
                break
            case .Error(let error):
                break
            case .Next(let memorial):
                break
            }
        }
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
}
