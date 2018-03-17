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
    
    // create a card view for cells??
    // http://www.kaleidosblog.com/swift-cache-how-to-download-and-cache-data-in-ios
    
    func searchReposForOwnerWithName(text: String?) {
        
    }
}

extension RepoViewVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: repoCellID, for: indexPath) as? RepoCell {
            
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}

extension RepoViewVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchReposForOwnerWithName(text: searchBar.text)
    }
}
