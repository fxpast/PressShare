//
//  Operation.swift
//  PressShare
//
//  Created by MacbookPRV on 30/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation


struct Operation {
    
    //MARK: Properties
    
    var op_id:Int
    var user_id:Int
    var op_date:Date
    var op_type:Int
    var op_montant:Double
    var op_libelle:String
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            op_id = Int(dico["op_id"] as! String)!
            user_id = Int(dico["user_id"] as! String)!
            op_date = Date().dateFromString(dico["op_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            op_type = Int(dico["op_type"] as! String)!
            op_montant = Double(dico["op_montant"] as! String)!
            op_libelle = dico["op_libelle"] as! String
            
        }
        else {
            op_id = 0
            user_id = 0
            op_date = Date()
            op_type = 0
            op_montant = 0
            op_libelle = ""
        }
        
    }
    
}


//MARK: Produits Array
class Operations {
    
    var operationArray :[[String:AnyObject]]!
    static let sharedInstance = Operations()
    
}



func getAllOperations(_ userId:Int, completionHandlerOperations: @escaping (_ success: Bool, _ operationArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
    
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_getAllOperations.php")!)
    // set Request Type
    request.httpMethod = "POST"
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    // Set Request Body
    let jsonBody: String = "user_id=\(userId)"
    request.httpBody = jsonBody.data(using: String.Encoding.utf8)
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerOperations(false, nil, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerOperations(false, nil, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerOperations(false, nil, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerOperations(false, nil, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        //print(parsedResult)
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["alloperations"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerOperations(true, resultArray, nil)
        }
        else {
            
            completionHandlerOperations(false, nil, resultDico["error"] as? String)
            
        }
        
    })
    
    
    task.resume()
    
}


func setAddOperation(_ operation: Operation, completionHandlerAddOp: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "op_libelle=\(operation.op_libelle)&op_montant=\(operation.op_montant)&op_type=\(operation.op_type)&user_id=\(operation.user_id)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_addoperation.php")!)
    // set Request Type
    request.httpMethod = "POST"
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    // Set Request Body
    request.httpBody = jsonBody.data(using: String.Encoding.utf8)
    
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerAddOp(false, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerAddOp(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerAddOp(false, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerAddOp(false, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerAddOp(true, nil)
        }
        else {
            completionHandlerAddOp(false, "impossible d'ajouter l'operation")
            
        }
        
    })
    
    
    task.resume()
    
}





