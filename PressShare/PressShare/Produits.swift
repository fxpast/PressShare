//
//  Data.swift
//  PressShare
//
//  Created by MacbookPRV on 11/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation


struct Produit {
    
    //MARK: Properties
    
     
    var prod_id:Int
    var prod_nom:String
    var prod_date:NSDate
    var prod_prix:Double
    var prod_by_user:Int
    var prod_by_cat:Int
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            prod_id = dico["prod_id"] as! Int
            prod_nom = dico["prod_nom"] as! String
            prod_date = dico["prod_date"] as! NSDate
            prod_prix = dico["prod_prix"] as! Double
            prod_by_user = dico["prod_by_user"] as! Int
            prod_by_cat = dico["prod_by_cat"] as! Int

        }
        else {
            prod_id = 0
            prod_nom = ""
    
            prod_date = NSDate()
            prod_prix = 0
            prod_by_user = 0
            prod_by_cat = 0

        }
        
    }
    
}


//MARK: Produits Array
class Produits {
    
    var produitsArray :[[String:AnyObject]]!
    static let sharedInstance = Produits()
    
}



func getAllProduits(completionHandlerProduits: (success: Bool, produitArray: [[String:AnyObject]]?, errorString: String?) -> Void) {
 
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_getAllProduits.php")!)
    // set Request Type
    request.HTTPMethod = "POST"
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerProduits(success: false, produitArray: nil, errorString: "There was an error with your request: \(error)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            completionHandlerProduits(success: false, produitArray: nil, errorString: "Your request returned a status code other than 2xx! : \(StatusCode(((response as? NSHTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerProduits(success: false, produitArray: nil, errorString:"No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerProduits(success: false, produitArray: nil, errorString: "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        print(parsedResult)
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["produits"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerProduits(success: true, produitArray: resultArray, errorString: nil)
        }
        else {
            completionHandlerProduits(success: false, produitArray: nil, errorString: "wrong password and user")
            
        }
        
    }
    
    
    task.resume()
    
}



func setUpdateProduit(user: User, completionHandlerOAuth: (success: Bool, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_email=\(user.user_email)&user_pass=\(user.user_pass)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_updatepass.php")!)
    // set Request Type
    request.HTTPMethod = "POST"
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    // Set Request Body
    request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
    
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerOAuth(success: false, errorString: "There was an error with your request: \(error)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            completionHandlerOAuth(success: false, errorString: "Your request returned a status code other than 2xx! : \(StatusCode(((response as? NSHTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerOAuth(success: false, errorString:"No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerOAuth(success: false, errorString: "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerOAuth(success: true, errorString: nil)
        }
        else {
            completionHandlerOAuth(success: false, errorString: "impossible to update the passeword")
            
        }
        
    }
    
    
    task.resume()
    
}



func setAddProduit(produit: Produit, completionHandlerProduit: (success: Bool, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let body: String = "prod_by_user=\(produit.prod_by_user)&prod_date=\(produit.prod_date)&prod_nom=\(produit.prod_nom)&prod_prix=\(produit.prod_prix)&prod_by_cat=\(produit.prod_by_cat)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_addProduit.php")!)
    // set Request Type
    request.HTTPMethod = "POST"
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    // Set Request Body
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerProduit(success: false, errorString: "There was an error with your request: \(error)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            completionHandlerProduit(success: false, errorString: "Your request returned a status code other than 2xx! : \(StatusCode(((response as? NSHTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerProduit(success: false, errorString:"No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerProduit(success: false, errorString: "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerProduit(success: true, errorString: nil)
        }
        else {
            completionHandlerProduit(success: false, errorString: "impossible d'enregistrer le produit")
            
        }
        
    }
    
    
    task.resume()
    
}





