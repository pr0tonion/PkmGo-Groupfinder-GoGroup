//
//  GroupTableViewCell.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 29.12.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
