//
//  AdConfirmationVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 20.12.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit

protocol adConfirmDelegate {
    func userAdResult(answer:Bool)
}

class AdConfirmationVC: UIViewController {

    
    var delegate: adConfirmDelegate? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func acceptBtn(_ sender: Any) {
        delegate?.userAdResult(answer: true)
        self.view.removeFromSuperview()
    }
    
    @IBAction func declineBtn(_ sender: Any) {
        delegate?.userAdResult(answer: false)
        self.view.removeFromSuperview()
    }
    

}
