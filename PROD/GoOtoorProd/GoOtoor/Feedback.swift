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

struct Feedback {
   
    
    //MARK: Properties
    
    var feedback_id:Int
    var comment:String
    var origin:String
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            feedback_id = Int(dico["feedback_id"] as! String)!
            comment = dico["comment"] as! String
            origin = dico["origin"] as! String
            
        }
        else {
            feedback_id = 0
            comment = ""
            origin = ""
        }
        
    }
    
}



