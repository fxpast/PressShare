
//
//  Transaction.swift
//  GoOtoor
//
//  Description : This class contains all the properties for buy / exchange product
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation


//MARK: Structure Transaction
struct Transaction {
    
    //MARK: Properties Transaction
    
    var trans_id:Int
    var trans_date:Date
    var trans_type:Int   //1 : Buy. 2 : Exchange
    var trans_wording:String
    var prod_id:Int
    var trans_amount:Double
    var client_id:Int
    var vendeur_id:Int
    var proprietaire:Int
    var trans_valid:Int  //0 : La transaction en cours. 1 : La transaction a été annulée. 2 : La transaction est confirmée.
    var trans_avis:String  //interlocuteur, conformite, absence, "tap text"
    var trans_arbitrage:Bool
    var trans_note:Int //noter la transaction sur 5
    
    //MARK: Initialisation Transaction
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            trans_id = Int(dico["trans_id"] as! String)!
            trans_date = Date().dateFromServer(dico["trans_date"] as! String)
            trans_type = Int(dico["trans_type"] as! String)!
            trans_wording = dico["trans_wording"] as! String
            prod_id = Int(dico["prod_id"] as! String)!
            trans_amount = Double(dico["trans_amount"] as! String)!
            vendeur_id = Int(dico["vendeur_id"] as! String)!
            client_id = Int(dico["client_id"] as! String)!
            proprietaire = Int(dico["proprietaire"] as! String)!
            trans_valid = Int(dico["trans_valid"] as! String)!
            trans_avis = dico["trans_avis"] as! String
            trans_arbitrage = (Int(dico["trans_arbitrage"] as! String)! == 0) ? false : true
            trans_note = Int(dico["trans_note"] as! String)!
            
        }
        else {
            
            trans_id = 0
            trans_date = Date()
            trans_type = 0
            trans_wording = ""
            prod_id = 0
            trans_amount = 0
            vendeur_id = 0
            client_id = 0
            proprietaire = 0
            trans_valid = 0
            trans_avis = ""
            trans_arbitrage = false
            trans_note = 0
            
        }
        
    }
    
    
}


