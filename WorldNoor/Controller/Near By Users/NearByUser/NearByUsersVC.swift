//
//  NearByUsersVC.swift
//  WorldNoor
//
//  Created by apple on 3/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import MapKit
import FittedSheets
import Combine

protocol NearByUsersProtocol: AnyObject {
    func messageTapped(nearUserModel: NearByUserModel)
}

class NearByUsersVC: UIViewController  {
    
    @IBOutlet private weak var searchBar: UISearchBar? {
        didSet {
            searchBar?.delegate = self
        }
    }
    @IBOutlet private weak var tbleViewNearUser : TableEmptyView? {
        didSet {
            tbleViewNearUser?.registerCustomCells(viewModel.cellInfos())
        }
    }
    @IBOutlet private weak var lblHeading: UILabel!
    
    // MARK: - Properties -
    var arrayNearUser: [NearByUserModel] = []
    var isAPICall = false
    var isRefresh: Bool = false
    var userLngP: String = .emptyString
    var userLatP: String = .emptyString
    var selectedAge: String?
    var selectedDistance : String? // circleRadious= 20000.0
    var selectedGender: String?  //isMaleP
    var selectedRelationShipID: String? //relationShip
    var selectedInterestID: String? //InterestP
    var searchQuery: String?
    var viewModel = NearByUsersViewModel()
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Lazy Properties -
    lazy var refreshControlHandler: RefreshControlHandler = {
        let refreshControlHandler = RefreshControlHandler(scrollView: tbleViewNearUser!)
        return refreshControlHandler
    }()
    lazy var loadMoreHandler: LoadMoreHandler = {
        let loadMoreHandler = LoadMoreHandler(scrollView: tbleViewNearUser!)
        return loadMoreHandler
    }()
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupCallbackListner()
        setupRefreshListner()
        setupLoadMoreListner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.arrayNearUser.count == 0 {
            self.arrayNearUser.removeAll()
            self.loadMoreHandler.resetPage()
            viewModel.setupLocation()
        }
    }
    
    // MARK: - Methods -
    func setupRefreshListner() {
        refreshControlHandler.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                arrayNearUser = []
                self.searchQuery = nil
                self.selectedDistance = nil
                self.selectedGender = nil
                self.selectedAge = nil
                self.selectedInterestID = nil
                loadMoreHandler.resetPage()
                self.isAPICall = false
                self.isRefresh = true
                viewModel.setupLocation()
            }.store(in: &bag)
    }
    
    func setupLoadMoreListner() {
        loadMoreHandler.loadMorePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] page in
                self?.loadMoreData(for: page)
            }
            .store(in: &bag)
    }
    
    private func loadMoreData(for page: Int) {
        guard loadMoreHandler.canLoadMore() else { return }
        loadMoreHandler.isLoading = true
        LogClass.debugLog("Loading data for page \(page)")
        getNearUSer()
    }
    
    func setupCallbackListner() {
        viewModel.locationUpdatedCompletion = {[weak self] lat, lon in
            guard let self else { return }
            userLatP = lat
            userLngP = lon
            getNearUSer()
        }
        viewModel.locationAuthorizationCompletion = {
            self.navigationController?.popViewController(animated: true)
        }
        viewModel.sendFriendRequestSuccessCompletion = { [weak self] index in
            guard let self else { return }
            arrayNearUser[index].friendStatus = Const.pending
            tbleViewNearUser?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
        viewModel.cancelFriendRequestSuccessCompletion = { [weak self] index in
            guard let self else { return }
            self.arrayNearUser[index].friendStatus = Const.friendNotExist
            tbleViewNearUser?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    func stopRefresh() {
        refreshControlHandler.endRefreshing()
    }
    
    func initialSetup() {
        self.title = viewModel.screenTitle()
        self.navigationController?.addRightButton(self, selector: #selector(self.filterAction), image: .nearyByFilter)
        viewModel.showError()
    }
    
    @objc func filterAction() {
        let filterController = FilterNearByUsersViewController()
        filterController.delegate = self
        openBottomSheet(filterController, sheetSize: [.fixed(self.view.frame.height - 50)], animated: false)
    }
    
    func buildPeopleNearbyParameters() -> [String: String] {
        var parameters: [String: String] = ["token": String(loadMoreHandler.currentPage),
                                            "page": String(loadMoreHandler.currentPage),
                                            "filters[latitude]": self.userLatP,
                                            "filters[longitude]": self.userLngP]
        // 1- distance done
        if selectedDistance != nil && self.selectedDistance?.addDecimalPoints() != "1" {
            parameters["circle_radius"] = self.selectedDistance?.addDecimalPoints()
        }
        // 2- gender in progress
        if selectedGender != nil {
            parameters["filter_by_gender"] = self.selectedGender
        }
        // 3- interest
        if selectedInterestID != nil {
            parameters["filter_by_interests"] = self.selectedInterestID
        }
        // 4- search query
        if selectedAge != nil && self.selectedAge?.addDecimalPoints() != "16" {
            parameters["fromAge"] = "16"
            parameters["toAge"] = self.selectedAge?.addDecimalPoints()
        }
        // 5- Relationship
        if selectedRelationShipID != nil {
            parameters["relationship_status_id"] = self.selectedRelationShipID
        }
        // 6- search query
        if self.searchQuery != nil {
            parameters["name"] = self.searchQuery
        }
        parameters["token"] = SharedManager.shared.userToken()
        return parameters
    }
    
    func getNearUSer() {
        guard !isAPICall else { return }
        isAPICall = true
        let parameters = buildPeopleNearbyParameters()
        viewModel.getUserRequest(.peopleNearByRequest(parameters)) {[weak self] response in
            guard let self else { return }
            if isRefresh {
                stopRefresh()
                isRefresh.toggle()
            }
            for resObj in response.data {
                isAPICall = false
                arrayNearUser.append(resObj)
            }
            tbleViewNearUser?.reloadData()
            // loadMoreHandler.hideActivityIndicator()
            if response.data.count > 0 {
                loadMoreHandler.dataLoadedSuccessfully()
            } else {
                isAPICall = true
                _ = !loadMoreHandler.canLoadMore()
            }
        }
    }
    
    func openProfile(sender : Int) {
        let controller = viewModel.profileData(obj: arrayNearUser[sender])
        controller.isNavPushAllow = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showProfile(nearUserModel: NearByUserModel) {
        guard let sender = self.arrayNearUser.firstIndex(where: { nearUserModel.userId == $0.userId }) else { return }
        if nearUserModel.friendStatus == "friend_or_my_post" {
            viewModel.createConversationRequest(nearUserModel: nearUserModel) { controller in
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else if nearUserModel.friendStatus == Const.pending.localized() {
            SharedManager.shared.ShowAlertWithCompletaion(message: "Do you really want to cancel this request?", isError: true) { status in
                if status {
                    self.viewModel.cancelFriendRequest(.cancelFriendRequest(["user_id" : "\(nearUserModel.userId)"]), sender: sender)
                }
            }
        } else {
            self.viewModel.sendFriendRequest(.sendFriendRequest(["user_id" : "\(nearUserModel.userId)"]), sender: sender)
        }
    }
}
