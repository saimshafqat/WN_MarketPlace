//
//  ChatReportVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 05/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ChatReportVC: UIViewController {
    
    @IBOutlet weak private var collection: UICollectionView!
    @IBOutlet weak private var subCollection: UICollectionView!
    
    @IBOutlet private var dataSource : ViewControllerDataSource!
    @IBOutlet private var dataSubSource : ViewControllerDataSubSource!
    
    var reportArr:[ReportModel]?
    var reportSubArr:[Int:[ReportModel]]?
    var selectedCatID = ""
    var selectedSub = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Report".localized()
        manageData()
        manageLayout()
        manageSubLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func manageLayout(){
        if  let flowLayout = collection.collectionViewLayout as? PartyPicksVerticalFlowLayout {
            flowLayout.delegate = dataSource
            flowLayout.cellHeight = 40
            flowLayout.cellSpacing = 8
            flowLayout.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
        collection.delegate = self
        collection.collectionViewLayout.invalidateLayout()
    }
    
    func manageSubLayout(){
        if  let flowSubLayout = subCollection.collectionViewLayout as? PartyPicksVerticalFlowLayout {
            flowSubLayout.delegate = dataSubSource
            flowSubLayout.cellHeight = 40
            flowSubLayout.cellSpacing = 8
            flowSubLayout.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
        subCollection.delegate = self
        subCollection.collectionViewLayout.invalidateLayout()
    }
    
    func manageData(){
        reportArr = [ReportModel.init(dict: ["name":"Harassment", "id":0]),
                     ReportModel.init(dict: ["name":"Sucide or self-injury", "id":1]),
                     ReportModel.init(dict: ["name":"Pretending to be someone", "id":2]),
                     ReportModel.init(dict: ["name":"Sharing inappropriate things", "id":3]),
                     ReportModel.init(dict: ["name":"Hate speech", "id":4]),
                     ReportModel.init(dict: ["name":"Unauthorised sales", "id":5]),
                     ReportModel.init(dict: ["name":"Scams", "id":6]),
                     ReportModel.init(dict: ["name":"Other", "id":7])]
        
        reportSubArr = [2:[ReportModel.init(dict: ["name":"Me", "id":0]),
                           ReportModel.init(dict: ["name":"A Friend", "id":1]),
                           ReportModel.init(dict: ["name":"A celebrity", "id":2])],
                        
                        3:[ReportModel.init(dict: ["name":"Nudity", "id":0]),
                           ReportModel.init(dict: ["name":"Pornography", "id":1]),
                           ReportModel.init(dict: ["name":"Violent or graphic content", "id":2]),
                           ReportModel.init(dict: ["name":"Child nudity", "id":3]),
                           ReportModel.init(dict: ["name":"Sharing private images", "id":4]),
                           ReportModel.init(dict: ["name":"Violent or graphic content", "id":5])
                          ],
                        5:[ReportModel.init(dict: ["name":"Guns", "id":0]),
                           ReportModel.init(dict: ["name":"Drugs", "id":1])],
                        7:[ReportModel.init(dict: ["name":"Technical issue", "id":0]),
                           ReportModel.init(dict: ["name":"Spam", "id":1]),
                           ReportModel.init(dict: ["name":"False information", "id":2]),
                           ReportModel.init(dict: ["name":"Hacked", "id":3]),
                           ReportModel.init(dict: ["name":"Something else", "id":4])
                          ]]
        self.dataSource.source = reportArr!
        self.collection.reloadData()
    }
}

extension ChatReportVC:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collection {
            selectedSub = indexPath.row
            self.dataSource.source.forEach({$0.isSelected = false})
            let reportObj = self.dataSource.source[indexPath.row]
            reportObj.isSelected = true
            self.selectedCatID = reportObj.id
            self.dataSource.source[indexPath.row] = reportObj
            self.collection.reloadData()
            if let arr = reportSubArr?[indexPath.row] as? [ReportModel] {
                self.dataSubSource.source = arr
                if  let flowSubLayout = self.subCollection.collectionViewLayout as? PartyPicksVerticalFlowLayout {
                    flowSubLayout.clearCache()
                }
                self.subCollection.reloadData()
            }else {
                self.dataSubSource.source = []
                self.subCollection.reloadData()
            }
        }else {
            self.dataSubSource.source.forEach({$0.isSelected = false})
            let reportObj = self.dataSubSource.source[indexPath.row]
            reportObj.isSelected = true
            self.dataSubSource.source[indexPath.row] = reportObj
            self.subCollection.reloadData()
        }
    }
}
