//
//  PersonalViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/26/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class PersonalViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
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
                    // submit
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
        picker.dismissViewControllerAnimated(true, completion: nil)
        // TODO upload image
    }
}
