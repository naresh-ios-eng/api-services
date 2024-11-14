//
//  LowBandwidthAdaptable.swift
//
//
//  Created by Naresh on 14/11/24.
//

import Foundation

/// This protocol ensure that no api will be called within a time fram. e,g, we restrict the user to make an api call once in 30 minutes only.
/// We need this functionality for Routers only.
protocol LowBandwidthAdaptable where Self: Routable {
    
    /// The time with in repeated api calls. It is in seconds.
    var minWaitingTime: TimeInterval { get }
    
    /// This will update the call log, means at what time the api gets called. The endpoint is being used as persistent key.
    func updateApiCallLog()
    
    /// This will return if the api call can be made or not. The decision is taken based on the minWaitingTime within the last api call and now. If it crosses the limit then we are allowed to make api call else we are not.
    func canMakeApiCall() -> Bool
}


extension LowBandwidthAdaptable {
    
    /// This function will associated with each router and will used to save the router last hit time.
    func updateApiCallLog() {
        /// This will save the api log in userdefault.
        UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: self.endPoint)
    }
    
    
    /// This function will be associated with each Router and we can check if we can make the api call or not.
    /// - Returns: Status whether we are allowed to make api call or not.
    func canMakeApiCall() -> Bool {
        /// This will save the api log in userdefault.
        let lastTimeWhenApiCalled = UserDefaults.standard.double(forKey: self.endPoint)
        let now = Date().timeIntervalSince1970
        if lastTimeWhenApiCalled == 0 {
            return true
        } else {
            let gapInSeconds = now - lastTimeWhenApiCalled
            return gapInSeconds >= minWaitingTime
        }
    }
}
