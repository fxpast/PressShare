//
//  Creneau.swift
//  GoOtoor
//
//  Description : This class contains all the properties for time slots / créneaux horaires
//
//  Created by MacbookPRV on 04/04/2018.
//  Copyright © 2018 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: Structure Creneau
struct Creneau {
    
    //MARK: Properties Creneau
    var cre_id:Int
    var prod_id:Int
    var cre_dateDebut:Date
    var cre_dateFin:Date
    var cre_repeat:Int // 0: none, 1: daily, 2:weekly
    var cre_mapString:String //le nom du lieu sur la carte
    var cre_latitude:Double
    var cre_longitude:Double
 
    
    //MARK: Initialisation Creneau
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            cre_id = Int(dico["cre_id"] as! String)!
            prod_id = Int(dico["prod_id"] as! String)!
            cre_dateDebut = Date().dateFromServer(dico["cre_dateDebut"] as! String)
            cre_dateFin = Date().dateFromServer(dico["cre_dateFin"] as! String)
            cre_repeat = Int(dico["cre_repeat"] as! String)!
            cre_mapString = dico["cre_mapString"] as! String
            cre_latitude = Double(dico["cre_latitude"] as! String)!
            cre_longitude = Double(dico["cre_longitude"] as! String)!
            
        } else {
            
            cre_id = 0
            prod_id = 0
            cre_dateDebut = Date()
            cre_dateFin = Date()
            cre_repeat = 0
            cre_mapString = ""
            cre_latitude = 0
            cre_longitude = 0
            
        }
            
    }
        
    
}
