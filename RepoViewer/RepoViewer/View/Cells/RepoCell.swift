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
        //cardSetUp()
    }
    // Add proxima nove reg, light and bold later, also gradient view
    // Add a uiview to bckground later
    //Set up the design of the cardview
//    func cardSetUp() {
//        cardView.backgroundColor = UIColor.white
//        contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
//        contentView.translatesAutoresizingMaskIntoConstraints = true
//
//        cardView.layer.cornerRadius = 5.0
//        cardView.layer.masksToBounds = false
//        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        cardView.layer.shadowOpacity = 0.8
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
