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
    
    var errorLogin:String!
        {
        
        get {
            let resultat = dico["errorLogin"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorPassword:String!
        {
        
        get {
            let resultat = dico["errorPassword"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var impossibleDeldMes:String!
        {
        
        get {
            let resultat = dico["impossibleDeldMes"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var impossibleDeldPr:String!
        {
        
        get {
            let resultat = dico["impossibleDeldPr"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var impossibleUpdPr:String!
        {
        
        get {
            let resultat = dico["impossibleUpdPr"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
      }
    
    var emailSender:String!
        {
        
        get {
            let resultat = dico["emailSender"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var loginPassword:String!
        {
        
        get {
            let resultat = dico["loginPassword"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var confirmSubsWithDepot:String!
        {
        
        get {
            let resultat = dico["confirmSubsWithDepot"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var commission:String!
        {
        
        get {
            let resultat = dico["commission"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    var errorMail:String!
        {
        
        get {
            let resultat = dico["errorMail"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
  
    var withdrawalMade:String!
        {
        
        get {
            let resultat = dico["withdrawalMade"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorAcceptReject:String!
        {
        
        get {
            let resultat = dico["errorAcceptReject"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var errorEndedTrans:String!
        {
        
        get {
            let resultat = dico["errorEndedTrans"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var seller:String!
        {
        
        get {
            let resultat = dico["seller"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var customer:String!
        {
        
        get {
            let resultat = dico["customer"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var canceled:String!
        {
        
        get {
            let resultat = dico["canceled"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var confirmed:String!
        {
        
        get {
            let resultat = dico["confirmed"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var subscriptionHas:String!
        {
        
        get {
            let resultat = dico["subscriptionHas"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var subscribeSubs:String!
        {
        
        get {
            let resultat = dico["subscribeSubs"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var sell:String!
        {
        
        get {
            let resultat = dico["sell"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var cancelSubs:String!
        {
        
        get {
            let resultat = dico["cancelSubs"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var confirmTermin:String!
        {
        
        get {
            let resultat = dico["confirmTermin"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    var confirmSubs:String!
        {
        
        get {
            let resultat = dico["confirmSubs"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var paymentMade:String!
        {
        
        get {
            let resultat = dico["paymentMade"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    var OneTimeDepo:String!
        {
        
        get {
            let resultat = dico["OneTimeDepo"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var OneTimeWithd:String!
        {
        
        get {
            let resultat = dico["OneTimeWithd"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var confirmPayment:String!
        {
        
        get {
            let resultat = dico["confirmPayment"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var confirmWithdrawal:String!
        {
        
        get {
            let resultat = dico["confirmWithdrawal"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var error:String!
        {
        
        get {
            let resultat = dico["error"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    var ErrorDescription:String!
        {
        
        get {
            let resultat = dico["ErrorDescription"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var takePicture:String!
        {
        
        get {
            let resultat = dico["takePicture"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var ErrorGeolocation:String!
        {
        
        get {
            let resultat = dico["ErrorGeolocation"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
 
    var ErrorGeocode:String!
        {
        
        get {
            let resultat = dico["ErrorGeocode"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var ErrorPrice:String!
        {
        
        get {
            let resultat = dico["ErrorPrice"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var makeChoice:String!
        {
        
        get {
            let resultat = dico["makeChoice"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var customerFor:String!
        {
        
        get {
            let resultat = dico["customerFor"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
   
    var deletionFor:String!
        {
        
        get {
            let resultat = dico["deletionFor"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    var hastobechosen:String!
        {
        
        get {
            let resultat = dico["hastobechosen"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var theProduct:String!
        {
        
        get {
            let resultat = dico["theProduct"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var buy:String!
        {
        
        get {
            let resultat = dico["buy"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var reply:String!
        {
        
        get {
            let resultat = dico["reply"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorNoDataRequest:String!
        {
        
        get {
            let resultat = dico["errorNoDataRequest"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorParseJSON:String!
        {
        
        get {
            let resultat = dico["errorParseJSON"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var errorTypeTrans:String!
        {
        
        get {
            let resultat = dico["errorTypeTrans"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var errorBalanceTrans:String!
        {
        
        get {
            let resultat = dico["errorBalanceTrans"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var errorContactSeller:String!
        {
        
        get {
            let resultat = dico["errorContactSeller"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    
    var errorUpdateTrans:String!
        {
        
        get {
            let resultat = dico["errorUpdateTrans"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var errorAddOperat:String!
        {
        
        get {
            let resultat = dico["errorAddOperat"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorDelMessage:String!
        {
        
        get {
            let resultat = dico["errorDelMessage"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorAddTrans:String!
        {
        
        get {
            let resultat = dico["errorAddTrans"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }

    var errorRequest:String!
        {
        
        get {
            let resultat = dico["errorRequest"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorRequestReturn:String!
        {
        
        get {
            let resultat = dico["errorRequestReturn"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var emailPassword:String!
        {
        
        get {
            let resultat = dico["emailPassword"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorNewPassword:String!
        {
        
        get {
            let resultat = dico["errorNewPassword"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var errorCheckPassword:String!
        {
        
        get {
            let resultat = dico["errorCheckPassword"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var errorOldPassword:String!
        {
        
        get {
            let resultat = dico["errorOldPassword"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var message:String!
        {
        
        get {
            let resultat = dico["message"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var emptyMessage:String!
        {
        
        get {
            let resultat = dico["emptyMessage"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    
    var sentMessage:String!
        {
        
        get {
            let resultat = dico["sentMessage"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    var inBox:String!
        {
        
        get {
            let resultat = dico["inBox"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var sendBox:String!
        {
        
        get {
            let resultat = dico["sendBox"] as! [AnyObject]
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
    
    var send:String!
        {
        
        get {
            let resultat = dico["send"] as! [AnyObject]
            return resultat[langue-1] as! String
        }
        
    }
    
    var delete:String!
        {
        
        get {
            let resultat = dico["delete"] as! [AnyObject]
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
