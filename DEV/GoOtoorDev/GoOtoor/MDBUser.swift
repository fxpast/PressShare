//
//  MDBUser.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: User methods
class MDBUser {
    
    let translate = TranslateMessage.sharedInstance
    
    func getUser(_ userId:Int, completionHandlerUser: @escaping (_ success: Bool, _ usersArray: [[String : AnyObject]]?, _ errorString:String?) -> Void)
    {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
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
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
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
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
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
        
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerOAuth(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_email=\(config.user_email!)&user_pass=\(config.user_pass!)&user_lastpass=\(config.user_lastpass!)&user_newpassword=\(config.user_newpassword)&lang=\(translate.message("lang"))"
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
    
    
    
    func setUpdUserStar(_ config: Config, _ aTransaction: Transaction, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUpdate(false, translate.message("errorConnection"))
            return
        }
        
        var otherId = 0
        if aTransaction.client_id == config.user_id {
            otherId = aTransaction.vendeur_id
        }
        else if aTransaction.vendeur_id == config.user_id {
            otherId = aTransaction.client_id
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_id=\(otherId)&user_note=\(config.user_note!)&user_countNote=\(config.user_countNote!)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_updUserStar.php")!)
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
    
    
    func setUpdateUser(_ config: Config, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
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
        
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerToken(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_id=\(config.user_id!)&user_device=\(config.user_device!)&user_tokenPush=\(config.tokenString!)&lang=\(translate.message("lang"))"
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
        
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerOAuth(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "user_pseudo=\(config.user_pseudo!)&user_pass=\(config.user_pass!)&user_adresse=\(config.user_adresse!)&user_codepostal=\(config.user_codepostal!)&user_nom=\(config.user_nom!)&user_prenom=\(config.user_prenom!)&user_email=\(config.user_email!)&user_pays=\(config.user_pays!)&user_ville=\(config.user_ville!)&user_latitude=\(config.latitude!)&user_longitude=\(config.longitude!)&user_mapString=\(config.mapString!)&user_tokenPush=\(config.tokenString!)&user_newpassword=\(config.user_newpassword)&lang=\(translate.message("lang"))"
        
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

