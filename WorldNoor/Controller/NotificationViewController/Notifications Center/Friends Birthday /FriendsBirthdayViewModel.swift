//
//  FriendsBirthdayViewModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 04/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

protocol FriendsBirthdayViewModelProtocol: AnyObject {
    func getFriendsBirthdayList(completion: @escaping BlockWithMessageAndBool)
    func openChat(friendID: String, completion: @escaping BlockWithMessageAndBool)
    var sectionList: [BirthdaySectionItem] { set get }
    var currentConversationID: String? { set get }
}

class FriendsBirthdayViewModel: FriendsBirthdayViewModelProtocol {
    
    private var todayBirthdayList: [FriendBirthdayModel] = []
    private var tomorrowBirthdayList: [FriendBirthdayModel] = []
    private var currentMonthBirthdayList: [FriendBirthdayModel] = []
    private var monthlyBirthdayList: [MonthBirthdayModel] = []
    
    var sectionList: [BirthdaySectionItem] = []
    var currentConversationID: String?
    
    init() { }
    
    func getFriendsBirthdayList(completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "event/birthdays",
                          "token": SharedManager.shared.userToken(),
                          "device" : "ios"]
        
        RequestManager.fetchDataGet(Completion: { (response) in
            
            switch response {
                
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                    
                } else if let newRes = res as? [String: Any] {
                    
                    if let friends = newRes["todayBirthday"] as? [[String : Any]] {
                        for index in friends {
                            self.todayBirthdayList.append(FriendBirthdayModel.init(fromDictionary: index))
                        }
                    }
                    
                    if let friends = newRes["tomorrow_bithday"] as? [[String : Any]] {
                        for index in friends {
                            self.tomorrowBirthdayList.append(FriendBirthdayModel.init(fromDictionary: index))
                        }
                    }
                    
                    if let friends = newRes["current_month_birthday"] as? [[String : Any]] {
                        for index in friends {
                            self.currentMonthBirthdayList.append(FriendBirthdayModel.init(fromDictionary: index))
                        }
                    }
                    
                    if let friends = newRes["monthlyBirthday"] as? [[String : Any]] {
                        for index in friends {
                            self.monthlyBirthdayList.append(MonthBirthdayModel.init(fromDictionary: index))
                        }
                    }
                    
                    self.makeSections()
                    completion("sucess", true)
                }
            }
        }, param: parameters)
    }
    
    private func makeSections() {
        
        if !todayBirthdayList.isEmpty {
            let todaySection = BirthdaySectionItem(title: "Today".localized(),
                                                   type: .today,
                                                   list: todayBirthdayList)
            sectionList.append(todaySection)
        }
        
        if !tomorrowBirthdayList.isEmpty || !currentMonthBirthdayList.isEmpty || !monthlyBirthdayList.isEmpty {
            let upComingSection = BirthdaySectionItem(title: "Upcoming".localized(),
                                                      type: .upcoming,
                                                      list: [])
            sectionList.append(upComingSection)
        }
        
        // make upcoming section list
        //        tomorrow / later on this month / other months
        
        if !tomorrowBirthdayList.isEmpty {
            let tomorrowSection = BirthdaySectionItem(title: "Tomorrow".localized(),
                                                      type: .tomorrow,
                                                      list: self.tomorrowBirthdayList)
            sectionList.append(tomorrowSection)
        }
        
        if !currentMonthBirthdayList.isEmpty {
            
            let title = "Later in".localized() + " " + self.getCurrentMonthName()
            let currentMonthSection = BirthdaySectionItem(title: title,
                                                          type: .laterOn,
                                                          list: self.currentMonthBirthdayList)
            sectionList.append(currentMonthSection)
        }
        
        
        if !monthlyBirthdayList.isEmpty {
            
            for element in monthlyBirthdayList {
                
                if !element.birthdaysList.isEmpty {
                    let monthNumber = element.monthNumber
                    let monthSection = BirthdaySectionItem(title: self.getMonthName(monthNumber: monthNumber),
                                                           type: .month,
                                                           list: element.birthdaysList)
                    sectionList.append(monthSection)
                }
            }
        }
    }
    
    func getMonthName(monthNumber: String) -> String {
        let number = Int(monthNumber) ?? 0
        return DateFormatter().monthSymbols[number - 1]
    }
    
    func getCurrentMonthName() -> String {
        let monthNumber = Calendar.current.component(.month, from: Date()) // 4
        let monthName = Calendar.current.monthSymbols[monthNumber - 1] // April
        return monthName
    }
    
    func openChat(friendID: String, completion: @escaping BlockWithMessageAndBool) {
        
        let memberID: [String] = [friendID]
        let parameters: NSDictionary = ["action": "conversation/create",
                                        "token": SharedManager.shared.userToken(),
                                        "serviceType": "Node",
                                        "conversation_type": "single",
                                        "member_ids": memberID]
        
        RequestManager.fetchDataPost(Completion: { response in
            
            self.currentConversationID = nil
            
            switch response {
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else {
                    if res is NSDictionary {
                        
                        let dict = res as! NSDictionary
                        let conversationID = self.ReturnValueCheck(value: dict["conversation_id"] as Any)
                        self.currentConversationID = conversationID
                        completion("sucess", true)
                    }
                }
            }
        }, param:parameters as! [String : Any])
    }
    
    func ReturnValueCheck(value : Any) -> String {
        if let MainValue = value as? Int {
            return String(MainValue)
        }else  if let MainValue = value as? String {
            return MainValue
        }else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
}


struct BirthdaySectionItem {
    var title: String?
    var type: BirthdayListSectionTypes?
    var list: [FriendBirthdayModel]?
}

enum BirthdayListSectionTypes {
    case today
    case upcoming
    case tomorrow
    case laterOn
    case month
}
