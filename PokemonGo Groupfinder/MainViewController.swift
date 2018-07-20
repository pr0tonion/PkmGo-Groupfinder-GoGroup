//
//  MainViewController.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 02.08.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import MapKit
import GoogleMobileAds



class MainViewController: UIViewController, GADBannerViewDelegate,updateMainCallouts {

    @IBOutlet weak var chatBtnOutlet: UIButton!
    @IBOutlet var chatView: UIView!
    @IBOutlet weak var gMapsView: GMSMapView!
    
    @IBOutlet weak var addCalloutOutlet: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatInputField: UITextField!
    
    @IBOutlet weak var adWordsBanner: GADBannerView!
    
    //Constraint outlets
    @IBOutlet weak var chatBtnBtmCons: NSLayoutConstraint!
    
    var tappedMarker: GMSMarker?
    let geoCoder = GMSGeocoder()
    let mainSB = UIStoryboard(name: "Main", bundle: nil)
    let popupSB = UIStoryboard(name: "PopupViews", bundle: nil)
    var chatActive: Bool = false
    let cache = NSCache<NSString, LocationCache>()
    var locationData: LocationCache?
    var didFindLocation: Bool = false {
        didSet{
            UpdateChat(locCache: LocationCache.currentLocation)
            getCallouts(locCache: LocationCache.currentLocation)

        }
    }
    
    
        //FirebaseHandler().calloutEval(eval: true, calloutID: "-L1TX0SStmSvlqulNDhD", country: "United States", city: "San Francisco")
    
    
    
    lazy var mapView = GMSMapView()
    var locationManager = CLLocationManager()
    
    var localchatData: [LocationMessage] = []
    var localMarkers: [GMSMarker] = []
    var localCallouts: [Callout] = []
    
    var pkmApiHandler: PokeAPIHandler!
    var updateTimer = Timer()
    let updateDelay = 5.0
    let firDbRef = Database.database().reference(fromURL: "https://pokemongo-groupfinder.firebaseio.com/")
    var mainStoryBoard: UIStoryboard? = nil
    let startUpQueue = DispatchQueue(label: "startUpQueue")

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        pkmApiHandler = PokeAPIHandler()
        //getCurrentUser(uid: Auth.auth().currentUser!.uid)
        
        //GOOGLE MAPS
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 20
        locationManager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        gMapsView.delegate = self
        gMapsView.isMyLocationEnabled = true
        
        addCalloutOutlet.isHidden = true
        
        //Height placement
        self.chatView.frame.origin.y = (view.frame.maxY) - self.tabBarController!.tabBar.frame.height
        //Width placement
        chatView.frame.size.width = view.frame.width
        
