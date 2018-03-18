//
//  CoreDataManager.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/18/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "GitHub_Repo_Viewer_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    mutating func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
