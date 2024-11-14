//
//  MethodType.swift
//
//
//  Created by Naresh on 14/11/24.
//


import Foundation

enum ServerStatusCode: Int {
    
    case success = 200
    case pageNotFound = 404
    case authRequired = 401
    case permmissionDenied = 429
    case accessRestricted = 403
    case invalidBaseCurrency = 400
}
