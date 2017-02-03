//
//  Commercant.swift
//  PressShare
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: Structure Commercant
struct Commercant {
    
    //MARK: Properties Commercant
    
    var VERSION:Int
    var TYPE:String
    var SITE:Int
    var RANG:Int
    var IDENTIFIANT:Int
    var LOGIN:Int
    var CLE:String
    
    //MARK: Initialisation Commercant
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            VERSION = Int(dico["VERSION"] as! String)!
            TYPE = dico["TYPE"] as! String
            SITE = Int(dico["SITE"] as! String)!
            RANG = Int(dico["RANG"] as! String)!
            IDENTIFIANT = Int(dico["IDENTIFIANT"] as! String)!
            LOGIN = Int(dico["LOGIN"] as! String)!
            CLE = dico["CLE"] as! String
            
        }
        else {
            VERSION = 0
            TYPE = ""
            SITE = 0
            RANG = 0
            IDENTIFIANT = 0
            LOGIN = 0
            CLE = ""
        }
        
    }
    
    
}
