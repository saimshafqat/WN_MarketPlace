//
//  MPSellViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import FittedSheets

class MPSellViewController: UIViewController {
    
    // MARK: - Properties -
    var viewHelper = MPSellLayout()
    var sellerDashboardData: MPSellDashboardData?
    
    lazy var dataSource: SSSectionedDataSource? = {
        let ds = SSSectionedDataSource(sections: [])
        return ds
    }()
    
    @IBOutlet weak var collectionView: UICollectionView?
    var categoryList = [
        Section(items: [
            Item(name: "Inbox"),
            Item(name: "Your Listings"),
            Item(name: "Announcements"),
            Item(name: "Insights"),
            Item(name: "Notifications")
        ]),
        Section(items: [
            Item(name: "Create Listing")
        ]),
        Section(items: [
            Item(name: "Chat to answer", iconImage: UIImage(named: "sell_chat"), counterStr: "0"),
            Item(name: "Active Listings", iconImage: UIImage(named: "sell_active_listing"), counterStr: "0"),
            Item(name: "Listing to renew", iconImage: UIImage(named: "sell_renew_listing"), counterStr: "0"),
//            Item(name: "Listings to delete and relist", iconImage: UIImage(named: "sell_delete_listing"), counterStr: "0"),
        ]),
        Section(items: [
//            Item(name: "No payout history", counterStr: "$ 0.00"),
            Item(name: "Clicks on listings", description: "Last 7 days", counterStr: "0"),
            Item(name: "Seller rating", description: "0 ratings", counterStr: "0"),
            Item(name: "New followers", description: "Last 7 days", counterStr: "0"),
        ])
    ]
    
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(header: MPProductDetailHeaderView.self)
        viewHelper.dataSource = dataSource
        collectionView?.collectionViewLayout = viewHelper.compositionalLayout()
        collectionView?.delegate = self
        updateSection()
        configureView()
        callRequestForSellerDashbaord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func callRequestForSellerDashbaord() {
        
        MPRequestManager.shared.request(endpoint: "seller_dashboard") { response in
            switch response {
            case .success(let data):
                if let jsonData = data as? Data {
                    do {
                        let decoder = JSONDecoder()
                        let dashboardResponse = try decoder.decode(MPSellDashboardResponse.self, from: jsonData)
                        self.sellerDashboardData = dashboardResponse.data
                        self.updateDatasource()
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                    }
                }
                else {
                    LogClass.debugLog("not getting good response")
                }
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            }
        }
    }
    
    func configureView() {
        dataSource?.cellCreationBlock = { object, parentView, index in
            let currentSection = self.dataSource?.section(at: index?.section ?? 0)
            var clazzInstance: SSBaseCollectionCell.Type
            let currentValue = currentSection?.sectionIdentifier as? String
            if currentValue == SectionIdentifier.MPSellTag.type {
                clazzInstance = MPSellTagCell.self
            } else if currentValue == SectionIdentifier.MPSellListCreating.type {
                clazzInstance = MPSellCreateListingCell.self
            } else {
                clazzInstance = MPSellOverviewCell.self
            }
            return clazzInstance.init(for: parentView as? UICollectionView, indexPath: index)
        }
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            let currentSection = self.dataSource?.section(at: indexPath?.section ?? 0)
            let sectionId = currentSection?.sectionIdentifier
            (cell as? SSBaseCollectionCell)?.configureCell(sectionId, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
            
            if cell is MPSellCreateListingCell {
                (cell as? MPSellCreateListingCell)?.mpSellCreateListingDelegate = self
            }
        }
        dataSource?.collectionViewSupplementaryElementClass = MPProductDetailHeaderView.self
        dataSource?.collectionSupplementaryConfigureBlock = { view, kind, cv, indexPath in
            let section = self.dataSource?.section(at: indexPath?.section ?? 0) as? SectionInfo
            (view as? MPProductDetailHeaderView)?.configureView(obj: section, parentObj:  nil, indexPath: indexPath ?? IndexPath())
        }
        
        dataSource?.rowAnimation = .automatic
        dataSource?.collectionView = collectionView
    }
    
    func updateSection() {
        if categoryList[0].items.count  > 0  {
            configureSection(.MPSellTag, object: categoryList[0].items, sortOrder: 0)
        }
        if categoryList[1].items.count  > 0  {
            configureSection(.MPSellListCreating, object: categoryList[1].items, sortOrder: 1)
        }
        if categoryList[2].items.count  > 0  {
            configureSection(.MPSellOverview, object: categoryList[2].items, sortOrder: 2)
        }
        if categoryList[3].items.count  > 0  {
            configureSection(.sellPerformance, object: categoryList[3].items, sortOrder: 3)
        }
    }
    
