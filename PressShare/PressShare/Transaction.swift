//
//  Transaction.swift
//  PressShare
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation




//MARK: Structure Transaction
struct Transaction {
    
    
    //MARK: Properties Transaction
    var NUMQUESTION:Int
    var MONTANT:Int
    var DEVISE:Int
    var REFERENCE:String
    var DATEQ:Int
    var ACQUEREUR:String
    var ACTIVITE:Int
    var ARCHIVAGE:String
    var DATENAISS:Int
    var PAYS:String
    var user_id:Int
    
    
    //MARK: Initialisation Transaction
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            NUMQUESTION = Int(dico["NUMQUESTION"] as! String)!
            MONTANT = Int(dico["MONTANT"] as! String)!
            DEVISE = Int(dico["DEVISE"] as! String)!
            REFERENCE = dico["REFERENCE"] as! String
            DATEQ = Int(dico["DATEQ"] as! String)!
            ACQUEREUR = dico["ACQUEREUR"] as! String
            ACTIVITE = Int(dico["DATEQ"] as! String)!
            ARCHIVAGE = dico["ARCHIVAGE"] as! String
            DATENAISS = Int(dico["DATENAISS"] as! String)!
            PAYS = dico["PAYS"] as! String
            user_id = Int(dico["user_id"] as! String)!
            
        }
        else {
            NUMQUESTION = 0
            MONTANT = 0
            DEVISE = 0
            REFERENCE = ""
            DATEQ = 0
            ACQUEREUR = ""
            ACTIVITE = 0
            ARCHIVAGE = ""
            DATENAISS = 0
            PAYS = ""
            user_id = 0
            
            
        }
        
    }
    
    
}
