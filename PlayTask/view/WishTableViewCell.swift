//
//  WishTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class WishTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var loopLabel: UILabel!
    
    var wish: Wish! {
        didSet {
            self.titleLabel.text = self.wish.title
            self.scoreLabel.text = "-\(self.wish.score)"
            
            let satisfiedTime = self.wish.getSatisfiedTimes()
            if self.wish.loop == 0 {
                self.loopLabel.text = "\(satisfiedTime)/∞"
            } else {
                self.loopLabel.text = "\(satisfiedTime)/\(self.wish.loop)"
            }
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
