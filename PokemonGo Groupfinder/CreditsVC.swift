//
//  CreditsVC.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 19.12.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.
//

import UIKit

struct Creditors {
    var usage: String?
    var creator: String?
    var linkToPage: String?
    var image: UIImage?
}

class CreditsVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var creditTableView: UITableView!
    
    
    var creditsList = [Creditors]()
    var credit1: Creditors = Creditors()
    override func viewDidLoad() {
        super.viewDidLoad()

        credit1.linkToPage = "https://art.alphacoders.com/arts/view/89262"
        credit1.creator = "Robotkoboto"
        credit1.image = #imageLiteral(resourceName: "pkmGoBackground 2")
        credit1.usage = "Login background"
        
        creditsList.append(credit1)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can hhibe recreated.
    }
    //tags
    //1: Usage: Login
    //2: Created by:
    //3: linkTopage btn
    //4: Image
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = creditTableView.dequeueReusableCell(withIdentifier: "creditCell")
        let usageText = cell?.viewWithTag(1) as? UILabel
        let CreatedByText = cell?.viewWithTag(2) as? UILabel
        let linkPage = cell?.viewWithTag(3) as? UIButton
        let image = cell?.viewWithTag(4) as? UIImageView
        
        usageText?.text = "Usage: " + credit1.usage!
        CreatedByText?.text = "Created by: " + credit1.creator!
        image?.image = credit1.image
        
        
        
        return cell!
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
