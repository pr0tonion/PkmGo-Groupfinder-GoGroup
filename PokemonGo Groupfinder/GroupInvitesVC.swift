//
//  GroupInvitesVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 25.01.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit

class GroupInvitesVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var invitesTableView: UITableView!
    
    var inviteArray: [Invite] = []
    var locationCache = LocationCache()
    var thisGroup = Group()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let FirDbHandler = FirebaseHandler()
        
        
        let cache = NSCache<NSString, LocationCache>()
        
        if let cachedLocation = cache.object(forKey: "LocationCache"){
            
            locationCache = cachedLocation
            
            
        }

    
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inviteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = invitesTableView.dequeueReusableCell(withIdentifier: "groupInviteCell") as! InviteCell
        
        cell.imageLoader.startAnimating()
        cell.isHidden = false
        cell.userNameLabel.text = inviteArray[indexPath.row].sender
        cell.inviteText.text = inviteArray[indexPath.row].invText
        cell.inviteImage.image = inviteArray[indexPath.row].inviteImage
        cell.locationCache = locationCache
        
        
        
        return cell
        
    }

}


class InviteCell: UITableViewCell{
    
    
    @IBOutlet weak var inviteImage: UIImageView!
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var inviteText: UILabel!
    var userUid: String!
    var groupId: String!
    var thisGroup = Group()
    var locationCache = LocationCache()
    
    
    @IBAction func acceptBtn(_ sender: Any) {
        
        
        FirebaseHandler().getUser(uid: userUid) { (user) in
            
            FirebaseHandler().saveUserInGroup(requestId: nil, uid: self.userUid, displayName: user.userName!, groupId: self.thisGroup.groupId!, country: self.locationCache.country!, locality: self.locationCache.locality!) { (true) in
                //TODO - save groupid to the device
            }
        }
        
        
        
        
    }
    
    
    @IBAction func denyBtn(_ sender: Any) {
        
        FirebaseHandler().getUser(uid: userUid) { (user) in
            
            FirebaseHandler().saveUserInGroup(requestId: nil, uid: self.userUid, displayName: user.userName!, groupId: self.thisGroup.groupId!, country: self.locationCache.country!, locality: self.locationCache.locality!) { (false) in
                //TODO - save country to the device
            }
        }
        
    }
    
    
    
}
