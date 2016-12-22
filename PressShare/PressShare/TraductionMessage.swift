//
//  TraductionMessage.swift
//  PressShare
//
//  Created by MacbookPRV on 07/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo : Traduction des messages d'alertes anglais / français

//Todo :Les commentaires doivent être en anglais
//Todo :Les classes doivent avoir en entete l'auteur , la date de création, de modification, la definitions, leurs paramètres
//Todo :Les methodes doivent avoir en entete leur definition, leurs paramètre et leur @return


import Foundation

class TraductionMessage {
    
    
    private var dico:[String:AnyObject]
    private var langue:Int
    
    
    
    init () {
        
        dico = [String:AnyObject]()
        langue = 0
        
        let plistPath = Bundle.main.path(forResource: "TraductionMessage", ofType: "plist")
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
    
    static let sharedInstance = TraductionMessage()
    
    var lang:String!
        {
        
        get {
            let resultat = dico["lang"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    
}
