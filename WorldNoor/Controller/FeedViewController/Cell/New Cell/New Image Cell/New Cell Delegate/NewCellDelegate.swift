//
//  NewCellDelegate.swift
//  WorldNoor
//
//  Created by apple on 8/17/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
enum ActionType : Int {
    case shareAction = 1 // For share
    case downloadAction = 2 // For download video/Image
    case cameraAction = 3 // For (Image) comment Camera option
    case cameraUploadAction = 4 // For (Image) comment gallery option
    case gifBrowseAction = 5 // For (Gif) comment Browse option
    case gifUploadAction = 6 // For (Gif) comment New Gif option
    case audioRecordAction = 7 // For (Audio) comment record new Audio option
    case audioUploadAction = 8 // For (Audio) comment upload from gallery
    case attachmentAction = 9 // For (Attachment) comment
    case sendAction = 10 // For (Send Action) comment
    case reloadTable = 11 // For reload Table
}
protocol CellDelegate {
    func moreAction(indexObj : IndexPath , feedObj : FeedData)
    func userProfileAction(indexObj : IndexPath , feedObj : FeedData)
    func imgShowAction(indexObj : IndexPath , feedObj : FeedData)
    func sharePostAction(indexObj : IndexPath , feedObj : FeedData)
    func downloadPostAction(indexObj : IndexPath , feedObj : FeedData)
    func commentActions(indexObj : IndexPath , feedObj : FeedData , typeAction: ActionType)
    func reloadRow(indexObj : IndexPath , feedObj : FeedData)
    func reloadTableDataFriendShipStatus(feedObj : FeedData)
}


protocol LikeCellDelegate {
    func actionPerformed(feedObj : FeedData , typeAction: ActionType) 
}



protocol ReloadDelegate {
    func reloadRow()
}


