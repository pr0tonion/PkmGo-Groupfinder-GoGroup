//
//  SettingsVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 15.12.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import FirebaseAuth
class SettingsVC: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    var creditList = ["Credits","Send feedback","Report problem"]
    let auth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
       
        // Do any additional setup after loading the view.
    }
    
    //TODO - Fix logout for users
    @IBAction func logOutBtn(_ sender: Any) {
       
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "LogOutSegue", sender: nil)
            }catch{
                print("couldnt log out")
            }
           
        }else{
            self.performSegue(withIdentifier: "LogOutSegue", sender: nil)
        }
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true) {
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: "settingsCell") as! UITableViewCell
        let settingsLabel = cell.viewWithTag(1) as? UILabel
        settingsLabel?.text = creditList[indexPath.row]
        return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            print(indexPath.row)
            performSegue(withIdentifier: "segueToCredits", sender: nil)
            break
        case 1:
            performSegue(withIdentifier: "segueToFeedBack", sender: nil)
            break
        case 2:
            present(ReportProblemVC(), animated: true, completion: nil)
            break
        default:
            print("Default")
        }
        
        
    }

}
