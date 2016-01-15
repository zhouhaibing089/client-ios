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

    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var pledgeLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.update()
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
    
    func update() {
        self.playerLabel.text = String(format: self.playerLabel.text!, self.dungeon.currentPlayer, self.dungeon.maxPlayer)
        let pledge: Int = Int(self.dungeon.cashPledge ?? self.dungeon.bronzePledge ?? 0)
        var unit = "元"
        if self.dungeon.cashPledge == nil {
            unit = "铜币"
        }
        self.pledgeLabel.text = String(format: self.pledgeLabel.text!, pledge, unit)
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

}
