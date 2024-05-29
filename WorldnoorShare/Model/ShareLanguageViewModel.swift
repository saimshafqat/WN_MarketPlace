//
//  ShareLanguageViewModel.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class ShareLanguageViewModel: NSObject {
//    var langugageHandlerDetected:((Int, Int)->())?
    var languageUpdateHandler:((Int)->())?
    var reloadSpecificRowCommentImageUpload:((IndexPath)->())?
    
    func populateLangData()->[LanguageModel]{
        var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
        let lang1 = LanguageModel(name: " English", id: "1")
        let lang2 = LanguageModel(name: " Arabic", id: "2")
        let lang3 = LanguageModel(name: " French", id: "3")
        let lang4 = LanguageModel(name: " German", id: "4")
        let lang5 = LanguageModel(name: " Italian", id: "5")
        let lang6 = LanguageModel(name: " Japanese", id: "6")
        let lang7 = LanguageModel(name: " Russian", id: "7")
        let lang8 = LanguageModel(name: " Spanish", id: "8")
        let lang9 = LanguageModel(name: " Hindi", id: "9")
        let lang10 = LanguageModel(name: " Czech", id: "10")
        let lang11 = LanguageModel(name: " Danish", id: "11")
        let lang12 = LanguageModel(name: " Dutch", id: "12")
        let lang13 = LanguageModel(name: " Filipino", id: "13")
        let lang14 = LanguageModel(name: " Finnish", id: "14")
        let lang15 = LanguageModel(name: " Greek", id: "15")
        let lang16 = LanguageModel(name: " Hungarian", id: "16")
        let lang17 = LanguageModel(name: " Indonesian", id: "17")
        let lang18 = LanguageModel(name: " Korean", id: "18")
        let lang19 = LanguageModel(name: " Polish", id: "19")
        let lang20 = LanguageModel(name: " Portuguese", id: "20")
        let lang21 = LanguageModel(name: " Slovak", id: "21")
        let lang22 = LanguageModel(name: " Swedish", id: "22")
        let lang23 = LanguageModel(name: " Turkish", id: "23")
        let lang24 = LanguageModel(name: " Ukrainian", id: "24")
        let lang25 = LanguageModel(name: " Vitenamese", id: "25")
        let lang26 = LanguageModel(name: " Chinese", id: "26")

        lanaguageModelArray.append(lang1)
        lanaguageModelArray.append(lang2)
        lanaguageModelArray.append(lang3)
        lanaguageModelArray.append(lang4)
        lanaguageModelArray.append(lang5)
        lanaguageModelArray.append(lang6)
        lanaguageModelArray.append(lang7)
        lanaguageModelArray.append(lang8)
        lanaguageModelArray.append(lang9)
        lanaguageModelArray.append(lang10)
        lanaguageModelArray.append(lang11)
        lanaguageModelArray.append(lang12)
        lanaguageModelArray.append(lang13)
        lanaguageModelArray.append(lang14)
        lanaguageModelArray.append(lang15)
        lanaguageModelArray.append(lang16)
        lanaguageModelArray.append(lang17)
        lanaguageModelArray.append(lang18)
        lanaguageModelArray.append(lang19)
        lanaguageModelArray.append(lang20)
        lanaguageModelArray.append(lang21)
        lanaguageModelArray.append(lang22)
        lanaguageModelArray.append(lang23)
        lanaguageModelArray.append(lang24)
        lanaguageModelArray.append(lang25)
        lanaguageModelArray.append(lang26)
        return lanaguageModelArray
    }
}
