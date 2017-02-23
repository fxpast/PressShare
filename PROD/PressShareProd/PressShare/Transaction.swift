
//
//  Transaction.swift
//  PressShare
//
//  Description : This class contains all the properties for buy / exchange product
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation


//MARK: Structure Transaction
struct Transaction {
    
    //MARK: Properties Transaction
    
    
    
    var trans_id:Int
    var trans_date:Date
    var trans_type:Int   //1 : Buy. 2 : Exchange
    var trans_wording:String
    var prod_id:Int
    var trans_amount:Double
    var client_id:Int
    var vendeur_id:Int
    var proprietaire:Int
    var trans_valid:Int  //0 : La transaction en cours. 1 : La transaction a été annulée. 2 : La transaction est confirmée.
    var trans_avis:String  //interlocuteur, conformite, absence, "tap text"
    var trans_arbitrage:Bool
    
    
    
    /*
     var NUMQUESTION:Int
     var MONTANT:Int
     var DEVISE:Int
     var REFERENCE:String
     var DATEQ:Int
     var ACQUEREUR:String
     var ACTIVITE:Int
     var ARCHIVAGE:String
     var DATENAISS:Int
     var PAYS:String
     var user_id:Int
     */
    
    //MARK: Initialisation Transaction
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            trans_id = Int(dico["trans_id"] as! String)!
            trans_date = Date().dateFromString(dico["trans_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            trans_type = Int(dico["trans_type"] as! String)!
            trans_wording = dico["trans_wording"] as! String
            prod_id = Int(dico["prod_id"] as! String)!
            trans_amount = Double(dico["trans_amount"] as! String)!
            vendeur_id = Int(dico["vendeur_id"] as! String)!
            client_id = Int(dico["client_id"] as! String)!
            proprietaire = Int(dico["proprietaire"] as! String)!
            trans_valid = Int(dico["trans_valid"] as! String)!
            trans_avis = dico["trans_avis"] as! String
            trans_arbitrage = (Int(dico["trans_arbitrage"] as! String)! == 0) ? false : true

            /*
             NUMQUESTION = Int(dico["NUMQUESTION"] as! String)!
             MONTANT = Int(dico["MONTANT"] as! String)!
             DEVISE = Int(dico["DEVISE"] as! String)!
             REFERENCE = dico["REFERENCE"] as! String
             DATEQ = Int(dico["DATEQ"] as! String)!
             ACQUEREUR = dico["ACQUEREUR"] as! String
             ACTIVITE = Int(dico["DATEQ"] as! String)!
             ARCHIVAGE = dico["ARCHIVAGE"] as! String
             DATENAISS = Int(dico["DATENAISS"] as! String)!
             PAYS = dico["PAYS"] as! String
             user_id = Int(dico["user_id"] as! String)!
             */
            
        }
        else {
            
            trans_id = 0
            trans_date = Date()
            trans_type = 0
            trans_wording = ""
            prod_id = 0
            trans_amount = 0
            vendeur_id = 0
            client_id = 0
            proprietaire = 0
            trans_valid = 0
            trans_avis = ""
            trans_arbitrage = false
            
            
            /*
             NUMQUESTION = 0
             MONTANT = 0
             DEVISE = 0
             REFERENCE = ""
             DATEQ = 0
             ACQUEREUR = ""
             ACTIVITE = 0
             ARCHIVAGE = ""
             DATENAISS = 0
             PAYS = ""
             user_id = 0
             */
            
        }
        
    }
    
    
}


//MARK: Transactions Array
class Transactions {
    
    var transactionArray :[[String:AnyObject]]!
    static let sharedInstance = Transactions()
    
}

class MDBTransact {
    
    let translate = TranslateMessage.sharedInstance
    
    func getAllTransactions(_ userId:Int, completionHandlerTransactions: @escaping (_ success: Bool, _ transactionArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
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
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUpdTrans(false, translate.message("errorConnection"))
            return
        }
   
        // Create your request string with parameter name as defined in PHP file
        let body: String = "trans_id=\(transaction.trans_id)&trans_avis=\(transaction.trans_avis)&trans_valid=\(transaction.trans_valid)&lang=\(translate.message("lang"))"
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
        
        guard  BlackBox.sharedInstance.isConnectedToNetwork() == true else {
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
