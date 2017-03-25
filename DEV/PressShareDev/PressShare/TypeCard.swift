//
//  TypeCard.swift
//  PressShare
//
//  Description : This class contains all properties for type of card as master card , visa
//
//  Created by MacbookPRV on 05/02/2017.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation

struct TypeCard {
    
    //MARK: Properties
    
    var typeCard_id:Int
    var typeCard_ImageUrl:String
    var typeCard_Wording:String
    
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            typeCard_id = Int(dico["typeCard_id"] as! String)!
            typeCard_ImageUrl = dico["typeCard_ImageUrl"] as! String
            typeCard_Wording = dico["typeCard_Wording"] as! String
            
            
        }
        else {
            typeCard_id = 0
            typeCard_ImageUrl = ""
            typeCard_Wording = ""
            
        }
        
    }
    
}


//MARK: TypeCards Array
class TypeCards {
    
    var typeCardsArray :[[String:AnyObject]]!
    static let sharedInstance = TypeCards()
    
}


//MARK: TypeCard methods
class MDBTypeCard {
    
    let translate = TranslateMessage.sharedInstance
    
    func getAllTypeCards(completionHandlerTypeCards: @escaping (_ success: Bool, _ typeCardsArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerTypeCards(false, nil, translate.message("errorConnection"))
            return
        }

        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getAllTypeCards.php")!)
        let body: String = "lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["alltypecards"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerTypeCards(true, resultArray, nil)
                    }
                    else {
                        completionHandlerTypeCards(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerTypeCards(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    static let sharedInstance = MDBTypeCard()
    
    
}

