//
//  createGroupVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 30.08.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Firebase



class createGroupVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,adConfirmDelegate{

    @IBOutlet weak var navBarOutlet: UINavigationBar!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var groupActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var grpNameInput: UITextField!
    @IBOutlet weak var teamSelector: UISegmentedControl!
    @IBOutlet weak var grpImageView: UIImageView!
    @IBOutlet weak var groupTeamLabel: UILabel!
    @IBOutlet weak var groupTypeLabel: UILabel!
    @IBOutlet weak var groupTypeSegmentControls: UISegmentedControl!
    
    var delegate: RefreshGroupsProtocol?
    var values = [String: Any]()
    var adInterstitial: GADInterstitial!
    let imagePicker = UIImagePickerController()
    var imageToSend: UIImage? = nil
    var groupTeam = ""
    let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")
    let popupSB = UIStoryboard(name: "PopupViews", bundle: nil)
    var dbRef: DatabaseReference?
    let globalQueue = DispatchQueue.global()
    var groupType: String = "Open"
    var skipImg: Bool = false
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        navBarItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(self.backBtn(_:)))
        
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        dbRef = firDbRef.child("Locations").child(LocationCache.currentLocation.country! + "_" + LocationCache.currentLocation.locality!).child("Groups").childByAutoId()

        groupActivityIndicator.isHidden = true
        
       
        
       
        
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
    }
    
    
    @IBAction func teamSelectControls(_ sender: Any) {
        
        //If segmentControls are for team
        
        switch teamSelector.selectedSegmentIndex {
        case 0:
        groupTeam = "Valor"
        
        break
        case 1:
        groupTeam = "Instinct"
        break
        case 2:
        groupTeam = "Mystic"
        break
            
        default:
        
        break
        }
            //If segmentcontrols are for group type
        
    }
    
   
    
    
    @IBAction func groupTypeSegmentControls(_ sender: Any) {
        
        switch groupTypeSegmentControls.selectedSegmentIndex{
        case 0:
            groupType = "Open"
            break
        case 1:
            
            groupType = "Invite only"
            break
        default:
            break
        }

        
        
    }
    
    
    @IBAction func createGrpBtn(_ sender: Any) {
        checkInputAndCreateGroup()
    }
    
    func checkInputAndCreateGroup(){
        
        
        //Groupname check
        if grpNameInput.text == "" {
            //Alert pls enter name
            createAlert(title: "No group name given", text: "Please give your group a name", btnText: "OK")
            return
            
        }
        
        //Teamcheck
        if groupTeam == ""{
            //pls select team
            createAlert(title: "No team chosen for group", text: "Please select a group team above", btnText: "OK")
            return
        }
        
        //Grouptype check
        if groupType == ""{
            //Alert pls select grouptype, press X button
            createAlert(title: "No group type chosen", text: "Please select the type of group you wish to create. If you are on iphone 4 or 4s please click the X icon to switch to type option", btnText: "OK")
            return
        }
        
        //Image check
        if imageToSend == nil{
            //Pls select image, skip?
            let alert = UIAlertController(title: "No group image selected", message: "Please select a photo as your group photo, you can also skip this if you like", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                return
            } ))
            alert.addAction(UIAlertAction(title: "Skip", style: .default, handler: { (alertAction) in
                self.skipImg = true
                self.globalQueue.async {
                    self.handlegroupcreation()
                }
                
            }))
            self.present(alert,animated: true)
            return
        }        //self.view.isUserInteractionEnabled = false
        self.groupActivityIndicator.isHidden = false
        self.groupActivityIndicator.startAnimating()
        
        self.globalQueue.async {
            self.handlegroupcreation()
        }
        
        
        
    }
    
    
    func handlegroupcreation(){
        
       
        let imgName = NSUUID().uuidString
        let storage = Storage.storage().reference().child("groupImages/"+"\(imgName)")
        
        
        if skipImg == false{
        
        if let imageData = imageToSend!.jpeg(.medium){
            print("imagedata count:" + String(imageData.count))
            
            storage.putData(imageData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    print(error?.localizedDescription)
                }
                
                self.values = ["name": self.grpNameInput.text!,
                          "team":self.groupTeam,
                          "groupId":self.dbRef?.key,
                          "admin": User.currentUser.uid,
                          "imageName": imgName,
                          "groupType": self.groupType,
                          "city": LocationCache.currentLocation.locality,
                          "country":LocationCache.currentLocation.country]
                
                FirebaseHandler().saveUserInGroup(requestId: nil, uid: User.currentUser.uid!, displayName: (Auth.auth().currentUser?.displayName)!, groupId: (self.dbRef?.key)!, country: LocationCache.currentLocation.country!, locality: LocationCache.currentLocation.locality!, completion: { (result) in
                    
                })
                
                self.dbRef?.updateChildValues(self.values)
                self.groupActivityIndicator.stopAnimating()
                self.groupActivityIndicator.isHidden = true
                self.dismiss(animated: false, completion: nil)
            })
            
        }else{
          createAlert(title: "Could not make JPEG", text: "Was not able to create a JPEG, please choose another image", btnText: "OK")
        }
        }else{
            self.values = ["name": self.grpNameInput.text!,
                           "team":self.groupTeam,
                           "groupId":self.dbRef?.key,
                           "admin": User.currentUser.uid,
                           "groupType": self.groupType,
                           "city": LocationCache.currentLocation.locality,
                           "country":LocationCache.currentLocation.country]
            
            self.dbRef?.updateChildValues(self.values)
            self.groupActivityIndicator.stopAnimating()
            self.groupActivityIndicator.isHidden = true
            self.delegate?.refreshGroups()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func userAdResult(answer: Bool) {
        
        switch answer {
        case true:
            
            
            break
            
        case false:
            dismiss(animated: true, completion: nil)
            break
        }
        
    }
    
    func presentAdInterstitial(){
        if adInterstitial.isReady{
            adInterstitial.present(fromRootViewController: self)
        }else{
            presentAdInterstitial()
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraImgPicker(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func defaultImgPicker(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func createAlert(title: String, text: String, btnText: String ){
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: btnText, style: .default, handler: { (alertAction) in
        }))
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            grpImageView.contentMode = .scaleAspectFit
            grpImageView.image = pickedImage
            imageToSend = pickedImage
            dismiss(animated: true, completion: nil)
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat{
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data?{
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
}

