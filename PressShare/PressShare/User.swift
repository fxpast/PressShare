//
//  User.swift
//  PressShare
//
//  Created by MacbookPRV on 09/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dico: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        if dico.count > 1 {
            
            user_id = Int((dico["user_id"] as! String))!
            user_pseudo = dico["user_pseudo"] as? String
            user_pass = dico["user_pass"] as? String
            user_email = dico["user_email"] as? String
            user_date = NSDate().dateFromString(dico["user_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            user_level = Int((dico["user_level"] as! String))!
            user_nom = dico["user_nom"] as? String
            user_prenom = dico["user_prenom"] as? String
            user_adresse = dico["user_adresse"] as? String
            user_codepostal = dico["user_codepostal"] as? String
            user_ville = dico["user_ville"] as? String
            user_pays = dico["user_pays"] as? String
            user_newpassword = Bool(Int(dico["user_newpassword"] as! String)!)
            
        }
        else {
            user_id = 0
            user_pseudo = ""
            user_pass = ""
            user_email = ""
            user_date = NSDate()
            user_level = 0
            user_nom = ""
            user_prenom = ""
            user_adresse = ""
            user_codepostal = ""
            user_ville = ""
            user_pays = ""
            user_newpassword = false
            
        }
        
        user_logout = false
        
    }
    
    
    
}




//MARK: Students Array
class Users {
    
    var usersArray :[[String:AnyObject]]!
    static let sharedInstance = Users()
    
}


class Config {
    
    var user_id:Int!
    var user_pseudo:String!
    var user_email:String!
    var latitude:Double!
    var longitude:Double!
    var mapString:String!
    var user_nom:String!
    var user_prenom:String!
    var user_newpassword:Bool!
    var previousView:String!
    var user_adresse:String!
    var user_codepostal:String!
    var user_ville:String!
    var user_pays:String!
    var verifpassword:String!
    var user_pass:String!
    
    static let sharedInstance = Config()
    
}


func getAllUsers(userId:Int, completionHandlerAllUsers: (success: Bool, usersArray: [[String : AnyObject]]?, errorString:String?) -> Void)
{
    // Create your request string with parameter name as defined in PHP file
    let body: String = "user_id=\(userId)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_getAllUsers.php")!)
    // set Request Type
    request.HTTPMethod = "POST"
    // Set Request Body
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerAllUsers(success: false, usersArray: nil, errorString: "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            completionHandlerAllUsers(success: false, usersArray: nil, errorString: "Your request returned a status code other than 2xx!, error : \(StatusCode(((response as? NSHTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerAllUsers(success: false, usersArray: nil, errorString: "No data was returned by the request!")
            return
        }
        
        
        /* Parse the data */
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerAllUsers(success: false, usersArray: nil, errorString: "Could not parse the data as JSON: '\(data)'")
            return
        }
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["allusers"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerAllUsers(success: true, usersArray: resultArray, errorString: nil)
        }
        else {
            completionHandlerAllUsers(success: false, usersArray: nil, errorString: resultDico["error"] as? String)
            
        }
        
        
    }
    task.resume()
    
}


func AuthentiFacebook(config: Config, completionHandlerOAuthFacebook: (success: Bool, userArray: [[String : AnyObject]]?, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_email=\(config.user_email)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_Facebook.php")!)
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
            completionHandlerOAuthFacebook(success: false, userArray: nil, errorString: "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            completionHandlerOAuthFacebook(success: false, userArray: nil, errorString: "Your request returned a status code other than 2xx! : \(StatusCode(((response as? NSHTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerOAuthFacebook(success: false, userArray: nil, errorString:"No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerOAuthFacebook(success: false, userArray: nil, errorString: "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["user"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerOAuthFacebook(success: true, userArray: resultArray, errorString: nil)
        }
        else {
            completionHandlerOAuthFacebook(success: false, userArray: nil, errorString: resultDico["error"] as? String)
        }
        
    }
    
    
    task.resume()
    
}


func Authentification(config: Config, completionHandlerOAuth: (success: Bool, userArray: [[String : AnyObject]]?, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_pseudo=\(config.user_pseudo)&user_pass=\(config.user_pass)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_signin.php")!)
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
            completionHandlerOAuth(success: false, userArray: nil, errorString: "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            completionHandlerOAuth(success: false, userArray: nil, errorString: "Your request returned a status code other than 2xx! : \(StatusCode(((response as? NSHTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerOAuth(success: false, userArray: nil, errorString:"No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerOAuth(success: false, userArray: nil, errorString: "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        //print(parsedResult)
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["user"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerOAuth(success: true, userArray: resultArray, errorString: nil)
        }
        else {
            completionHandlerOAuth(success: false, userArray: nil, errorString: resultDico["error"] as? String)
            
        }
        
        
    }
    
    
    task.resume()
    
}


func setUpdatePass(config: Config, completionHandlerOAuth: (success: Bool, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    
    let newpassword = (config.user_newpassword==true) ? 1 : 0
    let jsonBody: String = "user_email=\(config.user_email)&user_pass=\(config.user_pass)&user_newpassword=\(newpassword)"
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
            completionHandlerOAuth(success: false, errorString: result["error"])
            
        }
        
    }
    
    
    task.resume()
    
}


func setUpdateUser(config: Config, completionHandlerUpdate: (success: Bool, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_pseudo=\(config.user_pseudo)&user_pass=\(config.user_pass)&user_adresse=\(config.user_adresse)&user_codepostal=\(config.user_codepostal)&user_nom=\(config.user_nom)&user_prenom=\(config.user_prenom)&user_email=\(config.user_email)&user_pays=\(config.user_pays)&user_ville=\(config.user_ville)&user_id=\(config.user_id)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_updateuser.php")!)
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
            completionHandlerUpdate(success: false, errorString: "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            completionHandlerUpdate(success: false, errorString: "Your request returned a status code other than 2xx! : \(StatusCode(((response as? NSHTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerUpdate(success: false, errorString:"No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerUpdate(success: false, errorString: "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerUpdate(success: true, errorString: nil)
        }
        else {
            completionHandlerUpdate(success: false, errorString: result["error"])
            
        }
        
    }
    
    
    task.resume()
    
}


func setAddUser(config: Config, completionHandlerOAuth: (success: Bool, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_pseudo=\(config.user_pseudo)&user_pass=\(config.user_pass)&user_adresse=\(config.user_adresse)&user_codepostal=\(config.user_codepostal)&user_nom=\(config.user_nom)&user_prenom=\(config.user_prenom)&user_email=\(config.user_email)&user_pays=\(config.user_pays)&user_ville=\(config.user_ville)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_signup.php")!)
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
            completionHandlerOAuth(success: false, errorString: result["error"])
            
        }
        
    }
    
    
    task.resume()
    
}




