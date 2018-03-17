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
    

    
    // Do index row assignment logic here
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
