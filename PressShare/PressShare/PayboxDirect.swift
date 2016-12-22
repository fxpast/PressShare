//
//  Paybox Direct swift
//  PressShare
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation

struct ResponseRequete {
    
    var NUMTRANS:Int
    var NUMAPPEL:Int
    var NUMQUESTION:Int
    var SITE:Int
    var RANG:Int
    var AUTORISATION:Int
    var CODEREPONSE:Int
    var COMMENTAIRE:String
    var REFABONNE:String
    var PORTEUR:String
    
    //Autres
    /*
    var REMISE:Int
    var SHA_1:String
    var STATUS:String
    var TYPECARTE:String
    */
    
    
    //MARK: Initialisation Carte Bancaire
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            NUMTRANS = Int(dico["NUMTRANS"] as! String)!
            NUMAPPEL = Int(dico["NUMAPPEL"] as! String)!
            NUMQUESTION = Int(dico["NUMQUESTION"] as! String)!
            SITE = Int(dico["SITE"] as! String)!
            RANG = Int(dico["RANG"] as! String)!
            AUTORISATION = Int(dico["AUTORISATION"] as! String)!
            CODEREPONSE = Int(dico["CODEREPONSE"] as! String)!
            COMMENTAIRE = dico["COMMENTAIRE"] as! String
            REFABONNE = dico["REFABONNE"] as! String
            PORTEUR = dico["PORTEUR"] as! String
            
        }
        else {
            
            NUMTRANS = 0
            NUMAPPEL = 0
            NUMQUESTION = 0
            SITE = 0
            RANG = 0
            AUTORISATION = 0
            CODEREPONSE = 0
            COMMENTAIRE = ""
            REFABONNE = ""
            PORTEUR = ""
        }
        
    }
    
    
    
}



/*
func creationWallet(_ carte: CarteBancaire, commercant:Commercant, transaction:Transaction, completionHandlerCreWallet: @escaping (_ success: Bool, _ walletArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
    
    // Create your request string with parameter name as defined in PHP file
    let body: String = "VERSION=\(commercant.VERSION)&TYPE=\(commercant.TYPE)&SITE=\(commercant.SITE)&RANG=\(commercant.RANG)&CLE=\(commercant.CLE)&NUMQUESTION=\(transaction.NUMQUESTION)&MONTANT=\(transaction.MONTANT)&DEVISE=\(transaction.DEVISE)&REFERENCE=\(transaction.REFERENCE)&PORTEUR=\(carte.PORTEUR)&DATEVAL=\(carte.DATEVAL)&CVV=\(carte.CVV)&REFABONNE=\(carte.REFABONNE)&ACTIVITE=\(transaction.ACTIVITE)&DATEQ=\(transaction.DATEQ)&PAYS=\(transaction.PAYS)"
    // Create Data from request
    let request = NSMutableURLRequest(url: URL(string: "https://preprod-ppps.paybox.com/PPPS.php")!)
    // set Request Type
    request.httpMethod = "POST"
    // Set content-type
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    // Set Request Body
    request.httpBody = body.data(using: String.Encoding.utf8)
    
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHandlerCreWallet(false, nil, "There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHandlerCreWallet(false, nil, "Your request returned a status code other than 2xx! : \(StatusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHandlerCreWallet(false, nil, "No data was returned by the request!")
            return
            
        }
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerCreWallet(false, nil, "Could not parse the data as JSON: '\(data)'")
            
            return
            
        }
        //print(parsedResult)
        
        let resultDico = parsedResult as! [String:AnyObject]
        let resultArray = resultDico["allproduits"] as! [[String:AnyObject]]
        
        
        if resultDico["success"] as! String == "1" {
            completionHandlerCreWallet(true, resultArray, nil)
        }
        else {
            
            completionHandlerCreWallet(false, nil, resultDico["error"] as? String)
            
        }
        
    }) 
    
    
    task.resume()
    
}

*/




