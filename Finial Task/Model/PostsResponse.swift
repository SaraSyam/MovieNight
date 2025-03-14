//
//  PostsResponse.swift
//  Session 22 Demo
//
//  Created by Ahmed Taha on 01/11/2024.
//

import Foundation

struct PostsResponse: Codable {
    var userId: Int
    var title: String
    var body: String
    var id: Int
}
