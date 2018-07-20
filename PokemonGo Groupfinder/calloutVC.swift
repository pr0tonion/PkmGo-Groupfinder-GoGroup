//
//  calloutVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 28.08.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import Cosmos
import AZSearchView


protocol updateMainCallouts {
    func updateCallouts()
}



class calloutVC: UIViewController, sendingPkmDelegate, sendingPkmLocation {

    
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var eggSwitchOutlet: UISwitch!
    @IBOutlet weak var pkmImageView: UIImageView!
    @IBOutlet weak var pkmCpInput: UITextField!
    @IBOutlet weak var eggRaterView: CosmosView!
    @IBOutlet weak var calloutMinLeftInput: UITextField!
    @IBOutlet weak var calloutText: UITextView!
    @IBOutlet weak var addPlaceBtnElement: UIButton!
    
    let mainSB = UIStoryboard(name: "Main", bundle: nil)
    let popupSB = UIStoryboard(name: "PopupViews", bundle: nil)
    var country: String!
    var city: String!
    let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")
    var calloutMarker: GMSMarker!
    var delegate: updateMainCallouts?
    var callSend = Callout()
    var calloutType = "Raid"
    var pkmSearchController: AZSearchViewController!
    var allPkmArray:[String] = PokemonList.pokemons.listOfAll
    var skipCP: Bool = false
    var skipText: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        country = LocationCache.currentLocation.country
        city = LocationCache.currentLocation.locality
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        eggRaterView.isHidden = true
        
        
        calloutText.layer.borderWidth = 1
        
