//
//  ApiConfigurable.swift
//  
//
//  Created by Naresh on 14/11/24.
//

import Foundation

public protocol ApiConfiguration {
    /// This enviroment must be fetched from the current scheme we are running. As of now we are hardcoding this.
    var enviroment: UrlConfigurable { set get }
    /// After how much the the api should fail if the response doesn't returned
    var timeout: TimeInterval { set get }
    /// If internet is not there then any api call happen then on connectivity it will call the api.
    var waitsForConnectivity: Bool { set get }
}
