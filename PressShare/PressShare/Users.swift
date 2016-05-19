//
//  Data.swift
//  PressShare
//
//  Created by MacbookPRV on 11/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation


struct User {
    
    //MARK: Properties
    
    
    var user_id:Int
    var user_pseudo:String
    var user_pass:String
    var user_email:String
    var user_date:NSDate
    var user_level:Int
    var user_nom:String
    var user_prenom:String
    var user_adresse:String
    var user_codepostal:String
    var user_ville:String
    var user_pays:String
    var user_latitude:Float
    var user_longitude:Float
    var user_mapString:String

    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            user_id = Int((dico["user_id"] as! String))!
            user_pseudo = dico["user_pseudo"] as! String
            user_pass = ""
            user_email = dico["user_email"] as! String
            user_date = NSDate().dateFromString(dico["user_date"] as! String, format: "yyyy-MM-dd HH:mm:ss") 
            user_level = Int((dico["user_level"] as! String))!
            user_nom = dico["user_nom"] as! String
            user_prenom = dico["user_prenom"] as! String
            user_adresse = dico["user_adresse"] as! String
            user_codepostal = dico["user_codepostal"] as! String
            user_ville = dico["user_ville"] as! String
            user_pays = dico["user_pays"] as! String
            user_latitude = Float(dico["user_latitude"] as! String)!
            user_longitude = Float(dico["user_longitude"] as! String)!
            user_mapString = dico["user_mapString"] as! String

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
            user_latitude = 0.0
            user_longitude = 0.0
            user_mapString = ""

        }
        
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
    var latitude:Float!
    var longitude:Float!
    var mapString:String!
    var user_nom:String!
    var user_prenom:String!
    
    static let sharedInstance = Config()
    
}


func getAllUsers(completionHandlerAllUsers: (success: Bool, usersArray: [[String : AnyObject]]?, errorString:String?) -> Void)
{
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_getAllUsers.php")!)
    // set Request Type
    request.HTTPMethod = "POST"
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerAllUsers(success: false, usersArray: nil, errorString: "There was an error with your request: \(error)")
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
            completionHandlerAllUsers(success: false, usersArray: nil, errorString: "impossible to get users")
            
        }
        
        
    }
    task.resume()
    
}


func AuthentiFacebook(user: User, completionHandlerOAuthFacebook: (success: Bool, userArray: [[String : AnyObject]]?, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_email=\(user.user_email)"
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
            completionHandlerOAuthFacebook(success: false, userArray: nil, errorString: "There was an error with your request: \(error)")
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
            completionHandlerOAuthFacebook(success: false, userArray: nil, errorString: "wrong password and user")
            
        }
        
        
        
        
    }
    
    
    task.resume()
    
}


func Authentification(user: User, completionHandlerOAuth: (success: Bool, userArray: [[String : AnyObject]]?, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_pseudo=\(user.user_pseudo)&user_pass=\(user.user_pass)"
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
            completionHandlerOAuth(success: false, userArray: nil, errorString: "There was an error with your request: \(error)")
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
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["user"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerOAuth(success: true, userArray: resultArray, errorString: nil)
        }
        else {
            completionHandlerOAuth(success: false, userArray: nil, errorString: "wrong password and user")
            
        }
        
        
        
        
    }
    
    
    task.resume()
    
}


func setLocation(user: User, completionHandlerLocation: (success: Bool, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let body: String = "user_longitude=\(user.user_longitude)&user_latitude=\(user.user_latitude)&user_pseudo=\(user.user_pseudo)&user_mapString=\(user.user_mapString)"
    // Create Data from request
    let request = NSMutableURLRequest(URL: NSURL(string: "http://pressshare.fxpast.com/api_postLocation.php")!)
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
            completionHandlerLocation(success: false, errorString: "There was an error with your request: \(error)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            completionHandlerLocation(success: false, errorString: "Your request returned a status code other than 2xx! : \(StatusCode(((response as? NSHTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerLocation(success: false, errorString:"No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerLocation(success: false, errorString: "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerLocation(success: true, errorString: nil)
        }
        else {
            completionHandlerLocation(success: false, errorString: "impossible to update the location")
            
        }
        
    }
    
    
    task.resume()
    
}


func setUpdatePass(user: User, completionHandlerOAuth: (success: Bool, errorString: String?) -> Void) {
    
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



func setAddUser(user: User, completionHandlerOAuth: (success: Bool, errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_pseudo=\(user.user_pseudo)&user_pass=\(user.user_pass)&user_adresse=\(user.user_adresse)&user_codepostal=\(user.user_codepostal)&user_nom=\(user.user_nom)&user_prenom=\(user.user_prenom)&user_email=\(user.user_email)&user_pays=\(user.user_pays)&user_ville=\(user.user_ville)"
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
            completionHandlerOAuth(success: false, errorString: "impossible to record the user")
            
        }
        
    }
    
    
    task.resume()
    
}





