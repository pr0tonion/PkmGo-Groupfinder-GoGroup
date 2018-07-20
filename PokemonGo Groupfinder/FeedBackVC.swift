//
//  FeedBackVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 19.12.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Firebase

class FeedBackVC: UIViewController {

    @IBOutlet weak var feedBackTextView: UITextView!
    
    let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func sendFeedBackBtn(_ sender: Any) {
        
        if feedBackTextView.text != ""{
        
        let feedBackRef = firDbRef.child("feedback").childByAutoId()
        let timeStamp = NSDate().timeIntervalSince1970

        
        let values = ["useruid": Auth.auth().currentUser?.uid,
                      "text": feedBackTextView.text,
                      "username": User.currentUser.userName,
                      "timestamp": timeStamp] as [String : Any]
        feedBackRef.updateChildValues(values)
            dismiss(animated: true, completion:nil)
            
        }else{
            let alert = UIAlertController(title: "No text to send", message: "Please write something :)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        }
        
    }
    

}
