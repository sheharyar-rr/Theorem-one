//
//  URLSessionHTTPClient.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation

/// A protocol for defining HTTP client operations.
protocol HTTPClient {
    /// Performs an HTTP GET request to the specified URL and decodes the response into a given type.
    /// - Parameters:
    ///   - url: The URL to send the GET request to.
    /// - Returns: A result containing either the decoded response or an error.
    func GETRequest<T: Codable>(url: URL) async -> Result<T, Error>
    
    /// Performs an HTTP POST request to the specified URL with an optional request body and decodes the response into a given type.
    /// - Parameters:
    ///   - url: The URL to send the POST request to.
    ///   - body: An optional dictionary representing the request body.
    /// - Returns: A result containing either the decoded response or an error.
    func POSTRequest<T: Codable>(url: URL, body: [String: [String]]?) async -> Result<T, Error>
}

/// A concrete implementation of the `HTTPClient` protocol using `URLSession`.
class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    /// Initializes a `URLSessionHTTPClient` with an optional URLSession and JSON decoder, defaulting to the shared URLSession and a new JSON decoder.
    /// - Parameters:
    ///   - session: An optional URLSession to use for network requests.
    ///   - decoder: An optional JSON decoder to use for decoding responses.
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func GETRequest<T: Codable>(url: URL) async -> Result<T,Error> {
        do {
            let (data, _) = try await session.data(from: url)
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            print("HTTPClient error in \(#function): \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func POSTRequest<T: Codable>(url: URL, body: [String: [String]]? = nil) async -> Result<T,Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body as Any)
            let (data, _) = try await session.data(for: request)
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            print("HTTPClient error in \(#function): \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
