//
//  MDBCapital.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: Capital methods
class MDBCapital {
    
    let translate = TranslateMessage.sharedInstance
    
    func setUpdateCapital(_ capital: Capital, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUpdate(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_id=\(capital.user_id)&balance=\(capital.balance)&failure_count=\(capital.failure_count)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_updateCapital.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerUpdate(true, nil)
                    }
                    else {
                        completionHandlerUpdate(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerUpdate(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func getCapital(_ userId:Int, completionHandlerCapital: @escaping (_ success: Bool, _ capitalArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerCapital(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getCapital.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allcapitals"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerCapital(true, resultArray, nil)
                    }
                    else {
                        completionHandlerCapital(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerCapital(false, nil, errorStr)
                }
                
            })
            
            
            
        })
        
        
        task.resume()
        
    }
    
    static let sharedInstance = MDBCapital()
    
}
