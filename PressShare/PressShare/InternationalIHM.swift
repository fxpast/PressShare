//
//  InternationalIHM.swift
//  PressShare
//
//  Created by MacbookPRV on 24/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation


class InternationalIHM {
    
    
    
    fileprivate var dico:[String:AnyObject]
    fileprivate var langue:Int
    
    
    
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
    
    
    var oda1:String!
        {
        
        get {
            let resultat = dico["oda1"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var oda2:String!
        {
        
        get {
            let resultat = dico["oda2"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var oda3:String!
        {
        
        get {
            let resultat = dico["oda3"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var oda4:String!
        {
        
        get {
            let resultat = dico["oda4"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var oda5:String!
        {
        
        get {
            let resultat = dico["oda5"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    
    //MARK: Page avec Map
    
    var pam1:String!
        {
        
        get {
            let resultat = dico["pam1"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pam2:String!
        {
        
        get {
            let resultat = dico["pam2"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pam3:String!
        {
        
        get {
            let resultat = dico["pam3"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pam4:String!
        {
        
        get {
            let resultat = dico["pam4"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    //MARK: Page sur paramètre
    
    var psp1:String!
        {
        
        get {
            let resultat = dico["psp1"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var psp2:String!
        {
        
        get {
            let resultat = dico["psp2"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var psp3:String!
        {
        
        get {
            let resultat = dico["psp3"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var psp4:String!
        {
        
        get {
            let resultat = dico["psp4"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var psp5:String!
        {
        
        get {
            let resultat = dico["psp5"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var psp6:String!
        {
        
        get {
            let resultat = dico["psp6"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    //MARK: Page sur modifier mon profil
    
    
    var pmp1:String!
        {
        
        get {
            let resultat = dico["pmp1"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp2:String!
        {
        
        get {
            let resultat = dico["pmp2"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp3:String!
        {
        
        get {
            let resultat = dico["pmp3"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp4:String!
        {
        
        get {
            let resultat = dico["pmp4"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp5:String!
        {
        
        get {
            let resultat = dico["pmp5"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp6:String!
        {
        
        get {
            let resultat = dico["pmp6"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp7:String!
        {
        
        get {
            let resultat = dico["pmp7"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp8:String!
        {
        
        get {
            let resultat = dico["pmp8"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp9:String!
        {
        
        get {
            let resultat = dico["pmp9"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp10:String!
        {
        
        get {
            let resultat = dico["pmp10"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp11:String!
        {
        
        get {
            let resultat = dico["pmp11"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pmp12:String!
        {
        
        get {
            let resultat = dico["pmp12"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    //MARK: Page sur information de connexion
    
    
    var pic1:String!
        {
        
        get {
            let resultat = dico["pic1"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pic2:String!
        {
        
        get {
            let resultat = dico["pic2"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pic3:String!
        {
        
        get {
            let resultat = dico["pic3"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pic4:String!
        {
        
        get {
            let resultat = dico["pic4"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pic5:String!
        {
        
        get {
            let resultat = dico["pic5"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pic6:String!
        {
        
        get {
            let resultat = dico["pic6"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    //MARK: Page sur épingle
    
    var pse1:String!
        {
        
        get {
            let resultat = dico["pse1"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pse2:String!
        {
        
        get {
            let resultat = dico["pse2"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pse3:String!
        {
        
        get {
            let resultat = dico["pse3"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pse4:String!
        {
        
        get {
            let resultat = dico["pse4"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pse5:String!
        {
        
        get {
            let resultat = dico["pse5"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pse6:String!
        {
        
        get {
            let resultat = dico["pse6"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pse7:String!
        {
        
        get {
            let resultat = dico["pse7"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var pse8:String!
        {
        
        get {
            let resultat = dico["pse8"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    var pse9:String!
        {
        
        get {
            let resultat = dico["pse9"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
}
