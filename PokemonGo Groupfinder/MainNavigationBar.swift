 //
//  MainNavigationBar.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 02.05.2018.
//  Copyright © 2018 Marcus Pedersen. All rights reserved.
//

import UIKit

class MainNavigationBar: UITabBarController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainSB = UIStoryboard(name: "Main", bundle: nil)

        var finderVC = MainViewController()
        var groupFinderVC = GroupFinderVC()
        var myProfileVC = MyProfileVC()
        var settingsVC = SettingsVC()
        
        finderVC.tabBarItem.title = "Finder"
        groupFinderVC.tabBarItem.title = "Groupfinder"
        myProfileVC.tabBarItem.title = "My profile"
        settingsVC.tabBarItem.title = "Settings"
        
        finderVC.tabBarItem.image = #imageLiteral(resourceName: "Pokeball simplistic")
        groupFinderVC.tabBarItem.image = #imageLiteral(resourceName: "add pokeball simplistic")
        myProfileVC.tabBarItem.image = #imageLiteral(resourceName: "userIconSmall")
        settingsVC.tabBarItem.image = #imageLiteral(resourceName: "settingsIcon")
        
        finderVC = mainSB.instantiateViewController(withIdentifier: "mainVC") as! MainViewController
        groupFinderVC = mainSB.instantiateViewController(withIdentifier: "groupFinderVC") as! GroupFinderVC
        myProfileVC = mainSB.instantiateViewController(withIdentifier: "myProfileVC") as! MyProfileVC
        settingsVC = mainSB.instantiateViewController(withIdentifier: "settingsVC") as! SettingsVC
        
        finderVC.locationManager.startUpdatingLocation()
        
        viewControllers = [finderVC,groupFinderVC,myProfileVC,settingsVC]
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
