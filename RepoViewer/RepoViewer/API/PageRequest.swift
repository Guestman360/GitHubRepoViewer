//
//  PageRequest.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import UIKit

class PageRequest {
    
    var path: String?
    var parameters: [(key: String, value: String)]?
    var page: Int = 1
    var pageSize: Int = 6
    
    // Computed property url utilizes var below to help set the url
    var url: URL? {
        return urlComponents.url
    }
    
    fileprivate var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.github.com"
        if let path = path {
            urlComponents.path = path
        }
        var queryItems = [URLQueryItem]()
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: value)
                queryItems.append(queryItem)
            }
        }
        queryItems.append(URLQueryItem(name: "page", value: String(describing: page)))
        queryItems.append(URLQueryItem(name: "per_page", value: String(describing: pageSize)))
        urlComponents.queryItems = queryItems
        return urlComponents
    }
    
}
