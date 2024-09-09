//
//  VerifiableCredentialsError.swift
//  vc-wallet-library
//
//  Created by 小林弘和 on 2024/09/06.
//

import Foundation


public enum VerifiableCredentialsError: Error {
    case networkError
    case unknownError
    
}

public enum HttpError: Error {
    case networkError(statusCode: Int, response: [String: Any]?)
    case clientError(statusCode: Int, response: [String: Any]?)
    case tooManyRequestsError(statusCode: Int = 429, response: [String: Any]?)
    case serverError(statusCode: Int, response: [String: Any]?)
    case serverMentenanceError(statusCode: Int = 503, response: [String: Any]?)

}
