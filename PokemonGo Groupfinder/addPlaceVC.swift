//
//  addPlaceVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 20.09.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces

protocol sendingPkmLocation {
    func userDidAddPosition(marker: GMSMarker)
}

class addPlaceVC: UIViewController, GMSMapViewDelegate {

    
    @IBOutlet weak var gmsView: GMSMapView!
    let locationManager = CLLocationManager()
    var placesClient = GMSPlacesClient()
    var calloutMarker: GMSMarker?
    var delegate: sendingPkmLocation? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 20
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        gmsView.delegate = self
        placesClient = GMSPlacesClient.shared()
    }
    

    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true,completion: nil)
    }
    
    @IBAction func selectBtn(_ sender: Any) {
        
        if calloutMarker != nil {
            print(calloutMarker?.position.latitude)
            delegate?.userDidAddPosition(marker: calloutMarker!)
            dismiss(animated: true, completion: nil)
            
        }else{
            print("Select a marker position first")
        }
        
    }
    
}

//marker on tap

extension addPlaceVC: CLLocationManagerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 15.0)
        gmsView.camera = camera
        gmsView.animate(to: camera)
        
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            gmsView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            
            print("Location status is OK.")
            
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.gmsView.clear()
        let marker = GMSMarker(position: coordinate)
        calloutMarker = marker
        marker.map = self.gmsView
    }
    
}


    
