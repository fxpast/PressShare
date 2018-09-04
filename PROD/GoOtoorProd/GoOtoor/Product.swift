//
//  Data.swift
//  GoOtoor
//
//  Description : This class contains all properties for item to buy / exchange
//
//  Created by MacbookPRV on 11/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit


struct Product {
    
    //MARK: Properties
    
    
    var prod_id:Int
    var prod_image:UIImage // stocker l'image
    var prod_imageUrl:String //stoker url de l'image
    var prod_nom:String
    var prod_date:Date
    var prod_prix:Double
    var prod_by_user:Int //le vendeur
    var prod_oth_user:Int //le client
    var prod_by_cat:Int
    var prod_latitude:Double
    var prod_longitude:Double
    var prod_mapString:String //le nom du lieu sur la carte
    var prod_comment:String
    var prod_etat:Int //number of star
    var prod_hidden:Bool
    var prod_echange:Bool // autoriser l'echange de produit
    var prodImageOld:String
    var prod_closed:Bool
    var state:PhotoRecordState
    
    
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            prod_id = Int(dico["prod_id"] as! String)!
            prod_imageUrl = dico["prod_imageUrl"] as! String            
            prod_nom = dico["prod_nom"] as! String
            prod_date = Date().dateFromServer(dico["prod_date"] as! String)
            prod_prix = Double(dico["prod_prix"] as! String)!
            prod_by_user = Int(dico["prod_by_user"] as! String)!
            prod_oth_user = Int(dico["prod_oth_user"] as! String)!
            prod_by_cat = Int(dico["prod_by_cat"] as! String)!
            prod_latitude = Double(dico["prod_latitude"] as! String)!
            prod_longitude = Double(dico["prod_longitude"] as! String)!
            prod_mapString = dico["prod_mapString"] as! String
            prod_comment = dico["prod_comment"] as! String
            prod_etat = Int(dico["prod_etat"] as! String)!            
            prod_hidden = (Int(dico["prod_hidden"] as! String)! == 0) ? false : true
            prod_echange = (Int(dico["prod_echange"] as! String)! == 0) ? false : true
            prod_closed = (Int(dico["prod_closed"] as! String)! == 0) ? false : true
            
        }
        else {
            prod_id = 0
            prod_imageUrl = ""
            prod_nom = ""
            prod_date = Date()
            prod_prix = 0
            prod_by_user = 0
            prod_oth_user = 0
            prod_by_cat = 0
            prod_latitude = 0
            prod_longitude = 0
            prod_mapString = ""
            prod_comment = ""
            prod_etat = 0
            prod_hidden=false
            prod_echange=false
            prod_closed=false
            
        }
        
        prod_image = #imageLiteral(resourceName: "noimage")
        state = PhotoRecordState.New
        prodImageOld = ""
        
    }
    
}




