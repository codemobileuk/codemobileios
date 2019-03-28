//
//  Commands.swift
//  CodeMobile
//
//  Created by Louis Woods on 10/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import Foundation

class Commands{
    // List of all api commands
    static let SCHEDULE = "/Schedule"
    static let SPEAKERS = "/Speakers"
    static let LOCATIONS = "/Locations"
    static let TAGS = "/Tags"
    static let MODIFIED = "/Modified"
    static let SITE_URL = "https://code-mobile-api-dev-free.v2.vapor.cloud"
    static let API_ROOT = "/api/v1"
    //static let API_URL : String = "http://api.app.codemobile.co.uk/api"
    static let WEBSITE_URL : String = "http://codemobile.co.uk"
    static let FORM_URL : String = "https://docs.google.com/forms/d/e/1FAIpQLSfWruGR12AtCEMVJo_RHzqwyIiaYw9KMvOrK36_DlAD2xUlQw/viewform?usp=sf_link"
    
    static var API_URL: String {
        return "\(SITE_URL)\(API_ROOT)"
    }
}
