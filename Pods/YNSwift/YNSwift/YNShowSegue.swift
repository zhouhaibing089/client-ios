//
//  YNShowSegue.swift
//  YNSwift
//
//  Created by Yoncise on 1/8/16.
//  Copyright © 2016 yon. All rights reserved.
//

import UIKit

class YNShowSegue: YNSegue {
    override func perform() {
        self.source.navigationController?.pushViewController(self.instantiated, animated: true)
    }
}
