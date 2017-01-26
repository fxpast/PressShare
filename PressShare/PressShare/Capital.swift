//
//  Capital.swift
//  PressShare
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
            date_maj = Date().dateFromString(dico["date_maj"] as! String, format: "yyyy-MM-dd HH:mm:ss")
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


//MARK: Produits Array
class Capitals {
    
    var capitalsArray :[[String:AnyObject]]!
    static let sharedInstance = Capitals()
    
}

class MDBCapital {
    
    let translate = TranslateMessage.sharedInstance
    
    func setUpdateCapital(_ capital: Capital, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_id=\(capital.user_id)&balance=\(capital.balance)&failure_count=\(capital.failure_count)&lang=\(translate.lang!)"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_updateCapital.php")!)
        
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
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_getCapital.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.lang!)"
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
