//
//  MPFilterSelect.swift
//  WorldNoor
//
//  Created by Ahmad on 20/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol ApplyFilterDelegate: AnyObject{
    func applyFilterParameter(item: Item,  indexPath: IndexPath?, isComeFromSelectFilter: Bool)
    func resetFilter()

}

class MPFilterSelectcontroller: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewOfPrice: UIView!
    weak var filterDelegate: ApplyFilterDelegate?
    
    @IBOutlet weak var minimumPriceText: UITextField!
    @IBOutlet weak var maximumPriceText: UITextField!
    @IBOutlet weak var btnFilter: UIButton!

    var viewModel = MPFilterSelectionModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = viewModel.getSelectViewTitle()
        viewModel.delegate = self
        registerCustomCell()
        if viewModel.selectedItem?.selectedItem == .condition {
            viewOfPrice.isHidden = true
            tblView.isHidden = false
            viewModel.getCondition()
        } else if viewModel.selectedItem?.selectedItem == .date_listed ||  viewModel.selectedItem?.selectedItem == .availability {
            viewOfPrice.isHidden = true
            tblView.isHidden = false
            viewModel.getAvailabilitySlot()
            self.tblView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnFilter.isSelected = !btnFilter.isSelected
        btnFilter.isSelected = !viewModel.isResetButtonEnableOrDisable()
    }
    
    private func registerCustomCell() {
        tblView.registerCustomCells([MPApplyFilterCell.className])
    }
    
    

    
    @IBAction func onClickBack(_ sender: UIButton) {
        goinBackVc()
    }
    
    private func goinBackVc() {
        let context = (self)
        self.dismissVC {
            context.setTheFilterItem(applyFilterParameter: false)
        }
    }
    
    @IBAction func sellAllItem_Pressed(_ sender: UIButton) {
        let context = (self)
        self.dismissVC {
            context.setTheFilterItem(applyFilterParameter: true)
        }
    }
    
    @IBAction func btnResetFilter(_ sender: UIButton) {
        self.dismissVC {
            SharedManager.shared.filterItem.removeAll()
            self.filterDelegate?.resetFilter()
        }
    }

    func setTheFilterItem(applyFilterParameter: Bool){
        var isPriceFilter  = false
        if minimumPriceText.text?.count ?? 0 > 0 {
            isPriceFilter = true
        } else if maximumPriceText.text?.count ?? 0 > 0 {
            isPriceFilter = true
        }
        
        switch viewModel.selectedItem?.selectedItem {
        case .price:
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.selectedItem?.description ?? "", selectedItem: viewModel.selectedItem?.selectedItem ?? .price, minimumPrice: minimumPriceText.text ?? "", maximumPrice: maximumPriceText.text ?? "", isApplyFilter: isPriceFilter), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter )
            break
        case .availability:
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: "Any", selectedItem: viewModel.selectedItem?.selectedItem ?? .availability, availability: viewModel.getFilterItem() , isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            break
        case .condition:
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.getSelectedCondition().isEmpty ? "Any" : viewModel.getSelectedCondition() , selectedItem: viewModel.selectedItem?.selectedItem ?? .condition, condition: viewModel.getFilterItem() , isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            break
        case .date_listed:
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.getSelectedDateAvailability().isEmpty ? "Any" : viewModel.getSelectedDateAvailability(), selectedItem: viewModel.selectedItem?.selectedItem ?? .date_listed, daysSinceListed: viewModel.getFilterItem() , isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            break
        case .none:
            break
        }

    }
}

extension MPFilterSelectcontroller: ProductListDelegate {
    func isProductAvalaibleOrNot(_ avalaible: Bool) {
        if avalaible {
            tblView?.delegate = self
            tblView?.dataSource = self
            tblView?.reloadData()
        }
    }
}
