//
//  DungeonAPI.swift
//  PlayTask
//
//  Created by Yoncise on 1/12/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

extension API {
    class func getDungeons() -> Observable<Dungeon> {
        return API.req(.GET, "/dungeons").flatMap { json -> Observable<Dungeon> in
            var dungeons = [Dungeon]()
            for (_, subJson) : (String, JSON) in json {
                dungeons.append(Dungeon(json: subJson))
            }
            return dungeons.toObservable()
        }
    }
    
    class func getJoinedDungeons(user: User) -> Observable<Dungeon> {
        return API.req(.GET, "/users/\(user.sid.value!)/dungeons").flatMap({ (json) -> Observable<Dungeon> in
            var dungeons = [Dungeon]()
            for (_, subJson) : (String, JSON) in json {
                dungeons.append(Dungeon(json: subJson))
            }
            return dungeons.toObservable()
        })
    }
    
    class func joinDungeon(user: User, dungeon: Dungeon) -> Observable<Dungeon> {
        return API.req(.PUT, "/users/\(user.sid.value!)/dungeons/\(dungeon.id)", suppressError: false).map({ (json) -> Dungeon in
            return Dungeon(json: json)
        })
    }
    
    class func sendMemorial(user: User, dungeon: Dungeon, content: String, imageIds: [Int]) -> Observable<Memorial> {
        return API.req(.POST, "/dungeons/\(dungeon.id)/users/\(user.sid.value!)/memorials", parameters: [
            "content": content,
            "image_ids": String(JSON(imageIds))
            ]).map({ (json) -> Memorial in
            return Memorial(json: json)
        })
    }
    
    class func getMemorials(dungeon: Dungeon) -> Observable<Memorial> {
        return API.req(.GET, "/dungeons/\(dungeon.id)/memorials").flatMap({ (json) -> Observable<Memorial> in
            var memorials = [Memorial]()
            for (_, subJson) : (String, JSON) in json {
                memorials.append(Memorial(json: subJson))
            }
            return memorials.toObservable()
        })
    }
    
    class func commentMemorial(user: User, memorialId: Int, toUserId: Int?, content: String) -> Observable<MemorialComment> {
        var parameters: [String: AnyObject] = [
            "from_user_id": user.sid.value!,
            "content": content
        ]
        if let toUserId = toUserId {
            parameters["to_user_id"] = toUserId
        }
        return API.req(.POST, "/memorials/\(memorialId)/comments", parameters: parameters).map({ (json) -> MemorialComment in
            return MemorialComment(json: json)
        })
    }
    
    class func getDungeonNotifications(user: User, dungeonId: Int) -> Observable<DungeonNotification> {
        return API.req(.GET, "/dungeons/\(dungeonId)/users/\(user.sid.value!)/notifications").flatMap({ (json) -> Observable<DungeonNotification> in
            var dns = [DungeonNotification]()
            for (_, subJson) in json {
                dns.append(DungeonNotification(json: subJson))
            }
            return dns.toObservable()
        })
    }
    
}