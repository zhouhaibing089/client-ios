//
//  RxSwift.swift
//  Pods
//
//  Created by Yoncise on 12/6/15.
//
//

import Foundation
import RxSwift

// this generates
// [generator(0), [generator(1), [generator(2), ..].concat()].concat()].concat()
// https://github.com/ReactiveX/RxSwift/issues/315
public func generate<T>(startIndex: Int, _ generator: Int -> Observable<T>) -> Observable<T> {
    let all = [0, 1].lazy.map { i in
        return i == 0 ? generator(startIndex) : generate(startIndex + 1, generator)
    }
    return all.concat()
}