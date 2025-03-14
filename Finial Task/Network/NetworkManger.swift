//
//  NetworkManger.swift
//  taskSession22
//
//  Created by Sara Syam on 05/11/2024.
//

import Foundation
import Alamofire

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endPoint: EndPoints, response: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    
    private let bearerToken: String
    
    // Initialize the NetworkManager with the token
    init(bearerToken: String) {
        self.bearerToken = bearerToken
    }
    
    func request<T: Decodable>(_ endPoint: any EndPoints, response: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        let url = endPoint.baseURL + endPoint.path
        let method = Alamofire.HTTPMethod(rawValue: endPoint.method.rawValue)
        let headers = Alamofire.HTTPHeaders(endPoint.headers ?? [:])
        let encoding: ParameterEncoding = (endPoint.endcoding == .url) ? URLEncoding.default : JSONEncoding.default
        var parameters = endPoint.parameters ?? [:]
        if let page = endPoint.page{
            parameters["page"] = page
        }
        
        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseDecodable(of: T.self) { [weak self] response in
                guard let self else { return }
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    let statusCode = response.response?.statusCode ?? 0
                    let networkError = self.errorHandling(statusCode: statusCode, error: error)
                    completion(.failure(networkError))
                }
            }
    }
    
    func errorHandling(statusCode: Int, error: AFError) -> NetworkError {
        switch statusCode {
        case 400:
            return NetworkError.somethingWentWrong
        case 401:
            return NetworkError.unauthorized
        case 404:
            return NetworkError.pageNotFound
        case 500...599:
            return NetworkError.serverError
        default:
            return NetworkError.requestError(error.localizedDescription)
        }
    }
}
