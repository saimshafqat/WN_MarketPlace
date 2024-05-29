//
//  LifeEventUIConfiguration.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 27/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

enum LifeEventUIConfiguration: String {
    
    case work = "Work"
    case education = "Education"
    case relatinship = "Relationship"
    case homeAndLiving = "Home & Living"
    case unknown
    
    // Configuration model for UI elements
    struct UIConfiguration {
        var schoolTopConstraint: CGFloat
        var schoolTypeTopConstraint: CGFloat
        var locationTopConstraint: CGFloat
        var partnerTopConstraint: CGFloat
        var workSpaceTopConstraint: CGFloat
        
        var schoolHeightConstraint: CGFloat
        var schoolTypeHeightConstraint: CGFloat
        var locationHeightConstraint: CGFloat
        var partnerHeightConstraint: CGFloat
        var workspaceHeightConstraint: CGFloat
        
        var isSchoolHidden: Bool
        var isSchoolTypeDropDownHidden: Bool
        var isLocationHidden: Bool
        var isPartnerHidden: Bool
        var isWorkspaceHidden: Bool
    }
    
    var configuration: UIConfiguration {
        switch self {
        case .work:
            return UIConfiguration(
                schoolTopConstraint: 0, schoolTypeTopConstraint: 0, locationTopConstraint: 0, partnerTopConstraint: 0, workSpaceTopConstraint: 16,
                schoolHeightConstraint: 0, schoolTypeHeightConstraint: 0, locationHeightConstraint: 0, partnerHeightConstraint: 0, workspaceHeightConstraint: 52,
                isSchoolHidden: true, isSchoolTypeDropDownHidden: true, isLocationHidden: true, isPartnerHidden: true, isWorkspaceHidden: false)
            
        case .education:
            return UIConfiguration(
                schoolTopConstraint: 16, schoolTypeTopConstraint: 16, locationTopConstraint: 0, partnerTopConstraint: 0, workSpaceTopConstraint: 0,
                schoolHeightConstraint: 52, schoolTypeHeightConstraint: 45, locationHeightConstraint: 0, partnerHeightConstraint: 0, workspaceHeightConstraint: 0,
                isSchoolHidden: false, isSchoolTypeDropDownHidden: false, isLocationHidden: true, isPartnerHidden: true, isWorkspaceHidden: true)
            
        case .relatinship:
            return UIConfiguration(
                schoolTopConstraint: 0, schoolTypeTopConstraint: 0, locationTopConstraint: 0, partnerTopConstraint: 16, workSpaceTopConstraint: 0,
                schoolHeightConstraint: 0, schoolTypeHeightConstraint: 0, locationHeightConstraint: 0, partnerHeightConstraint: 52, workspaceHeightConstraint: 0,
                isSchoolHidden: true, isSchoolTypeDropDownHidden: true, isLocationHidden: true, isPartnerHidden: false, isWorkspaceHidden: true)
            
        case .homeAndLiving:
            return UIConfiguration(
                schoolTopConstraint: 0, schoolTypeTopConstraint: 0, locationTopConstraint: 16, partnerTopConstraint: 0, workSpaceTopConstraint: 0,
                schoolHeightConstraint: 0, schoolTypeHeightConstraint: 0, locationHeightConstraint: 52, partnerHeightConstraint: 0, workspaceHeightConstraint: 0,
                isSchoolHidden: true, isSchoolTypeDropDownHidden: true, isLocationHidden: false, isPartnerHidden: true, isWorkspaceHidden: true)
        case .unknown:
            return UIConfiguration(
                schoolTopConstraint: 0, schoolTypeTopConstraint: 0, locationTopConstraint: 0, partnerTopConstraint: 0, workSpaceTopConstraint: 0,
                schoolHeightConstraint: 0, schoolTypeHeightConstraint: 0, locationHeightConstraint: 0, partnerHeightConstraint: 0, workspaceHeightConstraint: 0,
                isSchoolHidden: true, isSchoolTypeDropDownHidden: true, isLocationHidden: true, isPartnerHidden: true, isWorkspaceHidden: true)
        }
    }
}
