//
//  ChatViewController+LoadMore.swift
//  Eva
//
//  Created by saran on 22/12/19.
//  Copyright © 2019 Eva. All rights reserved.
//

import UIKit

extension ChatViewController {
    func hitDB(body: String, queryType: QueryType = .textSearch) {
        /*var output = ("", [String: Any](), "")
        var queryString = body  // "الرصيد المتوفر"//
        self.showActivityView()
        let delayTime = DispatchTime.now() + .milliseconds(2)//+ Double(0.001)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            queryString = queryString.replacingOccurrences(of:"\'", with: "", options:.literal, range: nil)
            
                NayaAPIWebserviceManager.sharedManager.getUserQuery(self, queryString, queryType, completionHandler: { (status, object, errorMessage) -> Void in
                    DispatchQueue.main.async(execute: {
                        output = (status, object, errorMessage)
                        self.pushToTransactionDetails(responseString: output.1)
                    })
                })
        }*/
    }
    
}
