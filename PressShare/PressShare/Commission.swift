//
//  Data.swift
//  PressShare
//
//  Description : This class contains all properties for PressShare income
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
            com_date = Date().dateFromString(dico["date_ajout"] as! String, format: "yyyy-MM-dd HH:mm:ss")
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




class MDBCommission {
    
    let translate = TranslateMessage.sharedInstance
    
    
    func setAddCommission(_ commission: Commission, _ balance: Double, completionHandlerCommission: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        
        // Create your request string with parameter name as defined in PHP file
        
        let body: String = "user_id=\(commission.user_id)&product_id=\(commission.product_id)&com_amount=\(commission.com_amount)&balance=\(balance)&lang=\(translate.lang!)"
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_addCommission.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerCommission(true, nil)
                    }
                    else {
                        completionHandlerCommission(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerCommission(false, errorStr)
                }
                
            })
            
            
            
        })
        
        
        task.resume()
        
    }
    
    static let sharedInstance = MDBCommission()
    
}






