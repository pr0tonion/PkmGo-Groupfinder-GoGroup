//
//  inviteRequestTableViewVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 23.08.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Firebase

class inviteRequestTableViewVC: UITableViewController {
        
    let testUser = User()
    
    var requests: [Invite]!
    var groupId: String?
    let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return requests.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("RequestCell", owner: self, options: nil)?.first as! RequestCell
        cell.userNameLabel.text = requests[indexPath.row].sender
        cell.userTextLabel.text = requests[indexPath.row].invText
        cell.acceptBtn.tag = indexPath.row
        cell.denyBtn.tag = indexPath.row
        cell.acceptBtn.addTarget(self, action: #selector(accept), for: .touchUpInside)
        cell.denyBtn.addTarget(self, action: #selector(deny), for: .touchUpInside)
        return cell
    }
    

    func accept(){
        print("accepted")
    }
    func deny(){
        print("denied")
    }
    
    func getRequests(groupId: String){
        let requestRef = firDbRef.child("groupRequests").child(groupId)
        
        requestRef.observe(.childAdded, with: { (snapshot) in
            
            let invite = Invite()
            print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject]{
                invite.invText = dictionary["text"] as? String
                invite.sender = dictionary["sender"]as? String//uid
                invite.verdict = false
                
            }
            
            
        }) { (error) in
            print(error)
        }
    }
    
    
    
}
