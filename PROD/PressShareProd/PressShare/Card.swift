//
//  Card.swift
//  PressShare
//
//  Description : This class contains all properties for card account like visa, paypal
//
//  Created by MacbookPRV on 13/02/2017.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation

struct Card {
    
    //MARK: Properties
    
    var card_id:Int
    var typeCard_id:Int
    var user_id:Int
    var typeCard_ImageUrl:String
    var card_number:String
    var card_lastNumber:String
    var card_owner:String
    var card_date:String
    var card_crypto:String
    var main_card:Bool
    
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            card_id = Int(dico["card_id"] as! String)!
            typeCard_id = Int(dico["typeCard_id"] as! String)!
            user_id = 0
            typeCard_ImageUrl = ""
            card_number = ""
            card_lastNumber = dico["card_lastNumber"] as! String
            card_owner = ""
            card_date = ""
            card_crypto = ""
            main_card = (Int(dico["main_card"] as! String)! == 0) ? false : true
            
        }
        else {
            card_id = 0
            typeCard_id = 0
            typeCard_ImageUrl = ""
            user_id = 0
            card_number = ""
            card_lastNumber = ""
            card_owner = ""
            card_date = ""
            card_crypto = ""
            main_card = false
            
        }
        
    }
    
}


//MARK: TypeCards Array
class Cards {
    
    var cardsArray :[[String:AnyObject]]!
    static let sharedInstance = Cards()
    
}


class MDBCard {
    
    let translate = TranslateMessage.sharedInstance
    
    func getAllCards(user_id:Int, completionHandlerCards: @escaping (_ success: Bool, _ cardsArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerCards(false, nil, translate.message("errorConnection"))
            return
        }

        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getAllCards.php")!)
        let body: String = "user_id=\(user_id)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allcards"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerCards(true, resultArray, nil)
                    }
                    else {
                        completionHandlerCards(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerCards(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func setDeleteCard(_ card: Card, completionHandlerDelCard: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerDelCard(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "card_id=\(card.card_id)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_delCard.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerDelCard(true, nil)
                    }
                    else {
                        completionHandlerDelCard(false, self.translate.message("impossibleDeldPr"))
                        
                    }
                    
                }
                else {
                    completionHandlerDelCard(false, errorStr)
                }
                
            })
            
        })
        
        
        task.resume()
        
    }
    
    
    func setUpdateCard(_ card: Card, completionHandlerUpdCard: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUpdCard(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "card_id=\(card.card_id)&main_card=\(card.main_card)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_updateCard.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerUpdCard(true, nil)
                    }
                    else {
                        completionHandlerUpdCard(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerUpdCard(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func setAddCard(_ card: Card, completionHandlerCard: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerCard(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "typeCard_id=\(card.typeCard_id)&user_id=\(card.user_id)&card_number=\(card.card_number)&card_lastNumber=\(card.card_lastNumber)&card_owner=\(card.card_owner)&card_date=\(card.card_date)&card_crypto=\(card.card_crypto)&lang=\(translate.message("lang"))"
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_addCard.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerCard(true, nil)
                    }
                    else {
                        completionHandlerCard(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerCard(false, errorStr)
                }
                
            })
            
            
            
        })
        
        
        task.resume()
        
    }
    
    
    
    
    static let sharedInstance = MDBCard()
    
    
}

