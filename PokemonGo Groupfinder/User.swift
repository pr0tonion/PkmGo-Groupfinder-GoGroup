//
//  User.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 28.07.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit


class User: NSObject {

    var uid: String?
    var userName:String?
    var email:String?
    var joinedGroups:[Group]?
    var team: String?
    var profilePic: UIImage!
    var userLevel: Int?
    var trustLevel: Int?
    
    static var currentUser = User()
    

}
