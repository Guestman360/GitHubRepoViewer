//
//  GHHeaderLinkParser.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import Foundation

class GHHeaderLinkParser: NSObject {
    
    class func getNextPage(from headerLink: String) -> [String: String] {
        var relations = [String: String]()
        let separatedRelations = headerLink.components(separatedBy: ",")
        
        for tuple in separatedRelations {
            let components = tuple.components(separatedBy: ";")
            guard components.count == 2, let urlComponent = components.first, let relationComponent = components.last else { fatalError("header link has wrong format") }
            
            guard let relationRegex = try? NSRegularExpression(pattern: ".rel=\"(.*)\"", options: []) else { fatalError("cannot construct regex for header link relation") }
            let relation = relationRegex.stringByReplacingMatches(in: relationComponent, options: [], range: NSRange(location: 0, length: relationComponent.count), withTemplate: "$1")
            
            // drop brackets
            let start = urlComponent.index(urlComponent.startIndex, offsetBy: 1)
            let end = urlComponent.index(urlComponent.endIndex, offsetBy: -1)
            let url = String(urlComponent[start..<end])
            
            relations[relation] = url
        }
        return relations
    }
    
}
