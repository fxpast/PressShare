//
//  MDBCreneau.swift
//  GoOtoor
//
//  Created by MacbookPRV on 04/04/2018.
//  Copyright © 2018 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: Creneau methods

class MDBCreneau {
    
    let translate = TranslateMessage.sharedInstance
    
    
    func getCreneauxProd(_ prod_id:Int, completionHandlerCreneaux: @escaping (_ success: Bool, _ creneauArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerCreneaux(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getCreneauxProd.php")!)
        let body: String = "prod_id=\(prod_id)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allcreneaux"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerCreneaux(true, resultArray, nil)
                    }
                    else {
                        completionHandlerCreneaux(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerCreneaux(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
 
    
    func setDeleteCreneau(_ creneau: Creneau, completionHandlerDelCreneau: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerDelCreneau(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "cre_id=\(creneau.cre_id)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_delCreneau.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerDelCreneau(true, nil)
                    }
                    else {
                        completionHandlerDelCreneau(false, self.translate.message("impossibleDelCre"))
                        
                    }
                    
                }
                else {
                    completionHandlerDelCreneau(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
  
    
    func setAddCreneau(_ creneau: Creneau, completionHandlerCreneaux: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerCreneaux(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        
        var body: String = "prod_id=\(creneau.prod_id)&cre_dateFin=\(creneau.cre_dateFin)&cre_dateDebut=\(creneau.cre_dateDebut)&cre_repeat=\(creneau.cre_repeat)&cre_latitude=\(creneau.cre_latitude)&cre_longitude=\(creneau.cre_longitude)&cre_mapString=\(creneau.cre_mapString)&lang=\(translate.message("lang"))"
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_addCreneau.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerCreneaux(true, nil)
                    }
                    else {
                        completionHandlerCreneaux(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerCreneaux(false, errorStr)
                }
                
            })
            
            
            
        })
        
        
        task.resume()
        
    }
    
    
    
    
    static let sharedInstance = MDBCreneau()
    
    
}
