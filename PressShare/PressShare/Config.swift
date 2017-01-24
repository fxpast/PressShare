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
    var product_maj:Bool!
    var product_add:Bool!
    var transaction_maj:Bool!
    var vendeur_maj:Bool!
    var mess_badge:Int!
    var trans_badge:Int!
    var balance:Double!
    var failure_count:Int!
    var level:Int!
    var message_maj:Bool!
    
    
    
    
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
        product_maj = false
        product_add = false
        vendeur_maj = false
        transaction_maj = false
        mess_badge = 0
        trans_badge = 0
        balance = 0
        failure_count = 0
        level = 0
        message_maj = false
    }
    
    static let sharedInstance = Config()
    
}
