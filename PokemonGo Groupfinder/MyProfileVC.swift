

import UIKit
import Firebase



class MyProfileVC: UIViewController{

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLevel: UILabel!
    @IBOutlet weak var userTeam: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        let user = Auth.auth().currentUser
        
        profilePic.image = #imageLiteral(resourceName: "TeamInstinctLogo")
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.alpha = 0.8
        
        switch User.currentUser.team {
        case "Mystic"?:
            backgroundImage.image = #imageLiteral(resourceName: "TeamMysticBg")
            self.view.insertSubview(backgroundImage, at: 0)
            
            break
        case"Valor"?:
            backgroundImage.image = #imageLiteral(resourceName: "TeamValorBg")
            self.view.insertSubview(backgroundImage, at: 0)
            break
        case"Instinct"?:
            backgroundImage.image = #imageLiteral(resourceName: "TeamInstinctBg")
            self.view.insertSubview(backgroundImage, at: 0)
            break
        default:
            
            break
            
        }
        
        userTeam.text = "Team Valor"
        userName.text = user?.displayName
        userLevel.text = "Trust level: " + "22"
        
        
        
        }
    
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back" {
            
        }
    }
    
    
    
}
    









