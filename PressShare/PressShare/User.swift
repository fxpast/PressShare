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

    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    init(dico: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "User", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // Dictionary
        if dico.count > 1 {
            
            user_id = Int(dico["user_id"] as! String) as NSNumber?
            user_pseudo = dico["user_pseudo"] as? String
            user_pass = dico["user_pass"] as? String
            user_email = dico["user_email"] as? String
            user_date = Date().dateFromString(dico["user_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            user_level = Int(dico["user_level"] as! String) as NSNumber?
            user_nom = dico["user_nom"] as? String
            user_prenom = dico["user_prenom"] as? String
            user_adresse = dico["user_adresse"] as? String
            user_codepostal = dico["user_codepostal"] as? String
            user_ville = dico["user_ville"] as? String
            user_pays = dico["user_pays"] as? String
            user_newpassword = Bool(dico["user_newpassword"] as! String) as NSNumber?
            
        }
        else {
            user_id = 0
            user_pseudo = ""
            user_pass = ""
            user_email = ""
            user_date = Date()
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




//MARK: Users Array
class Users {
    
    var usersArray :[[String:AnyObject]]!
    static let sharedInstance = Users()
    
}


class Config {
    
    /*
     users(user_pseudo, user_pass, user_email ,user_date, user_level, user_nom,
     user_prenom, user_adresse, user_codepostal, user_ville, user_pays, user_derconnexion,
     user_nbreconnexion, user_latitude, user_longitude, user_mapString, user_newpassword)
     */
    
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
    var user_lastpass:String!
    
 
    
    func cleaner()  {
        
        user_id = 0
        user_pseudo = ""
        user_email = ""
        latitude = 0
        longitude = 0
        mapString = ""
        user_nom = ""
        user_prenom = ""
        user_newpassword = false
        previousView = ""
        user_adresse = ""
        user_codepostal = ""
        user_ville = ""
        user_pays = ""
        verifpassword = ""
        user_pass = ""
        user_lastpass = ""
        
    }
    
    static let sharedInstance = Config()
    
}



func getAllUsers(_ userId:Int, completionHandlerAllUsers: @escaping (_ success: Bool, _ usersArray: [[String : AnyObject]]?, _ errorString:String?) -> Void)
{
    // Create your request string with parameter name as defined in PHP file
    let body: String = "user_id=\(userId)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_getAllUsers.php")!)
    // set Request Type
    request.httpMethod = "POST"
    // Set Request Body
    request.httpBody = body.data(using: String.Encoding.utf8)
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        
    
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerAllUsers(false, nil, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerAllUsers(false, nil, "Your request returned a status code other than 2xx!, error : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerAllUsers(false, nil, "No data was returned by the request!")
            return
        }
        
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerAllUsers(false, nil, "Could not parse the data as JSON: '\(data)'")
            return
        }
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["allusers"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerAllUsers(true, resultArray, nil)
        }
        else {
            completionHandlerAllUsers(false, nil, resultDico["error"] as? String)
            
        }
        
        
    }) 
    task.resume()
    
}


func AuthentiFacebook(_ config: Config, completionHandlerOAuthFacebook: @escaping (_ success: Bool, _ userArray: [[String : AnyObject]]?, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_email=\(config.user_email)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_Facebook.php")!)
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
            completionHandlerOAuthFacebook(false, nil, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerOAuthFacebook(false, nil, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerOAuthFacebook(false, nil, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerOAuthFacebook(false, nil, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["user"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerOAuthFacebook(true, resultArray, nil)
        }
        else {
            completionHandlerOAuthFacebook(false, nil, resultDico["error"] as? String)
        }
        
    }) 
    
    
    task.resume()
    
}


func Authentification(_ config: Config, completionHandlerOAuth: @escaping (_ success: Bool, _ userArray: [[String : AnyObject]]?, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_pseudo=\(config.user_pseudo!)&user_pass=\(config.user_pass!)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_signin.php")!)
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
            completionHandlerOAuth(false, nil, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerOAuth(false, nil, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerOAuth(false, nil, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerOAuth(false, nil, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        //print(parsedResult)
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["user"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerOAuth(true, resultArray, nil)
        }
        else {
            completionHandlerOAuth(false, nil, resultDico["error"] as? String)
            
        }
        
        
    }) 
    
    
    task.resume()
    
}


func setUpdatePass(_ config: Config, completionHandlerOAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    
    let newpassword = (config.user_newpassword==true) ? 1 : 0
    let jsonBody: String = "user_email=\(config.user_email)&user_pass=\(config.user_pass)&user_lastpass=\(config.user_lastpass)&user_newpassword=\(newpassword)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_updatepass.php")!)
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
            completionHandlerOAuth(false, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerOAuth(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerOAuth(false, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerOAuth(false, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerOAuth(true, nil)
        }
        else {
            completionHandlerOAuth(false, result["error"])
            
        }
        
    }) 
    
    
    task.resume()
    
}


func setUpdateUser(_ config: Config, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_pseudo=\(config.user_pseudo)&user_pass=\(config.user_pass)&user_adresse=\(config.user_adresse)&user_codepostal=\(config.user_codepostal)&user_nom=\(config.user_nom)&user_prenom=\(config.user_prenom)&user_email=\(config.user_email)&user_pays=\(config.user_pays)&user_ville=\(config.user_ville)&user_id=\(config.user_id)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_updateuser.php")!)
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


func setAddUser(_ config: Config, completionHandlerOAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    

    // Create your request string with parameter name as defined in PHP file
    let jsonBody: String = "user_pseudo=\(config.user_pseudo)&user_pass=\(config.user_pass)&user_adresse=\(config.user_adresse)&user_codepostal=\(config.user_codepostal)&user_nom=\(config.user_nom)&user_prenom=\(config.user_prenom)&user_email=\(config.user_email)&user_pays=\(config.user_pays)&user_latitude=\(config.latitude)&user_longitude=\(config.longitude)&user_mapString=\(config.mapString)&user_newpassword=\(config.user_newpassword)"
    
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_signup.php")!)
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
            completionHandlerOAuth(false, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerOAuth(false, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerOAuth(false, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerOAuth(false, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        
        let result = parsedResult as! [String:String]
        
        if (result["success"] == "1") {
            completionHandlerOAuth(true, nil)
        }
        else {
            completionHandlerOAuth(false, result["error"])
            
        }
        
    }) 
    
    
    task.resume()
    
}