        chatBtnOutlet.layer.cornerRadius = 100
        addCalloutOutlet.layer.cornerRadius = 100
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
        chatTableView.register(UINib(nibName: "ChatCell",bundle: nil), forCellReuseIdentifier: "ChatCell")
         let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.presentBlockOptions(sender:)))
        chatTableView.addGestureRecognizer(longPress)
        
        loadAdBanner()
        
    }
    
    @IBAction func chatBtn(_ sender: Any) {
        
        if chatActive == false{
            //Push view up
            view.addSubview(chatView)
            UIView.animate(withDuration: 0.5, animations: {
                self.chatView.frame.origin.y = (self.view.frame.maxY - self.chatView.frame.height) - self.tabBarController!.tabBar.frame.height
                
                //self.addCalloutOutlet.frame.origin.y -= self.chatView.frame.height
                self.chatBtnBtmCons.constant += self.chatView.frame.height
                self.view.layoutIfNeeded()
                
                self.chatActive = true
            }) { (true) in
                print("Chat opened")
                
            }
        }else{
            //Push view down
            UIView.animate(withDuration: 0.5, animations: {
                self.chatView.frame.origin.y += self.view.frame.maxY
                
                self.chatBtnBtmCons.constant -= self.chatView.frame.height
                self.view.layoutIfNeeded()
                
                self.chatActive = false
            }) { (true) in
                print("Chat closed")
                self.chatView.removeFromSuperview()
            }
        }
        
    }
    
    func loadAdBanner(){
        adWordsBanner.adUnitID = "ca-app-pub-8402441429963926/5940607539"
        adWordsBanner.rootViewController = self
        adWordsBanner.delegate = self
        adWordsBanner.load(GADRequest())
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let destination = segue.destination as? calloutVC{
            destination.delegate = self
        }
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("didrecive")
    }
    
    //////Chat
    
    

    
    
    func updateCallouts(){
        print("Updating callouts...")
        let timeNow = Date().timeIntervalSince1970
        gMapsView.clear()
        var i: Int = 0
        
        
        for callout in localCallouts{
            
            let lat: Double = callout.latitude
            let lon: Double = callout.longditude!
            let pos = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: pos)
            
            if timeNow < callout.timeLeft! && callout.type != .Egg{
                
                if callout.pkmSprite == nil{
                
                    pkmApiHandler.getPkmSprite(id: callout.pokemonId!, finished: { (sprite) in
                        
                        callout.pkmSprite = sprite
                        marker.icon = sprite
                        marker.map = self.gMapsView
                        return
                        
                    })
                }else{
                    marker.icon = callout.pkmSprite
                    marker.map = self.gMapsView
                    return
                }
               return
            }
            
            if timeNow < callout.timeLeft! + 1800 && callout.type == .Egg{
                
                let eggLevel = callout.eggLevel!
                
                if eggLevel <= 2{
                    callout.pkmSprite = resizeImage(image: #imageLiteral(resourceName: "PkmNormalEgg"), targetSize: CGSize(width: 50, height: 50))
                    
                }
                
                if eggLevel > 2{
                    
                    callout.pkmSprite = resizeImage(image: #imageLiteral(resourceName: "PkmRareEgg"), targetSize: CGSize(width: 50, height: 50))
                }
                if eggLevel == 5{
                    
                    callout.pkmSprite = resizeImage(image: #imageLiteral(resourceName: "Pokemon-GO-Legendary-Egg"), targetSize: CGSize(width: 50, height: 50))
                }
                
                marker.icon = callout.pkmSprite
                marker.map = self.gMapsView
                
            }else{
                localCallouts.remove(at: i)
            }
            
            i += 1
        }
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func getCallouts(locCache: LocationCache){
        let calloutRef = firDbRef.child("Locations").child(locCache.country! + "_" + locCache.locality!).child("Callouts")
        let timeNow = Date().timeIntervalSince1970
        
        //var updateChecker: Timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateCallouts), userInfo: nil, repeats: true)
        calloutRef.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as?[String: AnyObject]{
                let callout = Callout()
                print(dictionary["Type"])
                if let type = dictionary["Type"] as? String{
                    
                    switch type{
                    case "Raid":
                        callout.type = .Raid
                        break
                    case "Nest":
                        callout.type = .Nest
                        break
                    case "Pokemon":
                        callout.type = .Pkm
                        break
                    case "Egg":
                        callout.type = .Egg
                        break
                    default:
                        break
                    }
                    
                }
                
                if let eggLevel = dictionary["Egglevel"] as? Int{
                    callout.eggLevel = eggLevel
                }
                
                callout.cp = dictionary["CP"] as? Int
                callout.pokemonId = dictionary["pokemonid"] as? Int
                callout.pokemonName = dictionary["pokemonName"] as? String
                callout.timeStamp = dictionary["timestamp"] as? Double
                callout.latitude = dictionary["lat"] as? Double
                callout.longditude = dictionary["lon"] as? Double
                callout.createdBy = dictionary["createdBy"] as? String
                callout.timeLeft = dictionary["timeLeft"] as? Double
                callout.userUid = dictionary["UID"] as? String
                callout.trustLevel = dictionary["trustLevel"] as! Int
                callout.validation = dictionary["validation"] as! Int
                callout.calloutId = snapshot.key
                
                var pos = CLLocationCoordinate2DMake(callout.latitude, callout.longditude!)
                callout.marker = GMSMarker(position: pos)
                
                
                if(timeNow < callout.timeLeft!){
                    self.localCallouts.append(callout)
                    self.updateCallouts()
                }else{
                    if callout.type == .Egg && callout.timeLeft! < callout.timeLeft! + 1800000{
                        self.localCallouts.append(callout)
                        self.updateCallouts()
                    }
                }
            }
            
        })
            
        { (error) in
            print(error)
        }
        
    }
    
 
    
    
    func UpdateChat(locCache: LocationCache){
        
        localchatData = []
        locationManager.stopUpdatingLocation()
        let cityReferance = self.firDbRef.child("Locations").child(LocationCache.currentLocation.country! + "_" + LocationCache.currentLocation.locality!).child("Chat")
        var finalDictionary: [String: AnyObject] = [:]
        
        cityReferance.observe(.childAdded, with: { (snapshot) in
            print(snapshot.children)
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = LocationMessage()
                
                message.from = dictionary["username"] as? String
                message.text = dictionary["text"] as? String
                message.team = dictionary["team"] as? String
                
                self.localchatData.append(message)
                
                if self.localchatData.count > 0{
                let indexPath = NSIndexPath(row: self.localchatData.count-1, section: 0)
                self.chatTableView.reloadData()
                self.chatTableView.endUpdates()
                self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            }
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    //TODO - Create timer every 1 minutes and go through every callout and delete the ones with timeleft< timenow
    
    
    
    @IBAction func SendBtn(_ sender: Any) {
        
        var finalDictionary: [String: String] = [:]
        let cityReferance = self.firDbRef.child("Locations").child(LocationCache.currentLocation.country! + "_" + LocationCache.currentLocation.locality!).child("Chat")
        let messageRef = cityReferance.childByAutoId()
        let timeStamp = NSDate().timeIntervalSince1970
        let message = LocationMessage()
        if chatInputField.text == ""{
        return
        }
        if (User.currentUser.userName != nil){
            
            let values = ["useruid": Auth.auth().currentUser?.uid,
                      "text": chatInputField.text!,
                      "team":User.currentUser.team!,
                      "username": User.currentUser.userName!,
                      "timestamp": timeStamp] as [String : Any]
            
            
            message.from = values["useruid"] as! String
            message.text = chatInputField.text
            messageRef.updateChildValues(values)
        }else{
            print("userName not found")
        }
      
        chatInputField.text = ""
        chatTableView.reloadData()
        chatTableView.endUpdates()
        
        self.view.endEditing(true)
        
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
   
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
 
   
 
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print(self.view.frame.origin.y)
            
            if self.view.frame.origin.y == 20{
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
    
   
    @objc func presentBlockOptions(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: chatTableView)
            if let indexPath = chatTableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                print(indexPath)
            }
        }
        
    }
    
}


extension MainViewController: UITableViewDelegate,UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        
        let chatText = localchatData[indexPath.row].text
        let un = localchatData[indexPath.row].from
        switch localchatData[indexPath.row].team {
        case "Valor":
            cell.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.2156862745, blue: 0.1921568627, alpha: 1)
            break
        case "Instinct":
            cell.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.8274509804, blue: 0.2901960784, alpha: 1)
            break
        case "Mystic":
            cell.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.3725490196, blue: 0.862745098, alpha: 1)
            break
        default:
            
            break
            
        }
        
        cell.chatText.text = un! + ": " + chatText!
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return localchatData.count
        
    }
    
    
    
}


