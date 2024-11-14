//
//  File.swift
//  
//
//  Created by Naresh on 14/11/24.
//

import Foundation

public final class ApiService {
        
    public static func apiServiceProvider(with configuration: ApiConfiguration) -> ApiServicable {
        
        return ApiServiceManager.init(configuration: configuration)
        
    }
}
