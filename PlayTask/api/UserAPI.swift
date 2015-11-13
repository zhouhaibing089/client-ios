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
    class func registerWithAccount(account: String, email: String, password: String) -> Observable<User> {
        return API.req(.POST, "/users", parameters: ["account" : account,
            "email": email, "password": password]).resp(false).map { json in
            let user = User(account: account, email: email, sid: json["sid"].intValue)
            user.save()
            return user
        }
    }
    
    class func loginWithAccount(account: String, password: String) -> Observable<Bool> {
        return API.req(.POST, "/sessions", parameters: ["account": account, "password": password]).resp(false).map { json in
            let sid = json["user"]["id"].intValue
            if let user = User.getBySid(sid) {
                Util.loggedUser = user
            } else {
                let user = User(account: json["account"].stringValue, email: json["email"].stringValue, sid: sid)
                user.save()
                Util.loggedUser = user
            }
            Util.sessionId = json["id"].stringValue
            return true
        }
    }
    
    class func loginWithSessionId(sessionId: String) -> Observable<Bool> {
        return API.req(.GET, "/sessions/\(sessionId)").resp().map { json in
            let sid = json["user"]["id"].intValue
            if let user = User.getBySid(sid) {
                Util.loggedUser = user
            } else {
                let user = User(account: json["account"].stringValue, email: json["email"].stringValue, sid: sid)
                user.save()
                Util.loggedUser = user
            }
            Util.sessionId = json["id"].stringValue
            return true
        }
    }
    
    class func logoutWithSessionId(sessionId: String) -> Observable<Bool> {
        return API.req(.DELETE, "/sessions/\(sessionId)").resp(false).map { _ in
            Util.loggedUser = nil
            Util.sessionId = nil
            return true
        }
    }
    
    class func getUserWithUserSid(userSid: Int) -> Observable<User> {
        return API.req(.GET, "/users/\(userSid)").resp().map { json in
            if let user = User.getBySid(userSid) {
                user.update(["score": json["score"].intValue])
            }
            return Util.currentUser
        }
    }
}
