//
//  ChatCell.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 28.08.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var chatText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
