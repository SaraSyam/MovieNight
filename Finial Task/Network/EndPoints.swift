//
//  EndPoints.swift
//  taskSession22
//
//  Created by Sara Syam on 05/11/2024.
//
import Foundation
import Alamofire

enum HttpsMethods: String {
    case get = "GET"
    case post = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum EncodingTypes {
    case url
    case json
}

protocol EndPoints {
    var baseURL: String { get }
    var path: String { get }
    var method: HttpsMethods { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var endcoding: EncodingTypes { get }
    var page: Int? { get }
}

extension EndPoints {
    var baseURL: String {
        return Constants.baseURL
    }
    
    var headers: [String: String]? {
        return ["Authorization" : "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ODAwMWExMWVjODhjMmZiNzg1ZDlkYTU2MWI1YmE3MyIsIm5iZiI6MTczMzEzOTkzMi4wMzIsInN1YiI6IjY3NGQ5ZGRjZDU3NzQ3ZjIxMTU3OTZjZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.nxd-VfhwhyG0y7HVcAME3v35InTb1zdPfB48JVvmMeU"]
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var endcoding: EncodingTypes {
        return EncodingTypes.url
    }
}

