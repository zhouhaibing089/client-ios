//
//  YNModalSegue.swift
//  YNSwift
//
//  Created by Yoncise on 1/8/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation

import UIKit

class YNModalSegue: YNSegue {
    override func perform() {
        self.source.presentViewController(self.instantiated, animated: true, completion: nil)
    }
}
