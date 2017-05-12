//
//  ParamTable.swift
//  PressShare
//
//  Description : This class contains all properties for setting general app's informations
//
//  Created by MacbookPRV on 30/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation


struct ParamTable {
    
    //MARK: Properties
    
    var param_id:Int
    var distanceProduct:Double
    var regionGeoLocat:Double
    var regionProduct:Double
    var commisPourcBuy:Double
    var commisFixEx:Double
    var maxDayTrigger:Int
    var subscriptAmount:Double!
    var minimumAmount:Double!
    var colorApp:String!
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            param_id = Int(dico["param_id"] as! String)!
            distanceProduct = Double(dico["distanceProduct"] as! String)!
            regionGeoLocat = Double(dico["regionGeoLocat"] as! String)!
            regionProduct = Double(dico["regionProduct"] as! String)!
            commisPourcBuy = Double(dico["commisPourcBuy"] as! String)!
            commisFixEx = Double(dico["commisFixEx"] as! String)!
            maxDayTrigger = Int(dico["maxDayTrigger"] as! String)!
            subscriptAmount = Double(dico["subscriptAmount"] as! String)!
            minimumAmount = Double(dico["minimumAmount"] as! String)!
            colorApp = dico["colorApp"] as! String
        }
        else {
            param_id = 0
            distanceProduct = 0
            regionGeoLocat = 0
            regionProduct = 0
            commisPourcBuy = 0
            commisFixEx = 0
            maxDayTrigger = 0
            subscriptAmount = 0
            minimumAmount = 0
            colorApp = ""
        }
        
    }
    
}


//MARK: ParamTables Array
class ParamTables {
    
    var paramTableArray :[[String:AnyObject]]!
    static let sharedInstance = ParamTables()
    
}


//MARK: ParamTable methods
class MDBParamTable {
    
    let translate = TranslateMessage.sharedInstance
    
    func getAllParamTables(completionHandlerParamTables: @escaping (_ success: Bool, _ paramTablesArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
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




