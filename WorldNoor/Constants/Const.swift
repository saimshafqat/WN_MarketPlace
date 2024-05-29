//
//  StringConstant.swift
//  WorldNoor
//
//  Created by Raza najam on 9/5/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit

struct Const {
    
    struct Callframes {
        static let high = 25
        static let med = 22
        static let low = 18
    }
    struct CallQuality {
        static let high = 250
        static let med = 100
        static let low = 50
    }
    struct CallAudioQuality {
        static let high = 50
        static let med = 30
        static let low = 19
    }
    
    struct Notification {
        static let forwardMessage = "popForwardMessageController"
        static let selectedMessages = "multipleMessagesSelected"
        static let unSelectMessage = "UnSelectMessage"
        static let calLogsReload = "callogs"
    }
    
    struct ResponseKey {
        static let body = "body"
        static let accept = "Accept"
        static let jwtToken = "jwtToken"
        static let authorization = "Authorization"
        static let token = "token"
        static let pageid = "page_id"
        static let groupid = "group_id"
        static let query = "query"
        static let startingPointId = "starting_point_id"
        static let page = "page"
        static let newsfeedCount = "newsfeed_count"
    }
    
    struct NetworkKey {
        static let https = "https"
        static let route = "/api/"
        static let savedNewFeed = "saved/newsfeed"
        static let searchPost = "search/posts"
        static let postTranslation = "post/translation/"
        static let checkEmail = "check-email"
        static let kMemory = "memories"
        static let kFeedView = "newsfeed"
        static let kProfileFeedView = "profile/newsfeed"
        
        static let newFeedVideos = "newsfeed-videos"
        static let getReels = "getReels"
       // static let getSavedReels = "saved/user/reels"
        static let getSavedReels = "saved/user/reelsv2"

        static let savedUnsaved = "saved/unsave"
        static let sendFriendRequest = "user/send_friend_request"
        static let cancelFriendRequest = "user/cancel_friend_request"
        static let postReaction = "react"
        static let registerNewUser = "register_new"
        static let images = "newsfeed-images"
        static let fcmTokenStore = "fcm/store"
        static let relationStatusList = "get-relationship-status"
        static let relationStatusSave = "relationship-status-save"
        static let deleteRelationStauts = "del-relationship-status"
        static let familyRelationStatusList = "get-family-relationship-status"
        static let savefamilyRelationStatus = "family-relationship-status-save"
        static let deleteFamilyRelationStaus = "del-family-relationship-status"
        static let getSuggestedFriends = "get-suggested-friends"
        static let getUserFriend = "user/friends"
        static let relationshipStatusUpdate = "relationship-status-update"
        static let familyRelationshipStatusUpdate = "family-relationship-status-update"
        static let profileWebsiteEdit = "profile/website/edit"
        static let profileWebsiteDelete = "profile/website/delete"
        static let profileWebsiteSave = "profile/website/save"
        static let lifeEventCategories = "life-events-list"
        static let getCurrencyList = "profile/currency/list"
        static let currencyUpdate = "profile/currency/update"
        static let deleteLifeEvent = "delete-life-event"
        static let saveLifeEvent = "save-life-event"
        static let getSingleLifeEvent = "get-single-life-event"
        static let getCatergoryLikedPages = "profile/get-category-wise-liked-pages"
        static let createConversation = "conversation/create"
        static let searchPeopleNearBy = "search/people_nearby"
        static let pageVisibilityRequest = "profile/page-visibility/save"
        static let hiddenNewsFeed = "hidden/newsfeed"
        static let groupMemberLeave = "group/members/leave"
        static let groupFeedAPI = "group/newsfeed"
        static let recentSearch = "search/user/recent"
        static let pageViewAPI = "page/view"
        static let pageFeedAPI = "page/newsfeed"
        static let updateUserLocation = "user/update-location"
        static let userStories = "stories/stories_for_all_users"
    }

    static let accept = "OK"
    static let emailValid = "Please enter valid email address."
    static let paswordValid = "Enter valid email address or phone number."
    static let paswordValidNEw = "Please enter new password."
    
    static let networkProblem = "Network problem."
    static let networkProblemMessage = "Something went wrong. Please check your network connection"
    
    static let verificationEmpty = "Please enter the verification code received on your phone."
    
    
    static let feedTab = "FeedTabBar"
    static let MarketPlace = "MarketPlace"
    //    static let tabStory = "TabBar"
    //    static let signUpScreen = "showSignupSegue"
    //    static let likeBarViewName = "FeedCommentBarView"
    static let XQAudioPlayer = "XQAudioPlayer"
    
    static let feedTopBar = "FeedTopBarView"
    static let KloginNav = "loginNav"
    
    static let KAction = "action"
    //    static let KProfileViewController = "ProfileViewController"
    static let PostView = "PostView"
    static let FeedDetailController = "FeedDetailController"
    //    static let FeedNewDetailController = "FeedNewDetailController"
    static let FullScreenController = "FullScreenController"
    static let FullGalleryScreenController = "FullGalleryScreenController"
    //    static let NewStroiesVC = "NewStroiesVC"
    
    static let VideoView = "VideoView"
    static let klinkPreview = "LinkPreview"
    
    static let SingleImageView = "SingleImageView"
    //    static let loginAction = "login"
    //    static let KLoginViewController = "LoginViewController"
    //    static let KFeedStatisticsController = "FeedStatisticsController"
    