        navBarItem.title = "Raid callout"
        navBarItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(self.backBtn(_:)))
        
        self.pkmSearchController = AZSearchViewController()
        pkmSearchController.dataSource = self
        pkmSearchController.delegate = self
        pkmSearchController.searchBarPlaceHolder = "Search pokemon name"
        pkmSearchController.searchBarBackgroundColor = .white
        pkmSearchController.keyboardAppearnce = .light
       
        eggRaterView.settings.fillMode = .full
        eggRaterView.settings.filledImage = #imageLiteral(resourceName: "PkmNormalEgg")
        eggRaterView.didTouchCosmos = {rating in
        self.eggRaterView.rating = 1
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
        
        eggSwitchOutlet.addTarget(self, action: #selector(self.eggSwitchChange(switch:)), for: UIControlEvents.valueChanged)
        
        
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func eggSwitchChange(switch: UISwitch){
        
        if eggSwitchOutlet.isOn{
            calloutType = "Egg"
            
            eggRaterView.isHidden = false
            
        }else{
            calloutType = "Raid"
            eggRaterView.isHidden = true
        }
        
    }
    
    
    
   
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPkmToCallout(_ sender: Any) {
       // let addPkmPopup = popupSB.instantiateViewController(withIdentifier: "selectPokemonPopup") as! SelectPokemonPopup
        //addPkmPopup.delegate = self
        //self.addChildViewController(addPkmPopup)
        //addPkmPopup.view.frame = self.view.frame
        //self.view.addSubview(addPkmPopup.view)
        //addPkmPopup.didMove(toParentViewController: self)
        
        pkmSearchController.show(in: self)
        
    }
    
    @IBAction func addPlaceForCallout(_ sender: Any) {
        let VC = mainSB.instantiateViewController(withIdentifier: "addPlaceSBID") as! addPlaceVC
        VC.delegate = self
        self.present(VC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func sendCalloutBtn(_ sender: Any) {
        
        var calloutRef = firDbRef.child("Locations").child(country + "_" + city).child("Callouts").childByAutoId()
        let timeNow = NSDate().timeIntervalSince1970
        var timeLeft:Double?
        if calloutMinLeftInput.text == ""{
         //Alert Time left not set
            let alert = UIAlertController(title: "Time left not set", message: "Please set the approximate time left until the pokemon or raid is gone", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }else{
            //Gang med 60 hvis timeinterval er sec
            //Gang med 60000 hvis timeinterval er i milli
            print(timeNow)
            var minutes = Int(calloutMinLeftInput.text!)
            
            timeLeft = timeNow + Double(minutes! * 60)
            print(timeLeft)
            
        }
        
       
        
        switch skipText {
        case false:
           
            if calloutText.text == ""{
                
                let alert = UIAlertController(title: "Alert", message: "Tell people something about this callout, you can also skip this", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Skip", style: UIAlertActionStyle.default, handler: { (alertAction) in
                    self.skipText = true
                    
                }))
                self.present(alert, animated: true, completion: nil)
                break
            }
            
        break
        case true:
            
            break
        
            
        }
        //Checking inputs
       
        
        
        if (pkmImageView.image == nil){
            let alert = UIAlertController(title: "Please select a pokemon", message: "You have to have the image of the pokemon for the pokemon to be registered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //CP
        
        if skipCP == true{
            callSend.cp = 0
        }else{
        
            if(pkmCpInput.text != ""){
                callSend.cp = Int(pkmCpInput.text!)
            }else{
                
                //CPCHECK Skip?
                let alert = UIAlertController(title: "Please set pokemon CP", message: "You can add the CP of the pokemon or skip it if you want", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) in
                    return
                }))
                alert.addAction(UIAlertAction(title: "Skip", style: UIAlertActionStyle.default, handler: { (alertAction) in
                    print(alertAction)
                    
                    self.skipCP = true
                    self.sendCalloutBtn(self)
                })
                )
                self.present(alert, animated: true, completion: nil)
                return
            }
        
        
    }
        
        //MarkerCheck
        if callSend.latitude != nil{
            
            
        }else{
            //LOCATIONCHECK
            print(callSend.latitude)
            let alert = UIAlertController(title: "Please set a location", message: "This callout needs a location so other people can see where the pokemon is", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) in
                
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        callSend.timeStamp = Date().timeIntervalSince1970
        
        
        
        //Send to DB
        let values = ["pokemonid": callSend.pokemonId,
                      "pokemonName":callSend.pokemonName,
                      "lat": callSend.latitude,
                      "lon": callSend.longditude,
                      "CP": callSend.cp,
                      "text": calloutText.text!,
                      "timestamp": callSend.timeStamp,
                      "timeLeft": timeLeft,
                      "validation": 0,
                      "Type": calloutType,
                      "createdBy": Auth.auth().currentUser?.displayName,
                      "UID": Auth.auth().currentUser?.uid] as [String : Any]
        calloutRef.updateChildValues(values)
        
        dismiss(animated: true) {
            // delegate method to update callouts in main
            
            
        }
        
    }
    
    

    func userGotImage(name: String, image: UIImage, id: Int) {
        
        print(id)
        print(name)
        callSend.pokemonName = name
        callSend.pokemonId = id
       
        
        pkmImageView.image = image
        
        
    }
   
    
    func userDidAddPosition(marker: GMSMarker){
        
        
        callSend.latitude = marker.position.latitude
        callSend.longditude = marker.position.longitude
         addPlaceBtnElement.setTitle("Place set", for: .normal)
        
    }
   
}

extension calloutVC: AZSearchViewDelegate{
    
    func searchView(_ searchView: AZSearchViewController, didSearchForText text: String) {
        pkmSearchController.dismiss(animated: true) {
            
        }
    }
    
    func searchView(_ searchView: AZSearchViewController, didSelectResultAt index: Int, text: String) {
        self.pkmSearchController.dismiss(animated: true, completion: {
            
            //Gjør noe med teksten, søk opp bilde
            
        })
    }
    
    func searchView(_ searchView: AZSearchViewController, didTextChangeTo text: String, textLength: Int) {
        self.allPkmArray.removeAll()
        
        if textLength > 3 {
            for i in 0..<arc4random_uniform(10)+1 {self.allPkmArray.append("\(text) \(i+1)")}
        }
        searchView.reloadData()
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension calloutVC: AZSearchViewDataSource{
   
    
    func statusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    func results() -> [String] {
        return self.allPkmArray
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchView.cellIdentifier)
        cell?.textLabel?.text = self.allPkmArray[indexPath.row]
        cell?.imageView?.image = #imageLiteral(resourceName: "PkmGymSign")
        cell?.imageView?.tintColor = UIColor.gray
        cell?.contentView.backgroundColor = .white
        return cell!
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .destructive, title: "Remove") { action, index in
            self.allPkmArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            //searchView.reloadData()
        }
        
        remove.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        
        
        return [remove]
    }
    
    
}


