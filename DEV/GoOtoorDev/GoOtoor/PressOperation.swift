//
//  Operation.swift
//  GoOtoor
//
//  Description : This class contains all properties for history of capital updating
//
//  Created by MacbookPRV on 30/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation


struct PressOperation {
    
    //MARK: Properties
    
    var op_id:Int
    var user_id:Int
    var op_date:Date
    var op_type:Int //1: deposit, 2: withdrawal, 3: buy, 4: sell, 5:Commission, 6:refund
    var op_amount:Double
    var op_wording:String
    
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            op_id = Int(dico["op_id"] as! String)!
            user_id = Int(dico["user_id"] as! String)!
            op_date = Date().dateFromServer(dico["op_date"] as! String)
            op_type = Int(dico["op_type"] as! String)!
            op_amount = Double(dico["op_amount"] as! String)!
            op_wording = dico["op_wording"] as! String
            
        }
        else {
            op_id = 0
            user_id = 0
            op_date = Date()
            op_type = 0
            op_amount = 0
            op_wording = ""
        }
        
    }
    
}




