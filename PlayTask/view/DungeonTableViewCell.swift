//
//  DungeonTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 1/12/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit
import AlamofireImage

class DungeonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    var dungeon: Dungeon! {
        didSet {
            self.titleLabel.text = self.dungeon.title
            self.coverImageView.af_setImageWithURL(NSURL(string: self.dungeon.cover)!, placeholderImage: UIImage(named: "line_chart"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
