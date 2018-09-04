//
//  Capital.swift
//  GoOtoor
//
//  Description : This class contains user's balance
//
//  Created by MacbookPRV on 30/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation

struct Capital {
    
    //MARK: Properties
    
    
    var user_id:Int
    var date_maj:Date
    var balance:Double
    var failure_count:Int
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            user_id = Int(dico["user_id"] as! String)!
            date_maj = Date().dateFromServer(dico["date_maj"] as! String)
            balance = Double(dico["balance"] as! String)!
            failure_count = Int(dico["failure_count"] as! String)!
        }
        else {
            user_id = 0
            date_maj = Date()
            balance = 0
            failure_count = 0
            
        }
        
    }
    
}

