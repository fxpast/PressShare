//
//  MDBCommission.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: Commission methods
class MDBCommission {
    
    let translate = TranslateMessage.sharedInstance
    
    
    func setAddCommission(_ commission: Commission, _ balance: Double, completionHandlerCommission: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerCommission(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        
        let body: String = "user_id=\(commission.user_id)&product_id=\(commission.product_id)&com_amount=\(commission.com_amount)&balance=\(balance)&lang=\(translate.message("lang"))"
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_addCommission.php")!)
        
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

