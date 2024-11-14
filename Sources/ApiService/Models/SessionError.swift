//
//  MethodType.swift
//
//
//  Created by Naresh on 14/11/24.
//


import Foundation

/// These are the errors we can throw from api function if any sepecified condition met.
public enum SessionError: Error, Equatable {
    /// We will thow this error when the data parsing failed due to some reason
    case parsingError
    /// we will throw this error when the URL request can't be built, Some error in the URL
    case invalidRequest
    /// If api retuns 401 then we will throw this error to take appropriate action. logging out or refreshing token.
    case encryptionDescryptionFailed
    /// This error is for rest of all errors.
    case error(code: Int, message: String)
    case authenticationFailed
    
    /*
    /// Here we will specify the message we need to show to the end user. The localisation can also be done here if needed.
    var message: String {
        switch self {
        case .parsingError:
            return "The data is not in the correct format. Please try agian later"
        case .invalidRequest:
            return "The invalid request. Please try agian later"
        case .error(_, let message):
            return message
        case .encryptionDescryptionFailed:
            return "Data encryptio failed, please email is issue us at abc@xyz.com"
        case .authenticationFailed:
            <#code#>
        }
    }
     */
}


