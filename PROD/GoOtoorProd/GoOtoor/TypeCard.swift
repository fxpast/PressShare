//
//  TypeCard.swift
//  GoOtoor
//
//  Description : This class contains all properties for type of card as master card , visa
//
//  Created by MacbookPRV on 05/02/2017.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation

struct TypeCard {
    
    //MARK: Properties
    
    var typeCard_id:Int
    var typeCard_ImageUrl:String
    var typeCard_Wording:String
    
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            typeCard_id = Int(dico["typeCard_id"] as! String)!
            typeCard_ImageUrl = dico["typeCard_ImageUrl"] as! String
            typeCard_Wording = dico["typeCard_Wording"] as! String
            
            
        }
        else {
            typeCard_id = 0
            typeCard_ImageUrl = ""
            typeCard_Wording = ""
            
        }
        
    }
    
}


