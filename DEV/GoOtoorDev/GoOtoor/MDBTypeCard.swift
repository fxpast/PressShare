//
//  MDBTypeCard.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: TypeCard methods
class MDBTypeCard {
    
    let translate = TranslateMessage.sharedInstance
    
    func getAllTypeCards(completionHandlerTypeCards: @escaping (_ success: Bool, _ typeCardsArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
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

