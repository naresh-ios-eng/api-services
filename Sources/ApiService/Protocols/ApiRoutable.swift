//
//  Routable.swift
//
//
//  Created by Naresh on 14/11/24.
//

import Foundation
import Combine

/// This protocol must be confirmed by an enum. Becase in an enum each case would corresponds to the api endpoint, for each endpoint (enum case) we have to provide the following information
public protocol ApiRoutable {
    /// Api method
    var method: MethodType { get }
    /// The api endpoint
    var endPoint: String { get }
    /// The additional headers are the headers those are specific to api's. e.g. while refreshing the token we need to send the refresh token in the api.
    var additionalHeaders: [String: String]? { get }
    /// The defaultHeaders are pointing to the common header in each api. e,g, Content-Type, Authorization etc
    var defaultHeaders: [String: String]? { get }
    /// The parameters are pointing to the api specific parameters
    var parameters: [String: Any]? { get }
    /// The parameters those we need to send in the api url.
    var queryParams: [String: String]? { get }
    /// This will build the api request
    func urlRequest(enviroment: UrlConfigurable) throws -> URLRequest
}

// MARK: - Building Request -
extension ApiRoutable {
    
    /// Setting the default headers those will get included in all api's
    var defaultHeaders: [String: String]? {
        ["Content-Type": "Application/Json"]
    }
    
    /// This function will build the api request from ApiRoute protocol
    /// - Parameter route: The api route which provide the network related information
    /// - Returns: URLRequest
    func urlRequest(enviroment: UrlConfigurable) throws -> URLRequest {
        
        /// Create the url from the base url & url endpoint first
        guard let url = URL(string: (enviroment.baseUrl + self.endPoint)) else {
            throw SessionError.invalidRequest
        }
        var urlRequest = URLRequest.init(url: url)
        urlRequest.httpMethod = self.method.rawValue
        /// Merging all headers
        urlRequest.allHTTPHeaderFields = self.allHeaders()
        if let params = self.parameters {
            do {
                let data = try JSONSerialization.data(withJSONObject: params)
                urlRequest.httpBody = data
            } catch {
                throw error
            }
        }
        
        if let queryParams = self.queryParams {
            /// Adding the default parameters
            var items: [URLQueryItem] = []
            for key in queryParams.keys {
                let item = URLQueryItem.init(name: key, value: queryParams[key])
                items.append(item)
            }
            if #available(iOS 16.0, *) {
                urlRequest.url?.append(queryItems: items)
            } else {
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
                urlComponents.queryItems = items
                urlRequest.url = urlComponents.url!
            }
        }
        return urlRequest
    }
     
    /// This will combine the additionalHeaders and default headers. Incase the additional header specify the same key as of default header the additional headers would be preferred.
    /// - Returns: The dictionary contains the complete headers.
    private func allHeaders() -> [String: String] {
        guard let additionalHeaders = additionalHeaders else {
            return defaultHeaders ?? [:]
        }
        guard let defaultHeaders = defaultHeaders else {
            return additionalHeaders
        }
        /// This will merge all the distinict keys, for same keys the values from additionalHeaders will be taken
        return defaultHeaders.merging(additionalHeaders) { defaultHeaderKey, additionalHeaderKey in
            /// we always prefer the addition header if the same value come, else both will be considered.
            return additionalHeaderKey
        }
    }
}


#if DEBUG
// MARK: - This enxtension contains some public function those are only available to test private members
extension ApiRoutable {
    public func allHeadersClone() -> [String: String] {
        self.allHeaders()
    }
}
#endif
