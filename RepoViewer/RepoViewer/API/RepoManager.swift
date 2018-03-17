//
//  RepoManager.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import UIKit

// Enums to handle successes and failures of fethcing and loading data
enum RepositoryFetchingError: Error {
    case loadingError
    case loadingLimitsError
    case notFound
    case mappingError
}

enum RepositoryLoadingResultType {
    case success(data: Data)
    case partialSuccess(data: Data)
    case error(error: RepositoryFetchingError)
}

enum RepositoryFetchingResultType {
    case success(repository: [LanguageForRepo])
    case error(error: RepositoryFetchingError)
}

class RepoManager {
    
    // This will get dict of repos groupd by language
    private var repoOwner: RepoOwner?
    
    // MARK: - Data management
    
    func fetchRepositories(ownerName: String, forceLoad: Bool, completion: ((RepositoryFetchingResultType) -> Void)?) {
        if forceLoad == true || repoOwner?.languageForRepo == nil {
            repoOwner = RepoOwner(name: ownerName)
            guard let owner = repoOwner else { completion?(.error(error: RepositoryFetchingError.mappingError)); return }
            var repoDict = [String: [Repo]]()
            loadPage(1, name: owner.name) { result in
                switch result {
                case .partialSuccess(let json):
                    do {
                        try self.mapReposTree(json, repo: &repoDict)
                    } catch {
                        completion?(.error(error: RepositoryFetchingError.mappingError))
                    }
                case .success(let json):
                    do {
                        try self.mapReposTree(json, repo: &repoDict)
                    } catch {
                        completion?(.error(error: RepositoryFetchingError.mappingError))
                    }
                    
                    let sortedLanguages = repoDict.keys.sorted { (lang1, lang2) -> Bool in
                        repoDict[lang1]?.count ?? 0 > repoDict[lang2]?.count ?? 0
                    }
                    for language in sortedLanguages {
                        if let owner = self.repoOwner, let repositories = repoDict[language] {
                            if owner.languageForRepo == nil {
                                owner.languageForRepo = [LanguageForRepo]()
                            }
                            let sortedRepo = repositories.sorted(by: { repository1, repository2 -> Bool in
                                repository1.starsCount ?? 0 > repository2.starsCount ?? 0
                            })
                            owner.languageForRepo?.append((language: language, repositories: sortedRepo) as! LanguageForRepo)
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
        
        guard let json = try? JSONSerialization.jsonObject(with: data) else { throw RepositoryFetchingError.mappingError }
        guard let jsonarray = json as? [Any] else { throw RepositoryFetchingError.mappingError }
        for item in jsonarray {
            guard let item = item as? [String: Any] else { throw RepositoryFetchingError.mappingError }
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
                throw RepositoryFetchingError.mappingError
            }
        }
    }
    
    // MARK: - Data fetching
    
    private weak var currentSessionTask: URLSessionDataTask?
    
    func loadPage(_ page: Int, name: String, completion: ((RepositoryLoadingResultType) -> Void)?) {
        let request = PageRequest()
        request.path = "/users/\(name)/repos"
        request.page = page
        guard let url = request.url else { fatalError("can't construct url") }
        
        currentSessionTask = URLSession.shared.dataTask(with: url) { (pageData, response, error) in
            guard let pageData: Data = pageData, let _: URLResponse = response, error == nil else { completion?(.error(error: RepositoryFetchingError.loadingError)); return }
            guard let httpResponse = response as? HTTPURLResponse else { completion?(.error(error: RepositoryFetchingError.loadingError)); return }
            guard httpResponse.statusCode != 404 else { completion?(.error(error: RepositoryFetchingError.notFound)); return }
            guard httpResponse.statusCode != 403 else { completion?(.error(error: RepositoryFetchingError.loadingLimitsError)); return }
            guard httpResponse.statusCode == 200 else { completion?(.error(error: RepositoryFetchingError.loadingError)); return }
            
            var hasMorePages = false
            if let linkString = httpResponse.allHeaderFields["Link"] as? String {
                let links = GHHeaderLinkParser.getNextPage(from: linkString)
                if links.keys.contains("next") {
                    hasMorePages = true
                }
            }
            
            if hasMorePages {
                completion?(RepositoryLoadingResultType.partialSuccess(data: pageData))
                self.loadPage(page + 1, name: name, completion: completion)
            } else {
                completion?(RepositoryLoadingResultType.success(data: pageData))
            }
            
        }
        
        currentSessionTask?.resume()
    }
    
    /// Closes last executed session task
    func closeCurrentSessionTaskIfNeeded() {
        currentSessionTask?.cancel()
        currentSessionTask = nil
    }
    
}
