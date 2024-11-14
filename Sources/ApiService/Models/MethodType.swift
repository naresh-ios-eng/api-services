//
//  MethodType.swift
//
//
//  Created by Naresh on 14/11/24.
//

import Foundation

/// MethodType 
public enum MethodType: String, CaseIterable {
    
    /// Get method type
    case get = "GET"
    
    /// Post method type
    case post = "POST"
    
    /// Put method type
    case put = "PUT"
    
    /// Delete method type
    case delete = "DELETE"
}
