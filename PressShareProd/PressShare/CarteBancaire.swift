//
//  CarteBancaire.swift
//  PressShare
//
//  Description : This class contains all properties of financial data user
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation


//MARK: Structure Carte Bancaire
struct CarteBancaire {
    
    //MARK: Properties Carte Bancaire
    
    var PORTEUR:String
    var DATEVAL:String
    var CVV:String
    var REFABONNE:String
    var user_id:Int
    
    //MARK: Initialisation Carte Bancaire
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            PORTEUR = dico["PORTEUR"] as! String
            DATEVAL = dico["DATEVAL"] as! String
            CVV = dico["CVV"] as! String
            REFABONNE = dico["REFABONNE"] as! String
            user_id = Int(dico["user_id"] as! String)!
        }
        else {
            PORTEUR = ""
            DATEVAL = ""
            CVV = ""
            REFABONNE = ""
            user_id = 0
        }
    }
}

class MDBCarteB {
    
    let translate = TranslateMessage.sharedInstance
    
    func getAllCard(userId:Int, completionHandlerCards: @escaping (_ success: Bool, _ cardArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerCards(false, nil, translate.errorConnection)
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String =        "VERSION=00104&TYPE=00001&SITE=1999888&RANG=032&CLE=1999888I&NUMQUESTION=194102418&MONTANT=1000&DEVISE=978&REFABONNE=fxpast@gmail.com&REFERENCE=TestPayb ox&PORTEUR=1111222233334444&DATEVAL=1216&CVV=123&ACTIVITE=024& DATEQ=30012013&PAYS="
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "https://preprod-ppps.paybox.com/PPPS.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandlerCards(false, nil, "There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                completionHandlerCards(false, nil, "Your request returned a status code other than 2xx! : \(BlackBox.sharedInstance.statusCode(((response as? HTTPURLResponse)?.statusCode)!))")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandlerCards(false, nil, "No data was returned by the request!")
                return
            }
            
            /* Parse the data */
            guard let parsedResult = String(data: data, encoding: String.Encoding.utf8) else {
                completionHandlerCards(false, nil, "Could not parse the data as STRING: '\(data)'")
                return
            }
            
            var resultDico = [String:AnyObject]()
            let array1 = parsedResult.components(separatedBy: "&")
            for item in array1 {
                let array2 = item.components(separatedBy: "=")
                resultDico[array2[0]] = array2[1] as AnyObject?
                
            }
            
            if resultDico.count > 1 {
                completionHandlerCards(true, [resultDico], nil)
            }
            else {
                
                completionHandlerCards(false, nil, "data response is empty")
                
            }
            
        }
        
        
        task.resume()
        
    }
    
    
    /*
     
     func setUpdateCard(carte: CarteBancaire, completionHandlerUCard: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
     
     // Create your request string with parameter name as defined in PHP file
     let jsonBody: String = "user_email=\(user.user_email)&user_pass=\(user.user_pass)"
     // Create Data from request
     let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_updatepass.php")!)
     // set Request Type
     request.httpMethod = "POST"
     // Set content-type
     request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
     request.addValue("application/json", forHTTPHeaderField: "Accept")
     // Set Request Body
     request.httpBody = jsonBody.data(using: String.Encoding.utf8)
     
     
     let session = URLSession.shared
     let task = session.dataTask(with: request as URLRequest) { data, response, error in
     
     /* GUARD: Was there an error? */
     guard (error == nil) else {
     completionHandlerUCard(false, "There was an error with your request: \(error!.localizedDescription)")
     return
     }
     
     /* GUARD: Did we get a successful 2XX response? */
     guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
     completionHandlerUCard(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
     return
     }
     
     /* GUARD: Was there any data returned? */
     guard let data = data else {
     completionHandlerUCard(false, "No data was returned by the request!")
     return
     
     }
     
     /* Parse the data */
     let parsedResult: Any!
     do {
     parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
     } catch {
     completionHandlerUCard(false, "Could not parse the data as JSON: '\(data)'")
     
     return
     
     }
     
     let result = parsedResult as! [String:String]
     
     if (result["success"] == "1") {
     completionHandlerUCard(true, nil)
     }
     else {
     completionHandlerUCard(false, "impossible to update the passeword")
     
     }
     
     }
     
     
     task.resume()
     
     }
     
     
     func setDelCard(carte: CarteBancaire, completionHandlerDCard: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
     
     // Create your request string with parameter name as defined in PHP file
     let body: String = "prod_by_user=\(produit.prod_by_user)&prod_date=\(produit.prod_date)&prod_nom=\(produit.prod_nom)&prod_prix=\(produit.prod_prix)&prod_by_cat=\(produit.prod_by_cat)&prod_latitude=\(produit.prod_latitude)&prod_longitude=\(produit.prod_longitude)&prod_mapString=\(produit.prod_mapString)&prod_comment=\(produit.prod_comment)&prod_image=\(produit.prod_image)"
     // Create Data from request
     let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_addproduit.php")!)
     // set Request Type
     request.httpMethod = "POST"
     // Set content-type
     request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
     request.addValue("application/json", forHTTPHeaderField: "Accept")
     // Set Request Body
     request.httpBody = body.data(using: String.Encoding.utf8)
     
     
     let session = URLSession.shared
     let task = session.dataTask(with: request as URLRequest) { data, response, error in
     
     /* GUARD: Was there an error? */
     guard (error == nil) else {
     completionHandlerDCard(false, "There was an error with your request: \(error!.localizedDescription)")
     return
     }
     
     /* GUARD: Did we get a successful 2XX response? */
     guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
     completionHandlerDCard(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
     return
     }
     
     /* GUARD: Was there any data returned? */
     guard let data = data else {
     completionHandlerDCard(false, "No data was returned by the request!")
     return
     
     }
     
     /* Parse the data */
     let parsedResult: Any!
     do {
     parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
     } catch {
     completionHandlerDCard(false, "Could not parse the data as JSON: '\(data)'")
     
     return
     
     }
     
     let result = parsedResult as! [String:String]
     
     if (result["success"] == "1") {
     completionHandlerDCard(true, nil)
     }
     else {
     completionHandlerDCard(false, result["error"])
     
     }
     
     }
     
     
     task.resume()
     
     }
     
     
     
     func setAddCard(carte: CarteBancaire, completionHandlerACard: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
     
     // Create your request string with parameter name as defined in PHP file
     let body: String = "prod_by_user=\(produit.prod_by_user)&prod_date=\(produit.prod_date)&prod_nom=\(produit.prod_nom)&prod_prix=\(produit.prod_prix)&prod_by_cat=\(produit.prod_by_cat)&prod_latitude=\(produit.prod_latitude)&prod_longitude=\(produit.prod_longitude)&prod_mapString=\(produit.prod_mapString)&prod_comment=\(produit.prod_comment)&prod_image=\(produit.prod_image)"
     // Create Data from request
     let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_addproduit.php")!)
     // set Request Type
     request.httpMethod = "POST"
     // Set content-type
     request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
     request.addValue("application/json", forHTTPHeaderField: "Accept")
     // Set Request Body
     request.httpBody = body.data(using: String.Encoding.utf8)
     
     
     let session = URLSession.shared
     let task = session.dataTask(with: request as URLRequest) { data, response, error in
     
     /* GUARD: Was there an error? */
     guard (error == nil) else {
     completionHandlerACard(false, "There was an error with your request: \(error!.localizedDescription)")
     return
     }
     
     /* GUARD: Did we get a successful 2XX response? */
     guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
     completionHandlerACard(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
     return
     }
     
     /* GUARD: Was there any data returned? */
     guard let data = data else {
     completionHandlerACard(false, "No data was returned by the request!")
     return
     
     }
     
     /* Parse the data */
     let parsedResult: Any!
     do {
     parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
     } catch {
     completionHandlerACard(false, "Could not parse the data as JSON: '\(data)'")
     
     return
     
     }
     
     let result = parsedResult as! [String:String]
     
     if (result["success"] == "1") {
     completionHandlerACard(true, nil)
     }
     else {
     completionHandlerACard(false, result["error"])
     
     }
     
     }
     
     
     task.resume()
     
     }
     
     */
    
    
    static let sharedInstance = MDBCarteB()
    
}

