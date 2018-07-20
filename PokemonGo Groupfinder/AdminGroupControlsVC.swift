//
//  AdminGroupControlsVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 06.06.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit


struct GroupRequest{
    let userUID: String!
    let userName: String!
    let groupId: String!
    let text: String!
    let requestId: String!
    let userTeam: String?
    
    
    init(userUid: String, userName: String, groupId: String, text: String, requestId: String, userTeam: String) {
        self.userUID = userUid
        self.userName = userName
        self.groupId = groupId
        self.text = text
        self.requestId = requestId
        self.userTeam = userTeam
    }
    
}

protocol adminSettingsProtocol{
    func updateLists(user: User?, request: GroupRequest?)
    
}

class AdminGroupControlsVC: UIViewController, adminSettingsProtocol {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var changeGroupNameOutlet: UITextField!
    @IBOutlet weak var changeBtnOutlet: UIButton!
    @IBOutlet weak var deleteGroupBtnOutlet: UIButton!
    @IBOutlet weak var tableViewSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var requestList: [GroupRequest] = []
    var memberList: [User] = []
    var thisGroup: Group!
    var delegate: UpdateGroupDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        
    }
    
    func prepareView(){
        
        changeGroupNameOutlet.text = thisGroup.name
        FirebaseHandler().getUsersInGroup(country: thisGroup.country!, groupId: thisGroup.groupId!, locality: thisGroup.city!) { (users) in
            self.memberList = users
            self.tableView.reloadData()
        }
        
        FirebaseHandler().getRequests(groupId: thisGroup.groupId!, country: thisGroup.country!, locality: thisGroup.city!) { (requests) in
            self.requestList = requests
            self.tableView.reloadData()
        }
        
        navBarItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(dismissVC))
        navBarItem.title = ""
    }

    @IBAction func changeBtn(_ sender: Any) {
        changeGroupNameOutlet.layer.borderColor = UIColor.clear.cgColor
        changeGroupNameOutlet.layer.borderWidth = 1
        
        if changeGroupNameOutlet.text != ""{
            
            FirebaseHandler().renameGroup(country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation.locality!, groupId: thisGroup.groupId!, newName: changeGroupNameOutlet.text!) { (didComplete) in
                
                if didComplete{
                    DispatchQueue.main.async {
                        self.changeGroupNameOutlet.layer.borderColor = UIColor.green.cgColor
                        self.delegate?.updateView(newName: self.changeGroupNameOutlet.text!)
                    }
                    
                    
                }else{
                    DispatchQueue.main.async {
                        self.changeGroupNameOutlet.layer.borderColor = UIColor.red.cgColor
                        
                    }
                    
                }
                
            }
            
            
        
        
        }else{
            
        }
    }
    
    @IBAction func deleteGroupBtn(_ sender: Any) {
        FirebaseHandler().deleteGroup(groupId: thisGroup.groupId!, country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation.locality!)
        
        self.dismiss(animated: true) {
            //delegate?
        }
        
    }
    
    func updateMembers(){
        
        memberList = []
        FirebaseHandler().getUsersInGroup(country: thisGroup.country!, groupId: thisGroup.groupId!, locality: thisGroup.city!) { (users) in
            self.memberList = []
            self.memberList = users
            self.tableView.reloadData()
        }
    }
    func updateRequests(){
        
        FirebaseHandler().getRequests(groupId: thisGroup.groupId!, country: thisGroup.country!, locality: thisGroup.city!) { (requests) in
            self.requestList = []
            self.requestList = requests
            self.tableView.reloadData()
        }
    }
    
    @IBAction func tableViewSegmentCtrls(_ sender: Any) {
        
        switch tableViewSegmentOutlet.selectedSegmentIndex {
        case 0:
            
            tableView.reloadData()
            break
            
        case 1:
            tableView.reloadData()
            break
        default:
            return
        }
        
    }
    
    func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AdminGroupControlsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableViewSegmentOutlet.selectedSegmentIndex {
        case 0:
            return requestList.count
            
            
        case 1:
            return memberList.count
            
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableViewSegmentOutlet.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell") as! GroupRequestCell
            //cell.group = thisGroup
            //cell.request = requestList[indexPath.row]
            cell.userNameOutlet.text = requestList[indexPath.row].userName
            cell.requestTextOutlet.text = requestList[indexPath.row].text
            //cell.delegate = self
            
            
            cell.acceptBtnOutlet.tag = indexPath.row
            cell.denyBtnOutlet.tag = indexPath.row
            cell.acceptBtnOutlet.addTarget(self, action: #selector(acceptOrDenyRequest(sender:)), for: UIControlEvents.touchUpInside)
            cell.denyBtnOutlet.addTarget(self, action: #selector(acceptOrDenyRequest(sender:)), for: UIControlEvents.touchUpInside)
            
            cell.selectionStyle = .none
            cell.acceptBtnOutlet.setTitle("Accept", for: .normal)
            cell.denyBtnOutlet.setTitle("Deny", for: .normal)
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! GroupMemberCell
            //cell.delegate = self
            //cell.group = thisGroup
            cell.userNameLabelOutlet.text = memberList[indexPath.row].userName
            cell.selectionStyle = .none
            cell.removeUserBtnOutlet.setTitle("Remove", for: .normal)
            
            cell.removeUserBtnOutlet.tag = indexPath.row
            cell.removeUserBtnOutlet.addTarget(self, action: #selector(acceptOrDenyRequest(sender:)), for: UIControlEvents.touchUpInside)
            
            
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    //Maybe use later
    func acceptOrDenyRequest(sender: UIButton){
        let indexPath = sender.tag
        if sender.currentTitle == "Deny"{
            //Deny
            let request: GroupRequest = requestList[indexPath]

            FirebaseHandler().removeRequest(groupId: thisGroup.groupId!, country: LocationCache.currentLocation.country!, locality:LocationCache.currentLocation.locality! , requestId: request.requestId!)
            
                updateLists(user: nil, request: request)
        }
        if sender.currentTitle == "Accept"{
            let request: GroupRequest = requestList[indexPath]
            FirebaseHandler().saveUserInGroup(requestId: request.requestId, uid: request.userUID, displayName: request.userName, groupId: request.groupId, country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation.locality!) { (success) in
                if success{
                    self.updateMembers()
                    self.updateLists(user: nil, request: request)
                }else{
                    
                }
                
            }
            
        }
        if sender.currentTitle == "Remove"{
            let memberUid: User = memberList[indexPath]
             FirebaseHandler().deleteUserFromGroup(uid:memberUid.uid! , groupId: thisGroup.groupId!, country:LocationCache.currentLocation.country! , locality: LocationCache.currentLocation.locality!)
            
            updateLists(user: memberUid, request: nil)
        }
        
        
    }
   
    func updateLists(user: User?, request: GroupRequest?){
        
        if user != nil{
            var counter = 0
            for i in memberList{
                
                if i.uid == user?.uid{
                    memberList.remove(at: counter)
                    
                }
                counter += 1
            }
            tableView.reloadData()
        }
        
        
        if request != nil{
           var counter = 0
            for i in requestList{
                
                if request?.requestId == i.requestId{
                    requestList.remove(at: counter)
                }
                counter += 1
            }
            tableView.reloadData()
        }
        
    }
    
    
}

class GroupRequestCell: UITableViewCell{
    
    @IBOutlet weak var denyBtnOutlet: UIButton!
    @IBOutlet weak var acceptBtnOutlet: UIButton!
    @IBOutlet weak var btnStackViewOutlet: UIStackView!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var requestTextOutlet: UILabel!
    
    //var request: GroupRequest!
    //var group: Group!
    //var delegate: adminSettingsProtocol!
    
    

    
    @IBAction func acceptBtn(_ sender: Any) {
        
        
        
    }
    @IBAction func denyBtn(_ sender: Any) {
       
    }
    
}

class GroupMemberCell: UITableViewCell{
    
    @IBOutlet weak var userNameLabelOutlet: UILabel!
    @IBOutlet weak var removeUserBtnOutlet: UIButton!
    
    //var user: User!
    //var group: Group!
    //var delegate: adminSettingsProtocol!
    
    @IBAction func removeUserBtn(_ sender: Any) {
       
        
        
    }
}
