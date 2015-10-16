//
//  BillItemTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 10/16/15.
//  Copyright © 2015 yon. All rights reserved.
//

import UIKit

class BillItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var billItem: BillItem! {
        didSet {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.titleLabel.text = self.billItem.title
            if self.billItem.score >= 0 {
                self.scoreLabel.textColor = self.contentView.tintColor
                self.scoreLabel.text = "+\(self.billItem.score)"
            } else {
                self.scoreLabel.textColor = UIColor(hexValue: 0xff3b30)
                self.scoreLabel.text = "\(self.billItem.score)"
            }
            self.timeLabel.text = dateFormatter.stringFromDate(self.billItem.modifiedTime)
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
