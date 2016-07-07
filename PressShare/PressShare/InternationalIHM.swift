//
//  InternationalIHM.swift
//  PressShare
//
//  Created by MacbookPRV on 24/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation


class InternationalIHM {
    
    
    
    var titre:String!
    {
        set {
            
            self.titre = ""
        }
        
        get {
            return ""
        }
        
    }
    
    var langue:Int! {
        
        get {
            
          let defaults = NSUserDefaults.standardUserDefaults()
          var langue = defaults.integerForKey("langue_de_preference")
            if langue == 0 {
                let langueIphone = NSLocale.preferredLanguages()[0]
                switch langueIphone {
                case "fr":
                    langue = 1
                case "en":
                    langue = 2
                case "es":
                    langue = 3
                default: break
                    
                }
                
            }
          return langue
        }
        
    }
    
    var Dictionnaire:[String:AnyObject] {
        
        get {
            
            let plistPath = NSBundle.mainBundle().pathForResource("InternationalIHM", ofType: "plist")
            let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath!)
            
            var dico = [String : AnyObject]()
            do {
                dico = try NSPropertyListSerialization.propertyListWithData(plistXML!, options: .MutableContainersAndLeaves, format: nil) as! [String : AnyObject]
            }
            catch {
              
            }
            
            return dico
        }
    }
    
    
        
    
    
    static let sharedInstance = InternationalIHM()
    
    
    
    
    
    
}
