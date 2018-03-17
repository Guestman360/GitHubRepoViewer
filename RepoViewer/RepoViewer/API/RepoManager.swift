//
//  RepoManager.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import UIKit

// Enums to handle successes and failures of fethcing and loading data
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
    
    // This will get dict of repos groupd by language
    private var repoOwner: RepoOwner?
    
    // MARK: - Data management
    
    func fetchRepos(ownerName: String, forceLoad: Bool, completion: ((RepoFetchingResultType) -> Void)?) {
        if forceLoad == true || repoOwner?.languageForRepo == nil {
            repoOwner = RepoOwner(name: ownerName)
            guard let owner = repoOwner else { completion?(.error(error: RepoFetchingError.mappingError)); return }
            var repoDict = [String: [Repo]]()
            loadPage(1, name: owner.name) { result in
                switch result {
                case .partialSuccess(let json):
                    do {
                        try self.mapReposTree(json, repo: &repoDict)
                    } catch {
                        completion?(.error(error: RepoFetchingError.mappingError))
                    }
                case .success(let json):
                    do {
                        try self.mapReposTree(json, repo: &repoDict)
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
    
    func mapReposTree(_ data: Data, repo: inout [String: [Repo]]) throws {
        
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
    
    func loadPage(_ page: Int, name: String, completion: ((RepoLoadingResultType) -> Void)?) {
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
            
            if hasMorePages {
                completion?(RepoLoadingResultType.partialSuccess(data: pageData))
                self.loadPage(page + 1, name: name, completion: completion)
            } else {
                completion?(RepoLoadingResultType.success(data: pageData))
            }
            
        }
        
        currentSessionTask?.resume()
    }
    
    // Closes last executed session task
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
        guard let repoTree = repoOwner?.languageForRepo else { return nil }
        guard repoTree.count > index else { fatalError("index can't be more of languages amount") }
        return repoTree[index].language
    }
    
    func numberOfReposForLanguageAtIndex(_ index: Int) -> Int {
        guard let repoTree = repoOwner?.languageForRepo else { return 0 }
        guard repoTree.count > index else { fatalError("can't check number of repositoryes for out of bounds language index") }
        let repos = repoTree[index].repos
        return repos.count
    }
    
    func repoForIndexPath(_ indexPath: IndexPath) -> Repo? {
        guard let repoTree = repoOwner?.languageForRepo else { return nil }
        guard repoTree.count > indexPath.section else { fatalError("") }
        let repos = repoTree[indexPath.section].repos
        guard repos.count > indexPath.row else { fatalError("") }
        return repos[indexPath.row]
    }
    
}
