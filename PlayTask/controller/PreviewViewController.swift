//
//  PreviewViewController.swift
//  yon
//
//  Created by Yoncise on 8/17/15.
//  Copyright (c) 2015 yon. All rights reserved.
//

import UIKit
import MBProgressHUD

class PreviewViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            self.scrollView.delegate = self
            self.scrollView.alwaysBounceVertical = true
            self.scrollView.alwaysBounceHorizontal = true
        }
    }
    // double tap to zoom in
    @IBOutlet var zoomRecognizer: UITapGestureRecognizer!
    // tap once to exit preview
    @IBOutlet var backRecognizer: UITapGestureRecognizer!
    @IBAction func back(sender: UITapGestureRecognizer) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func zoom(sender: UITapGestureRecognizer) {
        if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
    }
    
    var rawImage: UIImage?
    var imageView = UIImageView()

    var imageUrl: String?
    
    @IBOutlet weak var leftButton: UIButton! {
        didSet {
            if let title = self.leftButtonTitle {
                self.leftButton.setTitle(title, forState: UIControlState.Normal)
            } else {
                self.leftButton.hidden = true
            }
        }
    }
    @IBOutlet weak var rightButton: UIButton! {
        didSet {
            if let title = self.rightButtonTitle {
                self.rightButton.setTitle(title, forState: UIControlState.Normal)
            } else {
                self.rightButton.hidden = true
            }
        }
    }
    
    var onLeftButtonClicked: (() -> Void)?
    var onRightButtonClicked: (() -> Void)?
    var leftButtonTitle: String?
    var rightButtonTitle: String?
    
    @IBAction func leftButtonClicked(sender: UIButton) {
        self.onLeftButtonClicked?()
    }
    
    @IBAction func rightButtonClicked(sender: UIButton) {
        self.onRightButtonClicked?()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // iOS 8 在 viewDidLoad 时只有 self.view 的 bounds 是正确的
        self.scrollView.bounds = self.view.bounds
        self.scrollView.addSubview(self.imageView)
        self.backRecognizer.requireGestureRecognizerToFail(self.zoomRecognizer)
        
        if self.rawImage != nil {
            self.imageView.image = self.rawImage
            self.update()
        }
        if let imageUrl = self.imageUrl {
            let hud = MBProgressHUD.showHUDAddedTo(self.scrollView, animated: true)
            self.imageView.af_setImageWithURL(NSURL(string: imageUrl)!, placeholderImage: nil,
                filter: nil, imageTransition: .None, completion: { response in
                    if let image = response.result.value {
                        self.imageView.image = image
                        self.update()
                    }
                    hud.hide(true)
            })
        }
        
    }
    
    func update() {
        if let image = imageView.image {
            imageView.bounds.size.height = image.size.height
            imageView.bounds.size.width = image.size.width
            self.scrollView.contentSize = imageView.bounds.size
            self.zoomCenter()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((self.scrollView.bounds.width - self.scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((self.scrollView.bounds.height - self.scrollView.contentSize.height) * 0.5, 0)
        self.imageView.center = CGPoint(x: self.scrollView.contentSize.width * 0.5 + offsetX, y: self.scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func zoomCenter() {
        let widthRatio = self.scrollView.bounds.width / self.imageView.bounds.width
        let heightRatio = self.scrollView.bounds.height / self.imageView.bounds.height
        self.scrollView.minimumZoomScale = min(widthRatio, heightRatio)
        self.scrollView.maximumZoomScale = max(1, self.scrollView.minimumZoomScale) * 1.5
        // zoomToRect is buggy when you zoom to same frame twice
        // http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        // so, set zomm scale and contentOffset manually
        self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        self.scrollViewDidZoom(self.scrollView)
    }

}
