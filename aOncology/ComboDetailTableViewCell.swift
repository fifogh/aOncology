//
//  ComboDetailTableViewCell.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/10/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

class ComboDetailTableViewCell: UITableViewCell {

    @IBOutlet var gene: UILabel!
    @IBOutlet var hitScore: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}