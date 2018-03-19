//
//  Repo.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import Foundation
import CoreData

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

/// Extenson of Repo is for core data, to help with sotring/caching a response if necessary
extension Repo {
    
    enum CoreDataKeys: String {
        case identifier
        case name
        case desc
        case language
        case starsCount
        case forksCount
        case lastUpdatedDate
    }
    
    @discardableResult
    func createManagedObject(forContext context: NSManagedObjectContext) -> NSManagedObject? {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Repository", into: context)
        entity.setValue(identifier, forKey: CoreDataKeys.identifier.rawValue)
        entity.setValue(name, forKey: CoreDataKeys.name.rawValue)
        entity.setValue(description, forKey: CoreDataKeys.desc.rawValue)
        entity.setValue(language, forKey: CoreDataKeys.language.rawValue)
        entity.setValue(starsCount, forKey: CoreDataKeys.name.rawValue)
        entity.setValue(forksCount, forKey: CoreDataKeys.forksCount.rawValue)
        entity.setValue(lastUpdatedDate, forKey: CoreDataKeys.lastUpdatedDate.rawValue)
        return entity
    }
}
