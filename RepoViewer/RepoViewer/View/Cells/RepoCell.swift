//
//  RepoCell.swift
//  RepoViewer
//
//  Created by Matt Guest on 3/16/18.
//  Copyright © 2018 AlphaApplications. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var repoNameLbl: UILabel!
    @IBOutlet weak var repoDescLbl: UILabel!
    @IBOutlet weak var repoStarsLbl: UILabel!
    @IBOutlet weak var repoForksLbl: UILabel!
    @IBOutlet weak var repoUpdatedLbl: UILabel!
    @IBOutlet weak var starImg: UIImageView!
    @IBOutlet weak var forkImg: UIImageView!
    
    
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
    }
    
    // Opted to put cell logic in the actual cell file, instead of leaving in VC file, separation of concerns!
    /// This method sets the appropriate data to the appropriate UI element on the RepoCell
    func configure(with repo: Repo) {
        repoNameLbl.text = repo.name
        repoDescLbl.text = repo.description
        
        if let stars = repo.starsCount,
            let forks = repo.forksCount {
            
            let translatedStarsCount = String.localizedStringWithFormat(NSLocalizedString("Stars: %i", comment: "Stars: %i"), stars)
            repoStarsLbl.text = translatedStarsCount
            let translatedForksCount = String.localizedStringWithFormat(NSLocalizedString("Forks: %i", comment: "Fork: %i"), forks)
            repoForksLbl.text = translatedForksCount
            
            // Set up the star and fork images
            starImg.image = #imageLiteral(resourceName: "star")
            forkImg.image = #imageLiteral(resourceName: "network")
        }
        
        let dateString: String
        if let updated = repo.lastUpdatedDate {
            dateString = dateFormatter.string(from: updated)
        } else {
            dateString = NSLocalizedString("Unknown", comment: "")
        }
        let translatedDate = String.localizedStringWithFormat(NSLocalizedString("Updated: %@", comment: "Updated: %@"), dateString)
        repoUpdatedLbl.text = translatedDate
    }

}
