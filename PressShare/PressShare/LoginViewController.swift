//
//  LoginViewController.swift
//  On the Map
//
//  Created by MacbookPRV on 02/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var IBuser: UITextField!
    @IBOutlet weak var IBPassword: UITextField!
    @IBOutlet weak var IBLogin: UIButton!
    @IBOutlet weak var IBFacebook: UIButton!
    
    var facebookButton:FBSDKLoginButton!
    
    var user = User(dico: [String : AnyObject]())
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBuser.delegate = self
        IBPassword.delegate = self
        
        loginWithCurrentToken()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
    
    //MARK: Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User facebook Logged In")
        
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
                self.IBuser.hidden = true
                self.IBPassword.hidden = true
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User facebook Logged Out")
        loginWithCurrentToken()
    }
    
    
    //MARK: Sign in
    
    
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
        
        
        user.user_pseudo = IBuser.text!
        user.user_pass = IBPassword.text!
        
        Authentification(user) { (success, userArray, errorString) in
            
            if success {
                performUIUpdatesOnMain {
                    
                    self.user = User(dico: userArray![0])
                    let config = Config.sharedInstance
                    config.user_id = self.user.user_id
                    config.user_pseudo = self.user.user_pseudo
                    config.user_nom = self.user.user_nom
                    config.user_prenom = self.user.user_prenom
                    config.latitude = self.user.user_latitude
                    config.longitude = self.user.user_longitude
                    config.mapString = self.user.user_mapString
                    self.IBPassword.text = ""
                    self.setUIEnabled(true)
                    self.performSegueWithIdentifier("tabbar", sender: self)
                    
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
            self.user.user_email = result["email"] as! String
            AuthentiFacebook(self.user, completionHandlerOAuthFacebook: { (success, userArray, errorString) in
                
                
                if success {
                    performUIUpdatesOnMain {
                        
                        self.user = User(dico: userArray![0])
                        let config = Config.sharedInstance
                        config.user_id = self.user.user_id
                        config.user_pseudo = self.user.user_pseudo
                        config.user_nom = self.user.user_nom
                        config.user_prenom = self.user.user_prenom
                        config.latitude = self.user.user_latitude
                        config.longitude = self.user.user_longitude
                        config.mapString = self.user.user_mapString
                        self.IBPassword.text = ""
                        self.setUIEnabled(true)
                        self.performSegueWithIdentifier("tabbar", sender: self)
                        
                    }
                    
                }
                else {
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.displayAlert("Error", mess: errorString!)
                        
                    }
                }
                
                
            })
        })
        
        
    }
    
    
    
    
    
}