//
//  MDBFeedback.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: Feedback methods
class MDBFeedback {
    
    let translate = TranslateMessage.sharedInstance
    
    
    func setAddFeedback(_ feedback: Feedback, completionHandleFeedback: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandleFeedback(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "comment=\(feedback.comment)&origin=\(feedback.origin)&lang=\(translate.message("lang"))"
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_addFeedback.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandleFeedback(true, nil)
                    }
                    else {
                        completionHandleFeedback(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandleFeedback(false, errorStr)
                }
                
            })
            
            
            
        })
        
        
        task.resume()
        
    }
    
    
    
    
    static let sharedInstance = MDBFeedback()
    
    
}

