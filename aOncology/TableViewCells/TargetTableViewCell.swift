//
//  TargetTableViewCell.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/26/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import UIKit

protocol SelectButtonsDelegate{
    func toggleTargetTapped(at index:IndexPath)
}


class TargetTableViewCell: UITableViewCell {

    @IBOutlet var synoName:   UILabel!
    @IBOutlet var hugoName:   UILabel!     // in case sysnonym was entered
    @IBOutlet var aberration: UILabel!
    @IBOutlet var symbolImage:UIImageView!
    
    @IBOutlet var checkMark:  UIImageView!
    @IBOutlet var checkButton: UIButton!
    
    
    
    var targetAllowed :Bool!
    var delegate:SelectButtonsDelegate!
    var indexPath:IndexPath!
    
    @IBAction func toggleTargetTapped(_ sender: UIButton) {
        self.delegate?.toggleTargetTapped(at: indexPath)
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        targetAllowed = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
