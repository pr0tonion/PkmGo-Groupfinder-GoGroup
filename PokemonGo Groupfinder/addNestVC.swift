//
//  addNestVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 04.06.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit
import GoogleMaps

class addNestVC: UIViewController {

    
    var delegate: finishedCallout?
    var marker: GMSMarker?
    var thisCallout = Callout()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func createAlert(title: String, text: String, btnText: String ){
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: btnText, style: .default, handler: { (alertAction) in
        }))
        present(alert, animated: true, completion: nil)
        
        
    }
}
