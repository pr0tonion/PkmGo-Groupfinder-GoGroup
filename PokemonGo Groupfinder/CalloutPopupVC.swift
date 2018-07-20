//
//  GymPopupVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 30.05.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit

protocol changeCalloutProtocol {
    func changeCallout(callout: Callout)
}

class CalloutPopupVC: UIViewController, changeCalloutProtocol {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var raidCpOutlet: UILabel!
    @IBOutlet weak var raidNameOutlet: UILabel!
    @IBOutlet weak var raidMinLeftOutlet: UILabel!
    @IBOutlet weak var addRaidBtnOutlet: UIButton!
    @IBOutlet weak var gymIsBadBtnOutlet: UIButton!
    @IBOutlet weak var gymIsGoodBtnOutlet: UIButton!
    @IBOutlet weak var raidImgViewOutlet: UIImageView!
    @IBOutlet weak var gymNameOutlet: UILabel!
    @IBOutlet weak var infoStackViewOutlet: UIStackView!
    
    var callout: Callout!
    let timeNow = Date().timeIntervalSince1970
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        prepareView()
    }

    func prepareView(){
        raidCpOutlet.layer.cornerRadius = 8.0
        raidCpOutlet.layer.masksToBounds = true
        
        raidNameOutlet.layer.cornerRadius = 8.0
        raidNameOutlet.layer.masksToBounds = true
        
        raidMinLeftOutlet.layer.cornerRadius = 8.0
        raidMinLeftOutlet.layer.masksToBounds = true
        
        
        
        if callout.pkmSprite != nil{
            raidImgViewOutlet.image = callout.pkmSprite
        }
        
        switch callout.type {
        case .Egg:
            //Name
            raidNameOutlet.text = "Egg LV: " + String(callout.eggLevel!)
            //Timeleft
            raidMinLeftOutlet.text = "Min left: " + callout.timeLeftString()
            //Eggtype/level
            if callout.timeLeft! < timeNow{
            if callout.eggLevel! <= 2{
                raidImgViewOutlet.image = #imageLiteral(resourceName: "PkmNormalEgg")
            }
            
            if callout.eggLevel! > 2{
                raidImgViewOutlet.image = #imageLiteral(resourceName: "PkmRareEgg")
            }
            if callout.eggLevel! == 5{
                raidImgViewOutlet.image = #imageLiteral(resourceName: "Pokemon-GO-Legendary-Egg")
            }
            //If timeLeft> timenow -> show add raid btn
            }else{
                addRaidBtnOutlet.isHidden = false
            }
            break
        case .Raid:
            //Pkm name
            raidNameOutlet.text = callout.pokemonName!
            //timeleft
            raidMinLeftOutlet.text = "Min left: " + callout.timeLeftString()
            //CP
            raidCpOutlet.text = "CP: " + String(callout.cp!)
            
            addRaidBtnOutlet.isHidden = true
            break
        case .Nest:
            //pkmName
            raidNameOutlet.text = callout.pokemonName
            //Timeleft
            raidMinLeftOutlet.text = "Min left: " + callout.timeLeftString()
            addRaidBtnOutlet.isHidden = true
            break
        case .Pkm:
            //Pkmname
            raidNameOutlet.text = callout.pokemonName
            //CP
             raidCpOutlet.text = "CP: " + String(callout.cp!)
            //timeleft
            raidMinLeftOutlet.text = "Min left: " + callout.timeLeftString()
            addRaidBtnOutlet.isHidden = true

            break
        default:
            return
        }
        
    }
    func changeCallout(callout: Callout){
        self.callout = callout
        if callout.pkmSprite == nil{
            PokeAPIHandler().getPkmSprite(id: callout.pokemonId!) { (sprite) in
                self.callout.pkmSprite = sprite
                self.prepareView()
            }
        }
        prepareView()
    }
    
    @IBAction func gymIsBadBtn(_ sender: Any) {
        FirebaseHandler().calloutEval(eval: false, calloutID: callout.calloutId!, country: LocationCache.currentLocation.country!, city: LocationCache.currentLocation.locality!, uid: callout.userUid!)
    }
    
    @IBAction func gymIsGoodBtn(_ sender: Any) {
        FirebaseHandler().calloutEval(eval: true, calloutID: callout.calloutId!, country: LocationCache.currentLocation.country!, city: LocationCache.currentLocation.locality!, uid: callout.userUid!)
    }
    
    @IBAction func addRaidBtn(_ sender: Any) {
        
        let popupSB = UIStoryboard(name: "PopupViews", bundle: nil).instantiateViewController(withIdentifier: "addRaidPopup") as! addRaidVC
        
        popupSB.marker = callout.marker
        popupSB.oldCallout = callout
        
        popupSB.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        
        self.present(popupSB, animated: true) {
            
        }
        
    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view != popupView{
            
            self.view.removeFromSuperview()
            
        }
    }
    
}
