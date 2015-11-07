//
//  API.swift
//  PlayTask
//
//  Created by Yoncise on 11/3/15.
//  Copyright © 2015 yon. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CRToast
import RxSwift

class API {
    static let manager: Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 24.0 // 24 秒没接收到数据则视为超时
        return Manager(configuration: configuration)
    }()
    
    class func req(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL) -> Request {
        return API.manager.request(
            method,
            "\(Config.API.ROOT)/\(URLString)",
            parameters: parameters,
            encoding: encoding
        )
    }
}

enum NetworkError: ErrorType {
    case Timeout
    case Unknown(Int)
}

enum APIError: ErrorType {
    case Server(Int, String, JSON)
    case Common(Int, String, JSON)
    case Custom(Int, String, JSON)
}

extension Request {
    func resp(suppressError: Bool = false) -> Observable<JSON> {
        return create { observer in
            self.responseJSON { response in
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    let status = json["status"].intValue
                    if status < 10 { // 成功
                        observer.onNext(json["data"])
                        observer.onCompleted()
                    } else {
                        if status < 100 { // 服务器错误
                            observer.onError(APIError.Server(status, json["info"].stringValue, json["data"]))
                        } else if status < 200 { // 通用接口错误
                            observer.onError(APIError.Common(status, json["info"].stringValue, json["data"]))
                        } else {
                            observer.onError(APIError.Custom(status, json["info"].stringValue, json["data"]))
                        }
                    }
                    break
                case .Failure(let error):
                    if error.code == -1001 { //  网络连接超时
                        if !suppressError {
                            CRToastManager.showNotificationWithMessage("网络连接超时", completionBlock: nil)
                        }
                        observer.onError(NetworkError.Timeout)
                    } else { // 未知错误
                        if !suppressError {
                            CRToastManager.showNotificationWithMessage("网络连接错误 \(error.code)", completionBlock: nil)
                        }
                        observer.onError(NetworkError.Unknown(error.code))
                    }
                    break
                }
            }
            return NopDisposable.instance
        }
    }
}