//
//  IGStoryPreviewModel.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 18/03/18.
//  Copyright © 2018 DrawRect. All rights reserved.
//

import Foundation

class IGStoryPreviewModel: NSObject {
    
    //MARK:- iVars
    var stories: [FeedVideoModel]?
    var handPickedStoryIndex: Int? //starts with(i)
    
    //MARK:- Init method
    init(_ stories: [FeedVideoModel], _ handPickedStoryIndex: Int) {
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
    }
    
    //MARK:- Functions
    func numberOfItemsInSection(_ section: Int) -> Int {
        if let count = stories?.count {
            return count
        }
        return 0
    }
    func cellForItemAtIndexPath(_ indexPath: IndexPath) -> FeedVideoModel? {
        guard let count = stories?.count else {return nil}
        if indexPath.item < count {
            return stories![indexPath.item]
        }else {
            fatalError("Stories Index mis-matched :(")
        }
    }
}
