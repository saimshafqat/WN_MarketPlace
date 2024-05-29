//
//  GroupHandler.swift
//  WorldNoor
//
//  Created by Raza najam on 3/29/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GroupHandler: NSObject {
    static let shared = GroupHandler()
    var groupCallBackHandler:((GroupValue)->())?
    var groupCategoryCallBackHandler:((GroupValue)->())?
    var movieCallBackHandler:((String)->())?
    var tableDidScrollHandler:(()->())?
    var ImageSectionHandler:((Int, Int)->())?
}
