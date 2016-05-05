//
//  WalletAPI.swift
//  PlayTask
//
//  Created by Yoncise on 4/29/16.
//  Copyright © 2016 yon. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

extension API {
    class func getBalanceDetailsOfUser(userId: Int, before: NSDate?) -> Observable<BalanceDetail> {
        var params = [String: AnyObject]()
        if before != nil {
            params["before"] = before!.millisecondsSince1970
        }
        return API.req(.GET, "/users/\(userId)/balance_details").flatMap { json -> Observable<BalanceDetail> in
            var details = [BalanceDetail]()
            for (_, subJson) : (String, JSON) in json {
                details.append(BalanceDetail(json: subJson))
            }
            return details.toObservable()
        }
    }
}
