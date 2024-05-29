//
//  GlobalSearchViewModel.swift
//  WorldNoor
//
//  Created by Asher Azeem on 27/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

class GlobalSearchViewModel {
    
    
    // set user to core data
    func setDBChatObj(with searchUser: SearchUserModel) -> Chat {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let objModel = Chat(context: moc)
        objModel.profile_image = searchUser.profile_image
        objModel.member_id = searchUser.user_id
        objModel.name = searchUser.author_name
        objModel.latest_conversation_id = searchUser.conversation_id
        objModel.conversation_id = searchUser.conversation_id
        objModel.conversation_type = "single"
        return objModel
    }

}
