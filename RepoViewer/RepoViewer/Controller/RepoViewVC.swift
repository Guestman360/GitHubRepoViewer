//
//  RepoViewVC.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import UIKit



class RepoViewVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let repoCellID = "repoCell"
    
    var manager = RepoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        // Create programmatically later
//        activityIndicator.center = view.center
//        view.addSubview(activityIndicator)
//        view.bringSubview(toFront: activityIndicator)
        
        // From extension to help resign keyobard when tapping on screen, helpful for user experience
        hideKeyboard()
        
        self.getNib()
    }
    
    // method to help call our section header xib
    func getNib() {
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "SectionHeader")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // Call this method to reload UI
    func reloadUI() {
        tableView.reloadData()
    }
    
    // Just for convenience
    func noOwnerFoundAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Empty owner name", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // create a card view for cells??
    // http://www.kaleidosblog.com/swift-cache-how-to-download-and-cache-data-in-ios
    
    func searchReposForOwnerWithName(text: String?) {
        manager.closeCurrentSessionTaskIfNeeded()
        if let text = text {
            manager.fetchRepos(ownerName: text, forceLoad: true) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        break
                    case .error(let error):
                        var title: String?
                        var message: String?
                        switch error {
                        case .loadingError:
                            title = NSLocalizedString("Error", comment: "")
                            message = NSLocalizedString("Loading error", comment: "")
                        case .loadingLimitsError:
                            title = NSLocalizedString("Error", comment: "")
                            message = NSLocalizedString("Loading limits", comment: "")
                        case .notFound:
                            title = NSLocalizedString("Error", comment: "")
                            message = NSLocalizedString("Owner not found", comment: "")
                        case .mappingError:
                            title = NSLocalizedString("Error", comment: "")
                            message = NSLocalizedString("Mapping error", comment: "")
                        }
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                        self?.present(alertController, animated: true, completion: nil)
                    }
                    
                    self?.reloadUI()
                }
            }
        } else {
            self.noOwnerFoundAlert()
        }
    }
}

extension RepoViewVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return manager.numberOfLanguages()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.numberOfReposForLanguageAtIndex(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: repoCellID, for: indexPath) as? RepoCell {
            
            if let repoAtIndex = manager.repoForIndexPath(indexPath) {
                dump(repoAtIndex)
                cell.configure(with: repoAtIndex)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    // For some style
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as? SectionHeader
        
        if let language = manager.languageAtIndex(section) {
            let count = manager.numberOfReposForLanguageAtIndex(section)
            let title = "\(language) (\(count))"
            header?.sectionHeaderLabel.text = title
        }
        return header
    }
    
}

extension RepoViewVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchReposForOwnerWithName(text: searchBar.text)
    }
}
