//
//  FirebaseHandler.swift
//  PokemonGo Groupfinder
//
//  Created by Marcus Pedersen on 06.12.2017.
//  Copyright © 2017 Marcus Pedersen. All rights reserved.

import UIKit
import Firebase


class FirebaseHandler: NSObject {

    
    let firDbRef = Database.database().reference(fromURL: "")
    let storageRef = Storage.storage().reference()
    
    //Evaluate callout function
    func calloutEval(eval: Bool, calloutID: String, country: String, city: String, uid: String){
        
        let callLocation: String = country + "_" + city
        print(callLocation)
        
        //Good callout
        if (eval == true){
            
            //Write to DB that this callout was true
            let calloutRef = firDbRef.child("Locations").child(callLocation).child("Callouts").child(calloutID)
            
            calloutRef.runTransactionBlock({ (currentData) -> TransactionResult in
            
                
                if var callout = currentData.value as? [String: Any]{
                    
                    
                    var validation = callout["validation"] as? Int ?? 0
                    
                    if validation >= 10{
                        var trustLevel = callout["trustLevel"] as? Int ?? 0
                        trustLevel += 1
                        callout["trustLevel"] = trustLevel as Int
                        validation = 0
                    }else{
                        validation += 1
                        callout["validation"] = validation as Int
                    }
                    
                    var validationRegister: [String:Bool]
                    validationRegister = [Auth.auth().currentUser!.uid : true]
                    
                    let registerRef = calloutRef.child("validRegister")
                    //registerRef.updateChildValues(validationRegister)
                    
                    currentData.value = callout
                    
                    self.giveUserLevel(uid: uid, giveOrRemove: true)
                    return TransactionResult.success(withValue: currentData)
                }
                
                return TransactionResult.abort()
            }, andCompletionBlock: { (error, result, snapshot) in
                if let error = error{
                    print(error.localizedDescription)
                }
            })
            
           
        }else{
            let calloutRef = firDbRef.child("Locations").child(callLocation).child("Callouts").child(calloutID)
            
            calloutRef.runTransactionBlock({ (currentData) -> TransactionResult in
                
                if var callout = currentData.value as? [String: AnyObject]{
                    var validation = callout["validation"] as? Int ?? 0
                    
                    validation -= 1
                    
                    callout["validation"] = validation as AnyObject
                    
                    currentData.value = callout
                    self.giveUserLevel(uid: uid, giveOrRemove: false)
                    return TransactionResult.success(withValue: currentData)
                }
                
                
                return TransactionResult.success(withValue: currentData)
            }, andCompletionBlock: { (error, result, snapshot) in
                if let error = error{
                    print(error.localizedDescription)
                }
            })
            
        }
    }
    
    func updateCallout(oldCallout: Callout, newCallout: Callout ){
        let calloutRef = firDbRef.child("Locations").child(LocationCache.currentLocation.country! + "_" + LocationCache.currentLocation.locality!).child("Callouts").child(oldCallout.calloutId!)
        
        calloutRef.runTransactionBlock { (currentData) -> TransactionResult in
            
            var type: String!
            
            switch newCallout.type {
            case .Raid:
                type = "Raid"
                break
            case .Nest:
                type = "Nest"
                break
            case .Pkm:
                type = "Pokemon"
                break
            case .Egg:
                type = "Egg"
                break
                
            default:
                break
                
            }
            
            
            if var dict = currentData.value as? [String: Any]{
                
                dict["pokemonid"] = newCallout.pokemonId
                dict["pokemonName"] = newCallout.pokemonName
                dict["lat"] = newCallout.marker?.position.latitude
                dict["lon"] = newCallout.marker?.position.longitude
                dict["CP"] = newCallout.cp
                dict["timeLeft"] = newCallout.timeLeft
                dict["validation"] = 0
                dict["Type"] = type
                dict["createdBy"] = Auth.auth().currentUser?.displayName
                dict["UID"] = Auth.auth().currentUser?.uid
                
                currentData.value = dict
                return TransactionResult.success(withValue: currentData)
                
            }
            
            return TransactionResult.abort()
            
        }
    }
    
