//
//  Card.swift
//  GoOtoor
//
//  Description : This class contains all properties for card account like visa, paypal
//
//  Created by MacbookPRV on 13/02/2017.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation

struct Card {
    
    //MARK: Properties
    
    var card_id:Int
    var typeCard_id:Int
    var user_id:Int
    var typeCard_ImageUrl:String
    var tokenizedCard:String
    var card_lastNumber:String
    var main_card:Bool
    
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            card_id = Int(dico["card_id"] as! String)!
            typeCard_id = Int(dico["typeCard_id"] as! String)!
            user_id = Int(dico["user_id"] as! String)!
            typeCard_ImageUrl = ""
            tokenizedCard = dico["tokenizedCard"] as! String
            card_lastNumber = dico["card_lastNumber"] as! String
            main_card = (Int(dico["main_card"] as! String)! == 0) ? false : true
            
        }
        else {
            card_id = 0
            typeCard_id = 0
            typeCard_ImageUrl = ""
            user_id = 0
            tokenizedCard = ""
            card_lastNumber = ""
            main_card = false
            
        }
        
    }
    
}




