//
//  MDBTransact.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation



//MARK: Transaction methods
class MDBTransact {
    
    let translate = TranslateMessage.sharedInstance
    
    
    
    
    func getAllTransactions(_ userId:Int, completionHandlerTransactions: @escaping (_ success: Bool, _ transactionArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerTransactions(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getAllTransactions.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["alltransactions"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerTransactions(true, resultArray, nil)
                    }
                    else {
                        completionHandlerTransactions(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerTransactions(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    
    func setUpdateTransaction(_ transaction: Transaction, completionHandlerUpdTrans: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUpdTrans(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "trans_id=\(transaction.trans_id)&trans_avis=\(transaction.trans_avis)&trans_valid=\(transaction.trans_valid)&trans_note=\(transaction.trans_note)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_updateTransaction.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    print(res)
                    if (res["success"] == "1") {
                        completionHandlerUpdTrans(true, nil)
                    }
                    else {
                        completionHandlerUpdTrans(false, self.translate.message("errorUpdateTrans"))
                        
                    }
                    
                }
                else {
                    completionHandlerUpdTrans(false, errorStr)
                }
                
            })
            
        })
        
        
        task.resume()
        
    }
    
    
    func setAddTransaction(_ transaction: Transaction, completionHandlerAddTrans: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerAddTrans(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "trans_type=\(transaction.trans_type)&trans_valid=\(transaction.trans_valid)&client_id=\(transaction.client_id)&prod_id=\(transaction.prod_id)&trans_wording=\(transaction.trans_wording)&trans_amount=\(transaction.trans_amount)&vendeur_id=\(transaction.vendeur_id)&proprietaire=\(transaction.proprietaire)&trans_avis=\(transaction.trans_avis)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_addTransaction.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerAddTrans(true, nil)
                    }
                    else {
                        completionHandlerAddTrans(false, self.translate.message("errorAddTrans"))
                        
                    }
                    
                }
                else {
                    completionHandlerAddTrans(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    static let sharedInstance = MDBTransact()
    
}

