//
//  Data.swift
//  GoOtoor
//
//  Description : This class contains all properties for GoOtoor income
//
//  Created by MacbookPRV on 11/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation


struct Commission {
    
    //MARK: Properties
  
    var com_id:Int
    var user_id:Int
    var product_id:Int
    var com_date:Date
    var com_amount:Double
    
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            
            com_id = Int(dico["com_id"] as! String)!
            user_id = Int(dico["user_id"] as! String)!
            product_id = Int(dico["product_id"] as! String)!
            com_date = Date().dateFromServer(dico["date_ajout"] as! String)
            com_amount = Double(dico["balance"] as! String)!
        
        }
        else {
            com_id = 0
            user_id = 0
            product_id = 0
            com_date = Date()
            com_amount = 0
            
            
        }
        
    }
    
}








