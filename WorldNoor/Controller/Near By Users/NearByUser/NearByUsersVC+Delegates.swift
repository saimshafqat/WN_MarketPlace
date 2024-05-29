//
//  NearByUsersVC+Delegates.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 30/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension NearByUsersVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayNearUser.isEmpty ? (tableView as? TableEmptyView)?.showEmptyState(with: "We were not able to find a match.") : (tableView as? TableEmptyView)?.hideEmptyState()
        return arrayNearUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < arrayNearUser.count else { return UITableViewCell() }
        let celNear = tableView.dequeueReusableCell(withIdentifier: "NearUserCell", for: indexPath) as! NearUserCell
        let nearbyModel = self.arrayNearUser[indexPath.row]
        celNear.bind(nearUserModel: nearbyModel, delegate: self)
        return celNear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openProfile(sender: indexPath.row)
    }
}

extension NearByUsersVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        viewModel.dismissKeyboard(searchBar: searchBar)
        self.searchQuery = query
        loadMoreHandler.resetPage()
        self.isAPICall = false
        self.arrayNearUser = []
        self.getNearUSer()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.dismissKeyboard(searchBar: searchBar)
            self.loadMoreHandler.resetPage()
            self.searchQuery = nil
            self.isAPICall = false
            self.arrayNearUser = []
            self.getNearUSer()
        }
    }
}

extension NearByUsersVC: NearByUsersProtocol {
    func messageTapped(nearUserModel: NearByUserModel) {
        self.showProfile(nearUserModel: nearUserModel)
    }
}

extension NearByUsersVC : FilterDelegate {
    
    func filterapply(placeLat : String, placeLng : String, isMale : String, Interest : String) { }
    
    func filterTapped(toAge: String?, toDistance: String?, gender: String?, relationShipID: String?, InterestID: String?) {
        self.selectedAge = toAge
        self.selectedDistance = toDistance
        self.selectedGender = gender
        self.selectedRelationShipID = relationShipID
        self.selectedInterestID = InterestID
        self.loadMoreHandler.resetPage()
        self.isAPICall = false
        self.arrayNearUser = []
        self.getNearUSer()
    }
}
