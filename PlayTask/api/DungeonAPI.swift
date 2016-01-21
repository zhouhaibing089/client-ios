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
    
}