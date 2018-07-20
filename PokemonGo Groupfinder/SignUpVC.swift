//
//  SignUpVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 17.08.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit

import Firebase

class SignUpVC: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   
    @IBOutlet weak var userPassInput: UITextField!
    @IBOutlet weak var userEmailInput: UITextField!
    @IBOutlet weak var userNameInput: UITextField!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userTeamSegmentCtrl: UISegmentedControl!
    @IBOutlet weak var userLevelInput: UITextField!
    
    var userImage: UIImage?
    let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")
    var userTeam: String? = nil
    let imagePicker = UIImagePickerController()
    var didPressSegment: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        self.userLevelInput.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
        
    }

    
    @IBAction func profilePicBtn(_ sender: Any) {
        
        let alert = UIAlertController(title: "Select image", message: "Choose image type", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: {(alertAction) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Photo library", style: UIAlertActionStyle.default, handler: { (alertAction) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    @IBAction func teamSegmentControls(_ sender: Any) {
        
        didPressSegment = true
        switch userTeamSegmentCtrl.selectedSegmentIndex {
        case 0:
            userTeam = "Valor"
            break
        case 1:
            userTeam = "Instinct"
            break
        case 2:
            userTeam = "Mystic"
            break
            
        default:
            
            break
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImageView.image = pickedImage
            userImage = pickedImage
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func SignUpBtn(_ sender: Any) {
        
        
        if(userLevelInput.text == ""){
            
            createAlert(title: "Userlevel not found", message: "Please fill out your pokemonGO level", buttonMsg: "OK")
            return
        }else{
            if(Int(userLevelInput.text!) == nil){
                createAlert(title: "Level is not a number", message: "Your level is not a number, please remove illegal characters", buttonMsg: "OK")
                return
            }
        }
        
        if(userNameInput.text == ""){
            createAlert(title: "Username not found", message: "Please fill out your username", buttonMsg: "OK")
            return
        }else{}
        
        if(userPassInput.text == ""){
            createAlert(title: "No password found", message: "Please fill in a password", buttonMsg: "OK")
            return
        }else{}
        
        
        if(didPressSegment == false){
            let alert = UIAlertController(title: "Did not select team", message: "This pops up if you did not select a team, the default team is set to valor. Are you a member of Valor?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(alertAction) in
                self.didPressSegment = true
                self.userTeam = "Valor"
                
                self.SignUpBtn(Any)
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {(alertAction) in
            return
            }))
            present(alert, animated: true)
            return
        }else{
            print("pressSegment is true")
        }
        
            Auth.auth().createUser(withEmail: userEmailInput.text!, password: userPassInput.text!) { (user, error) in
                if error != nil{
                    
                    self.createAlert(title: "Error", message:  (error?.localizedDescription)!, buttonMsg: "OK")
                }
                var team: String!
                guard let uid = user?.uid else{
                    return
                    
                }
                    team = self.userTeam
                
                guard let username = self.userNameInput.text, let email = self.userEmailInput.text, let level = self.userLevelInput.text else{
                    
                    
                    print("form not valid")
                    return
                }
                
                let userReferance = self.firDbRef.child("users").child(uid)
                let values = ["username": username,
                              "email": email,
                              "level": level,
                              "team":team,
                              "userLevel":0,
                              "trustLevel":0] as [String : Any]
                
                let user = Auth.auth().currentUser
                
                let request = user?.createProfileChangeRequest()
                
                request?.displayName = username
                
                request?.commitChanges(completion: { (error) in
                    if error != nil{
                        print(error!.localizedDescription)
                    }
                    
                    return
                })
                
                userReferance.updateChildValues(values, withCompletionBlock: { (error, dbReferance) in
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                    
                    if self.userImage != nil{
                        FirebaseHandler().saveUserImage(UID: (user?.uid)!, userImage: self.userImage!)
                    }
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTbCtrl = storyBoard.instantiateViewController(withIdentifier: "mainTabBarController") as! MainNavigationBar
                    self.present(mainTbCtrl, animated: true, completion: nil)
                })
        }
    }
    
    func createAlert(title: String, message: String, buttonMsg: String){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    alert.addAction(UIAlertAction(title: buttonMsg, style: UIAlertActionStyle.default, handler: {(alertAction) in
        
    }))
    present(alert, animated: true)
    }

}

