//
//  RemoteRequests.swift
//  taskSession22
//
//  Created by Sara Syam on 05/11/2024.
//
import Foundation

enum RemoteRequests: EndPoints {
    case getPosts(page:Int)
    case getUsers
    case search(String)
    case productDetails(Int)
    case getNowPlaying
    case getComingSoon
    
    var path: String {
        switch self {
        case .getPosts:
            return "/3/trending/all/day"
        case .getUsers:
            return "/users"
        case .search(let searchValue):
            return "/3/search/movie?\(searchValue)"
        case .productDetails(let id):
            return "/3/movie/\(id)"
        case .getNowPlaying:
            return "/3/movie/now_playing"
        case .getComingSoon:
            return "/3/movie/upcoming"
            
        }
    }
    var method: HttpsMethods {
        return .get
    }
    var parameters: [String : Any]? {
        switch self {
        case .getPosts:
            return nil
        case .getUsers:
            return nil
        case .search(let searchValue):
            return ["query" : searchValue]
        case .productDetails:
            return nil
        case .getNowPlaying:
            return nil
        case .getComingSoon:
            return nil
        }
    }
    var page: Int? {
        switch self {
        case .getPosts(let page):
            return page
        default:
            return nil
        }
    }
}
