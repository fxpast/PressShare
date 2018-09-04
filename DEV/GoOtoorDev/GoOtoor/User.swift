//
//  User.swift
//  GoOtoor
//
// Description : User account with physical adresse and geolocalization
//
//  Created by MacbookPRV on 09/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



import Foundation


struct User {
    
   
    
     var user_adresse: String
     var user_codepostal: String
     var user_date: Date
     var user_email: String
     var user_id: Int
     var user_level: Int
     var user_newpassword: Bool
     var user_nom: String
     var user_pass: String
     var user_pays: String
     var user_prenom: String
     var user_pseudo: String
     var user_ville: String
     var user_tokenPush: String
     var user_device: String
     var user_braintreeID: String
     var user_note: Int //note per 5 stars
     var user_countNote: Int //count of note
    
    
    // Insert code here to add functionality to your managed object subclass
    
    
    init(dico : [String : AnyObject]) {
        
        // Dictionary
        if dico.count > 1 {
            
            user_id = Int(dico["user_id"] as! String)!
            user_pseudo = dico["user_pseudo"] as! String
            user_pass = dico["user_pass"] as! String
            user_email = dico["user_email"] as! String
            user_date = Date().dateFromServer(dico["user_date"] as! String)
            user_level = Int(dico["user_level"] as! String)!
            user_nom = dico["user_nom"] as! String
            user_prenom = dico["user_prenom"] as! String
            user_adresse = dico["user_adresse"] as! String
            user_codepostal = dico["user_codepostal"] as! String
            user_ville = dico["user_ville"] as! String
            user_pays = dico["user_pays"] as! String
            user_newpassword = (Int(dico["user_newpassword"] as! String)! == 0) ? false : true
            user_tokenPush = dico["user_tokenPush"] as! String
            user_device =	 dico["user_device"] as! String
            user_braintreeID = dico["user_braintreeID"] as! String
            user_note = Int(dico["user_note"] as! String)!
            user_countNote = Int(dico["user_countNote"] as! String)!
            
        }
        else {
            user_id = 0
            user_pseudo = ""
            user_pass = ""
            user_email = ""
            user_date = Date()
            user_level = 0 //level -1 = anonymous, level 0 = sign up, level 1 = subscriber, level 2 = admin
            user_nom = ""
            user_prenom = ""
            user_adresse = ""
            user_codepostal = ""
            user_ville = ""
            user_pays = ""
            user_newpassword = false
            user_tokenPush = ""
            user_device = ""
            user_braintreeID = ""
            user_note = 0 //note per 5 stars
            user_countNote = 0 //count of note
        }
                
    }
    
    
}




