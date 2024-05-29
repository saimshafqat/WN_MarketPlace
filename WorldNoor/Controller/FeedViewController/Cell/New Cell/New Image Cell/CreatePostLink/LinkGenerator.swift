//
//  LinkGenerator.swift
//  WorldNoor
//
//  Created by Raza najam on 4/23/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SwiftLinkPreview

protocol LinkGeneratorDelegate {
    func linkGeneratedDelegate(result:Response)
    func linkGenerateFailedDelegate()
}

class LinkGenerator: NSObject {
    private var result = Response()
    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    var delegate:LinkGeneratorDelegate?
       
       func getLinkData(text:String) {

           if let url = self.slp.extractURL(text: text),
               let cached = self.slp.cache.slp_getCachedResponse(url: url.absoluteString) {
               self.result = cached
                self.delegate?.linkGeneratedDelegate(result: self.result)

           } else {
               self.slp.preview(
                   text,
                   onSuccess: { result in

                       self.result = result
                    self.delegate?.linkGeneratedDelegate(result: self.result)
               },
                   onError: { error in
                    self.delegate?.linkGenerateFailedDelegate()
               })
           }
       }
}
