//
//  ConnecttivitityObserver.swift
//
//
//  Created by Naresh on 14/11/24.
//

import Network
import Combine
import Network

final class NetworkObserver: NetworkObservable {
    
    static var shared: NetworkObservable = NetworkObserver()
    
    var networkStatusPublisher: AnyPublisher<Bool, Never> {
        networkStatus.eraseToAnyPublisher()
    }
    
    var networkStatus = CurrentValueSubject<Bool, Never>(true)
    
    let monitor = NWPathMonitor()

    let queue = DispatchQueue(label: "com.poc.network.monitor")
    
    var isConnected: Bool {
        networkStatus.value
    }
    
    private init() {
        self.startNetworkMonitor()
    }
    
    private func startNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.networkStatus.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }
}
