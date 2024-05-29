//
//  LanguageSelectionController.swift
//  WorldNoor
//
//  Created by Raza najam on 3/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

protocol ShareLanguageSelectionDelegate {
    func lanaguageSelected(langObj:LanguageModel, indexPath:IndexPath)
}

class ShareLanguageController: UIViewController {
    var selectedLangObj:LanguageModel?
    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
    var delegate:ShareLanguageSelectionDelegate?
    let viewLanguageModel = ShareLanguageViewModel()
    var currentIndex:IndexPath? = nil
    @IBOutlet weak var langTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lanaguageModelArray = self.viewLanguageModel.populateLangData()
//        self.lanaguageModelArray = SharedRequestManager
    }
}

extension ShareLanguageController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lanaguageModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as? LanguageCell {
            let langObj = self.lanaguageModelArray[indexPath.row]
            cell.title.text = langObj.languageName
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedLangObj = self.lanaguageModelArray[indexPath.row]
        if self.currentIndex != nil {
            self.delegate?.lanaguageSelected(langObj: self.selectedLangObj!, indexPath:self.currentIndex!)
        }
    }
}

