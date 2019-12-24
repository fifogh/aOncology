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
    
    @IBOutlet var TSub1: UILabel!
    @IBOutlet var TSub2: UILabel!
    @IBOutlet var TSub3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
