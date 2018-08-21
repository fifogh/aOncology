//
//  ReviewTableViewCell.swift
//  aOncology
//
//  Created by Philippe-Faurie on 8/21/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet var date: UILabel!
    @IBOutlet var ratingCosmosView: CosmosView!
    @IBOutlet var memo: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
