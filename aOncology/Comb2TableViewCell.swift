//
//  Comb2TableViewCell.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/28/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

class Comb2TableViewCell: UITableViewCell {

    @IBOutlet var drug1: UILabel!
    @IBOutlet var drug2: UILabel!
    
    @IBOutlet var score: UILabel!
     @IBOutlet var warning: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
