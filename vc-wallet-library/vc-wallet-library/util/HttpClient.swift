//
//  HttpClient.swift
//  vc-wallet-library
//
//  Created by 小林弘和 on 2024/09/06.
//

import Foundation


public class HttpClient {
    
    public static let shared = HttpClient()
    
    
    func get(url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw URLError(.badURL) // Throw error if URL is invalid
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Validate response status code
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return data // Return the data if everything is successful
    }
}