    func configureSection(_ identifier: SectionIdentifier, object: [AnyObject]?, sortOrder: Int) {
        var section = dataSource?.section(withIdentifier: identifier.type)
        if section == nil {
            section = customSection(object, identifier: identifier, sortOrder: sortOrder)
            dataSource?.appendSection(section)
            sortingSection()
        }
    }
    
    func customSection(_ item: [AnyObject]?, identifier: SectionIdentifier, sortOrder: Int = 0) -> SSSection? {
        return SectionInfo.section(withItems: item, header: nil, identifier: identifier.type, sortId: sortOrder)
    }
    
    func updateDatasource() {
        guard let data = sellerDashboardData else { return }
        if let section = dataSource?.section(withIdentifier: SectionIdentifier.MPSellOverview.type) as? SectionInfo {
            if let item = section.items[0] as? Item {
                item.counterStr = "\(data.chatsToAnswer)"
            }
            
            if let item = section.items[1] as? Item {
                item.counterStr = "\(data.activeItemsCount)"
            }
            
            if let item = section.items[2] as? Item {
                item.counterStr = "\(data.renewListingsCount)"
            }
        }
        
        if let section = dataSource?.section(withIdentifier: SectionIdentifier.sellPerformance.type) as? SectionInfo {
            if let item = section.items[0] as? Item {
                item.counterStr = "\(data.userClicksCount7Days)"
            }
            
            if let item = section.items[2] as? Item {
                item.counterStr = "\(data.followersCount7Days)"
            }
        }
        
        collectionView?.reloadData()
    }
    
    // will sort section after update
    func sortingSection() {
        let sections = self.dataSource?.sections as? [SectionInfo]
        guard sections?.count ?? 0 > 1 else { return }
        if let sections {
            let sortedList = sections.sorted(by: {$0.sortId < $1.sortId})
            for (newIndex, item) in sortedList.enumerated() {
                print(newIndex, item)
                let oldIndex = sections.firstIndex(where: {$0 === item})
                if oldIndex != nil && oldIndex != newIndex {
                    self.dataSource?.moveSection(at: oldIndex ?? 0, to: newIndex)
                    if compare(sortedList, sections) {
                        break
                    }
                }
            }
        }
    }
    
    // it will compare section if both list will be same it will return true otherwise will return false and then we don't need to continue process
    func compare(_ sorted: [SectionInfo], _ unsorted: [SectionInfo]) -> Bool {
        return unsorted.count == sorted.count && sorted == unsorted.sorted(by: {$0.sortId < $1.sortId})
    }
    
    
    // MARK: - IBActions -
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension MPSellViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource?.section(at: indexPath.section)
        
        switch item?.sectionIdentifier as? String {
        case SectionIdentifier.MPSellTag.type:
            switch indexPath.item {
            case 0:
                let controller = MPChatListVC.instantiate(fromAppStoryboard: .Chat)
                navigationController?.pushViewController(controller, animated: true)
            default:
                break
            }
            
        case SectionIdentifier.MPSellOverview.type:
            switch indexPath.item {
            case 0:
                let controller = MPChatListVC.instantiate(fromAppStoryboard: .Chat)
                navigationController?.pushViewController(controller, animated: true)
            default:
                break
            }
        default:
            break
        }
    }
}

extension MPSellViewController: MPSellCreateListingDelegate {
    func createListingTapped() {
        openCreateListingBottomView()
    }
}

extension MPSellViewController {
    
    @IBAction func onClickCreateListingBtn(_ sender: UIButton) {
        openCreateListingBottomView()
    }
    
    func openCreateListingBottomView() {
        let controller = MPBottomCreateListingVC.instantiate(fromAppStoryboard: .Marketplace)
        controller.itemSelected = { item in
            LogClass.debugLog("Item: \(item.name)")
            
            if let currentVC = UIApplication.topViewController() as? SheetViewController {
                currentVC.dismiss(animated: false) { [weak self] in
                    let vc = MPCreateListingFormVC.instantiate(fromAppStoryboard: .Marketplace)
                    vc.modalPresentationStyle = .fullScreen
                    self?.presentVC(vc)
                }
            }
        }
        openBottomSheet(controller, sheetSize: [.fixed(250)], animated: false)
    }
}