    static let signupAction = "register"
    static let createPostView = "CreatePostView"
    static let audioView = "AudioView"
    static let ContactGroupIdentifier = "ContactGroupController"
    static let ContactViewIdentifier = "ContactViewController"
    static let BasicContactIdentifier = "BasicContactController"
    
    static let ChatViewController = "ChatViewController"
    static let KGalleryCollectionCell = "GalleryCollectionCell"
    static let KFullGalleryCollectionCell = "FullGalleryCollectionCell"
    static let KGalleryView = "GalleryView"
    static let KSharedView = "SharedView"
    
    static let KTextBGCollectionCell = "TextBGCollectionCell"
    static let KCreatePostViewController = "CreatePostViewController"
    static let KReceiveSendGalleryCell = "ReceiveSendGalleryCell"
    //    static let KFullVideoCollectionCell = "FullVideoCollectionCell"
    static let KAttachmentView = "AttachmentView"
    
    
    // LOGIN & SIGNUP
    static let AppName = "Worldnoor"
    
    class Video {
       static var isInitialLoad = false
    }
    
    //TODO:Feed Detail
    static let textViewPlaceholder = "Write your comment."
    static let chatTextViewPlaceholder = "Message"
    static let textCreatePlaceholder = "What’s on your mind?"//"Write what you wish."
    static let firstName = "Enter your first name."
    static let lastName = "Enter your last name."
    
    //Cell Identifier
    static let MyContactCell = "MyContactCell"
    //    static let MyContactChatCell = "MyContactChatCell"
    
    static let ReceiveCell = "ReceiveCell"
    static let SendCell = "SendCell"
    static let KReceiveSenderImageCell = "ReceiveSenderImageCell"
    static let FullCollectionCell = "FullCollectionCell"
    //Date formatter
    //    static let dateFormatFeed = "yyyy-MM-dd HH:mm:ss"
    //Title
    static let ContactViewTitle = "Contact"
    static let languageSelectionAlert = "Please provide the langugage against all the videos and audios before posting."
    //Player
    static let KPlayerPlayImg = "xqPlayBtn.png"
    static let KPauseImg = "xqPauseBtn"
    static let dateFormat1 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let dateFormatNew = "dd/MM/yyyy'T'HH:mm:ss.SSS'Z'"
    //Notifications
    static let KCommentUpdatedNotif = "KCommentUpdatedNotif"
    static let KLangChangeNotif = "KLangChangeNotif"
    
    //
    static let pending = "pending"
    static let friendOrMyPost = "friend_or_my_post"
    static let friendNotExist = "friend_not_exist"
    static let cancelFriendRequest = "Cancel Request"
    static let addFriendRequest = "Add Friend"
    static let showLess = "Show Less"
    static let showMore = "Show More"
    static let savedPost = "Saved Posts"
    static let Memories = "Memories"
    static let hiddenPosts = "Hidden Posts"
    static let watch = "Watch"
    static let FeedView = ""
    
    static let viewTranslated = "View Translated"
    static let loading = "Loading..."
    static let right = "right"
    static let noPostFound = "No post found"
    static let noCategoryFound = "No category found"
    
    static let locationPermissionTitle = "Open setting for change location permission."
    static let locationPermissionMessage = ""
    static let dismissButtonTitle = "Cancel"
    static let acceptButtonTitle = "Open Setting"

}

enum  PostDataType : Int {
    case Image = 1
    case Video = 2
    case Audio = 3
    case Text  = 4
    case GIF  = 6
    case Empty  = 0
    case imageText  = 5
    case GIFBrowse  = 7
    case AudioMusic  = 8
    case Attachment  = 9
}

enum  PostHeaderType : Int {
    case none = 0
    case Story = 1
    case Reels = 2
    case Rooms = 3
}

enum  GroupContactType : Int {
    case New        = 1
    case Contact    = 2
    case Admin      = 3
}


enum  Gender : Int {
    case Male        = 1
    case Female    = 2
    case All      = 3
}


enum  ReportType : Int {
    case Post = 1
    case Comment = 2
    case User = 3
    case Story = 4
    
}

enum ViewName: String {
    case postHeaderInfoView = "PostHeaderInfoView"
    case postSharingView = "PostSharingView"
    case PostSharingMemoriesView = "PostSharingMemoriesView"
    case reactionView = "ReactionView"
    case xQAudioPlayer = "XQAudioPlayer"
    case lifeEventImageVideoView = "LifeEventImageVideoView"
    case peopleIntroHeaderView = "PeopleIntroHeaderView"
    var type: String {
        rawValue
    }
}

enum MessageStatus:String {
    case delivered = "Delivered"
    case seen = "Seen"
    var type: String {
        rawValue
    }
}

enum PostType: String {
    case audio = "audio"
    case gallery = "gallery"
    case image = "image"
    case video = "video"
    case reelsFeed = "reels"
    case post = "post"
    case shared = "shared"
    case file = "attachment"
    case none = "none"
    case gif = "gif"
    case Ad = "Ad"
    case friendSuggestion = "FriendSuggestion"
    case liveStream = "livestream"
    case pageReview = "page_review"
    var type: String {
        rawValue
    }
}

enum PostTypes: String {
    case Saved
    case Report
    case Delete
    case Hide
    case HideAll = "Hide all"
    case Block
    case UnSave
    case Memory
    case Edit
    var type: String {
        rawValue
    }
}

enum UpdatePasswordVia: Int,Codable {
    case email = 0
    case phone = 1
}
