//
//  RequestPopupVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 06.06.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit
import Firebase


class RequestPopupVC: UIViewController {

    @IBOutlet weak var requestTextField: UITextField!
    @IBOutlet weak var sendBtnOutlet: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    var thisGroup = Group()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    func prepareView(){
        
    }
   
   
    @IBAction func sendReqBtn(_ sender: Any) {
        
        FirebaseHandler().saveRequests(groupId: thisGroup.groupId!, country: thisGroup.country!, locality: thisGroup.city!, text: requestTextField.text!, userName: User.currentUser.userName!, userUid: User.currentUser.uid!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch: UITouch? = touches.first
        
        if touch?.view != popupView{
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }

}
