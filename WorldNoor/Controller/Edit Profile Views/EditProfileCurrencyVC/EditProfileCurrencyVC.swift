//
//  EditProfileCurrencyVC.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine

class EditProfileCurrencyVC: UIViewController {
    
    // MARK: - Properties-
    var currenyList: [Currency] = []
    var filterCurrenyList: [Currency] = []
    var refreshParentView: (()->())?
    var type = -1
    var rowIndex = -1
    private var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    // MARK: - IBOutlet -
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        showError()
        if SharedManager.shared.currenciesList.count == 0 {
            loadCurrenciesRequest()
        } else {
            currenyList = SharedManager.shared.currenciesList
        }
    }
    
    // MARK: - IBActions -
    @IBAction func onClickBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods -
    func setDelegates() {
        searchBar.delegate = self
    }
    
    func reloadView(type : Int , rowIndexP : Int ) {
        self.type = type
        self.rowIndex = rowIndexP
    }
    
    func showError() {
        apiService.errorMessagePublisher
            .sink { errorValue in
                SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: errorValue)
            }.store(in: &subscription)
    }
    
    func loadCurrenciesRequest() {
        Loader.startLoading()
        apiService.getCurrenciesRequest(endPoint: .getCurrencyList([:]))
            .sink { completion in
                switch completion {
                case .finished:
                    Loader.stopLoading()
                    LogClass.debugLog("Currencies Load finished")
                case .failure(let err):
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: err.localizedDescription)
                }
            } receiveValue: { response in
                Loader.stopLoading()
                self.currenyList.removeAll()
                for currency in response.data {
                    self.currenyList.append(currency)
                }
                self.tableView.reloadData()
                SharedManager.shared.currenciesList = response.data
            }.store(in: &subscription)
    }
    
    func editCurrencyRequest(currencyItem: Currency) {
        Loader.startLoading()
        let params: [String: String] = ["currency_id" : "\(currencyItem.id)"]
        apiService.updateCurrencyRequest(endPoint: .currencyUpdate(params))
            .sink { completion in
                switch completion {
                case .finished:
                    Loader.stopLoading()
                    LogClass.debugLog("Currencies Load finished")
                case .failure(let err):
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: err.localizedDescription)
                }
            } receiveValue: { response in
                Loader.stopLoading()
                SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: response.meta.message ?? .emptyString)
                let currencyResponseDic: [String: String] = ["id":"\(response.data.id)", "name" : response.data.name, "symbol" : response.data.symbol]
                SharedManager.shared.userEditObj.currency = UserCurrency(fromDictionary: currencyResponseDic)
                self.dismiss(animated: true) {
                    self.refreshParentView?()
                }
            }.store(in: &subscription)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -
extension EditProfileCurrencyVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCurrenyList.isEmpty ? currenyList.count : filterCurrenyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCurrencyCell", for: indexPath) as! EditProfileCurrencyCell
        let currency = filterCurrenyList.isEmpty ? currenyList[indexPath.row] : filterCurrenyList[indexPath.row]
        cell.configureView(item: currency, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Determine the selected currency
        let selectedCurrency = filterCurrenyList.isEmpty ? currenyList[indexPath.row] : filterCurrenyList[indexPath.row]
        // Call the delegate method with the selected currency
        self.editCurrencyRequest(currencyItem: selectedCurrency)
    }
}

// MARK: - UISearchBarDelegate -
extension EditProfileCurrencyVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterCurrenyList =  self.currenyList.filter({item -> Bool in
            let stringMatch = item.name.lowercased().range(of: searchText.lowercased())
            return stringMatch != nil ? true : false
        })
        if searchText.count == 0 {
            self.filterCurrenyList = self.currenyList
        }
        self.tableView.reloadData()
    }
}
