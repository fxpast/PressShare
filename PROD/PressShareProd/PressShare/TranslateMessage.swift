//
//  TraductionMessage.swift
//  PressShare
//  
//  Description : This class has the necessary properties for translation 
//
//  Created by MacbookPRV on 07/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



import Foundation

class TranslateMessage {
    
    private var dico:[String:AnyObject]
    private var langue:Int
    
    init () {
        
        dico = [String:AnyObject]()
        langue = 0
        
        let plistPath = Bundle.main.path(forResource: "TranslateMessage", ofType: "plist")
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
    
    static let sharedInstance = TranslateMessage()
    
    var lang:String!
        {
        
        get {
            let resultat = dico["lang"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    func message(_ value:String) -> String {
        
        let resultat = dico[value] as! [AnyObject]
        return resultat[langue-1] as! String
        
    }
    
    
    
}
