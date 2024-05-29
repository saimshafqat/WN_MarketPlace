//
//  RegisterationData.swift
//  WorldNoor
//
//  Created by Walid Ahmed on 25/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

struct RegisterationData: Codable {
    var selectedFirstName = String()
    var selectedLastName = String()
    var selectedBirthDateStr = String()
    var selectedGender = String()
    var selectedCustomGender = String()
    var selectedPronoun = String()
    var selectedEmail = String()
    var selectedPhone = String()
    var selectedCountryCode = String()
    var selectedCountryId = String()
    var selectedPassword = String()
    var selectedGenderIndex = -1
    var selectedPronounIndex = -1
    var selectedBirthDate: Date?
    var OTP_ID = String()
    var updatePasswordVia: UpdatePasswordVia? = .email

    mutating func resetPhone(){
        selectedPhone = String()
    }
    mutating func resetCustomGender(){
        selectedPronoun = String()
        selectedPronounIndex = -1
    }
    mutating func setBirthdayString(){
        selectedBirthDateStr = selectedBirthDate?.dateString("yyyy-MM-dd") ?? ""
    }
    mutating func setGenderString(){
        selectedGender = ""
        if selectedGenderIndex == 0{
            selectedGender = "F"
        }else if selectedGenderIndex == 1{
            selectedGender = "M"
//        }else if selectedGenderIndex == 2{
//            selectedGender = selectedPronoun
        }
    }
}
public struct GenderModel {
    var genders: [Genders]
    
    public init(genders: [Genders]) {
        self.genders = genders
    }
}
public struct Genders {
    var title: String
    var details: String

    public init(title: String,details: String) {
        self.title = title
        self.details = details

    }
}
