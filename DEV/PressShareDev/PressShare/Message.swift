//
//  Data.swift
//  PressShare
//
//  Description : This class contains all properties for messaging between users
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
    var product_id:Int
    var date_ajout:Date
    var contenu:String
    var deja_lu:Bool
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            
            message_id = Int(dico["message_id"] as! String)!
            expediteur = Int(dico["expediteur"] as! String)!
            destinataire = Int(dico["destinataire"] as! String)!
            proprietaire = Int(dico["proprietaire"] as! String)!
            vendeur_id = Int(dico["vendeur_id"] as! String)!
            client_id = Int(dico["client_id"] as! String)!
            product_id = Int(dico["product_id"] as! String)!
            date_ajout = Date().dateFromString(dico["date_ajout"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            contenu = dico["contenu"] as! String
            deja_lu = (Int(dico["deja_lu"] as! String)! == 0) ? false : true
        }
        else {
            message_id = 0
            expediteur = 0
            destinataire = 0
            proprietaire = 0
            vendeur_id = 0
            client_id = 0
            product_id = 0
            date_ajout = Date()
            contenu = ""
            deja_lu = false
            
            
            
        }
        
    }
    
}


//MARK: Messages Array
class Messages {
    
    var MessagesArray :[[String:AnyObject]]!
    static let sharedInstance = Messages()
    
}


//MARK: Message methods
class MDBMessage {
    
    let translate = TranslateMessage.sharedInstance
    
    
    func getMessagesProd(_ message:Message, completionHandlerMessages: @escaping (_ success: Bool, _ messageArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerMessages(false, nil, translate.message("errorConnection"))
            return
        }

        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getMessagesProd.php")!)
        let body: String = "product_id=\(message.product_id)&product_id=\(message.proprietaire)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allmessages"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerMessages(true, resultArray, nil)
                    }
                    else {
                        completionHandlerMessages(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerMessages(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func checkMessage(_ userId:Int, completionHandlerCheck: @escaping (_ success: Bool, _ count: Int, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerCheck(false, 0, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_checkMessage.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultCount = Int(resultDico["allmessages"] as! String)
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerCheck(true, resultCount!, nil)
                    }
                    else {
                        completionHandlerCheck(false, 0, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerCheck(false, 0, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func getAllMessages(_ userId:Int, completionHandlerMessages: @escaping (_ success: Bool, _ messageArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerMessages(false, nil, translate.message("errorConnection"))
            return
        }

        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getAllMessages.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allmessages"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerMessages(true, resultArray, nil)
                    }
                    else {
                        completionHandlerMessages(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerMessages(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    
    func setDeleteMessage(_ message: Message, completionHandlerDelMessage: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerDelMessage(false, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String = "message_id=\(message.message_id)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_delMessage.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerDelMessage(true, nil)
                    }
                    else {
                        completionHandlerDelMessage(false, self.translate.message("impossibleDeldMes"))
                        
                    }
                    
                }
                else {
                    completionHandlerDelMessage(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    
    func setUpdateMessage(_ message: Message, completionHandlerUpdate: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUpdate(false, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        let body: String = "message_id=\(message.message_id)&deja_lu=\(message.deja_lu)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_updateMessage.php")!)
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
    
    
    func setAddMessage(_ message: Message, completionHandlerMessages: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerMessages(false, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        
        let body: String = "expediteur=\(message.expediteur)&destinataire=\(message.destinataire)&vendeur_id=\(message.vendeur_id)&client_id=\(message.client_id)&product_id=\(message.product_id)&contenu=\(message.contenu)&lang=\(translate.message("lang"))"
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_addMessage.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerMessages(true, nil)
                    }
                    else {
                        completionHandlerMessages(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerMessages(false, errorStr)
                }
                
            })
            
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func setPushNotification(_ message: Message, completionHandlerPush: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerPush(false, translate.message("errorConnection"))
            return
        }

        // Create your request string with parameter name as defined in PHP file
        
        let body: String = "destinataire=\(message.destinataire)&product_id=\(message.product_id)&contenu=\(message.contenu)&lang=\(translate.message("lang"))"
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_PushNotifications.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerPush(true, nil)
                    }
                    else {
                        completionHandlerPush(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerPush(false, errorStr)
                }
                
            })
            
            
            
        })
        
        
        task.resume()
        
    }
    
    static let sharedInstance = MDBMessage()
    
}






