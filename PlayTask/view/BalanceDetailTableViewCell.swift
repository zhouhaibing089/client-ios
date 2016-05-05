//
//  BalanceDetailTableViewCell.swift
//  PlayTask
//
//  Created by Yoncise on 4/29/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class BalanceDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    
    let dateFormatter = NSDateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    var balanceDetail: BalanceDetail! {
        didSet {
            self.update()
        }
    }
    
    func update() {
        self.titleLabel.text = self.balanceDetail.title
        self.dateLabel.text = self.dateFormatter.stringFromDate(self.balanceDetail.createdTime)
        self.statusLabel.hidden = false
        self.amountLabel.text = self.balanceDetail.amountStr
        switch self.balanceDetail.status {
        case .Normal:
            self.statusLabel.hidden = true
            break
        case .Processing:
            self.statusLabel.text = "处理中"
            break
        case .Failed:
            self.statusLabel.text = "失败"
            break
        case .Success:
            self.statusLabel.text = "成功"
            break
        default:
            break
        }
    }

}
