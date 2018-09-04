//
//  AppDelegate.swift
//  GoOtoor
//
//  Created by MacbookPRV on 28/04/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//-----------------------------------------
//Todo ASAP:
//-----------------------------------------

//Todo new: Token push + id machine

//Todo new : tous les champs boolean doivent avoir un prefixe "is"

//Todo bug: Est ce que un thread en cours d'exécution continue quand même le fenêtre d'origine se ferme

//Todo new: envoyer un push alert à l'utilisateur pour l'informer que la transaction va bientôt expirer dans 1 jour.

//Todo new: contentieux : automatiser les scénarios de contentieux.fxpast.com

//Todo new: Base de données : Optimiser les redondance dans la base de données

//Todo new: Recenser et reporter tous les traitement de base de données au niveau du serveur, cela accelère l'execution des tâches


//-----------------------------------------
//Todo may be:
//-----------------------------------------
//Todo new: Bien etudier le fonctionnement des protocoles

//Todo new: Preferer un cercle qui se forme à l'objet d’activité en attente par defaut d'apple

//Todo new: Les message d’erreur peuvent s’afficher comme une étiquette rouge non bloquante




import UIKit
import BraintreeCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String:AnyObject] {
            let aps = notification["aps"] as! [String:AnyObject]
            
            let manager = FileManager.default
            let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            let filePath  = url.appendingPathComponent("aps_dico")!.path
            
            NSKeyedArchiver.archiveRootObject(aps, toFile: filePath)
            
            
        }
        
        BTAppSwitch.setReturnURLScheme("com.prv.MemeMe2-0.payments")
        
        return true
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme?.localizedCaseInsensitiveCompare("com.prv.MemeMe2-0.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        let aps = userInfo["aps"] as! [String:AnyObject]
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("aps_dico")!.path
        
        NSKeyedArchiver.archiveRootObject(aps, toFile: filePath)
        
        
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
   
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var tokenString = ""
        
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [deviceToken[i] as CVarArg])
            
        }
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("tokenString")!.path
        
        NSKeyedArchiver.archiveRootObject(tokenString, toFile: filePath)
       
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register : ", error)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
}

