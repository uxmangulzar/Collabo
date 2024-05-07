//
//  Constants.swift
//  deliveriance
//
//  Created by Zeeshan Ashraf on 06/03/2020.
//  Copyright © 2020 SigiTechnologies. All rights reserved.
//

import Foundation

struct BaseUrls{
    
    static let baseUrl = "http://collabozone.com:8080/TAMY/FUNCTIONS/"
    static let baseUrlImages = "http://collabozone.com:8080/TAMY/"
}

// MARK: - Google Keys
struct Google {
    static let googlePlacesApiKey = "AIzaSyAWD3r8_xNLfwvjlpSvXc_FPgBRncfHXg4"
    static let gmsServiceApiKey = "AIzaSyAMG6PDA_yC-KwvNriijWO2dN_BQ_n13pY"
}

// MARK: - Messages
struct Message {
    static let warning = "Warning"
    static let call = "You device not supported calls at the moment"
}

struct UserDefaultKey {
    static let userId = "userId"
    static let userImg = "userImg"
    static let userName = "userName"
    static let userEmail = "userEmail"
    static let jwt = "jwt"
}
