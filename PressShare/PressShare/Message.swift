//
//  Data.swift
//  PressShare
//
//  Created by MacbookPRV on 11/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation



struct Message {
    
    //MARK: Properties
    
    
    var message_id:Int
    var expediteur:Int
    var destinataire:Int
    var proprietaire:Int
    var vendeur_id:Int
    var client_id:Int
    var produit_id:Int
    var date_ajout:Date
    var contenu:String
    var deja_lu_exp:Bool
    var deja_lu_dest:Bool
    
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            
            message_id = Int(dico["message_id"] as! String)!
            expediteur = Int(dico["expediteur"] as! String)!
            destinataire = Int(dico["destinataire"] as! String)!
            proprietaire = Int(dico["proprietaire"] as! String)!
            vendeur_id = Int(dico["vendeur_id"] as! String)!
            client_id = Int(dico["client_id"] as! String)!
            produit_id = Int(dico["produit_id"] as! String)!
            date_ajout = Date().dateFromString(dico["date_ajout"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            contenu = dico["contenu"] as! String
            var lu = Int(dico["deja_lu_exp"] as! String)!
            if lu == 0 {
                deja_lu_exp = false
            }
            else {
                deja_lu_exp = true
            }
            lu = Int(dico["deja_lu_dest"] as! String)!
            if lu == 0 {
                deja_lu_dest = false
            }
            else {
                deja_lu_dest = true
            }
            
            
            

        }
        else {
            message_id = 0
            expediteur = 0
            destinataire = 0
            proprietaire = 0
            vendeur_id = 0
            client_id = 0
            produit_id = 0
            date_ajout = Date()
            contenu = ""
            deja_lu_exp = false
            deja_lu_dest = false
    
            
            
        }
        
    }
    
}


//MARK: Produits Array
class Messages {
    
    var MessagesArray :[[String:AnyObject]]!
    static let sharedInstance = Messages()
    
}



func getAllMessages(_ userId:Int, completionHandlerMessages: @escaping (_ success: Bool, _ messageArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
 
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_getAllMessages.php")!)
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
            completionHandlerMessages(false, nil, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerMessages(false, nil, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerMessages(false, nil, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerMessages(false, nil, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["allmessages"] as! [[String:AnyObject]]
        
        //print(resultArray)
        
        if resultDico["success"] as! String == "1" {
            completionHandlerMessages(true, resultArray, nil)
        }
        else {

            completionHandlerMessages(false, nil, resultDico["error"] as? String)
            
        }
        
    }) 
    
    
    task.resume()
    
}



func setDeleteMessage(_ message: Message, completionHandlerDelMessage: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "message_id=\(message.message_id)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_delmessage.php")!)
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
            completionHandlerDelMessage(false, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerDelMessage(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerDelMessage(false, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerDelMessage(false, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerDelMessage(true, nil)
        }
        else {
            completionHandlerDelMessage(false, "impossible to delete the message")
            
        }
        
    }) 
    
    
    task.resume()
    
}



func setUpdateMessage(_ message: Message, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "message_id=\(message.message_id)&deja_lu_exp=\(message.deja_lu_exp)&deja_lu_dest=\(message.deja_lu_dest)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_updatemessage.php")!)
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


func setAddMessage(_ message: Message, completionHandlerMessages: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
    
    // Create your request string with parameter name as defined in PHP file
    
    let jsonBody: String = "expediteur=\(message.expediteur)&destinataire=\(message.destinataire)&vendeur_id=\(message.vendeur_id)&client_id=\(message.client_id)&produit_id=\(message.produit_id)&contenu=\(message.contenu)"
    
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_addmessage.php")!)
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
            completionHandlerMessages(false, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerMessages(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerMessages(false, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerMessages(false, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        //print(parsedResult)
        
        let result = parsedResult as! [String:String]
        
    
        if (result["success"] == "1") {
            completionHandlerMessages(true, nil)
        }
        else {
            completionHandlerMessages(false, result["error"])
            
        }
        
    })
    
    
    task.resume()
    
}







