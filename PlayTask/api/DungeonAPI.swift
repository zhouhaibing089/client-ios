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
//        return API.req(.GET, "/dungeons").map { json in
//            return [Dungeon(json: json)]
//        }
        return [Dungeon(json: JSON(["title": "早起副本",
            "cover": "http://img.xiami.net/images/collect/116/16/102950116_1436407566_V48i.png",
            "detail": "<h1>Header</h1><h2>Subheader</h2><p>Some <em>text</em></p><img src='http://img.xiami.net/images/collect/116/16/102950116_1436407566_V48i.png' width=70 height=100 />",
            "max_player": 30,
            "status": 1,
            "cash_pledge": 30,
            "current_player": 7]))].toObservable()
    }
    
    class func getJoinedDungeons(user: User) -> Observable<Dungeon> {
        return [Dungeon(json: JSON(["title": "早起副本",
            "cover": "http://img.xiami.net/images/collect/116/16/102950116_1436407566_V48i.png",
            "detail": "<h1>Header</h1><h2>Subheader</h2><p>Some <em>text</em></p><img src='http://img.xiami.net/images/collect/116/16/102950116_1436407566_V48i.png' width=70 height=100 />",
            "max_player": 30,
            "status": 1,
            "cash_pledge": 30,
            "current_player": 7]))].toObservable()
    }
    
}