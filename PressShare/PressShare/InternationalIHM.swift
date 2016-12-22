//
//  InternationalIHM.swift
//  PressShare
//
//  Created by MacbookPRV on 24/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo :Les commentaires doivent être en anglais
//Todo :Les classes doivent avoir en entete l'auteur , la date de création, de modification, la definitions, leurs paramètres
//Todo :Les methodes doivent avoir en entete leur definition, leurs paramètre et leur @return

import Foundation


class InternationalIHM {
    
    
    
    private var dico:[String:AnyObject]
    private var langue:Int
    
    
    
    init () {
        
        dico = [String:AnyObject]()
        langue = 0
        
        let plistPath = Bundle.main.path(forResource: "InternationalIHM", ofType: "plist")
        let plistXML = FileManager.default.contents(atPath: plistPath!)
        
        do {
            dico = try PropertyListSerialization.propertyList(from: plistXML!, options: .mutableContainersAndLeaves, format: nil) as! [String : AnyObject]
        }
        catch {
            
        }
        
        
        let defaults = UserDefaults.standard
        langue = defaults.integer(forKey: "langue_de_preference")
        if langue == 0 {
            let langueIphone = Locale.preferredLanguages[0]
            if langueIphone.contains("fr-") {
                langue = 1
            }
            else {
                langue = 2
            }
            
        }
        
    }
    
    
    static let sharedInstance = InternationalIHM()
    
    
    //MARK: Ouverture de l'application
    
    var lang:String!
        {
        
        get {
            let resultat = dico["lang"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var devise:String!
        {
        
        get {
            let resultat = dico["devise"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var connectToPress:String!
        {
        
        get {
            let resultat = dico["connectToPress"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var myAbsence:String!
        {
        
        get {
            let resultat = dico["myAbsence"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var other:String!
        {
        
        get {
            let resultat = dico["other"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var interlocutor:String!
        {
        
        get {
            let resultat = dico["interlocutor"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var compliant:String!
        {
        
        get {
            let resultat = dico["compliant"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var subscribe:String!
        {
        
        get {
            let resultat = dico["subscribe"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var unsubscribe:String!
        {
        
        get {
            let resultat = dico["unsubscribe"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var wording:String!
        {
        
        get {
            let resultat = dico["wording"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var date:String!
        {
        
        get {
            let resultat = dico["date"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var type:String!
        {
        
        get {
            let resultat = dico["type"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var amount:String!
        {
        
        get {
            let resultat = dico["amount"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var balance:String!
        {
        
        get {
            let resultat = dico["balance"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var withdrawal:String!
        {
        
        get {
            let resultat = dico["withdrawal"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var deposit:String!
        {
        
        get {
            let resultat = dico["deposit"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
 
    var product:String!
        {
        
        get {
            let resultat = dico["product"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var signin:String!
        {
        
        get {
            let resultat = dico["signin"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var signup:String!
        {
        
        get {
            let resultat = dico["signup"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var lostPassword:String!
        {
        
        get {
            let resultat = dico["lostPassword"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var anonyme:String!
        {
        
        get {
            let resultat = dico["anonyme"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    
    //MARK: Page avec Map
    
    var map:String!
        {
        
        get {
            let resultat = dico["map"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var list:String!
        {
        
        get {
            let resultat = dico["list"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var settings:String!
        {
        
        get {
            let resultat = dico["settings"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    //MARK: Page sur paramètre
    
    var editProfil:String!
        {
        
        get {
            let resultat = dico["editProfil"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var connectInfo:String!
        {
        
        get {
            let resultat = dico["connectInfo"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var mySubscrit:String!
        {
        
        get {
            let resultat = dico["mySubscrit"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var myCB:String!
        {
        
        get {
            let resultat = dico["myCB"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var myNotif:String!
        {
        
        get {
            let resultat = dico["myNotif"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var runTransac:String!
        {
        
        get {
            let resultat = dico["runTransac"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var ExplanTuto:String!
        {
        
        get {
            let resultat = dico["ExplanTuto"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
    }
    
    //MARK: Page sur modifier mon profil
    
    
    var cancel:String!
        {
        
        get {
            let resultat = dico["cancel"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var save:String!
        {
        
        get {
            let resultat = dico["save"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pseudo:String!
        {
        
        get {
            let resultat = dico["pseudo"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var mail:String!
        {
        
        get {
            let resultat = dico["mail"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var password:String!
        {
        
        get {
            let resultat = dico["password"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var nickName:String!
        {
        
        get {
            let resultat = dico["nickName"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var surname:String!
        {
        
        get {
            let resultat = dico["surname"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var adresse:String!
        {
        
        get {
            let resultat = dico["adresse"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var zipCode:String!
        {
        
        get {
            let resultat = dico["zipCode"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var city:String!
        {
        
        get {
            let resultat = dico["city"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var exchange:String!
        {
        
        get {
            let resultat = dico["exchange"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var confirm:String!
        {
        
        get {
            let resultat = dico["confirm"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var trade:String!
        {
        
        get {
            let resultat = dico["trade"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var country:String!
        {
        
        get {
            let resultat = dico["country"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    //MARK: Page sur information de connexion
    
    
    
    var done:String!
        {
        
        get {
            let resultat = dico["done"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var oldPass:String!
        {
        
        get {
            let resultat = dico["oldPass"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var checkPass:String!
        {
        
        get {
            let resultat = dico["checkPass"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var enterEmail:String!
        {
        
        get {
            let resultat = dico["enterEmail"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var newPass:String!
        {
        
        get {
            let resultat = dico["newPass"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    //MARK: Page sur épingle
    
    
    var tapALoc:String!
        {
        
        get {
            let resultat = dico["tapALoc"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var findOnMap:String!
        {
        
        get {
            let resultat = dico["findOnMap"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var description:String!
        {
        
        get {
            let resultat = dico["description"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var price:String!
        {
        
        get {
            let resultat = dico["price"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var comment:String!
        {
        
        get {
            let resultat = dico["comment"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var availableTime:String!
        {
        
        get {
            let resultat = dico["availableTime"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var state:String!
        {
        
        get {
            let resultat = dico["state"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    var exchangeBuy:String!
        {
        
        get {
            let resultat = dico["exchangeBuy"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
}
