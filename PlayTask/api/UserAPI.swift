//
//  UserAPI.swift
//  PlayTask
//
//  Created by Yoncise on 11/3/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RxSwift

extension API {
    static func registerWithAccount(account: String, email: String, password: String) -> Observable<User> {
        return API.req(.POST, "/users", parameters: ["account" : account,
            "email": email, "password": password]).resp().map { json in
            let user = User()
            return user
        }
    }
}
