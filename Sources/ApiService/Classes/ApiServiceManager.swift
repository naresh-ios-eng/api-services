//
//  ApiServiceManager.swift
//
//
//  Created by Naresh on 14/11/24.
//

import Foundation
import Combine

final class ApiServiceManager: NSObject, ApiServicable {

    /// The shared session
    private(set) var session: URLSession
    /// Configuration
    var urlConfiguration: URLSessionConfiguration
    /// After one minute the api will return timeout error
    var timeout: TimeInterval = 60
    /// This enviroment must be fetched from the current scheme we are running. As of now we are hardcoding this.
    var enviroment: UrlConfigurable
    /// If internet is not there then any api call happen then on connectivity it will call the api.
    var waitsForConnectivity: Bool = true
    /// variable for refreing the publisher.
    private var cancellable: Set<AnyCancellable> = []
    
    //var refreshTokenPublisher: AnyPublisher<RefreshTokenModel, SessionError>?
    
    init(configuration: ApiConfiguration) {
        /// ephemeral - a session configuration that uses no persistent storage for caches, cookies, or credentials.
        urlConfiguration = URLSessionConfiguration.ephemeral
        urlConfiguration.timeoutIntervalForRequest = configuration.timeout / 2
        urlConfiguration.timeoutIntervalForResource = configuration.timeout
        urlConfiguration.waitsForConnectivity = configuration.waitsForConnectivity
        session = URLSession.init(configuration: urlConfiguration)
        self.waitsForConnectivity = configuration.waitsForConnectivity
        self.timeout = configuration.timeout
        self.enviroment = configuration.enviroment
    }

    
    /// This function will make the api call and returns the publisher.
    /// - Parameters:
    ///   - route: The api route. Route will provide complete api detail like url, method, body, parameters etc. The route will build the urlRequest also.
    ///   - responseType: The type of response the particular route will return.
    /// - Returns: It will return a publisher that can publish the response or error.
    public func dataTaskPublisher<T: Codable>(route: ApiRoutable, responseType: T.Type) -> AnyPublisher<T, SessionError> {
        /// Let make the url request
        guard let urlRequest: URLRequest = try? route.urlRequest(enviroment: self.enviroment) else {
            /// As there is some issue while building the url request so let's return the fail publisher with session error invalidRequest
            return Fail(error: SessionError.invalidRequest)
                .eraseToAnyPublisher()
        }
        //self.display(urlRequest: urlRequest)
        return session
            .dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global())
            .receive(on: RunLoop.main)
            .tryMap() { [unowned self] element -> Data in
                return try self.handleData(element: element, route: route)
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .tryCatch({ [unowned self] error in
                guard let urlError = error as? URLError else {
                    //print("Error thrown at line ", #line, " error - ", error)
                    throw error
                }
                return try self.handleUrlError(error: urlError, route: route, responseType: responseType)
            })
            .mapError({ error in
                //print("Error map at line ", #line, " error - ", error)
                guard let urlError = error as? URLError else { return SessionError.parsingError }
                return SessionError.error(code: urlError.code.rawValue, message: urlError.localizedDescription)
            })
            .retry(2)
            .eraseToAnyPublisher()
    }
    

    /// This function will handle the url Error.
    /// - Parameters:
    ///- urlError: The URL error refrence
    ///- route: The route from which we get this error
    ///- responseType: The response type we want to send.
    /// - Returns: Publisher with response type or error
    private func handleUrlError<T: Codable>(error: URLError, route: ApiRoutable, responseType: T.Type) throws -> AnyPublisher<T, SessionError> {
        if error.code == .userAuthenticationRequired || error.code == .userCancelledAuthentication {
            //print("Error thrown at line ", #line, " error - ", urlError)
            /// The commented code in line number 89 must be umcomment in order to use the refresh token feature.
            if false /*route.endPoint != RefreshTokenRouter.refreshToken.endPoint*/ {
                throw SessionError.authenticationFailed
                /*if refreshTokenPublisher == nil {
                    /// holding an instance of refresh token publisher, so that we shouldn't have the multiple
                    refreshTokenPublisher = RefreshTokenServiceProvider().refreshToken()
                }
                /// Here the force unwrapping will not make any side effect as we have the if condition above.
                return refreshTokenPublisher!.flatMap { [unowned self] refreshTokenModel -> AnyPublisher<T, SessionError> in
                    /// Setting the new updated access token to store so that we can access.
                    UserStore.accessToken = refreshTokenModel.accessToken
                    //print("Refresh token retuned now make the same call")
                    /// Making the refresh token publisher as nil as it intended its pupose.
                    self.refreshTokenPublisher = nil
                    /// Finally making the same api call so that last api which thown 401 or 403 can be refetched again.
                    return self.dataTaskPublisher(route: route, responseType: responseType)
                }
                .eraseToAnyPublisher()
                 */
            } else {
                /// Refresh token api returns the error so better to logout the user
                //print("Error thrown at line ", #line, " error - ", urlError)
                throw SessionError.authenticationFailed
            }
        } else {
            throw error
        }
    }
    
    
    /// This function will map the error status code to the URLError and if there is not error then it will return the data
    /// - Parameter element: The output from the dataTaks upstream publisher
    /// - Returns: return data or throw error
    private func handleData(element: URLSession.DataTaskPublisher.Output, route: ApiRoutable) throws -> Data {
        guard let response = element.response as? HTTPURLResponse else {
            //print("Error thrown at line ", #line, " resp - ", element.response)
            throw URLError(.badServerResponse)
        }
        //print(#function, "\t", #line, response)
        if response.statusCode == ServerStatusCode.authRequired.rawValue || response.statusCode == ServerStatusCode.accessRestricted.rawValue {
            throw URLError(.userAuthenticationRequired)
        }
        /// Consider success
        return element.data
    }
    
    private func display(urlRequest: URLRequest) {
        print("URL Request -> ", urlRequest.url!)
        print("HttpBody -> ", urlRequest.httpBody ?? Data())
        print("Headers -> ", urlRequest.allHTTPHeaderFields ?? [:])
        print("HttpMethod -> ", urlRequest.httpMethod ?? "")
    }
}

// MARK: - These are the function used for writting unit test
#if DEBUG
extension ApiServiceManager {
    
    /// This function is required to set the timeout because while writting unit test it's not appropriate to wait for the actual time interval for each api
    /// - Parameter interval: The time interval
    func setTimeout(interval: TimeInterval) {
        self.timeout = interval
    }
    
    var timeoutInterval: TimeInterval {
        return self.timeout
    }
    
    /// This function is created to test the handleData function
    /// - Parameter element: The output of URLSession's data task publisher
    /// - Returns: Data.
    func handleDataClone(element: URLSession.DataTaskPublisher.Output, route: ApiRoutable) throws -> Data {
        try self.handleData(element: element, route: route)
    }
    
    func handleUrlErrorClone<T: Codable>(urlError: URLError, route: ApiRoutable, responseType: T.Type) throws -> AnyPublisher<T, SessionError> {
        try handleUrlError(error: urlError, route: route, responseType: responseType)
    }
}
#endif
