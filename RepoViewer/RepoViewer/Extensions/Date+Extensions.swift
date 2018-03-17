//
//  Date+Extensions.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import Foundation

extension Date {
    
    var stringDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: self)
    }
    
}