extension MainViewController: CLLocationManagerDelegate,GMSMapViewDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let geoCoder = GMSGeocoder()
        
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 14.0)
        gMapsView.camera = camera
        gMapsView.animate(to: camera)
        
        
        geoCoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            
            if let country = response?.firstResult()?.country{
                //Midlertidig
                LocationCache.currentLocation.country = country
                LocationCache.currentLocation.locality = response?.firstResult()?.locality
                if self.didFindLocation != true{
                    self.didFindLocation = true
                    
                }
                
            }
            else{print("No country found")}
        }

    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        
        marker.position = coordinate
        marker.map = gMapsView
        
        let popupSB = UIStoryboard(name: "PopupViews", bundle: nil).instantiateViewController(withIdentifier: "calloutSelector") as! selectCalloutTypePopupVC
        popupSB.delegate = self
        popupSB.marker = marker
        
        tappedMarker = marker
        
        
        popupSB.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.present(popupSB, animated: false) {
            
        }
       
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        var calloutPopup = popupSB.instantiateViewController(withIdentifier: "CalloutPopup") as! CalloutPopupVC
        print(localCallouts.count)
        
        for i in localCallouts{
            if i.latitude == marker.position.latitude && i.longditude == marker.position.longitude{
                
               calloutPopup.callout = i
                
                self.addChildViewController(calloutPopup)
                calloutPopup.view.frame = self.view.frame
                self.view.addSubview(calloutPopup.view)
                calloutPopup.didMove(toParentViewController: self)
                return true
            }else{
                print("Marker not found")
            }
        }
        
        return false
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            
            print("Location status is OK.")
            
        }
    }
    
}

extension MainViewController: CalloutTypeDelegate{
    func removeMarker() {
        tappedMarker?.map = nil
        
        
    }
    
    
    
    
}


