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
    
    class func getJoinedDungeons(user: User, before: NSDate? = nil) -> Observable<Dungeon> {
        var params = [String: AnyObject]()
        if before != nil {
            params["before"] = before!.millisecondsSince1970
        }
        return API.req(.GET, "/users/\(user.sid.value!)/dungeons", parameters: params).flatMap({ (json) -> Observable<Dungeon> in
            var dungeons = [Dungeon]()
            for (_, subJson) : (String, JSON) in json {
                dungeons.append(Dungeon(json: subJson))
            }
            return dungeons.toObservable()
        })
    }
    
    class func joinDungeon(user: User, dungeon: Dungeon, zone: String) -> Observable<Dungeon> {
        return API.req(.PUT, "/users/\(user.sid.value!)/dungeons/\(dungeon.id)", parameters: ["zone": zone],suppressError: false).map({ (json) -> Dungeon in
            return Dungeon(json: json)
        })
    }
    
    class func sendMemorial(user: User, dungeon: Dungeon, content: String, imageIds: [Int]) -> Observable<Memorial> {
        return API.req(.POST, "/dungeons/\(dungeon.id)/users/\(user.sid.value!)/memorials", parameters: [
            "content": content,
            "image_ids": String(JSON(imageIds))
            ], suppressError: false).map({ (json) -> Memorial in
            return Memorial(json: json)!
        })
    }
    
    class func getMemorials(dungeon: Dungeon, all: Bool, before: NSDate? = nil) -> Observable<Memorial> {
        var params = [String: AnyObject]()
        if before != nil {
            params["before"] = before?.millisecondsSince1970
        }
        params["all"] = String(all)
        return API.req(.GET, "/dungeons/\(dungeon.id)/memorials", parameters: params).flatMap({ (json) -> Observable<Memorial> in
            var memorials = [Memorial]()
            for (_, subJson) : (String, JSON) in json {
                memorials.append(Memorial(json: subJson)!)
            }
            return memorials.toObservable()
        })
    }
    
    /// 评论副本里的状态
    class func commentMemorial(user: User, memorialId: Int, toUserId: Int?, content: String) -> Observable<MemorialComment> {
        var parameters: [String: AnyObject] = [
            "from_user_id": user.sid.value!,
            "content": content
        ]
        if let toUserId = toUserId {
            parameters["to_user_id"] = toUserId
        }
        return API.req(.POST, "/memorials/\(memorialId)/comments", parameters: parameters, suppressError: false).map({ (json) -> MemorialComment in
            return MemorialComment(json: json)
        })
    }
    
    /// 获取副本下的消息
    class func getDungeonNotifications(user: User, dungeonId: Int, before: NSDate? = nil) -> Observable<DungeonNotification> {
        var params = [String: AnyObject]()
        if before != nil {
            params["before"] = before?.millisecondsSince1970
        }
        return API.req(.GET, "/dungeons/\(dungeonId)/users/\(user.sid.value!)/notifications", parameters: params).flatMap({ (json) -> Observable<DungeonNotification> in
            var dns = [DungeonNotification]()
            for (_, subJson) in json {
                dns.append(DungeonNotification(json: subJson))
            }
            return dns.toObservable()
        })
    }
    
    /// 删除 Memorial
    class func deleteMemorial(memorial: Memorial) -> Observable<Bool> {
        return API.req(.DELETE, "/memorials/\(memorial.id)").map({ (json) -> Bool in
            true
        })
    }
    
    // 删除 Memorial 评论
    class func deleteMemorialComment(commentId: Int) -> Observable<Bool> {
        return API.req(.DELETE, "/memorial_comments/\(commentId)").map({ (json) -> Bool in
            true
        })
    }
    
    // MARK: - 支付相关
    
    /// 创建支付订单
    class func createOrder(dungeonId: Int, zone: String) -> Observable<String> {
        return API.req(.POST, "/dungeons/\(dungeonId)/orders", parameters: [
            "zone": zone
            ]).map({ (json) -> String in
            json.stringValue
        })
    }
    
}