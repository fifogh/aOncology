//
//  DrugTableViewCell.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/22/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

protocol OptionButtonsDelegate{
    func checkMarkTapped(at index:IndexPath)
}

class DrugTableViewCell: UITableViewCell {

    @IBOutlet var drugName: UILabel!
    @IBOutlet var checkMark: UIImageView!
    @IBOutlet var checkButton: UIButton!
    
    var drugAllowed :Bool!
    var delegate:OptionButtonsDelegate!
    var indexPath:IndexPath!
   
    @IBAction func checkTapped(_ sender: UIButton) {
        self.delegate?.checkMarkTapped(at: indexPath)

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        drugAllowed = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
