//
//  ConnectivityObservable.swift
//
//
//  Created by Naresh on 14/11/24.
//

import Network
import Combine

protocol ConnectivityObservable {
    
    static var shared: ConnectivityObservable { get }
    
    var networkStatusPublisher: AnyPublisher<Bool, Never> { get }
    
    var isConnected: Bool { get }
}
