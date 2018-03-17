//
//  RepoOwner.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import Foundation

/// Purpose of typealias is convenienve, but also to better struture tableview, ex: (language: Swift, repos: 7)
typealias LanguageForRepo = (language: String, repos: [Repo])

class RepoOwner {
    
    var name: String
    var languageForRepo: [LanguageForRepo]?
    
    init(name: String) {
        self.name = name
    }
    
}

