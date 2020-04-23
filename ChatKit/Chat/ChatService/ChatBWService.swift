//
//  ChatBWService.swift
//  ChatApp
//
//  Created by Sarankumar on 29/08/18.
//  Copyright © 2018 Saran. All rights reserved.
//

import Foundation
import Alamofire

let kEmptyResponseErrorCode = 9999
let kNoInternetConnection = -1009


func HTTPHeaders() -> [String: String]? {
    var headers: [String: String] = [:]
    headers["Authorization"] = "Bearer TjMqMj4yyouD2DhD8QuaKpDSGNhUJS"
    return headers
}

class ChatBWService: NSObject {    
    class func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        shouldBypass401ErrorHandling: Bool = false,
        shouldBypass404ErrorHandling: Bool = false,
        _ completionHandler: @escaping ChatCompletionHandler) {
        var encoding: ParameterEncoding = URLEncoding.default
        switch method {
        case .get, .delete:
            break
        case .post, .patch, .put:
            encoding = JSONEncoding.default
        default:
            break
        }
        guard let headers = HTTPHeaders() else {
            completionHandler(false, nil, nil)
            return
        }
        let _ = Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { (response) in
            guard let httpResponse = response.response else {
                if let error = response.error as NSError?, error.code == kNoInternetConnection {
                    completionHandler(false, nil, error)
                } else {
                    let error = NSError(domain: "No response", code: kEmptyResponseErrorCode, userInfo: nil)
                    completionHandler(false, nil, error)
                }
                return
            }
            var isSuccess = false
            switch httpResponse.statusCode {
            case 200 ... 299:
                isSuccess = true
            default:
                print("unknown error \(httpResponse.statusCode)")
            }
            completionHandler(isSuccess, response.result.value as AnyObject?, response.error as NSError?)
        }
    }
    
    class func error(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        headers: HTTPHeaders?,
        HttpStatusCode: Int,
        response: AnyObject?){
        var errorLog = ["Description": "The request failed",
                        "HttpStatusCode": HttpStatusCode,
                        "URL": url,
                        "Method": method,
                        "Parameters": parameters ?? "No Params"] as [String : Any]
        if let JSONResponse = response {
            errorLog["Response"] = JSONResponse
        }
        if let headersInfo = headers {
            errorLog["Headers"] = headersInfo
        }
    }
}
