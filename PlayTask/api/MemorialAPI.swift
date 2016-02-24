//
//  MemorialAPI.swift
//  PlayTask
//
//  Created by Yoncise on 2/24/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

extension API {
    
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
        return API.req(.GET, "/dungeons/\(dungeon.id)/memorials", parameters: params, suppressError: false).flatMap({ (json) -> Observable<Memorial> in
            var memorials = [Memorial]()
            for (_, subJson) : (String, JSON) in json {
                memorials.append(Memorial(json: subJson)!)
            }
            return memorials.toObservable()
        })
    }
    
    /// 评论副本里的状态
    class func commentMemorial(user: User, memorialId: Int, toMemorialCommentId: Int?, content: String, fromDungeonId: Int) -> Observable<MemorialComment> {
        var parameters: [String: AnyObject] = [
            "from_user_id": user.sid.value!,
            "content": content,
            "from_dungeon_id": fromDungeonId
        ]
        if let toMemorialCommentId = toMemorialCommentId {
            parameters["to_memorial_comment_id"] = toMemorialCommentId
        }
        return API.req(.POST, "/memorials/\(memorialId)/comments", parameters: parameters, suppressError: false).map({ (json) -> MemorialComment in
            return MemorialComment(json: json)!
        })
    }
    
    /// 删除 Memorial
    class func deleteMemorial(memorial: Memorial) -> Observable<Bool> {
        return API.req(.DELETE, "/memorials/\(memorial.id)").map({ (json) -> Bool in
            true
        })
    }
    
    /// 删除 Memorial 评论
    class func deleteMemorialComment(commentId: Int) -> Observable<Bool> {
        return API.req(.DELETE, "/memorial_comments/\(commentId)").map({ (json) -> Bool in
            true
        })
    }
    
    /// 获得副本下的某个人的所有的 Memorials
    class func getMemorialsOfUser(userId: Int, inDungeon dungeon: Dungeon, before: NSDate? = nil) -> Observable<Memorial> {
        var params = [String: AnyObject]()
        if before != nil {
            params["before"] = before?.millisecondsSince1970
        }
        return API.req(.GET, "/dungeons/\(dungeon.id)/users/\(userId)/memorials", parameters: params, suppressError: false).flatMap({ (json) -> Observable<Memorial> in
            var memorials = [Memorial]()
            for (_, subJson) : (String, JSON) in json {
                memorials.append(Memorial(json: subJson)!)
            }
            return memorials.toObservable()
        })
    }
}