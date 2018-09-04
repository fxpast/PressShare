//
//  ParamTable.swift
//  GoOtoor
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
    var colorAppLabel:String!
    var colorAppText:String!
    var colorAppPlHd:String!
    var colorAppBt:String!
    
  
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
            colorAppLabel = dico["colorAppLabel"] as! String
            colorAppText = dico["colorAppText"] as! String
            colorAppPlHd = dico["colorAppPlHd"] as! String
            colorAppBt = dico["colorAppBt"] as! String
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
            colorAppLabel = ""
            colorAppText = ""
            colorAppPlHd = ""
            colorAppBt = ""
        }
        
    }
    
}





