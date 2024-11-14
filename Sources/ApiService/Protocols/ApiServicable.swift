//
//  ApiServicable.swift
//
//
//  Created by Naresh on 14/11/24.
//

import Foundation
import Combine

public protocol ApiServicable {
    
    init(configuration: ApiConfiguration)
    
    func dataTaskPublisher<T: Codable>(route: Routable, responseType: T.Type) -> AnyPublisher<T, SessionError>

}
