//
//  DungeonTaskTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/15/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class DungeonTaskTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainStatusLabel: UILabel!
    @IBOutlet weak var subStatusLabel: UILabel!
    
    var dungeon: Dungeon! {
        didSet {
            self.titleLabel.text = self.dungeon.title
        }
    }

}
