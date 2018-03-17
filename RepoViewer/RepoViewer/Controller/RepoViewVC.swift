//
//  RepoViewTVC.swift
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
}

extension RepoViewVC: UISearchBarDelegate {
    
}
