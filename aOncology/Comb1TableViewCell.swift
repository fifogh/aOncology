//
//  Comb1TableViewCell.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/28/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

class Comb1TableViewCell: UITableViewCell {

    @IBOutlet var drug1: UILabel!
    @IBOutlet var score: UILabel!
    @IBOutlet var matchScore: UILabel!
    @IBOutlet var warning: UIImageView!
    @IBOutlet var approved: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
