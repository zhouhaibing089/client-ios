//
//  UserAPI.swift
//  PlayTask
//
//  Created by Yoncise on 11/3/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

extension API {
    class func registerWithAccount(account: String, email: String, password: String) -> Observable<User> {
        return API.req(.POST, "/users", parameters: ["account" : account,
            "email": email, "password": password], suppressError: false).map { json in
            let user = User(json: json)
            user.save()
            return user
        }
    }
    
    class func loginWithAccount(account: String, password: String) -> Observable<Bool> {
        return API.req(.POST, "/sessions", parameters: ["account": account, "password": password], suppressError: false).map { json in
            let sid = json["user"]["id"].intValue
            if let user = User.getBySid(sid) {
                Util.loggedUser = user
            } else {
                let user = User(json: json["user"])
                user.save()
                Util.loggedUser = user
            }
            Util.sessionId = json["id"].stringValue
            return true
        }
    }
    
    class func loginWithSessionId(sessionId: String) -> Observable<Bool> {
        return API.req(.GET, "/sessions/\(sessionId)").map { json in
            let sid = json["user"]["id"].intValue
            if let user = User.getBySid(sid) {
                Util.loggedUser = user
            } else {
                let user = User(json: json["user"])
                user.save()
                Util.loggedUser = user
            }
            Util.sessionId = json["id"].stringValue
            return true
        }
    }
    
    class func logoutWithSessionId(sessionId: String) -> Observable<Bool> {
        return API.req(.DELETE, "/sessions/\(sessionId)", suppressError: false).map { _ in
            Util.loggedUser = nil
            Util.sessionId = nil
            return true
        }
    }
    
    class func getUserWithUserSid(userSid: Int) -> Observable<User> {
        return API.req(.GET, "/users/\(userSid)").map { json in
            if let user = User.getBySid(userSid) {
                user.update([
                    "score": json["score"].intValue,
                    "bronze": json["bronze"].intValue,
                    "avatarUrl": json["avatar_url"].stringValue
                    ])
                Util.currentUser.badge = Badge(json: json["badge"])
                //  创建 Group
                var groups = [Group]()
                for (_, subJson) in json["groups"] {
                    if let group = Group.getBySid(subJson["id"].intValue) {
                        group.update(json: subJson, value: ["name": subJson["name"].stringValue])
                        groups.append(group)
                    } else {
                        let g = Group(json: subJson)
                        g.name = subJson["name"].stringValue
                        g.save()
                        groups.append(g)
                    }
                }
                user.update(["groups": groups])
            }
            return Util.currentUser
        }
    }
    
    class func changePassword(user: User, oldPassword: String, newPassword: String) -> Observable<Bool> {
        return API.req(.PUT, "/users/\(user.sid.value!)", parameters: ["old_password": oldPassword,
            "new_password": newPassword], suppressError: false).map  { json in
                return true
        }
    }
}
