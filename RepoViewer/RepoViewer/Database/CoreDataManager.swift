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
    
    /**
     Call this method to cache the response coming in from GitHub
     
     - parameter repo: take a tuple which holds name of language and an array of repo objects
     */
    mutating func cacheAllReposFromOwner(repo: [LanguageForRepo]) {
        
    }
    
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
