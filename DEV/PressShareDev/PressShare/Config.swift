//
//  Config.swift
//  PressShare
//
//  Description : This class is a singletion with global variables
//
//  Created by MacbookPRV on 14/01/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation
import MapKit

class Config {
    
    
    var user_id:Int!
    var user_pseudo:String!
    var user_email:String!
    var latitude:Double!
    var longitude:Double!
    var mapString:String!
    var user_nom:String!
    var user_prenom:String!
    var user_newpassword:Bool!
    var previousView:String!
    var user_adresse:String!
    var user_codepostal:String!
    var user_ville:String!
    var user_pays:String!
    var verifpassword:String!
    var user_pass:String!
    var user_lastpass:String!
    var transaction_maj:Bool!
    var mess_badge:Int!
    var trans_badge:Int!
    var balance:Double!
    var failure_count:Int!
    var level:Int!
    var message_maj:Bool!
    var distanceProduct:CLLocationDistance! //product are grouped and display according to this distance in meters
    var regionGeoLocat:CLLocationDistance! //region of user geolocalization and displayed in meters
    var regionProduct:CLLocationDistance! //region of product dowload on the map in meters
    var commisPourcBuy:Double! //commission pourcentage for buy product
    var commisFixEx:Double! //commission fix for exchange product
    var minLongitude:Double!
    var maxLongitude:Double!
    var minLatitude:Double!
    var maxLatitude:Double!
    var tokenString:String!
    var typeCard_id:Int!
    var isReturnToTab:Bool!
    var maxDayTrigger:Int!
    var isRememberMe:Bool!
    var clientTokenBraintree:String!
    var user_braintreeID:String!
    var subscriptAmount:Double! //amount to deposit when subcribing
    var minimumAmount:Double! // minimum amount in the balance
    var heightImage:CGFloat!
    var widthImage:CGFloat!
    var isTimer:Bool!
    var dureeTimer:Double!
    var user_note: Int! //note per 5 stars
    var user_countNote: Int! //counter of note
    var colorApp:String! //theme color app
    var colorAppLabel:String! //theme color app label
    var colorAppText:String! //theme color app text
    var colorAppPlHd:String! //theme color app placeholder
    var colorAppBt:String! //theme color app button
    
    func cleaner()  {
        
        user_id = 0
        user_pseudo = ""
        user_email = ""
        latitude = 0
        longitude = 0
        mapString = ""
        user_nom = ""
        user_prenom = ""
        user_newpassword = false
        previousView = ""
        user_adresse = ""
        user_codepostal = ""
        user_ville = ""
        user_pays = ""
        verifpassword = ""
        user_pass = ""
        user_lastpass = ""
        transaction_maj = false
        mess_badge = 0
        trans_badge = 0
        balance = 0
        failure_count = 0
        level = 0
        message_maj = false
        minLongitude = 0
        maxLongitude = 0
        minLatitude = 0
        maxLatitude = 0
        tokenString = ""
        typeCard_id = 0
        isReturnToTab = false
        clientTokenBraintree = ""
        user_braintreeID = ""
        subscriptAmount = 0
        minimumAmount = 0
        heightImage = 0
        widthImage = 0
        isTimer = false
        dureeTimer = 5.0
        user_note = 0
        user_countNote = 0
        colorApp = "FFDBA3"
        colorAppLabel = "AAAAAA"
        colorAppText = "000000"
        colorAppPlHd = "D8D8D8"
        colorAppBt = "5858FA"
        
        //5858FA
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("colorApp")!.path

        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? String) == nil  {
            NSKeyedArchiver.archiveRootObject(colorApp, toFile: filePath)
        }
        else {
            colorApp = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! String
        }
        
        let filePathLab  = url.appendingPathComponent("colorAppLabel")!.path
        
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePathLab) as? String) == nil  {
            NSKeyedArchiver.archiveRootObject(colorAppLabel, toFile: filePathLab)
        }
        else {
            colorAppLabel = NSKeyedUnarchiver.unarchiveObject(withFile: filePathLab) as! String
        }
        
        let filePathTx  = url.appendingPathComponent("colorAppText")!.path
        
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePathTx) as? String) == nil  {
            NSKeyedArchiver.archiveRootObject(colorAppText, toFile: filePathTx)
        }
        else {
            colorAppText = NSKeyedUnarchiver.unarchiveObject(withFile: filePathTx) as! String
        }
        
        let filePathPl  = url.appendingPathComponent("colorAppPlHd")!.path
        
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePathPl) as? String) == nil  {
            NSKeyedArchiver.archiveRootObject(colorAppPlHd, toFile: filePathPl)
        }
        else {
            colorAppPlHd = NSKeyedUnarchiver.unarchiveObject(withFile: filePathPl) as! String
        }
        
        let filePathBt  = url.appendingPathComponent("colorAppBt")!.path
        
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePathBt) as? String) == nil  {
            NSKeyedArchiver.archiveRootObject(colorAppBt, toFile: filePathBt)
        }
        else {
            colorAppBt = NSKeyedUnarchiver.unarchiveObject(withFile: filePathBt) as! String
        }
        
        
        
        MDBParamTable.sharedInstance.getAllParamTables { (success, paramTablesArray, errorString) in
           
            if success {
                
                ParamTables.sharedInstance.paramTableArray = paramTablesArray
                let param = ParamTable(dico: ParamTables.sharedInstance.paramTableArray[0])
                self.distanceProduct = param.distanceProduct
                self.regionGeoLocat = param.regionGeoLocat
                self.regionProduct = param.regionProduct
                self.commisPourcBuy = param.commisPourcBuy
                self.commisFixEx = param.commisFixEx
                self.maxDayTrigger = param.maxDayTrigger
                self.subscriptAmount = param.subscriptAmount
                self.minimumAmount = param.minimumAmount
                self.colorApp = param.colorApp
                NSKeyedArchiver.archiveRootObject(self.colorApp, toFile: filePath)
                self.colorAppLabel = param.colorAppLabel
                NSKeyedArchiver.archiveRootObject(self.colorAppLabel, toFile: filePathLab)
                self.colorAppText = param.colorAppText
                NSKeyedArchiver.archiveRootObject(self.colorAppText, toFile: filePathTx)
                self.colorAppPlHd = param.colorAppPlHd
                NSKeyedArchiver.archiveRootObject(self.colorAppPlHd, toFile: filePathPl)
                self.colorAppBt = param.colorAppBt
                NSKeyedArchiver.archiveRootObject(self.colorAppBt, toFile: filePathBt)
                
                
            }
            else {
                self.distanceProduct = 0
                self.regionGeoLocat = 0
                self.regionProduct = 0
                self.commisPourcBuy = 0
                self.commisFixEx = 0
                self.maxDayTrigger = 0
                self.subscriptAmount = 0
                self.minimumAmount = 0
            }
        }
        
    }
    
    static let sharedInstance = Config()
    
}
