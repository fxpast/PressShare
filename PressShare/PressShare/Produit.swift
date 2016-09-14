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
    var prod_image:String
    var prod_nom:String
    var prod_date:NSDate
    var prod_prix:Double
    var prod_by_user:Int
    var prod_by_cat:Int
    var prod_latitude:Double
    var prod_longitude:Double
    var prod_mapString:String
    var prod_comment:String
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            prod_id = Int(dico["prod_id"] as! String)!
            prod_image = dico["prod_image"] as! String
            prod_nom = dico["prod_nom"] as! String
            prod_date = NSDate().dateFromString(dico["prod_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            prod_prix = Double(dico["prod_prix"] as! String)!
            prod_by_user = Int(dico["prod_by_user"] as! String)!
            prod_by_cat = Int(dico["prod_by_cat"] as! String)!
            prod_latitude = Double(dico["prod_latitude"] as! String)!
            prod_longitude = Double(dico["prod_longitude"] as! String)!
            prod_mapString = dico["prod_mapString"] as! String
            prod_comment = dico["prod_comment"] as! String

        }
        else {
            prod_id = 0
            prod_image = ""
            prod_nom = ""
    
            prod_date = NSDate()
            prod_prix = 0
            prod_by_user = 0
            prod_by_cat = 0
            prod_latitude = 0
            prod_longitude = 0
            prod_mapString = ""
            prod_comment = ""

        }
        
    }
    
}


//MARK: Produits Array
class Produits {
    
    var produitsArray :[[String:AnyObject]]!
    static let sharedInstance = Produits()
    
}



func getAllProduits(userId:Int, completionHandlerProduits: (success: Bool, produitArray: [[String:AnyObject]]?, errorString: String?) -> Void) {
 
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_getAllProduits.php")!)
    // set Request Type
    request.HTTPMethod = "POST"
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    // Set Request Body
    let jsonBody: String = "user_id=\(userId)"
    request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
    
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerProduits(success: false, produitArray: nil, errorString: "There was an error with your request: \(error!.localizedDescription)")
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
        //print(parsedResult)
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["allproduits"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerProduits(success: true, produitArray: resultArray, errorString: nil)
        }
        else {

            completionHandlerProduits(success: false, produitArray: nil, errorString: resultDico["error"] as? String)
            
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
            completionHandlerOAuth(success: false, errorString: "There was an error with your request: \(error!.localizedDescription)")
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
    let body: String = "prod_by_user=\(produit.prod_by_user)&prod_date=\(produit.prod_date)&prod_nom=\(produit.prod_nom)&prod_prix=\(produit.prod_prix)&prod_by_cat=\(produit.prod_by_cat)&prod_latitude=\(produit.prod_latitude)&prod_longitude=\(produit.prod_longitude)&prod_mapString=\(produit.prod_mapString)&prod_comment=\(produit.prod_comment)&prod_image=\(produit.prod_image)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_addproduit.php")!)
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
            completionHandlerProduit(success: false, errorString: "There was an error with your request: \(error!.localizedDescription)")
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
            completionHandlerProduit(success: false, errorString: result["error"])
            
        }
        
    }
    
    
    task.resume()
    
}





