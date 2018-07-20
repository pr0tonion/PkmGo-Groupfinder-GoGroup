//
//  GroupFinderVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 28.07.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Alamofire
import Firebase


protocol RefreshGroupsProtocol {
    func refreshGroups()
}

class GroupFinderVC: UIViewController, UITableViewDataSource, UITableViewDelegate, RefreshGroupsProtocol {

    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var groupsTableView: UITableView!
    let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")

    var groupImages: [UIImage] = []
    var groupsInArea: [Group] = []
    var imageChecker: UIImage?
    
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.createGroupBtn(_:)))
        navBarItem.title = "Groups in your area"
        retrieveGroups(location: LocationCache.currentLocation) {
            
        }
        
        self.groupsTableView.addSubview(refreshControl)
        
        
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        DispatchQueue.global(qos: .background).async {
            self.retrieveGroups(location: LocationCache.currentLocation) {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                
            }
        }
   

    }
    
    func refreshGroups() {
        DispatchQueue.main.async {
            self.refreshControl.beginRefreshing()
        }
        
        
    }
    
    func retrieveGroups(location: LocationCache, completion: @escaping ()->()){
    
        groupsInArea = []
        let groupsReference = firDbRef.child("Locations").child(LocationCache.currentLocation.country! + "_" + LocationCache.currentLocation.locality!).child("Groups")
        
        groupsReference.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? NSDictionary{
                
                let group = Group()
                group.groupId = snapshot.key
                
                if dictionary["imageName"] != nil{
                    group.imageName = dictionary["imageName"] as? String
                }
                group.name = dictionary["name"] as? String
                group.team = dictionary["team"] as? String
                group.admin = dictionary["admin"] as? String
                group.country = dictionary["country"] as? String
                group.city = dictionary["city"] as? String
                group.groupId = dictionary["groupId"] as? String
                
                if let groupType = dictionary["groupType"] as? String{
                    
                    switch groupType{
                    case "Open":
                        group.groupType = .Open
                        break
                    case "Invite only":
                        group.groupType = .Invite
                        break
                    default:
                        break
                    }
                    
                }
                
                self.groupsInArea.append(group)
                self.groupsTableView.reloadData()
                completion()
                
            }else{
                
            }
            
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
   
    }
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsInArea.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupsTableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
        var groupCount = 0;
        
        
        let group = groupsInArea[indexPath.row]
        
        cell.groupLoadingIndicator.startAnimating()
        cell.groupLoadingIndicator.isHidden = false
        cell.groupNameLabel.text = group.name
        
        if group.groupType == .Open{
            cell.statusLabel.text = "Open"
        }
        if group.groupType == .Invite{
            cell.statusLabel.text = "Invite only"

        }
        
        DispatchQueue.main.async {
            
            if group.groupId != nil{
            
                FirebaseHandler().getGroupCount(groupId: group.groupId!, country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation.locality!, completion: { (result) in
                    groupCount = result
                    cell.membersLabel.text = "Members: " + String(groupCount)
                })
            }else{
                cell.membersLabel.text = "Members: Not found"
            }
        }
        
        
        if let imageUrl = group.imageName{
            
            cell.groupLoadingIndicator.startAnimating()
            cell.groupLoadingIndicator.isHidden = false
            let storage = Storage.storage().reference().child("groupImages/" + group.imageName!)
            
            storage.getData(maxSize: 2*1024*1024, completion: { (data, error) in
                if error != nil{
                    print(error?.localizedDescription)
                }else{
                    let image: UIImage = UIImage(data: data!)!
                    
                    cell.groupImageView.image = image
                    self.groupImages.append(image)
                    cell.groupLoadingIndicator.stopAnimating()
                    cell.groupLoadingIndicator.isHidden = true
                }
            })
            
        }
        else{
            cell.groupImageView.image = #imageLiteral(resourceName: "Unknown")
            cell.groupLoadingIndicator.stopAnimating()
            cell.groupLoadingIndicator.isHidden = true
        }
        
        switch group.team {
        case "Valor"?:
            cell.backgroundView = UIImageView(image: UIImage(named: "ValorCellBg")!)
            break
        case "Instinct"?:
            cell.backgroundView = UIImageView(image: UIImage(named: "InstinctCellBg")!)

            break
        case "Mystic"?:
            cell.backgroundView = UIImageView(image: UIImage(named: "MysticCellBg")!)

            break
        default:
            break
        }
        
        return cell
        
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "segueToGroupDetails", sender: self)
    }
    
    @IBAction func createGroupBtn(_ sender: Any) {
        performSegue(withIdentifier: "segueToCreateGrp", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToGroupDetails"{
         let index = groupsTableView.indexPathForSelectedRow!
            if let destVC = segue.destination as? GroupDetailsVC{
                
                
                
                let group = groupsInArea[index.row]
                destVC.groupName = group.name
                destVC.groupMotto = group.motto
                destVC.groupId = group.groupId
                destVC.groupToSend = group
                destVC.groupAdmin = group.admin
                
                
                if let image = imageChecker{
                    destVC.groupImg = groupImages[index.row]
                }else{
                    destVC.imageUrl = group.imageName
                }
                
                destVC.groupTeam = group.team
                
                
            }
        }
        if segue.identifier == "segueToCreateGrp"{
            
            if let destVC = segue.destination as? createGroupVC{
                destVC.delegate = self
            }
            
        }
        if segue.identifier == "segueToGroupDetails"{
            if let destVC = segue.destination as? GroupDetailsVC{
                destVC.delegate = self
            }
        }

}
    
}





