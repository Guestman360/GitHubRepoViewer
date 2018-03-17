//
//  RepoOwner.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import Foundation

typealias LanguageForRepo = (language: String, repos: [Repo])

class RepoOwner {
    
    var name: String
    var languageForRepo: [LanguageForRepo]?
    
    init(name: String) {
        self.name = name
    }
    
}

// MARK: - Grouping
//extension RepoOwner {
//    static func groupByLanguage(_ repos: [Repo]) -> [RepoOwner] {
//        guard !repos.isEmpty else {
//            return []
//        }
//        let dict = Dictionary(grouping: repos, by: { $0.language }) // group by language
//        return dict.map { RepoOwner(name: $0, repos: $1.sorted(by: {$0.starsCount > $1.starsCount})) } // repos inside category are sorted by # of stars
//            .sorted(by: {$0.repos.count > $1.repos.count}) // sorted by # of repos
//    }
//}

