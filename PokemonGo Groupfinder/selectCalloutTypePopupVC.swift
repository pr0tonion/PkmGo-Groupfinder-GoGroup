//
//  selectCalloutTypePopupVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 13.04.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit
import GoogleMaps

protocol CalloutTypeDelegate {
    func removeMarker()
    
}
protocol finishedCallout{
    func dismissPopup()
}

class selectCalloutTypePopupVC: UIViewController, finishedCallout {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var viewOutlet: UIView!
    @IBOutlet weak var chooseRaidBtnOutlet: UIButton!
    @IBOutlet weak var calloutPkmBtnOutlet: UIButton!
    @IBOutlet weak var calloutNestBtnOutlet: UIButton!
    var delegate: CalloutTypeDelegate?
    var marker: GMSMarker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       prepareView()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        animateBackground()
    }
    
    
    func prepareView(){
        
        self.backgroundView.alpha = 0
        
        chooseRaidBtnOutlet.layer.cornerRadius = 25
        chooseRaidBtnOutlet.layer.borderWidth = 1
        chooseRaidBtnOutlet.layer.borderColor = UIColor.black.cgColor
        
        calloutPkmBtnOutlet.layer.cornerRadius = 25
        calloutPkmBtnOutlet.layer.borderWidth = 1
        calloutPkmBtnOutlet.layer.borderColor = UIColor.black.cgColor
        
        
        calloutNestBtnOutlet.layer.cornerRadius = 25
        calloutNestBtnOutlet.layer.borderWidth = 1
        calloutNestBtnOutlet.layer.borderColor = UIColor.black.cgColor
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        
        viewOutlet.layer.cornerRadius = 25
        viewOutlet.addGestureRecognizer(dismissTap)
        
        
        
    }
    
    func animateBackground(){
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundView.alpha += 0.5
        }) { (finished) in
            
        }
        
    }
    
    func dismissView(){
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundView.alpha -= 0
        }) { (finished) in
            if finished{
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    
    @IBAction func addRaid(_ sender: Any) {
        
        let popupSB = UIStoryboard(name: "PopupViews", bundle: nil).instantiateViewController(withIdentifier: "addRaidPopup") as! addRaidVC
        
        popupSB.delegate = self
        popupSB.marker = marker
        
        popupSB.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        
        self.present(popupSB, animated: true) {
            
        }
        
    }
    
    @IBAction func addPkm(_ sender: Any) {
        let popupSB = UIStoryboard(name: "PopupViews", bundle: nil).instantiateViewController(withIdentifier: "addPkmPopup") as! addPkmVC
        popupSB.delegate = self
        popupSB.marker = marker
        
        popupSB.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        self.present(popupSB, animated: true)
        
    }
    
    
    @IBAction func addNestBtn(_ sender: Any) {
        
         let popupSB = UIStoryboard(name: "PopupViews", bundle: nil).instantiateViewController(withIdentifier: "addNestPopup") as! addNestVC
        popupSB.delegate = self
        popupSB.marker = marker
        
        popupSB.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.present(popupSB, animated: true)
        
        
    }
    
    func dismissPopup() {
        delegate?.removeMarker()
        dismiss(animated: true, completion: nil)
    }
    
}