    func saveCallout(callSend: Callout){
    
        let calloutRef = firDbRef.child("Locations").child(LocationCache.currentLocation.country! + "_" + LocationCache.currentLocation.locality!).child("Callouts").childByAutoId()
        
        var type: String!
        
        switch callSend.type {
        case .Raid:
            type = "Raid"
            break
        case .Nest:
            type = "Nest"
            break
        case .Pkm:
             type = "Pokemon"
            break
        case .Egg:
            type = "Egg"
            break
        
        default:
            break
            
        }
        if callSend.pokemonId == 0{
            //Egg
            let values = ["pokemonid": callSend.pokemonId,
                          "pokemonName":"Egg",
                          "Egglevel":Int(callSend.eggLevel!),
                          "lat": callSend.marker?.position.latitude,
                          "lon": callSend.marker?.position.longitude,
                          "CP": callSend.cp,
                          "timeLeft": callSend.timeLeft,
                          "Type": type,
                          "createdBy": Auth.auth().currentUser?.displayName,
                          "UID": Auth.auth().currentUser?.uid,
                          "trustLevel":0,
                          "validation": 0] as [String : Any]
            
            calloutRef.updateChildValues(values)
        }else{
            let values = ["pokemonid": callSend.pokemonId,
                          "pokemonName":callSend.pokemonName,
                          "lat": callSend.marker?.position.latitude,
                          "lon": callSend.marker?.position.longitude,
                          "CP": callSend.cp,
                          "timeLeft": callSend.timeLeft,
                          "Type": type,
                          "createdBy": Auth.auth().currentUser?.displayName,
                          "UID": Auth.auth().currentUser?.uid,
                          "trustLevel":0,
                          "validation":0] as [String : Any]
            
            calloutRef.updateChildValues(values)
        }
        
        
    }
    
