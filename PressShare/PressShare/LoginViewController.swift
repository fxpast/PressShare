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
    @IBOutlet weak var IBAnonyme: UIButton!
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    var facebookButton:FBSDKLoginButton!
    
    var users = [User]()
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    let config = Config.sharedInstance
    var traduction = InternationalIHM.sharedInstance
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config.cleaner()
        
        users = fetchAllUser()
        
        loginWithCurrentToken()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        subscibeToKeyboardNotifications()
        
        IBuser.text = ""
        config.previousView = "LoginViewController"
        
        IBoda1.text = traduction.oda1
        IBuser.placeholder = traduction.pmp3
        IBPassword.placeholder = traduction.pmp5
        
        IBLogin.setTitle(traduction.oda2, for: UIControlState())
        IBLogin.titleLabel?.textAlignment = NSTextAlignment.center
        IBoda3.setTitle(traduction.oda3, for: UIControlState())
        IBoda3.titleLabel?.textAlignment = NSTextAlignment.center
        IBoda4.setTitle(traduction.oda4, for: UIControlState())
        IBoda4.titleLabel?.textAlignment = NSTextAlignment.center
        IBAnonyme.setTitle(traduction.oda5, for: UIControlState())
        IBAnonyme.titleLabel?.textAlignment = NSTextAlignment.center
        
        
        if users.count > 0 {
            for aUser in users {
                if aUser.user_logout == true && FBSDKAccessToken.current() != nil {
                    
                    let loginmanager = FBSDKLoginManager()
                    loginmanager.logOut()
                    
                }
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        facebookButton = FBSDKLoginButton()
        view.addSubview(facebookButton)
        
        facebookButton.frame = IBFacebook.frame
        facebookButton.center = IBFacebook.center
        IBFacebook.isHidden = true
        
        
        facebookButton.readPermissions = ["public_profile", "email", "user_friends"]
        facebookButton.delegate = self
        
        loginWithLogout()
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        let location = (event?.allTouches?.first?.location(in: self.view).y)! as CGFloat
        if (location < keybordY) {
        
            var textField = UITextField()
            
            
            if fieldName == "IBPassword" {
                textField = IBPassword
            }
            else if fieldName == "IBuser" {
                textField = IBuser
            }
        
            textField.endEditing(true)
        
        }
        
    }

    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField.isEqual(IBuser) {
            fieldName = "IBuser"
        }
        else if textField.isEqual(IBPassword) {
            fieldName = "IBPassword"
        }
    }
    
    
    fileprivate func setUIEnabled(_ enabled: Bool) {
        IBuser.isEnabled = enabled
        IBPassword.isEnabled = enabled
        IBLogin.isEnabled = enabled
        // adjust login button alpha
        if enabled {
            IBLogin.alpha = 1.0
        } else {
            IBLogin.alpha = 0.5
        }
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "tabbar"  {
            
            let controller = segue.destination as! UITabBarController
            let item1 = controller.tabBar.items![0]
            item1.title = traduction.pam1
            let item2 = controller.tabBar.items![1]
            item2.title = traduction.pam2
            let item3 = controller.tabBar.items![2]
            item3.title = traduction.pam3
            
            
        }
        
    }
    
    
    //MARK: keyboard function
    
    
    func  subscibeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    

    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
       
        
    }
    
    
    func keyboardWillShow(notification:NSNotification) {
        
        
        var textField = UITextField()
        
        
        if fieldName == "IBPassword" {
            textField = IBPassword
        }
        else if fieldName == "IBuser" {
            textField = IBuser
        }
        
        if textField.isFirstResponder {
            keybordY = view.frame.size.height - getkeyboardHeight(notification: notification)
            if keybordY < textField.frame.origin.y {
                view.frame.origin.y = keybordY - textField.frame.origin.y - textField.frame.size.height
            }
            
            
        }
        
        
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
        
        var textField = UITextField()
        
        
        if fieldName == "IBPassword" {
            textField = IBPassword
        }
        else if fieldName == "IBuser" {
            textField = IBuser
        }
        
        
        if textField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        fieldName = ""
        keybordY = 0
        
        
    }
    
    func getkeyboardHeight(notification:NSNotification)->CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    
    
    //MARK: coreData function
    
    
    fileprivate func fetchAllUser() -> [User] {
        
        users.removeAll()
        // Create the Fetch Request
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(request) as! [User]
        } catch _ {
            return [User]()
        }
    }
    
    
    
    //MARK: Facebook Delegate Methods
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if ((error) != nil)
        {
            // Process error
            displayAlert("Error", mess: error.localizedDescription)
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
                IBuser.isHidden = true
                IBPassword.isHidden = true
            }
        }
    }
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        loginWithCurrentToken()
    }
    
    
    //MARK: Sign in
    
    
    @IBAction func actionPassword(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "chgpass", sender: self)
        
    }
    
    
    fileprivate func loginWithLogout() -> Bool {
        
        if (FBSDKAccessToken.current() != nil) {
            return false
        }
        
        if users.count > 0 {
            for aUser in users {
                if aUser.user_logout == false {
                    // User is already logged in
                    self.AffecterUser(aUser)
                    return true
                }
            }
        }
        
        IBuser.isHidden = false
        IBPassword.isHidden = false
        return false
        
    }
    
    @IBAction func ActionAnonyme(_ sender: AnyObject) {
        IBuser.text = "anonymous"
        IBPassword.text = "anonymous"
        
        ActionLogin(self)
        
    }
    
    
    @IBAction func ActionLogin(_ sender: AnyObject) {
        
        if loginWithLogout() {
            return
        }
        
        if loginWithCurrentToken() {
            return
        }
        
        guard IBuser.text != "" else {
            
            displayAlert("Error", mess: "Error, login is empty")
            return
        }
        
        guard IBPassword.text != "" else {
            
            displayAlert("Error", mess:  "Error, password is empty")
            return
        }
        
        setUIEnabled(false)
        
        var flgOK = false
        
        config.user_pass = IBPassword.text!
        config.user_pseudo = IBuser.text!
        
        if users.count > 0 {
            for aUser in users {
                
                if aUser.user_pseudo == IBuser.text!  {
                    
                    if aUser.user_pass == config.user_pass {
                        self.AffecterUser(aUser)
                        flgOK = true
                        return
                    }
                    
                    
                    if flgOK == false && aUser.user_pass != ""  {
                        
                        displayAlert("Error", mess:  "Error, login / password ")
                        setUIEnabled(true)
                        return
                    }
                    
                }
                else {
                    
                    sharedContext.delete(users[0])
                    users.removeLast()
                    // Save the context.
                    do {
                        try sharedContext.save()
                    } catch let error as NSError {
                        print(error.debugDescription)
                        
                    }
                    
                    users = fetchAllUser()
                    
                }
                
                
                
            }
        }
        
        
        Authentification(config) { (success, userArray, errorString) in
            
            if success {
                performUIUpdatesOnMain {
                    
                    if self.users.count > 0 {
                        
                        self.sharedContext.delete(self.users[0])
                        self.users.removeLast()
                        // Save the context.
                        do {
                            try self.sharedContext.save()
                        } catch _ {}
                        
                    }
                    
                    self.users = self.fetchAllUser()
                    
                    
                    self.AffecterUser( User(dico: userArray![0], context: self.sharedContext))
                    
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
    
    
    fileprivate func loginWithCurrentToken() -> Bool {
        
        if (FBSDKAccessToken.current() != nil)
        {
            // User is already logged in
            
            LoadFaceBook()
            
            return true
        }
        else {
            
            
            IBuser.isHidden = false
            IBPassword.isHidden = false
            return false
        }
        
    }
    
    fileprivate func LoadFaceBook() {
        
        let parameters = ["fields":"email"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connexion, result, error) in
            
            let res = result as! [String:AnyObject]
            self.config.user_email = res["email"] as? String
            
            if self.users.count > 0 {
                for aUser in self.users {
                    if aUser.user_email == self.config.user_email  {
                        self.AffecterUser(aUser)
                        return
                        
                    }
                }
                
            }
            
            AuthentiFacebook(self.config, completionHandlerOAuthFacebook: { (success, userArray, errorString) in
                
                
                if success {
                    performUIUpdatesOnMain {
                        
                        
                        if self.users.count > 0 {
                            
                            self.sharedContext.delete(self.users[0])
                            self.users.removeLast()
                            // Save the context.
                            do {
                                try self.sharedContext.save()
                            } catch _ {}
                            
                        }
                        
                        
                        self.users = self.fetchAllUser()
                        
                        self.AffecterUser(User(dico: userArray![0], context: self.sharedContext))
                        
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
    
    
    
    
    fileprivate func AffecterUser(_ aUser:User) {
        
        
        config.user_id = aUser.user_id?.intValue
        config.user_pseudo = aUser.user_pseudo
        config.user_email = aUser.user_email
        config.user_nom = aUser.user_nom
        config.user_prenom = aUser.user_prenom
        
        if let newpass = aUser.user_newpassword?.boolValue {
            config.user_newpassword = newpass
        }
        else {
            config.user_newpassword = false
        }
        
        config.user_pays = aUser.user_pays
        config.user_ville = aUser.user_ville
        config.user_adresse = aUser.user_adresse
        config.user_codepostal = aUser.user_codepostal
        config.verifpassword = ""
        
        if let pass = config.user_pass {
            aUser.user_pass = pass
        }
        else {
            
            if let pass = aUser.user_pass {
                config.user_pass = pass
            }
            else {
                config.user_pass = ""
                aUser.user_pass = ""
            }
        }
        
        
        aUser.user_logout = false
        
        
        if let _ = config.user_pseudo {
            
            // Save the context.
            do {
                try sharedContext.save()
            } catch _ {}
            
            
            users = fetchAllUser()
            
            
            IBPassword.text = ""
            setUIEnabled(true)
            
            
            if (config.user_newpassword == true) {
                performSegue(withIdentifier: "chgpass", sender: self)
            }
            else {
                performSegue(withIdentifier: "tabbar", sender: self)
            }
            
            
            
        }
        
        
        
        
        
    }
    
    
}
