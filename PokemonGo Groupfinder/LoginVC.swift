//
//  LoginVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 17.08.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    
    @IBOutlet weak var passwordInputField: UITextField!
    @IBOutlet weak var userInputField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // view.backgroundColor = UIColor(patternImage: UIImage(named: "pkmGoBackground 2")!)
        
        
        let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
    }
    
    @IBAction func logInBtn(_ sender: Any) {
        if (passwordInputField.text != "" && userInputField.text != ""){
          Auth.auth().signIn(withEmail: userInputField.text!, password: passwordInputField.text!, completion: { (user, error) in
            if error != nil{
            print(error)
                return
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let mainTbCtrl = storyBoard.instantiateViewController(withIdentifier: "mainTabBarController") as! MainNavigationBar
            self.present(mainTbCtrl, animated: true, completion: nil)
          })
            
        }
        
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        
    }
   
   
    

    

}
