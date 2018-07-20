//
//  addRaidVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 30.05.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit
import Cosmos
import GoogleMaps

class addRaidVC: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var isEggSwitchOutlet: UISwitch!
    @IBOutlet weak var eggRaterView: CosmosView!
    @IBOutlet weak var pkmNameOutlet: UITextField!
    @IBOutlet weak var pkmCpOutlet: UITextField!
    @IBOutlet weak var pkmTimeLeftOutlet: UITextField!
    @IBOutlet weak var addPkmBtnOutlet: UIButton!
    @IBOutlet weak var searchPkmBtnOutlet: UIButton!
    
    var marker: GMSMarker!
    var isEgg: Bool = false
    var pkmName: String?
    var pkmCp: String?
    var pkmTimeLeft: Int?
    var delegate: finishedCallout?
    var oldCallout: Callout?
    var thisCallout = Callout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView(){
        
        popupView.layer.borderWidth = 1
        popupView.layer.borderColor = UIColor.black.cgColor
        popupView.layer.cornerRadius = 10
        
        eggRaterView.settings.fillMode = .full
        eggRaterView.settings.filledImage = #imageLiteral(resourceName: "PkmNormalEgg")
        eggRaterView.didTouchCosmos = {rating in
            
            if rating <= 2{
                self.eggRaterView.settings.filledImage = #imageLiteral(resourceName: "PkmNormalEgg")
            }
            
            if rating > 2{
                self.eggRaterView.settings.filledImage = #imageLiteral(resourceName: "PkmRareEgg")
            }
            if rating == 5{
                self.eggRaterView.settings.filledImage = #imageLiteral(resourceName: "Pokemon-GO-Legendary-Egg")
            }
            
        }
    }
    
    func dismissPopup(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func isEggSwitch(_ sender: Any) {
        
        if isEggSwitchOutlet.isOn{
            isEgg = true
            pkmNameOutlet.isHidden = true
            searchPkmBtnOutlet.isHidden = true
            
        }else{
            isEgg = false
            pkmNameOutlet.isHidden = false
            searchPkmBtnOutlet.isHidden = false
        }
        
    }
    
    @IBAction func addPkmBtn(_ sender: Any) {
        
        if isEgg == true{
            thisCallout.pokemonName = "Egg"
            thisCallout.pokemonId = 0
            thisCallout.eggLevel = Int(eggRaterView.rating)
        }
        
        if thisCallout.pokemonName == nil{
            createAlert(title: "Pokemon not set", text: "Please search for a pokemon and wait for green color around textfield", btnText: "OK")
            return
        }else{
            //Name set in searchPkmBtn
            
            
        }
        
        if Int(pkmCpOutlet.text!) != nil{
            thisCallout.cp = Int(pkmCpOutlet.text!)
        }else{
            //CP not correctly made
            createAlert(title: "CP is not valid", text: "CP is not valid. Please only use numerical values", btnText: "OK")
            return
        }
        
        if let timeLeft = Int(pkmTimeLeftOutlet.text!){
            let timeNow = NSDate().timeIntervalSince1970
            let minutes = Int(pkmTimeLeftOutlet.text!)
            
            if timeLeft > 100{
                createAlert(title: "Time is over 100 minutes", text: "As a restriction you can only set the timeleft at a max of 100 minuets as to stop spammers", btnText: "OK")
            }
            thisCallout.timeLeft = timeNow + Double(minutes! * 60)
            
            
        }else{
            //Time is broken
            createAlert(title: "Time is not set", text: "Please only use numerical values when describing how many minutes left. Max is 100 minutes", btnText: "OK")
            return
        }
        
        thisCallout.marker = marker
        
        if isEgg{
            thisCallout.type = .Egg
        }else{
            thisCallout.type = .Raid
        }
        
        self.dismiss(animated: true) {
            if self.delegate != nil{
                FirebaseHandler().saveCallout(callSend: self.thisCallout)
                self.delegate?.dismissPopup()
            }else{
                if self.oldCallout != nil{
                    FirebaseHandler().updateCallout(oldCallout: self.oldCallout!, newCallout: self.thisCallout)
                }
            }
        }
        
    }
    
    @IBAction func searchPkmBtn(_ sender: Any) {
        
        if pkmNameOutlet.text != ""{
            let nameSearched = self.pkmNameOutlet.text!
            
            PokeAPIHandler().getPokemon(withSprite: false, id: pkmNameOutlet.text!) { (pokemon, didFind) in
            
                if didFind == true{
                    self.thisCallout.pokemonId = pokemon?.id
                    self.thisCallout.pokemonName = pokemon?.name
                    
                    self.pkmNameOutlet.text = nameSearched
                    self.pkmNameOutlet.layer.borderWidth = 2
                    self.pkmNameOutlet.layer.borderColor = #colorLiteral(red: 0.2901960784, green: 0.6078431373, blue: 0.3450980392, alpha: 1)
                }else{
                    self.pkmNameOutlet.text = nameSearched
                    self.pkmNameOutlet.layer.borderWidth = 2
                    self.pkmNameOutlet.layer.borderColor = #colorLiteral(red: 0.8156862745, green: 0.2156862745, blue: 0.1921568627, alpha: 1)
                }
            }
            self.pkmNameOutlet.text = "Searching..."
            }else{
                return
            }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view != popupView{
            
            if touch?.view != eggRaterView{
            
            self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func createAlert(title: String, text: String, btnText: String ){
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: btnText, style: .default, handler: { (alertAction) in
        }))
        present(alert, animated: true, completion: nil)
        
        
    }
    

}
