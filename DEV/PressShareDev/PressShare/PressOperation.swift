//
//  Operation.swift
//  PressShare
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
            op_date = Date().dateFromString(dico["op_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
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


//MARK: Operations Array
class PressOperations {
    
    var operationArray :[[String:AnyObject]]!
    static let sharedInstance = PressOperations()
    
}


//MARK: Operation methods
class MDBPressOperation {
    
    let translate = TranslateMessage.sharedInstance
    
    func getAllOperations(_ userId:Int, completionHandlerOperations: @escaping (_ success: Bool, _ operationArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerOperations(false, nil, translate.message("errorConnection"))
            return
        }

        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getAllOperations.php")!)
        // Set Request Body
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["alloperations"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerOperations(true, resultArray, nil)
                    }
                    else {
                        completionHandlerOperations(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerOperations(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func setAddOperation(_ operation: PressOperation, completionHandlerAddOp: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerAddOp(false, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String = "op_wording=\(operation.op_wording)&op_amount=\(operation.op_amount)&op_type=\(operation.op_type)&user_id=\(operation.user_id)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_addOperation.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerAddOp(true, nil)
                    }
                    else {
                        completionHandlerAddOp(false, self.translate.message("errorAddOperat"))
                        
                    }
                    
                }
                else {
                    completionHandlerAddOp(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    func getBraintreeToken(_ userId:Int, completionHandlerbtToken: @escaping (_ success: Bool, _ clientToken: String?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerbtToken(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/bt_getToken.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let token = resultDico["clientToken"] as! String
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerbtToken(true, token, nil)
                    }
                    else {
                        completionHandlerbtToken(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerbtToken(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func operationBraintree(_ type:String, _ userId:Int, _ amount: Double, completionHandlerNonce: @escaping (_ success: Bool , _ restAmount: String?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerNonce(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_id=\(userId)&amount=\(amount)&lang=\(translate.message("lang"))"
        // Create Data from request
        
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/bt_\(type).php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let rest = resultDico["btTransaction"] as! String
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerNonce(true, rest, nil)
                    }
                    else {
                        completionHandlerNonce(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerNonce(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    static let sharedInstance = MDBPressOperation()
    
}




