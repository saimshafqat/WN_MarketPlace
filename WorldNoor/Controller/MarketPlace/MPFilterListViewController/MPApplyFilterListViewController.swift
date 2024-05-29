//
//  MPApplyFilterListViewContr.swift
//  WorldNoor
//
//  Created by Ahmad on 20/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol ApplyFilterViewDelegate: AnyObject {
    func applyFilterOnSelectedItem(params: [String: Any])
    func resetApplyFilter()
}
class MPApplyFilterListViewController: UIViewController {
    
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var resetFilterBtn: UIButton!

    var viewModel = MPFilterViewModel()
    weak var delegate: ApplyFilterViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCustomCell()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetFilterBtn.isSelected = !resetFilterBtn.isSelected
        SharedManager.shared.filterItem.isEmpty ? viewModel.getAllItem() : ()
        resetFilterBtn.isSelected = !viewModel.isResetButtonEnableOrDisable()

        tbleView.reloadData()
    }
    
    private func registerCustomCell() {
        tbleView.registerCustomCells([MPFilterCell.className])
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.dismiss(animated: true)
//        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnResetFilter(_ sender: UIButton) {
        self.dismissVC {
            SharedManager.shared.filterItem.removeAll()
            self.delegate?.resetApplyFilter()
        }
    }

    
    @IBAction func sellAllItem_Pressed(_ sender: UIButton) {
        let context = (self)
        self.dismissVC {
            context.viewModel.searchPrameter()
            context.delegate?.applyFilterOnSelectedItem(params: context.viewModel.params)
        }
    }
}
