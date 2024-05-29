//
//  PeopleSearchCollectionCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol PeopleSearchDelegate {
    func connectTapped(at indexPath: IndexPath, sender: LoadingButton, searchUser: SearchUserModel?)
}

@objc(PeopleSearchCollectionCell)
class PeopleSearchCollectionCell: SSBaseCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var searchImageView: UIImageView?
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var followButton: LoadingButton!
    
    // MARK: - Properties
    var peopleSearchDelegate: PeopleSearchDelegate?
    var indexPath: IndexPath?
    var searchUser: SearchUserModel?
    
    // MARK: - Override -
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let obj = object as? SearchUserModel {
            self.indexPath = thisIndex
            self.searchUser = obj
            searchImageView?.loadImage(urlMain: obj.profile_image)
            if let searchImageView {
                labelRotateCell(viewMain: searchImageView)
            }
            setAddress(obj: obj)
            setFollowBtn(obj)
        }
    }
    
    @IBAction func onClickFollow(_ sender: LoadingButton) {
        if let indexPath {
            peopleSearchDelegate?.connectTapped(at: indexPath, sender: sender, searchUser: searchUser)
        }
    }
    
    func setAddress(obj: SearchUserModel) {
        let city = obj.city
        let state = obj.state_name
        addressLabel.text = !(city.isEmpty) && !(state.isEmpty) ? (city + ", " + state) : !(city.isEmpty) ? city : state
        headingLabel.text = obj.author_name
    }
    
    func setFollowBtn(_ obj: SearchUserModel) {
        if obj.is_my_friend == "1" {
            updateFollowBtnDesign(title: "Send Message", color: UIColor(red: 41/255, green: 47/255, blue: 75/255, alpha: 1.0), titleColor: .white)
        } else if obj.already_sent_friend_req == "1" {
            updateFollowBtnDesign(title: "Cancel Request", color: .systemGray6, titleColor: .black)
        } else {
            updateFollowBtnDesign(title: "Add Friend", color: UIColor().hexStringToUIColor(hex: "DFF5FF"), titleColor: .blueColor)
        }
    }
    
    func updateFollowBtnDesign(title: String, color: UIColor, titleColor: UIColor) {
        followButton.setTitle(title.localized(), for: .normal)
        followButton.setTitleColor(titleColor, for: .normal)
        followButton.backgroundColor = color
    }
}

