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
    @IBOutlet weak var stackHeight: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewOfPrice: UIView!
    weak var filterDelegate: ApplyFilterDelegate?
    
    @IBOutlet weak var minimumPriceText: UITextField!
    @IBOutlet weak var maximumPriceText: UITextField!
    @IBOutlet weak var btnFilter: UIButton!
    
    var radioButtons = [RadioButton]()
    var selectedOptionId: String = ""
    var selectedOption : ((RadioButtonItem) -> ())?
    var viewModel = MPFilterSelectionModel()
  
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let availabilityArr = [RadioButtonItem(radioId: "0", radioTitle: "Available",                 radioDescription: ""),
                       RadioButtonItem(radioId: "1", radioTitle: "Sold", radioDescription: "")
                       ]
        let dateArr = [RadioButtonItem(radioId: "0", radioTitle: "All", radioDescription: ""),
                       RadioButtonItem(radioId: "1", radioTitle: "Last 24 hours", radioDescription: ""),
                       RadioButtonItem(radioId: "2", radioTitle: "Last 7 days", radioDescription: ""),
                       RadioButtonItem(radioId: "3", radioTitle: "Last 30 days", radioDescription: "")]
        self.selectedOptionId = viewModel.selectedItem?.selectedIndex ?? ""
        lblTitle.text = viewModel.getSelectViewTitle()
        viewModel.delegate = self
        registerCustomCell()
        if viewModel.selectedItem?.selectedItem == .condition {
            viewOfPrice.isHidden = true
            stackView.isHidden = true
            tblView.isHidden = false
            viewModel.getCondition()
        } else if viewModel.selectedItem?.selectedItem == .date_listed ||  viewModel.selectedItem?.selectedItem == .availability {
            if (viewModel.selectedItem?.selectedItem == .availability){
                self.stackHeight.constant = CGFloat(availabilityArr.count * 50)
                availabilityArr.forEach { avaiability in
                    let radioButton = RadioButton(radioItem: avaiability)
                    radioButton.delegate = self
                    radioButton.isSelected = avaiability.radioId == viewModel.selectedItem?.selectedIndex
                    stackView.addArrangedSubview(radioButton)
                    radioButtons.append(radioButton)
                }
            }
            else{
                
                self.stackHeight.constant = CGFloat(dateArr.count * 50)
                dateArr.forEach { date in
                    let radioButton = RadioButton(radioItem: date)
                    radioButton.delegate = self
                    radioButton.isSelected = date.radioId == viewModel.selectedItem?.selectedIndex
                    stackView.addArrangedSubview(radioButton)
                    radioButtons.append(radioButton)
                }
            }
            viewOfPrice.isHidden = true
            tblView.isHidden = true
            stackView.isHidden = false
            viewModel.getAvailabilitySlot()
            if self.selectedOptionId.count > 0 {
                if let item = viewModel.getItemAt(index: Int(self.selectedOptionId)!){
                    viewModel.updateSelectedItem(item: item)
                }
            }
            self.tblView.reloadData()
        }
        else if(viewModel.selectedItem?.selectedItem == .price){
            self.minimumPriceText.text = viewModel.selectedItem?.minimumPrice
            self.maximumPriceText.text = viewModel.selectedItem?.maximumPrice
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
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: "Any", selectedItem: viewModel.selectedItem?.selectedItem ?? .availability, availability: viewModel.getFilterItem() , isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true, selectedIndex: self.selectedOptionId), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            break
        case .condition:
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.getSelectedCondition().isEmpty ? "Any" : viewModel.getSelectedCondition() , selectedItem: viewModel.selectedItem?.selectedItem ?? .condition, condition: viewModel.getFilterItem() , isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true, selectedIndex: self.selectedOptionId), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            break
        case .date_listed:
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.getSelectedDateAvailability().isEmpty ? "Any" : viewModel.getSelectedDateAvailability(), selectedItem: viewModel.selectedItem?.selectedItem ?? .date_listed, daysSinceListed: viewModel.getFilterItem() , isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true , selectedIndex: self.selectedOptionId), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
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
extension MPFilterSelectcontroller : RadioButtonDelegate{
    func radioButtonDidSelect(_ radioButton: RadioButton) {
        
        for otherButton in self.radioButtons {
            if otherButton != radioButton {
                otherButton.isSelected = false
            }
        }
        
        if radioButton.isSelected {
            if  let radioButtonItem = radioButton.radioButtonItem {
                LogClass.debugLog("Selected Option: \(radioButtonItem.radioTitle)")
               
                
                
                if let item = viewModel.getItemAt(index: Int(radioButtonItem.radioId)!){
                    self.selectedOptionId = radioButtonItem.radioId
                    if viewModel.containsObjectss(object: item) {
                        if viewModel.selectedItem?.selectedItem == .availability  || viewModel.selectedItem?.selectedItem == .date_listed {
                            
                                viewModel.removeSelectedItem(item: item)
                            }
                        viewModel.updateSelectedItem(item: item)
                    }else {
                        if viewModel.selectedItem?.selectedItem == .availability  || viewModel.selectedItem?.selectedItem == .date_listed {
                            
                            if viewModel.maintainSelectedCondition.count == 0 {
                                viewModel.updateSelectedItem(item: item)
                            }
                        }else {
                            viewModel.updateSelectedItem(item: item)
                        }
                    }
                }
            }
        }
    
    }
}
