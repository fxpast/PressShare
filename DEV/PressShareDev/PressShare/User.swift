//
//  User.swift
//  PressShare
//
// Description : User account with physical adresse and geolocalization
//
//  Created by MacbookPRV on 09/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



import Foundation


struct User {
    
    
     var user_adresse: String
     var user_codepostal: String
     var user_date: Date
     var user_email: String
     var user_id: Int
     var user_level: Int
     var user_newpassword: Bool
     var user_nom: String
     var user_pass: String
     var user_pays: String
     var user_prenom: String
     var user_pseudo: String
     var user_ville: String
     var user_tokenPush: String
     var user_braintreeID: String

    
    // Insert code here to add functionality to your managed object subclass
    
    
    init(dico : [String : AnyObject]) {
        
        // Dictionary
        if dico.count > 1 {
            
            user_id = Int(dico["user_id"] as! String)!
            user_pseudo = dico["user_pseudo"] as! String
            user_pass = dico["user_pass"] as! String
            user_email = dico["user_email"] as! String
            user_date = Date().dateFromString(dico["user_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            user_level = Int(dico["user_level"] as! String)!
            user_nom = dico["user_nom"] as! String
            user_prenom = dico["user_prenom"] as! String
            user_adresse = dico["user_adresse"] as! String
            user_codepostal = dico["user_codepostal"] as! String
            user_ville = dico["user_ville"] as! String
            user_pays = dico["user_pays"] as! String
            user_newpassword = (Int(dico["user_newpassword"] as! String)! == 0) ? false : true
            user_tokenPush = dico["user_pays"] as! String
            user_braintreeID = dico["user_braintreeID"] as! String
            
        }
        else {
            user_id = 0
            user_pseudo = ""
            user_pass = ""
            user_email = ""
            user_date = Date()
            user_level = 0 //level -1 = anonymous, level 0 = sign up, level 1 = subscriber, level 2 = admin
            user_nom = ""
            user_prenom = ""
            user_adresse = ""
            user_codepostal = ""
            user_ville = ""
            user_pays = ""
            user_newpassword = false
            user_tokenPush = ""
            user_braintreeID = ""
        }
                
    }
    
    
}

//MARK: Users Array
class Users {
    
    var usersArray :[[String:AnyObject]]!
    static let sharedInstance = Users()
    
}


//MARK: User methods
class MDBUser {
    
    let translate = TranslateMessage.sharedInstance
    
    func getUser(_ userId:Int, completionHandlerUser: @escaping (_ success: Bool, _ usersArray: [[String : AnyObject]]?, _ errorString:String?) -> Void)
    {
    
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUser(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getUser.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["user"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerUser(true, resultArray, nil)
                    }
                    else {
                        completionHandlerUser(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerUser(false, nil, errorStr)
                }
                
            })
            
        })
        task.resume()
        
    }
    
    func AuthentiFacebook(_ config: Config, completionHandlerOAuthFacebook: @escaping (_ success: Bool, _ userArray: [[String : AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerOAuthFacebook(false, nil, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_email=\(config.user_email!)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_facebook.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["user"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerOAuthFacebook(true, resultArray, nil)
                    }
                    else {
                        completionHandlerOAuthFacebook(false, nil, resultDico["error"] as? String)
                    }
                    
                }
                else {
                    completionHandlerOAuthFacebook(false, nil, errorStr)
                }
                
            })
            
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func Authentification(_ config: Config, completionHandlerOAuth: @escaping (_ success: Bool, _ userArray: [[String : AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerOAuth(false, nil, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_pseudo=\(config.user_pseudo!)&user_pass=\(config.user_pass!)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_signIn.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["user"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerOAuth(true, resultArray, nil)
                    }
                    else {
                        completionHandlerOAuth(false, nil, resultDico["error"] as? String)
                    }
                    
                }
                else {
                    completionHandlerOAuth(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func setUpdatePass(_ config: Config, completionHandlerOAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerOAuth(false, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_email=\(config.user_email!)&user_pass=\(config.user_pass!)&user_lastpass=\(config.user_lastpass!)&user_newpassword=\(config.user_newpassword!)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_updatePassword.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerOAuth(true, nil)
                    }
                    else {
                        completionHandlerOAuth(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerOAuth(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func setUpdateUser(_ config: Config, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUpdate(false, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_pseudo=\(config.user_pseudo!)&user_adresse=\(config.user_adresse!)&user_codepostal=\(config.user_codepostal!)&user_nom=\(config.user_nom!)&user_prenom=\(config.user_prenom!)&user_email=\(config.user_email!)&user_pays=\(config.user_pays!)&user_ville=\(config.user_ville!)&user_id=\(config.user_id!)&user_tokenPush=\(config.tokenString!)&user_braintreeID=\(config.user_braintreeID!)&user_level=\(config.level!)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_updateUser.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerUpdate(true, nil)
                    }
                    else {
                        completionHandlerUpdate(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerUpdate(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    
    func setUpdateUserToken(_ config: Config, completionHandlerToken: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerToken(false, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_id=\(config.user_id!)&user_tokenPush=\(config.tokenString!)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_updateUserToken.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerToken(true, nil)
                    }
                    else {
                        completionHandlerToken(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerToken(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    func setAddUser(_ config: Config, completionHandlerOAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerOAuth(false, translate.message("errorConnection"))
            return
        }

        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_pseudo=\(config.user_pseudo!)&user_pass=\(config.user_pass!)&user_adresse=\(config.user_adresse!)&user_codepostal=\(config.user_codepostal!)&user_nom=\(config.user_nom!)&user_prenom=\(config.user_prenom!)&user_email=\(config.user_email!)&user_pays=\(config.user_pays!)&user_latitude=\(config.latitude!)&user_longitude=\(config.longitude!)&user_mapString=\(config.mapString!)&user_tokenPush=\(config.tokenString!)&user_newpassword=\(config.user_newpassword!)&lang=\(translate.message("lang"))"
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_signUp.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerOAuth(true, nil)
                    }
                    else {
                        completionHandlerOAuth(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerOAuth(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    static let sharedInstance = MDBUser()
    
    
}




