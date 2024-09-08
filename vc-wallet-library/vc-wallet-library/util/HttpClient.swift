//
//  HttpClient.swift
//  vc-wallet-library
//
//  Created by 小林弘和 on 2024/09/06.
//

import Foundation


public class HttpClient {
    
    // Singleton instance (optional)
    static let shared = HttpClient()
    
    private init() {} // Private initializer to enforce singleton pattern
    
    // Async GET Request with dictionary response
    public func get(url: String) async throws -> [String: Any] {
        guard let url = URL(string: url) else {
            throw URLError(.badURL) // Throw error if URL is invalid
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate response status code
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Parse the JSON data into a dictionary
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        // Ensure the parsed object is a dictionary
        guard let dictionary = jsonObject as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        return dictionary // Return the dictionary
    }
    
    // Async POST Request with dictionary response
    public func post(url: String, body: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: url) else {
            throw URLError(.badURL) // Throw error if URL is invalid
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert body dictionary to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate response status code
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Parse the JSON data into a dictionary
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        // Ensure the parsed object is a dictionary
        guard let dictionary = jsonObject as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        return dictionary // Return the dictionary
    }
}
