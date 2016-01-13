//
//  DungeonDetailViewController.swift
//  PlayTask
//
//  Created by Yoncise on 1/13/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class DungeonDetailViewController: UIViewController {
    
    var dungeon: Dungeon!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
