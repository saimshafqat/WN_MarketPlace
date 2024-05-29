//
//  GoogleSignInModel.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 05/07/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

struct Welcome: Codable {
    let nextPageToken: String?
    let totalSize: Int?
    let otherContacts: [OtherContact]?
}

// MARK: - OtherContact
struct OtherContact: Codable {
    let resourceName: String?
    let emailAddresses: [EmailAddress]?
    let etag: String?
    let names: [Name]?
}

// MARK: - EmailAddress
struct EmailAddress: Codable {
    let value: String?
    let metadata: EmailAddressMetadata?
}

// MARK: - EmailAddressMetadata
struct EmailAddressMetadata: Codable {
    let source: Source?
    let primary, sourcePrimary: Bool?
}

// MARK: - Source
struct Source: Codable {
    let type: TypeEnum?
    let id: String?
}

enum TypeEnum: String, Codable {
    case otherContact = "OTHER_CONTACT"
}

// MARK: - Name
struct Name: Codable {
    let displayNameLastFirst, displayName, familyName, unstructuredName: String?
    let givenName: String?
    let metadata: NameMetadata?
    let middleName: String?
}

// MARK: - NameMetadata
struct NameMetadata: Codable {
    let source: Source?
    let primary: Bool?
}
