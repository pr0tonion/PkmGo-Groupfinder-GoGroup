//
//  GroupDetailsVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 12.08.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

protocol UpdateGroupDetails {
    func updateView(newName: String)
    func updateGroupInfo()
}

class GroupDetailsVC: UIViewController, UITableViewDelegate,UITableViewDataSource, UpdateGroupDetails {

    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var UITeamName: UILabel!
    @IBOutlet weak var UITeamImg: UIImageView!
    @IBOutlet weak var navBarOutlet: UINavigationBar!
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatInputField: UITextField!
    
    var delegate: RefreshGroupsProtocol?
    var groupName: String? = nil
    var groupMotto: String? = nil
    var groupImg: UIImage? = nil
    var groupTeam: String? = nil
    var imageUrl: String? = nil
    var imageName: String? = nil
    var groupId: String!
    var groupAdmin: String!
    var updateTimer = Timer()
    var locationCache = LocationCache()
    
    
    var groupToSend = Group()
    
    let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")
    
    var chatMessages: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       prepareView()
        
        if Auth.auth().currentUser?.uid == groupAdmin{
            navBarItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.segueToGroupSettings))
            
            joinButton.isHidden = true
        }else{
        
            
            FirebaseHandler().isUserInGroup(groupId: groupId, uid: (Auth.auth().currentUser?.uid)!, country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation
                .locality!) { (result) in
                    
                    if result == true{
                        self.joinButton.isHidden = true
                        self.navBarItem.rightBarButtonItem = UIBarButtonItem(title: "Leave group", style: .done, target: self, action: #selector(self.leaveGroup))
                    }else{
                        
                        if self.groupToSend.groupType == .Open{
                            self.joinButton.setTitle("Join", for: .normal)
                        }
                        if self.groupToSend.groupType == .Invite{
                            self.joinButton.setTitle("Send invite", for: .normal)

                        }
                        
                        self.joinButton.isHidden = false
                    }
                    
            }
        }
        
        
        
        
        
        if groupImg != nil{
        UITeamImg.image = groupImg
        }else{
            if imageUrl != nil{
                getImage(Url: imageUrl!)
            }
        }
        
        
        updateChat(chatId: groupId)
        getGroupCount()
        
    }
    
    func getGroupCount(){
        FirebaseHandler().getGroupCount(groupId: groupId, country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation.locality!) { (count) in
            self.membersLabel.text = "Members: " + String(count)
        }
    }
    
    func prepareView(){
        
        chatTableView.register(UINib(nibName: "ChatCell",bundle: nil), forCellReuseIdentifier: "ChatCell")
        
        navBarItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(self.backBtn(_:)))
        navBarItem.title = ""
        navBarOutlet.setBackgroundImage(UIImage(), for: .default)
        navBarOutlet.shadowImage = UIImage()
        navBarOutlet.backgroundColor = .clear
        navBarOutlet.isTranslucent = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        UITeamName.text = groupName
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setBackground()
    }
    func setBackground(){
        
        switch groupTeam {
        case "Valor"?:
            
            let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
            backgroundImage.image = UIImage(named: "TeamValorBg")
            backgroundImage.contentMode =  UIViewContentMode.scaleAspectFill
            backgroundImage.alpha = 0.8
            self.view.insertSubview(backgroundImage, at: 0)
            
            break
        case "Instinct"?:
            
            let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
            backgroundImage.image = UIImage(named: "TeamInstinctBg")
            backgroundImage.contentMode =  UIViewContentMode.scaleAspectFill
            backgroundImage.alpha = 0.8
            self.view.insertSubview(backgroundImage, at: 0)
            
            break
            
        case "Mystic"?:
            
            let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
            backgroundImage.image = UIImage(named: "TeamMysticBg")
            backgroundImage.contentMode =  UIViewContentMode.scaleAspectFill
            backgroundImage.alpha = 0.8
            self.view.insertSubview(backgroundImage, at: 0)
            
            break
        default:
            self.view.backgroundColor = UIColor.black
        }
    }
    
    func updateView(newName: String) {
        UITeamName.text = newName
    }
    
    func updateGroupInfo() {
        getGroupCount()
    }
    
    func leaveGroup(){
        
        FirebaseHandler().deleteUserFromGroup(uid: (Auth.auth().currentUser?.uid)!, groupId: groupId, country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation.locality!)
        delegate?.refreshGroups()
        self.dismiss(animated: true, completion: nil)
    }
    
    func segueToGroupSettings(){
        
        performSegue(withIdentifier: "segueToSettings", sender: nil)
        
    }
    
    

    func getImage(Url:String){
        
        let storage = Storage.storage().reference().child("groupImages/" + groupToSend.imageName!)
        
        storage.getData(maxSize: 2*1024*1024, completion: { (data, error) in
            if error != nil{
                print(error?.localizedDescription)
            }else{
                let image: UIImage = UIImage(data: data!)!
                self.UITeamImg.image = image
            }
        })
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true) { 
            self.delegate?.refreshGroups()
        }
    }
    
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    func updateChat(chatId: String){
        let childRef = firDbRef.child("Locations").child(LocationCache.currentLocation.country! + "_" + LocationCache.currentLocation.locality!).child("Groups").child(groupId).child("Chat")
        
        
        childRef.observe(.childAdded, with: { (snapshot) in
        
            print(snapshot.value)
            
            if let dictionary = snapshot.value as? NSDictionary{
                let message = Message()
                
                message.from = dictionary["from"] as? String
                message.text = dictionary["text"] as? String
                self.chatMessages.append(message)
                
                let indexPath = NSIndexPath(row: self.chatMessages.count-1, section: 0)
                self.chatTableView.reloadData()
                self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                self.chatTableView.endUpdates()
                
            }
            
        }) { (error) in
            print(error)
        }
        
        
        
        
    }
    
    //TODO - Save user in group when finished
    
    //TODO - Dismiss keyboard
    //TODO - push chatTableview so that people can see what they are typing
    
    @IBAction func joinBtn(_ sender: Any) {
        
        if groupToSend.groupType == .Open{
            FirebaseHandler().saveUserInGroup(requestId: nil, uid: Auth.auth().currentUser!.uid, displayName: Auth.auth().currentUser!.displayName!, groupId: groupId, country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation.locality!, completion: {(answer) in
                
                if answer == true{
                    self.joinButton.isHidden = true
                    self.navBarItem.rightBarButtonItem = UIBarButtonItem(title: "Leave group", style: .done, target: self, action: #selector(self.leaveGroup))

                }else{
                    self.joinButton.setTitle("did not work", for: .normal)
                    
                }
            })
        }
        if groupToSend.groupType == .Invite{
            sendRequestPopup()
        }
    }
    
    @IBAction func inviteBtn(_ sender: Any) {
        
        performSegue(withIdentifier: "segueToInvites", sender: self)
        
    }
    
    func sendRequestPopup(){
        let popupSB = UIStoryboard(name: "PopupViews", bundle: nil).instantiateViewController(withIdentifier: "addRequestPopup") as! RequestPopupVC
        
        popupSB.thisGroup = groupToSend
        
        popupSB.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.present(popupSB, animated: true)
    }
    
    
    @IBAction func sendBtn(_ sender: Any) {
        
        let childRef = firDbRef.child("Locations").child(LocationCache.currentLocation.country! + "_" + LocationCache.currentLocation.locality!).child("Groups").child(groupId).child("Chat").childByAutoId()
        let values = ["from":User.currentUser.userName,
                      "text":chatInputField.text,
                      "timestamp": NSDate().timeIntervalSince1970] as [String : Any]
        
        childRef.updateChildValues(values)
        
        
        chatInputField.text = ""
        chatTableView.reloadData()
        
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSettings"{
            if let destVC = segue.destination as? AdminGroupControlsVC{
                destVC.delegate = self
                destVC.thisGroup = groupToSend
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        
        cell.chatText.text = chatMessages[indexPath.row].from! + ": " + chatMessages[indexPath.row].text!
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
   
}
