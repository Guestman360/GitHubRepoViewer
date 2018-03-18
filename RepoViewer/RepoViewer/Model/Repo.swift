//
//  Repo.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import Foundation

struct Repo {
    
    // Based props off sample app and from the GitHub docs, https://developer.github.com/v3/repos/#list-user-repositories
    
    var identifier: Int?
    var name: String?
    var description: String?
    var language: String?
    var starsCount: Int?
    var forksCount: Int?
    var lastUpdatedDate: Date?
    
    public init?(json: [String: Any]) {
        identifier = json["id"] as? Int
        name = json["name"] as? String
        description = json["description"] as? String
        language = json["language"] as? String
        starsCount = json["stargazers_count"] as? Int
        forksCount = json["forks_count"] as? Int
        
        if let lastUpdatedDateString = json["updated_at"] as? String {
            lastUpdatedDate = ISO8601DateFormatter().date(from: lastUpdatedDateString)
        }
    }
}
