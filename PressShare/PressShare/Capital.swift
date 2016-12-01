//
//  Capital.swift
//  PressShare
//
//  Created by MacbookPRV on 30/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation

struct Capital {
    
    //MARK: Properties
    
    
    var user_id:Int
    var date_maj:Date
    var solde:Double
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            user_id = Int(dico["user_id"] as! String)!
            date_maj = Date().dateFromString(dico["date_maj"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            solde = Double(dico["solde"] as! String)!
        }
        else {
            user_id = 0
            date_maj = Date()
            solde = 0
            
        }
        
    }
    
}


//MARK: Produits Array
class Capitals {
    
    var capitalsArray :[[String:AnyObject]]!
    static let sharedInstance = Capitals()
    
}


func setUpdateCapital(_ capital: Capital, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_id=\(capital.user_id)&solde=\(capital.solde)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_updatecapital.php")!)
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
            completionHandlerUpdate(false, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerUpdate(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerUpdate(false, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerUpdate(false, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerUpdate(true, nil)
        }
        else {
            completionHandlerUpdate(false, result["error"])
            
        }
        
    })
    
    
    task.resume()
    
}


func getCapital(_ userId:Int, completionHandlerCapital: @escaping (_ success: Bool, _ capitalArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
    
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_getcapital.php")!)
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
            completionHandlerCapital(false, nil, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerCapital(false, nil, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerCapital(false, nil, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerCapital(false, nil, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        //print(parsedResult)
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["allcapitals"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerCapital(true, resultArray, nil)
        }
        else {
            
            completionHandlerCapital(false, nil, resultDico["error"] as? String)
            
        }
        
    })
    
    
    task.resume()
    
}
