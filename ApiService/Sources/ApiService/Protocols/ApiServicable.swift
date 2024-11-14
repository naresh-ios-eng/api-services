//
//  File.swift
//  
//
//  Created by Naresh on 14/11/24.
//

import Foundation
import Combine

public protocol ApiServicable {
    /// This is the default instance of this class
    static var shared: ApiServicable { get }
    /// The shared session
    var session: URLSession { get }
    /// Configuration
    var configuration: URLSessionConfiguration { get }
    /// After one minute the api will return timeout error
}
