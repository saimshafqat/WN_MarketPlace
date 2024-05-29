//
//  ReelsFeedBackViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Cosmos

protocol FeedBackReasonProtocol {
    func toggleOption(feedBackReasonModel: inout [FeedBackReasonModel], isAdding: Bool)
}

struct FeedBackReasonModel: FeedBackReasonProtocol {
    var id: Int
    var name: String
}

extension FeedBackReasonModel {
    
    func toggleOption(feedBackReasonModel: inout [FeedBackReasonModel], isAdding: Bool) {
        if isAdding {
            if !feedBackReasonModel.contains(where: { $0.id == self.id }) {
                feedBackReasonModel.append(self)
            }
        } else if let index = feedBackReasonModel.firstIndex(where: { $0.id == self.id }) {
            feedBackReasonModel.remove(at: index)
        }
    }
}

class ReelsFeedBackViewController: BaseViewController {

    // MARK: - Properties -
    var optionsSubmit: [FeedBackReasonModel] = []
    var delegate: DismissReportDetailSheetDelegate?
    var feedObj : FeedData?
    
    var feedBackReasonModel: [FeedBackReasonModel] = [
        FeedBackReasonModel(id: 3, name: "reasons_blur"),
        FeedBackReasonModel(id: 4, name: "reasons_frozen"),
        FeedBackReasonModel(id: 5, name: "reasons_long"),
        FeedBackReasonModel(id: 6, name: "reasons_lag"),
        FeedBackReasonModel(id: 7, name: "reasons_audio")
    ]
    
    var arrayOptions: [FeedBAckOptions] = [
        FeedBAckOptions(id: 0,text:"Tell us more"),
        FeedBAckOptions(id: 3,text:"Blur or pixelation"),
        FeedBAckOptions(id: 4,text:"Frozen video"),
        FeedBAckOptions(id: 5,text:"Video took a long time to start"),
        FeedBAckOptions(id: 6,text:"Lag or buffering during playback"),
        FeedBAckOptions(id: 7,text:"Audio problems"),
        FeedBAckOptions(id: 2,text:"Submit")
    ]
    
    // MARK: - IBOutlets -
    @IBOutlet weak var ratingView: CosmosView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: - override -
    override func initilizeDataSource() -> SSBaseDataSource? {
        let ds = SSArrayDataSource(items: arrayOptions)
        return ds
    }

    override func configureView() {
        dataSource?.cellCreationBlock = {[weak self] object, parentView, index in
            guard let self else { return }
            let item = dataSource?.item(at: index) as? FeedBAckOptions
            let itemID = item?.id
            var clazzInstance: SSBaseTableCell.Type
            if itemID == 0 {
                clazzInstance = FeedBackInfoTableCell.self
            } else if itemID == 2 {
                clazzInstance = FeedbackSubmitTableCell.self
            } else {
                clazzInstance = FeedbackOptionTableCell.self
            }
            return clazzInstance.init(for: parentView as? UITableView)
        }
        super.configureView()
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseTableCell)?.configureCell(nil, atIndex: indexPath, with: object)
            (cell as? SSBaseTableCell)?.layoutIfNeeded()
            (cell as? FeedbackOptionTableCell)?.feedbackOptionCellDelegate = self
            (cell as? FeedbackSubmitTableCell)?.feedbackSubmitDelegate = self
        }
    }
}

// MARK: - FeedbackOptionCellDelegate -
extension ReelsFeedBackViewController: FeedbackOptionCellDelegate {
    func didChooseOptionTapped(with sender: UIButton, at indexPath: IndexPath, isAdded: Bool) {
        let item = dataSource?.item(at: indexPath) as? FeedBAckOptions
        let reason = feedBackReasonModel.filter({ $0.id ==  item?.id }).first
        reason?.toggleOption(feedBackReasonModel: &optionsSubmit, isAdding: isAdded)
        AppLogger.log(tag: .debug, "Option available", optionsSubmit)
    }
}

// MARK: - FeedbackOptionCellDelegate -
extension ReelsFeedBackViewController: FeedbackSubmitCellDelegate {
    
    func submitTapped(sender: UIButton) {
        Loader.startLoading()
        var parameters = [
            "action": "reel-feedback",
            "token": SharedManager.shared.userToken() ,
            "rating" : String(self.ratingView.rating) ,
            "post_files_id" : String(self.feedObj?.postID ?? 0)
        ]
        for (index, option) in self.optionsSubmit.enumerated() {
            parameters["reasons[\(index)]"] = option.name
        }
        RequestManager.fetchDataPost(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if let errorModel = error as? ErrorModel, let msg = errorModel.meta?.message {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: msg)
                } else {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: Const.networkProblemMessage.localized())
                }
            case .success(let res):
                if let newRes = res as? String {
                    self.dismiss(animated: true) {
                        self.delegate?.dismissReport(message: newRes)
                    }
                }
            }
        }, param: parameters)
    }
}
