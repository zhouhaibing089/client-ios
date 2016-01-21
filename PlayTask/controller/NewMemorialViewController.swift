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

class NewMemorialViewController: UIViewController {

    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var contentTextView: YNTextView! {
        didSet {
            self.contentTextView.onDidEndEditing = { tv in
                self.sendButton.enabled = tv.text != ""
            }
        }
    }
    
    var dungeon: Dungeon!
    
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
        let content = self.contentTextView.text
        API.sendMemorial(Util.loggedUser!, dungeon: self.dungeon, content: content, imageIds: []).subscribe { (event) -> Void in
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
