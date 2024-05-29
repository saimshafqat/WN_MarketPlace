//
//  LogClass.swift
//  WorldNoor
//
//  Created by Waseem Shah on 14/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class LogClass {
    
    class func debugLog(_ printP : Any){
    #if DEBUG
        print(printP)
    #endif
    }
}
