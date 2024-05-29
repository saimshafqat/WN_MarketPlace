//
//  CommandsListVC.swift
//  WorldNoor
//
//  Created by apple on 11/2/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class CommandsListVC : UIViewController {
    
    @IBOutlet var tbleViewList : UITableView!
    
    var arrayList = [[String : String]]()
    
    override func viewDidLoad() {
        self.tbleViewList.register(UINib.init(nibName: "CommandTableCell", bundle: nil), forCellReuseIdentifier: "CommandTableCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.arrayList.removeAll()
        self.arrayList.append(["Name" : "Refreshing your feeds." , "Des" : "Refresh your feed view"])
        self.arrayList.append(["Name" : "My Profile" , "Des" : "Open user profile"])
        self.arrayList.append(["Name" : "Create your post now." , "Des" : "open create post dialogue"])
        self.arrayList.append(["Name" : "Hey Worldnoor" , "Des" : "Hi Worldnoor"])
        self.tbleViewList.reloadData()
    }
    
    
}

extension CommandsListVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellList = tableView.dequeueReusableCell(withIdentifier: "CommandTableCell") as! CommandTableCell
        
        guard  let cellList = tableView.dequeueReusableCell(withIdentifier: "CommandTableCell") as? CommandTableCell else {
           return UITableViewCell()
        }
        
        cellList.lblTitle.text = self.arrayList[indexPath.row]["Name"]
        cellList.lblDes.text = self.arrayList[indexPath.row]["Des"]
        return cellList
    }
}


class CommandTableCell : UITableViewCell {
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblDes : UILabel!
}
