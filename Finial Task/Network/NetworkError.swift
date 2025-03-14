//
//  NetworkError.swift
//  taskSession22
//
//  Created by Sara Syam on 05/11/2024.
//

import Foundation
import Alamofire

enum NetworkError: Error,LocalizedError {
    case pageNotFound
    case unauthorized
    case serverError
    case somethingWentWrong
    case requestError(String)
    case networkError
    case decodingError(String)
    case invalidResponse
    case afError(AFError)
}

extension NetworkError {
    var getError: String? {
        switch self {
        case .pageNotFound:
            return "Page Not Found ❌"
        case .somethingWentWrong:
            return "Something went wrong!"
        case .requestError(let error):
            return error
        case .unauthorized:
            return "Please Login again."
        case .serverError:
            return "Please try again later."
        case .networkError:
            return "Network Error"
        case .decodingError:
            return "Decoding Error"
        case .invalidResponse:
            return "Invalid Response"
        case .afError(let afError):
            switch afError {
                case .sessionTaskFailed(let error):
                    return "Session Task Failed: \(error.localizedDescription)"
                case .responseValidationFailed(let reason):
                    switch reason {
                        // Handle specific response validation failure cases
                        case .unacceptableStatusCode(let code):
                            return "Unacceptable Status Code: \(code)"
                        // ... other cases
                        default:
                            return "Response Validation Failed"
                    }
                case .responseSerializationFailed(let reason):
                    switch reason {
                        // Handle specific response serialization failure cases
                        case .jsonSerializationFailed(let error):
                            return "JSON Serialization Failed: \(error.localizedDescription)"
                        // ... other cases
                        default:
                            return "Response Serialization Failed"
                    }
                default:
                    return "Request Failed"
            }
        }
    }
}

