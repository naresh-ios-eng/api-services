//
//  NetworkObservable.swift
//
//
//  Created by Naresh on 14/11/24.
//

import Network
import Combine

protocol NetworkObservable {
    
    static var shared: NetworkObservable { get }
    
    var networkStatusPublisher: AnyPublisher<Bool, Never> { get }
    
    var isConnected: Bool { get }
}
