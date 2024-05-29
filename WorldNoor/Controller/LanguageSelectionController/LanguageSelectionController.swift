//
//  LanguageSelectionController.swift
//  WorldNoor
//
//  Created by Raza najam on 3/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

protocol LanguageSelectionDelegate {
    func lanaguageSelected(langObj:LanguageModel)
    func lanaguageSelected(langObj:LanguageModel, indexPath:IndexPath)

}

class LanguageSelectionController: UIViewController {
    var selectedLangObj:LanguageModel?
    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
    var delegate:LanguageSelectionDelegate?
    let viewLanguageModel = ShareLanguageViewModel()
    var currentIndex:IndexPath? = nil
    
    @IBOutlet weak var langTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lanaguageModelArray = self.viewLanguageModel.populateLangData()
    }
}

extension LanguageSelectionController:UITableViewDelegate, UITableViewDataSource {
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
        }else {
            self.delegate?.lanaguageSelected(langObj: self.selectedLangObj!)
        }
    }
}

// MARK: - UI Resources
class LanguageCell : UITableViewCell {
    @IBOutlet var title : UILabel!
}
