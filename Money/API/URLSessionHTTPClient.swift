//
//  URLSessionHTTPClient.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation

protocol HTTPClient {
    func GETRequest<T: Codable>(url: URL) async -> Result<T,Error>
    func POSTRequest<T: Codable>(url: URL, body: [String: [String]]?) async -> Result<T,Error>
}

class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
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
            return .failure(error)
        }
    }
}
