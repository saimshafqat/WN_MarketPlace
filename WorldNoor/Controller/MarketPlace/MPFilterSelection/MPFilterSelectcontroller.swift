//
//  MPFilterSelect.swift
//  WorldNoor
//
//  created by Moeez akram on 20/05/2024.
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
    
    @IBOutlet weak var viewofSQ: UIView!
    @IBOutlet weak var mimimumSqTF: UITextField!
    @IBOutlet weak var maximumSqTf: UITextField!
    @IBOutlet weak var btnFilter: UIButton!
    
    var radioButtons = [RadioButton]()
    var selectedOptionId: String = ""
    var selectedOption : ((RadioButtonItem) -> ())?
    var viewModel = MPFilterSelectionModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let availabilityArr = [RadioButtonItem(radioId: "0", radioTitle: "Available",radioDescription: "", radioButtonValue: ""),
                               RadioButtonItem(radioId: "1", radioTitle: "Sold", radioDescription: "", radioButtonValue: "")
        ]
        let dateArr = [RadioButtonItem(radioId: "0", radioTitle: "All", radioDescription: "", radioButtonValue: ""),
                       RadioButtonItem(radioId: "1", radioTitle: "Last 24 hours", radioDescription: "", radioButtonValue: ""),
                       RadioButtonItem(radioId: "2", radioTitle: "Last 7 days", radioDescription: "", radioButtonValue: ""),
                       RadioButtonItem(radioId: "3", radioTitle: "Last 30 days", radioDescription: "", radioButtonValue: "")
        ]
        let bedroomArr = [RadioButtonItem(radioId: "0", radioTitle: "All",radioDescription: "", radioButtonValue: ""),
                          RadioButtonItem(radioId: "1", radioTitle: "1+", radioDescription: "", radioButtonValue: ""),
                          RadioButtonItem(radioId: "2", radioTitle: "2+", radioDescription: "", radioButtonValue: ""),
                          RadioButtonItem(radioId: "3", radioTitle: "3+", radioDescription: "", radioButtonValue: ""),
                          RadioButtonItem(radioId: "4", radioTitle: "4+", radioDescription: "", radioButtonValue: ""),
                          RadioButtonItem(radioId: "5", radioTitle: "5+", radioDescription: "", radioButtonValue: ""),
                          RadioButtonItem(radioId: "6", radioTitle: "6+", radioDescription: "", radioButtonValue: "")
        ]
        let bathroomArr = [RadioButtonItem(radioId: "0", radioTitle: "All",radioDescription: "", radioButtonValue: ""),
                           RadioButtonItem(radioId: "1", radioTitle: "1+", radioDescription: "", radioButtonValue: ""),
                           RadioButtonItem(radioId: "2", radioTitle: "2+", radioDescription: "", radioButtonValue: ""),
                           RadioButtonItem(radioId: "3", radioTitle: "3+", radioDescription: "", radioButtonValue: ""),
                           RadioButtonItem(radioId: "4", radioTitle: "4+", radioDescription: "", radioButtonValue: ""),
                           RadioButtonItem(radioId: "5", radioTitle: "5+", radioDescription: "", radioButtonValue: "")
        ]
        
        self.selectedOptionId = viewModel.selectedItem?.selectedIndex ?? ""
        lblTitle.text = viewModel.getSelectViewTitle()
        viewModel.delegate = self
        registerCustomCell()
        if viewModel.selectedItem?.selectedItem == .condition || viewModel.selectedItem?.selectedItem == .rentalTypes{
            viewOfPrice.isHidden = true
            viewofSQ.isHidden = true
            stackView.isHidden = true
            tblView.isHidden = false
            viewModel.getCondition()
            var selectedConditionString = ""
            if viewModel.selectedItem?.selectedItem == .condition{
                selectedConditionString = viewModel.selectedItem?.condition ?? ""
                let selectedConditionIDs = selectedConditionString.split(separator: ",").compactMap { Int($0) }
                viewModel.maintainSelectedCondition = selectedConditionIDs.compactMap { id in
                    return SharedManager.shared.conditionList.first { $0.id == id }
                }
            }else{
                selectedConditionString = viewModel.selectedItem?.rentaltypes ?? ""
                let selectedConditionIDs = selectedConditionString.split(separator: ",").compactMap { String($0) }
                viewModel.maintainSelectedCondition = selectedConditionIDs.compactMap { slug in
                    return viewModel.conditionList?.first { $0.slug == slug }
                }
            }
        } else if viewModel.selectedItem?.selectedItem == .dateListed ||  viewModel.selectedItem?.selectedItem == .availability || viewModel.selectedItem?.selectedItem == .bedrooms || viewModel.selectedItem?.selectedItem == .bathrooms{
            if (viewModel.selectedItem?.selectedItem == .availability){
                self.stackHeight.constant = CGFloat(availabilityArr.count * 50)
                availabilityArr.forEach { avaiability in
                    let radioButton = RadioButton(radioItem: avaiability)
                    radioButton.delegate = self
                    radioButton.isSelected = avaiability.radioId == viewModel.selectedItem?.selectedIndex
                    stackView.addArrangedSubview(radioButton)
                    radioButtons.append(radioButton)
                }
            }else if (viewModel.selectedItem?.selectedItem == .bedrooms){
                self.stackHeight.constant = CGFloat(bedroomArr.count * 50)
                bedroomArr.forEach { bedroom in
                    let radioButton = RadioButton(radioItem: bedroom)
                    radioButton.delegate = self
                    radioButton.isSelected = bedroom.radioId == viewModel.selectedItem?.selectedIndex
                    stackView.addArrangedSubview(radioButton)
                    radioButtons.append(radioButton)
                }
            }else if (viewModel.selectedItem?.selectedItem == .bathrooms){
                self.stackHeight.constant = CGFloat(bathroomArr.count * 50)
                bathroomArr.forEach { bathroom in
                    let radioButton = RadioButton(radioItem: bathroom)
                    radioButton.delegate = self
                    radioButton.isSelected = bathroom.radioId == viewModel.selectedItem?.selectedIndex
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
            viewofSQ.isHidden = true
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
            viewofSQ.isHidden = true
            self.minimumPriceText.text = viewModel.selectedItem?.minimumPrice
            self.maximumPriceText.text = viewModel.selectedItem?.maximumPrice
        }
        else if(viewModel.selectedItem?.selectedItem == .squareMeters){
            viewOfPrice.isHidden = true
            self.mimimumSqTF.text = viewModel.selectedItem?.minimumSq
            self.maximumSqTf.text = viewModel.selectedItem?.maximumSq
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
        
        var isSqFilter  = false
        if mimimumSqTF.text?.count ?? 0 > 0 {
            isSqFilter = true
        } else if maximumSqTf.text?.count ?? 0 > 0 {
            isSqFilter = true
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
        case .dateListed:
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.getSelectedDateAvailability().isEmpty ? "Any" : viewModel.getSelectedDateAvailability(), selectedItem: viewModel.selectedItem?.selectedItem ?? .dateListed, daysSinceListed: viewModel.getFilterItem() , isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true , selectedIndex: self.selectedOptionId), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            break
        case .none:
            break
        case .some(.bathrooms):
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.getSelectedDateAvailability().isEmpty ? "Any" : viewModel.getSelectedDateAvailability(), selectedItem: viewModel.selectedItem?.selectedItem ?? .bathrooms, isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true , selectedIndex: self.selectedOptionId, bathroom: viewModel.getFilterItem() ), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            
        case .some(.bedrooms):
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.getSelectedDateAvailability().isEmpty ? "Any" : viewModel.getSelectedDateAvailability(), selectedItem: viewModel.selectedItem?.selectedItem ?? .bedrooms, isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true , selectedIndex: self.selectedOptionId, bedroom: viewModel.getFilterItem() ), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            
        case .some(.rentalTypes):
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.getSelectedCondition().isEmpty ? "Any" : viewModel.getSelectedCondition() , selectedItem: viewModel.selectedItem?.selectedItem ?? .rentalTypes , isApplyFilter: viewModel.getFilterItem().isEmpty  ?  false : true, selectedIndex: self.selectedOptionId, rentaltypes: viewModel.getFilterItem()), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter)
            
        case .some(.squareMeters):
            filterDelegate?.applyFilterParameter(item: Item(name: viewModel.selectedItem?.name ?? "", description: viewModel.selectedItem?.description ?? "", selectedItem: viewModel.selectedItem?.selectedItem ?? .squareMeters, isApplyFilter: isSqFilter,minimumSq: mimimumSqTF.text ?? "",maximumSq: maximumSqTf.text ?? ""), indexPath: viewModel.indexPath, isComeFromSelectFilter: applyFilterParameter )
            
        }
        
    }
}

extension MPFilterSelectcontroller: ProductListDelegate {
    func isProductAvalaibleOrNot(_ avalaible: Bool, newIndexes : [IndexPath]) {
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
                        if viewModel.selectedItem?.selectedItem == .availability  || viewModel.selectedItem?.selectedItem == .dateListed || viewModel.selectedItem?.selectedItem == .bathrooms || viewModel.selectedItem?.selectedItem == .bedrooms{
                            viewModel.removeSelectedItem(item: item)
                        }
                        viewModel.updateSelectedItem(item: item)
                    }else {
                        if viewModel.selectedItem?.selectedItem == .availability  || viewModel.selectedItem?.selectedItem == .dateListed || viewModel.selectedItem?.selectedItem == .bathrooms || viewModel.selectedItem?.selectedItem == .bedrooms{
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
