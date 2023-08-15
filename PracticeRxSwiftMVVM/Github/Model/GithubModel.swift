//
//  GithubModel.swift
//  PracticeRxSwiftMVVM
//
//  Created by koala panda on 2023/08/14.
//

import Foundation

struct GithubResonse: Codable {
    let items: [GithubModel]?
}

struct GithubModel: Codable {
    let id: Int
    let name: String
    private let fullName: String
    var urlStr: String { "https://github.com/\(fullName)"}

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
    }
}
