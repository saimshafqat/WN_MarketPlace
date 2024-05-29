//
//  DropDownDataSourceConfig.swift
//  Bank Alflah
//
//  Created by Muhammad Asher on 18/08/2023.
//

import UIKit

enum DDDataConfig: String, CaseIterable {
    case Public = "Public"
    case Friends = "Friends"
    case OnlyMe = "Only me"
    static var dataList: [String] {
        return DDDataConfig.allCases.map({$0.rawValue})
    }
}
