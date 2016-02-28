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
        return API.req(.GET, "/dungeons", suppressError: false).flatMap { json -> Observable<Dungeon> in
            var dungeons = [Dungeon]()
            for (_, subJson) : (String, JSON) in json {
                dungeons.append(Dungeon(json: subJson))
            }
            return dungeons.toObservable()
        }
    }
    
    class func getJoinedDungeons(user: User, closed: Bool, before: NSDate? = nil) -> Observable<Dungeon> {
        var params = [String: AnyObject]()
        if before != nil {
            params["before"] = before!.millisecondsSince1970
        }
        params["closed"] = String(closed)
        return API.req(.GET, "/users/\(user.sid.value!)/dungeons", parameters: params, suppressError: false).flatMap({ (json) -> Observable<Dungeon> in
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
    
    /// 获取副本下的消息
    class func getDungeonNotifications(user: User, dungeonId: Int, before: NSDate? = nil) -> Observable<DungeonNotification> {
        var params = [String: AnyObject]()
        if before != nil {
            params["before"] = before?.millisecondsSince1970
        }
        return API.req(.GET, "/dungeons/\(dungeonId)/users/\(user.sid.value!)/notifications", parameters: params, suppressError: false).flatMap({ (json) -> Observable<DungeonNotification> in
            var dns = [DungeonNotification]()
            for (_, subJson) in json {
                dns.append(DungeonNotification(json: subJson))
            }
            return dns.toObservable()
        })
    }
    
    // MARK: - 支付相关
    
    /// 创建支付订单
    class func createOrder(dungeonId: Int, zone: String) -> Observable<String> {
        return API.req(.POST, "/dungeons/\(dungeonId)/orders", parameters: [
            "zone": zone
            ], suppressError: false).map({ (json) -> String in
            json.stringValue
        })
    }
    
    // MARK: - 申诉
    class func complain(dungeon: Dungeon, content: String) -> Observable<Bool> {
        return API.req(.POST, "/dungeons/\(dungeon.id)/complains", parameters: [
            "content": content,
            ], suppressError: false).map({ (json) -> Bool in
                return true
            })
    }
    
}