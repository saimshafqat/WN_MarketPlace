//
//  API Calling.swift
//  WorldNoor
//
//  Created by apple on 9/22/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func callingAPI(parameters:[String:String])  {
        let fileUrl = ""
        let paramDict = parameters

        RequestManager.fetchDataMultipart(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                LogClass.debugLog(res)

            }
        }, param:paramDict, fileUrl: fileUrl)
    }
}
