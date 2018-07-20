//
//  addPkmVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 30.05.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit
import GoogleMaps

class addPkmVC: UIViewController {

    
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var pkmNameTextField: UITextField!
    @IBOutlet weak var pkmCpTextField: UITextField!
    @IBOutlet weak var pkmSearchBtnOutlet: UIButton!
    @IBOutlet weak var pkmTimeLeftTextField: UITextField!
    @IBOutlet weak var addPkmBtnOutlet: UIButton!
    
    var marker: GMSMarker!
    var thisCallout = Callout()
    var delegate: finishedCallout?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
    }
    
    
    func prepareView(){
        
        //popupView.layer.borderWidth = 1
        //popupView.layer.borderColor = UIColor.black.cgColor
        popupView.layer.cornerRadius = 25
        
    }

    @IBAction func pkmSearchBtn(_ sender: Any) {
        
        if pkmNameTextField.text != ""{
            let nameSearched = self.pkmNameTextField.text!
            
            PokeAPIHandler().getPokemon(withSprite: false, id: pkmNameTextField.text!) { (pokemon, didFind) in
                
                if didFind == true{
                    self.thisCallout.pokemonId = pokemon?.id
                    self.thisCallout.pokemonName = pokemon?.name
                    
                    self.pkmNameTextField.text = nameSearched
                    self.pkmNameTextField.layer.borderWidth = 2
                    self.pkmNameTextField.layer.borderColor = #colorLiteral(red: 0.2901960784, green: 0.6078431373, blue: 0.3450980392, alpha: 1)
                }else{
                    self.pkmNameTextField.text = nameSearched
                    self.pkmNameTextField.layer.borderWidth = 2
                    self.pkmNameTextField.layer.borderColor = #colorLiteral(red: 0.8156862745, green: 0.2156862745, blue: 0.1921568627, alpha: 1)
                }
            }
            self.pkmNameTextField.text = "Searching..."
        }else{
            return
        }
    }
    
    @IBAction func addPkmBtn(_ sender: Any) {
        
        if thisCallout.pokemonId! > 0{
            //Name set in searchbtn
        }else{
            createAlert(title: "Pokemon is not set", text: "Please write the pokemons name or pokedex ID then click search and wait for the green color to appear", btnText: "OK")
        }
        if Int(pkmCpTextField.text!) != nil{
            thisCallout.cp = Int(pkmCpTextField.text!)
        }else{
            createAlert(title: "CP is not a number", text: "Only use numerical values when choosing CP", btnText: "OK")
        }
        if let timeleft = Int(pkmTimeLeftTextField.text!){
          
            if timeleft <= 30{
                let timeNow = NSDate().timeIntervalSince1970
                thisCallout.timeLeft = timeNow + Double(timeleft * 60)
            }else{
                createAlert(title: "Time left is too high", text: "Please add a valid number and make sure it is below or qeual to 30 minutes", btnText: "OK")
            }
            
        }else{
            createAlert(title: "Time is not numerical", text: "Please use numerical values when selecting time left", btnText: "OK")
        }
        
        thisCallout.marker = marker
        thisCallout.type = .Pkm
        
        FirebaseHandler().saveCallout(callSend: thisCallout)
        self.dismiss(animated: true) {
            self.delegate?.dismissPopup()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view != popupView{
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func createAlert(title: String, text: String, btnText: String ){
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: btnText, style: .default, handler: { (alertAction) in
        }))
        present(alert, animated: true, completion: nil)
        
        
    }

}
