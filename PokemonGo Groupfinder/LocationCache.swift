//
//  LocationCache.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 04.04.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationCache: NSObject {

    var country: String?
    var locality: String?
    var automatic: Bool = true
    
    static var currentLocation = LocationCache()
    
    
}
