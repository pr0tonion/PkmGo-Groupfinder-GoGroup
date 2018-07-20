//
//  SharedInfo.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 07.09.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit

class SharedInfo: NSObject {

    static let sharedInstace = SharedInfo()
    
    
    var city: String!
    var country: String!
    
    func setCity(city: String){
        self.city = city
    }
    
    
    func getCity() -> String{
        
        return city
    }
    
    func setCountry(country: String){
        self.country = country
    }
    
    
    func getCountry() -> String{
        
        return country
    }
    
    
}
