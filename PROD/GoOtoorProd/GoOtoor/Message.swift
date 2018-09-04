//
//  Message
//  GoOtoor
//
//  Description : This class contains all properties for messaging between users
//
//  Created by MacbookPRV on 11/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation

struct Message {
    
    //MARK: Properties
    
    var message_id:Int
    var expediteur:Int
    var destinataire:Int
    var proprietaire:Int
    var vendeur_id:Int
    var client_id:Int
    var product_id:Int
    var date_ajout:Date
    var contenu:String
    var deja_lu:Bool
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            
            message_id = Int(dico["message_id"] as! String)!
            expediteur = Int(dico["expediteur"] as! String)!
            destinataire = Int(dico["destinataire"] as! String)!
            proprietaire = Int(dico["proprietaire"] as! String)!
            vendeur_id = Int(dico["vendeur_id"] as! String)!
            client_id = Int(dico["client_id"] as! String)!
            product_id = Int(dico["product_id"] as! String)!
            date_ajout = Date().dateFromServer(dico["date_ajout"] as! String)
            contenu = dico["contenu"] as! String
            deja_lu = (Int(dico["deja_lu"] as! String)! == 0) ? false : true
        }
        else {
            message_id = 0
            expediteur = 0
            destinataire = 0
            proprietaire = 0
            vendeur_id = 0
            client_id = 0
            product_id = 0
            date_ajout = Date()
            contenu = ""
            deja_lu = false
            
            
            
        }
        
    }
    
}







