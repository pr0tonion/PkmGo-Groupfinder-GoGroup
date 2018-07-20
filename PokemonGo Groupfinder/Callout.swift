//
//  Callout.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 23.10.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import GoogleMaps

class Callout: NSObject {
    
    var pokemonId: Int?
    var pokemonName: String?
    var latitude: Double!
    var longditude: Double?
    var calloutText: String?
    var timeStamp: Double?
    var cp: Int?
    var marker: GMSMarker?
    var calloutId: String?
    var createdBy: String?
    var timeLeft: Double?
    var userUid: String?
    var pkmSprite: UIImage?
    var type: CalloutType!
    var eggLevel: Int?
    var trustLevel: Int?
    var validation: Int?
    
    func timeLeftString() -> String{
        let timeNow = Date().timeIntervalSince1970
        let minutesInt = Int((self.timeLeft!-timeNow)/60)
        let minutesString: String = String(minutesInt)
        return minutesString
    }
    func timeLeftInt() -> Int{
        let timeNow = Date().timeIntervalSince1970
        let minutesInt: Int = Int((self.timeLeft!-timeNow)/60)
        
        return minutesInt
    }
  
}
enum CalloutType{
    case Nest
    case Pkm
    case Raid
    case Egg
}
