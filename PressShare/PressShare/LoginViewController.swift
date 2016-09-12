//
//  LoginViewController.swift
//  On the Map
//
//  Created by MacbookPRV on 02/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import Foundation
import UIKit

class LoginViewController : UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var IBuser: UITextField!
    @IBOutlet weak var IBPassword: UITextField!
    @IBOutlet weak var IBLogin: UIButton!
    @IBOutlet weak var IBFacebook: UIButton!
    @IBOutlet weak var IBoda1: UILabel!
    @IBOutlet weak var IBoda3: UIButton!
    @IBOutlet weak var IBoda4: UIButton!
    
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    var facebookButton:FBSDKLoginButton!
    
    
    var users = [User]()
    var user:User!
    
    var config = Config.sharedInstance
    var traduction = InternationalIHM.sharedInstance
    
    
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = fetchAllUser()
        
        loginWithCurrentToken()
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        IBoda1.text = traduction.oda1
        IBLogin.titleLabel?.text = traduction.oda2
        IBoda3.titleLabel?.text =  traduction.oda3
        IBoda4.titleLabel?.text = traduction.oda4
        IBuser.placeholder = traduction.pmp3
        IBPassword.placeholder = traduction.pmp5

        
        config.latitude = 0
        config.longitude = 0
        config.mapString = ""
        config.user_adresse = ""
        config.user_codepostal = ""
        config.user_email = ""
        config.user_id = 0
        config.user_nom = ""
        config.user_pays = ""
        config.user_prenom = ""
        config.user_pseudo = ""
        config.user_ville = ""
        config.user_newpassword = false
        config.previousView = "LoginViewController"
        
        
        facebookButton = FBSDKLoginButton()
        view.addSubview(facebookButton)
        
        facebookButton.frame = IBFacebook.frame
        facebookButton.center = IBFacebook.center
        IBFacebook.hidden = true
        
        facebookButton.readPermissions = ["public_profile", "email", "user_friends"]
        facebookButton.delegate = self
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    
    private func setUIEnabled(enabled: Bool) {
        IBuser.enabled = enabled
        IBPassword.enabled = enabled
        IBLogin.enabled = enabled
        // adjust login button alpha
        if enabled {
            IBLogin.alpha = 1.0
        } else {
            IBLogin.alpha = 0.5
        }
        
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "tabbar"  {
            
            let controller = segue.destinationViewController as! UITabBarController
            let item1 = controller.tabBar.items![0]
            item1.title = traduction.pam1
            let item2 = controller.tabBar.items![1]
            item2.title = traduction.pam2
            let item3 = controller.tabBar.items![2]
            item3.title = traduction.pam3
            
            
        }
        
        
        
        
    }
    
    //MARK: coreData function
    
    
    func fetchAllUser() -> [User] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [User]
        } catch _ {
            return [User]()
        }
    }

    
    //MARK: Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if ((error) != nil)
        {
            // Process error
            displayAlert("Error", mess: error.debugDescription)
        }
        else if result.isCancelled {
            // Handle cancellations
            print("log in is cancelled")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                LoadFaceBook()
                IBuser.hidden = true
                IBPassword.hidden = true
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        loginWithCurrentToken()
    }
    
    
    //MARK: Sign in
    
    
    @IBAction func actionPassword(sender: AnyObject) {
        
        performSegueWithIdentifier("chgpass", sender: self)
        
    }

    
    
    @IBAction func ActionLogin(sender: AnyObject) {
        
        
        if loginWithCurrentToken() {
            return
        }
        
        guard IBuser.text != "" else {
            
            displayAlert("Error", mess: "Error, Email is empty")
            return
        }
        
        guard IBPassword.text != "" else {
            
            displayAlert("Error", mess:  "Error, password is empty")
            return
        }
        
        setUIEnabled(false)
        
        
        config.user_pseudo = IBuser.text!
        config.user_pass = IBPassword.text!
        
        if users.count > 0 {
            for aUser in users {
                if aUser.user_pseudo == config.user_pseudo {
                    user = aUser
                    self.AffecterUser()
                    break
                }
            }
            
        }
        else {
            
            Authentification(config) { (success, userArray, errorString) in
                
                if success {
                    performUIUpdatesOnMain {
                        
                        self.user = User(dico: userArray![0], context: self.sharedContext)
                        self.AffecterUser()
                        
                    }
                    
                }
                else {
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.displayAlert("Error", mess: errorString!)
                        
                    }
                }
            }
            
        }
        
    }
    
    
    private func loginWithCurrentToken() -> Bool {
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in
            IBuser.hidden = true
            IBPassword.hidden = true
            
            LoadFaceBook()
     
            return true
        }
        else {
            
            IBuser.hidden = false
            IBPassword.hidden = false
            return false
        }
        
    }
    
    private func LoadFaceBook() {
    
        let parameters = ["fields":"email"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connexion, result, error) in
            print(result)
            self.config.user_email = result["email"] as? String
            
            if self.users.count > 0 {
                for aUser in self.users {
                    if aUser.user_email == self.config.user_email {
                        self.user = aUser
                        self.AffecterUser()
                        break
                    }
                }
                
                
            }
            else {
                
                AuthentiFacebook(self.config, completionHandlerOAuthFacebook: { (success, userArray, errorString) in
                    
                    
                    if success {
                        performUIUpdatesOnMain {
                            
                            self.user = User(dico: userArray![0], context: self.sharedContext)
                            self.AffecterUser()
                            
                        }
                        
                    }
                    else {
                        performUIUpdatesOnMain {
                            self.setUIEnabled(true)
                            self.displayAlert("Error", mess: errorString!)
                            
                        }
                    }
                    
                    
                })
                
            }
            
        })
        
        
    }
    
    
    
    private func AffecterUser() {
        
        
        // Save the context.
        do {
            try sharedContext.save()
        } catch _ {}
        
        
        config.user_id = user.user_id?.integerValue
        config.user_pseudo = user.user_pseudo
        config.user_email = user.user_email
        config.user_nom = user.user_nom
        config.user_prenom = user.user_prenom
        config.user_newpassword = user.user_newpassword?.boolValue
        config.user_pays = user.user_pays
        config.user_ville = user.user_ville
        config.user_adresse = user.user_adresse
        config.user_codepostal = user.user_codepostal
        IBPassword.text = ""
        setUIEnabled(true)
        if (config.user_newpassword == true) {
            performSegueWithIdentifier("chgpass", sender: self)
        }
        else {
            performSegueWithIdentifier("tabbar", sender: self)
        }
        
        
    }
    
    
}