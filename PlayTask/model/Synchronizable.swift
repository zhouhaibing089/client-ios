//
//  Synchronizable.swift
//  PlayTask
//
//  Created by Yoncise on 11/9/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RxSwift

protocol Synchronizable {
    func push() -> Observable<Table>
    static func push() -> Observable<Table>
    static func pull() -> Observable<Table>
}