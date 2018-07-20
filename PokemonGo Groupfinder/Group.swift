//
//  Group.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 28.07.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit

enum groupType {
    case Invite
    case Open
}

class Group: NSObject {
    
    var imageName: String?
    var motto: String?
    var name: String?
    var team: String?
    var groupId: String?
    var admin: String?
    var country: String?
    var city: String?
    var groupType: groupType?
    
    
    
    
}
