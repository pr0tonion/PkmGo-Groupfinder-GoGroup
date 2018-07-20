//
//  PokeAPIHandler.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 23.11.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class PokeAPIHandler: NSObject {

    func getPkmSprite(id: Int, finished: @escaping (UIImage) -> Void) -> Void{
        print(id)
        var pkmImageFile: UIImage!
        let storageRef = Storage.storage().reference(withPath: "Pokemon/\(id).png")
        storageRef.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
            if error != nil{
                print("image could not be downloaded")
                
               
            }else{
             pkmImageFile = UIImage(data: data!)
                finished(pkmImageFile)
            }
            print(pkmImageFile)
            
        })
     
    }
    
    func getAllPokemonInGO(){
        
        var baseString = "https://pokeapi.co/api/v2/generation/"
        var genCounter = 1
        
        while genCounter <= 3{
            
            Alamofire.request(baseString + String(genCounter)).responseJSON { (response) in
                
                if response.error != nil{
                    print(response.error)
                    return
                }
                
                do{
                    let json = try JSON(data: response.data!)
                    
                    if let pokemons = json["pokemon_species"].array{
                        for pokemon in pokemons{
                            
                            PokemonList.pokemons.listOfAll.append(pokemon["name"].string!)
                            
                            
                        }
                    }
                    
                    
                    
                    
                }catch{
                
                }
            }
            
            
            genCounter = genCounter + 1
        }
      
    }
    
    func getPokemon(withSprite: Bool, id: String, completion: @escaping (Pokemon?,Bool)->()){
        
        let baseLink = "http://pokeapi.co/api/v2/pokemon/" + id
        var pokemon = Pokemon()
        Alamofire.request(baseLink).responseJSON { (response) in
            
            if response.error != nil{
                completion(nil, false)
                return
            }
            let json = JSON(response.data!)
    
            if json["name"].exists(){
            pokemon.id = json["id"].int
            pokemon.name = json["name"].string
            
                if withSprite == true{
                    self.getPkmSprite(id: pokemon.id, finished: { (sprite) in
                        pokemon.sprite = sprite
                        completion(pokemon, true)
                    })
                }else{
                    completion(pokemon, true)
                }
            
            }else{
                completion(nil,false)
            }
        }
        
    }
    
    
}
