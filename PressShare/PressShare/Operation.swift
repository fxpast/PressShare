//
//  Operation.swift
//  PressShare
//
//  Created by MacbookPRV on 30/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



//Todo :les valeurs possibles et leurs significations des propriétés :op_type

//Todo :Les commentaires doivent être en anglais
//Todo :Les classes doivent avoir en entete l'auteur , la date de création, de modification, la definitions, leurs paramètres
//Todo :Les methodes doivent avoir en entete leur definition, leurs paramètre et leur @return


import Foundation


struct Operation {
    
    //MARK: Properties
    
    var op_id:Int
    var user_id:Int
    var op_date:Date
    var op_type:Int
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
class Operations {
    
    var operationArray :[[String:AnyObject]]!
    static let sharedInstance = Operations()
    
}


class MDBOperation {
    
    func getAllOperations(_ userId:Int, completionHandlerOperations: @escaping (_ success: Bool, _ operationArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_getAllOperations.php")!)
        // Set Request Body
        let body: String = "user_id=\(userId)"
        
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
    
    
    func setAddOperation(_ operation: Operation, completionHandlerAddOp: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "op_wording=\(operation.op_wording)&op_amount=\(operation.op_amount)&op_type=\(operation.op_type)&user_id=\(operation.user_id)"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_addOperation.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerAddOp(true, nil)
                    }
                    else {
                        completionHandlerAddOp(false, "impossible d'ajouter l'operation")
                        
                    }
                    
                }
                else {
                    completionHandlerAddOp(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    static let sharedInstance = MDBOperation()
    
}