    func giveUserLevel(uid: String, giveOrRemove: Bool){
        
        if giveOrRemove == true{
            
            let usersRef = firDbRef.child("users").child(uid)
        usersRef.runTransactionBlock({ (currentData) -> TransactionResult in
           
            if var user = currentData.value as? [String: Any]{
                
                
                var rank = user["userLevel"] as? Int ?? 0
                var trustLevel = user["trustLevel"] as? Int ?? 0
                
                if rank >= 10{
                    user["userLevel"] = 0
                    user["trustLevel"] = trustLevel += 1
                }else{
                  rank += 1
                    user["userLevel"] = rank
                }
            
                currentData.value = user
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.abort()
            
        }) { (error, result, snapshot) in
            if let error = error{
            print(error.localizedDescription)
            }
            
        }
        }else{
            let usersRef = firDbRef.child("users").child(uid)
            
            usersRef.runTransactionBlock({ (currentData) -> TransactionResult in
                
                print(currentData.value)
                
                if var user = currentData.value as? [String: AnyObject]{
                    
                    var rank = user["userLevel"] as? Int ?? 0
                    
                    rank -= 1
                    
                    user["userLevel"] = rank as AnyObject
                    
                }
                return TransactionResult.success(withValue: currentData)
                
            }) { (error, result, snapshot) in
                if let error = error{
                    print(error.localizedDescription)
                }
                
            }
            
            
        }
      
    }
    
    
    
    //Returns user
    func getUser(uid:String, completion: @escaping (User) -> ()){
        let usersRef = firDbRef.child("users").child(uid)
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject]{
                
                
                let user = User()
                user.uid = snapshot.key
                user.email = dictionary["email"] as? String
                user.team = dictionary["team"] as? String
                user.userName = dictionary["username"] as? String
                user.userLevel = dictionary["userLevel"] as? Int
                user.trustLevel = dictionary["trustLevel"] as? Int
                
                completion(user)
                
            }
            
        }) { (error) in
            print(error)
        }
        
        
    }
    
    //Returns a list of all groups in area
    func getAllGroupsInArea(country: String, city: String, completion: @escaping ([Group])->()){
        let groupsReference = firDbRef.child("Locations").child(country + "_" + city).child("Groups")
        var groupList = [Group]()
        
        
        groupsReference.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String]{
                print(snapshot)
                let group = Group()
                group.groupId = snapshot.key
                group.imageName = dictionary["imageName"]!
                group.name = dictionary["name"]!
                group.team = dictionary["team"]
                group.motto = dictionary["motto"]
                
                groupList.append(group)
                
            }
            
            
            
        }) { (error) in
            print(error)
        }
        completion(groupList)
    }
    
    
    //Return count of specific group
    func getGroupCount(groupId: String,country: String,locality: String,completion: @escaping (Int)->()){
        
        let userInGroupRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId).child("Users")
    
        
        
        userInGroupRef.observeSingleEvent(of: .value, with: { (snapShot) in
           
            completion(Int(snapShot.childrenCount))
            
        }) { (error) in
            print(error.localizedDescription)
            completion(0)
        }
        
    }
    
    
    
    func getUsersInGroup(country:String, groupId: String, locality: String, completion: @escaping ([User]) -> ()){
    
        let userInGroupRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId).child("Users")
        var usersInGroup = [User]()
        
        
        userInGroupRef.observeSingleEvent(of: .value, with: { (snapShot) in
            
            for user in snapShot.children.allObjects as! [DataSnapshot]{
                let thisUser = User()
                
                let userInfo = user.value as? NSDictionary
                
                thisUser.userName = userInfo!["userName"] as? String
                thisUser.uid = userInfo!["userId"] as? String
                usersInGroup.append(thisUser)
                
            }
            
            
            completion(usersInGroup)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    
    }
    
    //Checks if user is in group and returns a boolean
    func isUserInGroup(groupId: String,uid: String, country: String, locality: String, completion: @escaping (Bool) ->()){
    
        let ref = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId).child("Users").child((Auth.auth().currentUser?.uid)!)
        
        ref.observeSingleEvent(of: .value, with: { (snapShot) in
            print(snapShot.value)
            
            if snapShot.exists(){
               print(snapShot.value)
                completion(true)
            }else{
                completion(false)
            }
           
        }) { (error) in
            print(error.localizedDescription)
            completion(false)
        }
        
        
    }
    
    
    //Saves user in a group
    func saveUserInGroup(requestId: String?,uid: String,displayName: String,groupId: String,country: String, locality: String,completion: @escaping (Bool)->()){
        let userInGroupRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId).child("Users")
        
        let groupRef = userInGroupRef.child(uid)
        
        if let values: [String: Any] = ["userId":uid,
                                        "timeStamp": NSDate().timeIntervalSince1970,
                                        "userName":displayName]{
            groupRef.updateChildValues(values)
            if requestId != nil{
                removeRequest(groupId: groupId, country: country, locality: locality, requestId: requestId!)
            }
            completion(true)
        }else{
            completion(false)
        }
        
        
    }
    
    
    
    
    //Deletes user from a specific group
    func deleteUserFromGroup(uid: String, groupId: String,country: String,locality: String){
        let userGroupRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId).child("Users")
        
        let groupRef = userGroupRef.child(uid)
        
        groupRef.removeValue()
        
    }
    
    //Saves a new image to a user
    func saveUserImage(UID: String, userImage: UIImage){
        
        let t = storageRef.child("userProfileImages/\(UID).png")
        
        if let imageData = UIImagePNGRepresentation(userImage){
            
            t.putData(imageData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    print(error)
                }
                print("image saved")
                
            })
            
        }else{
            print("image not saved")
        }
        
    }
    
    func renameGroup(country: String, locality: String, groupId: String, newName: String, completion: @escaping (Bool)->()){
        let groupRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId)
        
        groupRef.runTransactionBlock({ (currentData) -> TransactionResult in
           
            
            if var group = currentData.value as? [String: Any]{
                
                group["name"] = newName
                currentData.value = group
                completion(true)
                return TransactionResult.success(withValue: currentData)
            }
            completion(false)
            return TransactionResult.success(withValue: currentData)
        }) { (error, didWork, snapShot) in
            if let error = error{
                completion(false)
                print(error.localizedDescription)
            }
        }
       
    }
    
    func deleteGroup(groupId: String, country: String, locality: String){
        
        let groupRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId)
        
        groupRef.removeValue { (error, dbRef) in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            print("Deleted group: " + groupId)
        }
    }
    
    func removeRequest(groupId: String, country: String, locality: String, requestId: String){
        let requestsRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId).child("Requests").child(requestId)
        
        requestsRef.removeValue()
    }
    
    func getRequests(groupId: String, country: String, locality: String, completion: @escaping ([GroupRequest])->()){
        
        var requestList: [GroupRequest] = []
        let requestsRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId).child("Requests")
        
        requestsRef.observeSingleEvent(of: .value, with: { (snapShot) in
            
            for request in snapShot.children.allObjects as! [DataSnapshot]{
                
                if let requestInfo = request.value as? NSDictionary{
                
                let object = GroupRequest(userUid: requestInfo["userUid"] as! String,
                                          userName: requestInfo["userName"] as! String,
                                          groupId: groupId,
                                          text: requestInfo["text"] as! String,
                                          requestId: request.key,
                                          userTeam: requestInfo["team"] as! String)
                requestList.append(object)
                }
            }
            completion(requestList)
                
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
    }
    
    func saveRequests(groupId: String, country: String, locality: String, text: String, userName: String, userUid: String){
        let requestsRef = firDbRef.child("Locations").child(country + "_" + locality).child("Groups").child(groupId).child("Requests").childByAutoId()
        
        let values: [String: Any] = [
            "userUid": userUid,
            "userName": userName,
            "team":User.currentUser.team,
            "text": text,
            "timeStamp": NSDate().timeIntervalSince1970]
        
        requestsRef.updateChildValues(values)

    }
    
}
