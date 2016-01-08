//
//  WishAPI.swift
//  PlayTask
//
//  Created by Yoncise on 11/11/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

extension API {
    // MARK: Wish
    class func createWish(wish: Wish) -> Observable<Wish> {
        return API.req(.POST, "/users/\(wish.userSid.value!)/wishes", parameters: [
            "title": wish.title,
            "score": wish.score,
            "rank": wish.rank,
            "loop": wish.loop,
            
            "deleted": wish.deleted ? "true" : "false",
            "modified_time": wish.modifiedTime.timeIntervalSince1970 * 1000,
            "created_time": wish.createdTime.timeIntervalSince1970 * 1000
            ]).map { json in
            wish.update(json: json)
            return wish
        }
    }
    
    class func updateWish(wish: Wish) -> Observable<Wish> {
        return API.req(.PUT, "/wishes/\(wish.sid.value!)", parameters: [
            "rank": wish.rank,
            "loop": wish.loop,
            
            "modified_time": wish.modifiedTime.timeIntervalSince1970 * 1000,
            "deleted": wish.deleted ? "true" : "false",
            ]).map { json in
            wish.update(json: json)
            return wish
        }
    }
    
    class func getWishes(user: User, after: NSDate) -> Observable<[Wish]> {
        return API.req(.GET, "/users/\(user.sid.value!)/wishes", parameters: [
            "after": after.timeIntervalSince1970 * 1000
            ]).map { json in
            var wishes = [Wish]()
            for (_, subJson): (String, JSON) in json {
                if let w = Wish.getBySid(subJson["id"].intValue) {
                    let rank = subJson["rank"].intValue
                    let loop = subJson["loop"].intValue
                    
                    w.update(json: subJson, value: ["rank": rank, "loop": loop])
                    wishes.append(w)
                } else {
                    let w = Wish(json: subJson)
                    w.rank = subJson["rank"].intValue
                    w.score = subJson["score"].intValue
                    w.title = subJson["title"].stringValue
                    w.loop = subJson["loop"].intValue
                    w.userSid.value = subJson["user_id"].intValue
                    
                    w.save()
                    wishes.append(w)
                }
            }
            return wishes
        }
    }
    
    // MARK: WishHistory
    class func createWishHistory(wishHistory: WishHistory) -> Observable<WishHistory> {
        if wishHistory.wish.sid.value == nil {
            return Observable.empty()
        }
        return API.req(.POST, "/wishes/\(wishHistory.wish.sid.value!)/wish_histories", parameters: [
            "satisfied_time": wishHistory.satisfiedTime.timeIntervalSince1970 * 1000,
            "canceled": wishHistory.canceled ? "true" : "false",
            
            "deleted": wishHistory.deleted ? "true" : "false",
            "modified_time": wishHistory.modifiedTime.timeIntervalSince1970 * 1000,
            "created_time": wishHistory.createdTime.timeIntervalSince1970 * 1000
            ]).map { json in
            wishHistory.update(json: json)
            return wishHistory
        }
    }
    
    class func updateWishHistory(wishHistory: WishHistory) -> Observable<WishHistory> {
        return API.req(.PUT, "/wish_histories/\(wishHistory.sid.value!)", parameters: [
            "satisfied_time": wishHistory.satisfiedTime.timeIntervalSince1970 * 1000,
            "canceled": wishHistory.canceled ? "true" : "false",
            
            "deleted": wishHistory.deleted ? "true" : "false",
            "modified_time": wishHistory.modifiedTime.timeIntervalSince1970 * 1000
            ]).map { json in
            wishHistory.update(json: json)
            return wishHistory
        }
    }
    
    class func getWishHistories(user: User, after: NSDate) -> Observable<[WishHistory]> {
        return API.req(.GET, "/users/\(user.sid.value!)/wish_histories", parameters: [
            "after": after.timeIntervalSince1970 * 1000
            ]).map { json in
            var wishHistories = [WishHistory]()
            for (_, subJson): (String, JSON) in json {
                if let wh = WishHistory.getBySid(subJson["id"].intValue) {
                    let satisfiedTime = NSDate(timeIntervalSince1970: subJson["satisfied_time"].doubleValue / 1000)
                    let canceled = subJson["canceled"].boolValue
                    wh.update(json: subJson, value: ["satisfiedTime": satisfiedTime, "canceled": canceled])
                    wishHistories.append(wh)
                } else {
                    if let w = Wish.getBySid(subJson["wish_id"].intValue) {
                        let wh = WishHistory(json: subJson)
                        wh.satisfiedTime = NSDate(timeIntervalSince1970: subJson["satisfied_time"].doubleValue / 1000)
                        wh.canceled = subJson["canceled"].boolValue

                        wh.wish = w
                        wh.userSid.value = subJson["user_id"].int
                        
                        wh.save()
                        wishHistories.append(wh)
                    }
                }
            }
            return wishHistories
        }
    }
    
    
}
