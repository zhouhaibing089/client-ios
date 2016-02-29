//
//  Observable.swift
//  YNSwift
//
//  Created by Yoncise on 1/8/16.
//  Copyright © 2016 yon. All rights reserved.
//

import RxSwift

public extension Observable {

    // this generates
    // [generator(0), [generator(1), [generator(2), ..].concat()].concat()].concat()
    // https://github.com/ReactiveX/RxSwift/issues/315
    public static func generate(startIndex: Int, _ generator: Int -> Observable<E>) -> Observable<E> {
        let all = [0, 1].lazy.map { i in
            return i == 0 ? generator(startIndex) : Observable.generate(startIndex + 1, generator)
        }
        return all.concat()
    }
}