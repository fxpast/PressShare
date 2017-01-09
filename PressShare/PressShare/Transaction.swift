
//
//  Transaction.swift
//  PressShare
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


//Todo :les valeurs possibles et leurs significations des propriétés :trans_type, trans_valide et trans_avis

//Todo :Les commentaires doivent être en anglais
//Todo :Les classes doivent avoir en entete l'auteur , la date de création, de modification, la definitions, leurs paramètres
//Todo :Les methodes doivent avoir en entete leur definition, leurs paramètre et leur @return


import Foundation


//MARK: Structure Transaction
struct Transaction {
    
    //MARK: Properties Transaction
    
    
    
    var trans_id:Int
    var trans_date:Date
    var trans_type:Int   //1 : Trade. 2 : Exchange
    var trans_wording:String
    var prod_id:Int
    var trans_amount:Double
    var client_id:Int
    var vendeur_id:Int
    var proprietaire:Int
    var trans_valide:Int  //1 : La transaction a été annulée. 2 : La transaction est confirmée.
    var trans_avis:String
    
    
    
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
            trans_valide = Int(dico["trans_valide"] as! String)!
            trans_avis = dico["trans_avis"] as! String
            
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
            trans_valide = 0
            trans_avis = ""
            
            
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
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_getAllTransactions.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.lang!)"
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
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "trans_id=\(transaction.trans_id)&trans_avis=\(transaction.trans_avis)&trans_valide=\(transaction.trans_valide)&lang=\(translate.lang!)"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_updateTransaction.php")!)
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerUpdTrans(true, nil)
                    }
                    else {
                        completionHandlerUpdTrans(false, self.translate.errorUpdateTrans!)
                        
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
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "trans_type=\(transaction.trans_type)&trans_valide=\(transaction.trans_valide)&client_id=\(transaction.client_id)&prod_id=\(transaction.prod_id)&trans_wording=\(transaction.trans_wording)&trans_amount=\(transaction.trans_amount)&vendeur_id=\(transaction.vendeur_id)&proprietaire=\(transaction.proprietaire)&trans_avis=\(transaction.trans_avis)&lang=\(translate.lang!)"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_addTransaction.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerAddTrans(true, nil)
                    }
                    else {
                        completionHandlerAddTrans(false, self.translate.errorAddTrans!)
                        
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
