//
//  SelectPokemonPopup.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 19.09.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import AZSearchView

protocol sendingPkmDelegate {
    func userGotImage(name: String, image: UIImage, id: Int)
}

class SelectPokemonPopup: UIViewController {

    @IBOutlet weak var pkmSearchField: UITextField!
    @IBOutlet weak var pkmImage: UIImageView!
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var viewTopLabel: UILabel!
    @IBOutlet weak var searchBtnOutlet: UIButton!
    var delegate: sendingPkmDelegate? = nil
    var pkmName: String!
    var pkmImageFile: UIImage?
    var pkmId: Int!
    var searchTimer: Timer!
    var timerSec = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        searchingIndicator.isHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
                
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //TODO - Create timer if name is wrong
    @IBAction func searchBtn(_ sender: Any) {
        searchingIndicator.isHidden = false
        searchingIndicator.startAnimating()
        dismissKeyboard()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
            self.timerSec + 1
            if self.timerSec == 30{
                self.searchingIndicator.isHidden == true
                //TODO - present error
                self.searchTimer.invalidate()
            }
            
            
        })
        
        Alamofire.request("http://pokeapi.co/api/v2/pokemon/" + pkmSearchField.text! ).responseJSON { (response) in
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("example success")
                    self.searchTimer.invalidate()
                default:
                    print("error with response status: \(status)")
                    self.viewTopLabel.text = "Could not find pokemon, make sure name is correct"
                    self.searchingIndicator.stopAnimating()
                    self.searchingIndicator.isHidden = true
                    return
                }
            }
            //to get JSON return value
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                self.pkmName = JSON["name"] as? String
                self.viewTopLabel.text = self.pkmName
                self.pkmId = JSON["id"] as? Int
                self.getPkmSprite(id: self.pkmId!)
            }else{
                print("POKEMON NOT FOUND")
            }
            
            
         //Get image, then stop indicator
            self.searchingIndicator.stopAnimating()
            self.searchingIndicator.isHidden = true
        }
    }
    
    func getPkmSprite(id: Int){
        print("Pokemon/\(id).png")
        let storageRef = Storage.storage().reference(withPath: "Pokemon/\(id).png")
        self.searchingIndicator.startAnimating()
        storageRef.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
            if error != nil{
                self.pkmImage.image = #imageLiteral(resourceName: "Unknown")
                self.viewTopLabel.text = "Please select a gen1 or gen2 pokemon"
                self.searchingIndicator.stopAnimating()
            }else{
                self.pkmImageFile = UIImage(data: data!)
                self.pkmImage.image = self.pkmImageFile
                self.searchingIndicator.stopAnimating()
            }
        })
    }

    @IBAction func backBtn(_ sender: Any) {
        self.view.removeFromSuperview()
        dismiss(animated: true) {
            
        }
    }
   
    @IBAction func addToCalloutBtn(_ sender: Any) {
        if (pkmImageFile != nil){
            delegate?.userGotImage(name: pkmName, image: pkmImageFile!, id: pkmId)
           
            
            self.view.removeFromSuperview()
        }else{
            viewTopLabel.text = "Please wait until sprite has loaded"
            
        }
    }
    
    
}
