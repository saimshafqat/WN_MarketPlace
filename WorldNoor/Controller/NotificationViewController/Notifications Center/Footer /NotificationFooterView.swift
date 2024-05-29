//
//  NotificationFooterView.swift
//  WorldNoor
//
//  Created by Omnia Samy on 07/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class NotificationFooterView: UITableViewHeaderFooterView {
    
    private var delegate: FriendSuggestionsDelegate?
    
    func bind(delegate: FriendSuggestionsDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func seeAllTapped(_ sender: Any) {
        delegate?.seeAllSuggestionsTapped()
    }
}
