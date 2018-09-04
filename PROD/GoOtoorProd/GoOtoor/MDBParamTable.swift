//
//  MDBParamTable.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: ParamTable methods
class MDBParamTable {
    
    let translate = TranslateMessage.sharedInstance
    
    func getAllParamTables(completionHandlerParamTables: @escaping (_ success: Bool, _ paramTablesArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerParamTables(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getAllParamTables.php")!)
        // Set Request Body
        let body: String = "lang=\(translate.message("lang"))"
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allparamtables"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerParamTables(true, resultArray, nil)
                    }
                    else {
                        completionHandlerParamTables(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerParamTables(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    static let sharedInstance = MDBParamTable()
    
}

