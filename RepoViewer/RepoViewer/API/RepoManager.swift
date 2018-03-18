//
//  RepoManager.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import UIKit

/// Enums to best handle successes and failures of fetching and loading data
enum RepoFetchingError: Error {
    case loadingError
    case loadingLimitsError
    case notFound
    case mappingError
}

enum RepoLoadingResultType {
    case success(data: Data)
    case partialSuccess(data: Data)
    case error(error: RepoFetchingError)
}

enum RepoFetchingResultType {
    case success(repository: [LanguageForRepo])
    case error(error: RepoFetchingError)
}

class RepoManager {
    
    private var repoOwner: RepoOwner?
    
    // MARK: - Data management
    
    /**
     This method is used to fetch the data from an owner's repo from GitHub
     
     - parameter ownerName: name of repo owner
     - parameter forceLoad: forcibly loads a repo
     - parameter completion: competion handler that contains a success or error case
     - returns: dict with key as relation (first, next, prev, last) and the value a link
     */
    func fetchReposByName(ownerName: String, forceLoad: Bool, completion: ((RepoFetchingResultType) -> Void)?) {
        if forceLoad == true || repoOwner?.languageForRepo == nil {
            repoOwner = RepoOwner(name: ownerName)
            guard let owner = repoOwner else { completion?(.error(error: RepoFetchingError.mappingError)); return }
            var repoDict = [String: [Repo]]()
            loadRepoByPage(1, name: owner.name) { result in
                switch result {
                case .partialSuccess(let json):
                    do {
                        try self.mapRepos(json, repo: &repoDict)
                    } catch {
                        completion?(.error(error: RepoFetchingError.mappingError))
                    }
                case .success(let json):
                    do {
                        try self.mapRepos(json, repo: &repoDict)
                    } catch {
                        completion?(.error(error: RepoFetchingError.mappingError))
                    }
                    
                    let sortedLanguages = repoDict.keys.sorted { (lang1, lang2) -> Bool in
                        repoDict[lang1]?.count ?? 0 > repoDict[lang2]?.count ?? 0
                    }
                    for language in sortedLanguages {
                        if let owner = self.repoOwner, let repos = repoDict[language] {
                            if owner.languageForRepo == nil {
                                owner.languageForRepo = [LanguageForRepo]()
                            }
                            let sortedRepo = repos.sorted(by: { repo1, repo2 -> Bool in
                                repo1.starsCount ?? 0 > repo2.starsCount ?? 0
                            })
                            self.repoOwner?.languageForRepo?.append((language: language, repos: sortedRepo))
                        }
                    }
                    if let languageForRepo = self.repoOwner?.languageForRepo {
                        completion?(.success(repository: languageForRepo))
                    } else {
                        completion?(.success(repository: []))
                    }
                case .error(let error):
                    completion?(.error(error: error))
                }
            }
        } else {
            if let languageForRepo = repoOwner?.languageForRepo {
                completion?(.success(repository: languageForRepo))
            } else {
                completion?(.success(repository: []))
            }
        }
    }
    
    /**
     This method will take data and map the repos by language
     
     - parameter data: this input takes a JSON string
     - parameter repo: holds repo data, in this case the key is the language, and the value are an array of repos
     - throws: checks if loading json failed, if so, runs the mapping logic
     */
    func mapRepos(_ data: Data, repo: inout [String: [Repo]]) throws {
        
        guard let json = try? JSONSerialization.jsonObject(with: data) else { throw RepoFetchingError.mappingError }
        guard let jsonarray = json as? [Any] else { throw RepoFetchingError.mappingError }
        for item in jsonarray {
            guard let item = item as? [String: Any] else { throw RepoFetchingError.mappingError }
            if let newRepo = Repo(json: item) {
                var language = NSLocalizedString("Other", comment: "")
                if let repoLang = newRepo.language {
                    language = repoLang
                }
                if repo[language] != nil {
                    repo[language]?.append(newRepo)
                } else {
                    repo[language] = [newRepo]
                }
            } else {
                throw RepoFetchingError.mappingError
            }
        }
    }
    
    // MARK: - Data fetching
    
    private weak var currentSessionTask: URLSessionDataTask?
    
    /**
     This method can retrieve info about next avaialable page in owner's repo
     
     - parameter page: page number
     - parameter name: name of repo owner
     - parameter completion: completion handler that returns an enum of success or partial success
     */
    func loadRepoByPage(_ page: Int, name: String, completion: ((RepoLoadingResultType) -> Void)?) {
        let request = PageRequest()
        request.path = "/users/\(name)/repos"
        request.page = page
        guard let url = request.url else { fatalError("can't construct url") }
        
        currentSessionTask = URLSession.shared.dataTask(with: url) { (pageData, response, error) in
            guard let pageData: Data = pageData, let _: URLResponse = response, error == nil else { completion?(.error(error: RepoFetchingError.loadingError)); return }
            guard let httpResponse = response as? HTTPURLResponse else { completion?(.error(error: RepoFetchingError.loadingError)); return }
            guard httpResponse.statusCode != 404 else { completion?(.error(error: RepoFetchingError.notFound)); return }
            guard httpResponse.statusCode != 403 else { completion?(.error(error: RepoFetchingError.loadingLimitsError)); return }
            guard httpResponse.statusCode == 200 else { completion?(.error(error: RepoFetchingError.loadingError)); return }
            
            var hasMorePages = false
            if let linkString = httpResponse.allHeaderFields["Link"] as? String {
                let links = GHHeaderLinkParser.getNextPage(from: linkString)
                if links.keys.contains("next") {
                    hasMorePages = true
                }
            }
            // Recurse if link contains "next", signals there are more pages to load
            if hasMorePages {
                completion?(RepoLoadingResultType.partialSuccess(data: pageData))
                self.loadRepoByPage(page + 1, name: name, completion: completion)
            } else {
                completion?(RepoLoadingResultType.success(data: pageData))
            }
        }
        currentSessionTask?.resume()
    }
    
    // Can be used to close the last session task, if still currently running
    func closeCurrentSessionTaskIfNeeded() {
        currentSessionTask?.cancel()
        currentSessionTask = nil
    }
    
}

// Purpose of extension is to add 4 methods to help with getting language count and with indexing
// Helpful for UITableview delegate methods
extension RepoManager {
    
    func numberOfLanguages() -> Int {
        guard let count = repoOwner?.languageForRepo?.count else { return 0 }
        return count
    }
    
    func languageAtIndex(_ index: Int) -> String? {
        guard let repo = repoOwner?.languageForRepo else { return nil }
        guard repo.count > index else { fatalError("index can't be more than languages amount") }
        return repo[index].language
    }
    
    func numberOfReposForLanguageAtIndex(_ index: Int) -> Int {
        guard let repo = repoOwner?.languageForRepo else { return 0 }
        guard repo.count > index else { fatalError("can't check number of repo's for out of bounds language index") }
        let repos = repo[index].repos
        return repos.count
    }
    
    func repoForIndexPath(_ indexPath: IndexPath) -> Repo? {
        guard let repo = repoOwner?.languageForRepo else { return nil }
        guard repo.count > indexPath.section else { fatalError("Out of bounds") }
        let repos = repo[indexPath.section].repos
        guard repos.count > indexPath.row else { fatalError("Out of bounds") }
        return repos[indexPath.row]
    }
    
}
