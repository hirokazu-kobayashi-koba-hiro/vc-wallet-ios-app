//
//  HttpClient.swift
//  vc-wallet-library
//
//  Created by 小林弘和 on 2024/09/06.
//

import Foundation


public class HttpClient {
    
    let urlSession: URLSession
    
    public init(sessonConfiguration: URLSessionConfiguration) {
        urlSession = URLSession.init(configuration: sessonConfiguration)
    }
    
    

    public func get(url: String) async throws -> [String: Any] {
        guard let url = URL(string: url) else {
            throw URLError(.badURL) // Throw error if URL is invalid
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
    
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dictionary = jsonObject as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        return dictionary
    }
    
    // Async POST Request with dictionary response
    public func post(url: String, headers: [String: String]? = nil, body: [String: Any]? = nil) async throws -> [String: Any] {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
        headers?.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.value)
        }
        
        
        if body != nil {
            let jsonData = try JSONSerialization.data(withJSONObject: body!, options: [])
            request.httpBody = jsonData
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dictionary = jsonObject as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        return dictionary
    }
}
