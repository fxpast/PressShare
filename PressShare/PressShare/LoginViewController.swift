//
//  LoginViewController.swift
//  PressShare
//
//  Description : Sign in and if you have forgotten you can ask a new one. Connection by user/password or by facebook
//
//  Created by MacbookPRV on 02/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import Foundation
import UIKit


class LoginViewController : UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var IBUser: UITextField!
    @IBOutlet weak var IBPassword: UITextField!
    @IBOutlet weak var IBLogin: UIButton!
    @IBOutlet weak var IBFacebook: UIButton!
    @IBOutlet weak var IBPressConnect: UILabel!
    @IBOutlet weak var IBNewAccount: UIButton!
    @IBOutlet weak var IBLostPass: UIButton!
    @IBOutlet weak var IBAnonyme: UIButton!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    var facebookButton:FBSDKLoginButton!
    
    var users = [User]()
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    let config = Config.sharedInstance   
    let translate = TranslateMessage.sharedInstance
    
    
    //MARK: Locked portrait
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            return .portrait
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    open override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        config.cleaner()
        
        users = fetchAllUser()
        
        loginWithCurrentToken()
        
        
        IBActivity.isHidden = true
        subscibeToKeyboardNotifications()
        
        IBUser.text = ""
        config.previousView = "LoginViewController"
        Operations.sharedInstance.operationArray = nil
        Messages.sharedInstance.MessagesArray = nil
        Transactions.sharedInstance.transactionArray = nil
        Capitals.sharedInstance.capitalsArray = nil
        Products.sharedInstance.productsArray = nil
                
        IBPressConnect.text = translate.connectToPress
        IBUser.placeholder = translate.pseudo
        IBPassword.placeholder = translate.password
        
        IBLogin.setTitle(translate.signin, for: UIControlState())
        IBLogin.titleLabel?.textAlignment = NSTextAlignment.center
        IBNewAccount.setTitle(translate.signup, for: UIControlState())
        IBNewAccount.titleLabel?.textAlignment = NSTextAlignment.center
        IBLostPass.setTitle(translate.lostPassword, for: UIControlState())
        IBLostPass.titleLabel?.textAlignment = NSTextAlignment.center
        IBAnonyme.setTitle(translate.anonyme, for: UIControlState())
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
        unSubscribeFromKeyboardNotifications()
        
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
        if (Double(location) < Double(keybordY)) {
            
            var textField = UITextField()
            
            
            if fieldName == "IBPassword" {
                textField = IBPassword
            }
            else if fieldName == "IBUser" {
                textField = IBUser
            }
            
            textField.endEditing(true)
            
        }
        
    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        if IBUser.text != "" && IBPassword.text != "" {
            
            actionLogin(self)
            
        }
        
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField.isEqual(IBUser) {
            fieldName = "IBUser"
        }
        else if textField.isEqual(IBPassword) {
            fieldName = "IBPassword"
        }
    }
    
    
    private func setUIEnabled(_ enabled: Bool) {
        IBUser.isEnabled = enabled
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
            
            IBActivity.isHidden = false
            self.IBActivity.startAnimating()
            
            let controller = segue.destination as! UITabBarController
            let item0 = controller.tabBar.items![0]
            item0.title = self.translate.map
            let item1 = controller.tabBar.items![1]
            item1.title = self.translate.list
            let item2 = controller.tabBar.items![2]
            item2.title = self.translate.settings
            
            
            MDBMessage.sharedInstance.getAllMessages(config.user_id) {(success, messageArray, errorString) in
                
                if success {
                    
                    Messages.sharedInstance.MessagesArray = messageArray
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        var i = 0
                        
                        for mess in Messages.sharedInstance.MessagesArray {
                            
                            let message = Message(dico: mess)
                            
                            if message.destinataire == self.config.user_id && message.deja_lu_dest == false {
                                i+=1
                            }
                            
                        }
                        if i > 0 {
                            self.config.mess_badge = i
                            item1.badgeValue = "\(i)"
                        }
                        
                        self.IBActivity.stopAnimating()
                        
                    }
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            }
            
            MDBTransact.sharedInstance.getAllTransactions(config.user_id) { (success, transactionArray, errorString) in
                
                if success {
                    
                    Transactions.sharedInstance.transactionArray = transactionArray
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        var i = 0
                        for tran in Transactions.sharedInstance.transactionArray  {
                            
                            let tran1 = Transaction(dico: tran)
                            
                            if (tran1.trans_valide != 1 && tran1.trans_valide != 2 )  {
                                i+=1
                            }
                            
                        }
                        if i > 0 {
                            self.config.trans_badge = i
                            item2.badgeValue = "\(i)"
                        }
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                       
                            self.IBActivity.stopAnimating()
                            self.IBActivity.isHidden = true
                        }
                        
                    }
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            }
            
        }
        
    }
    
    
    //MARK: keyboard function
    
    
    func  subscibeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    
    func unSubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    
    func keyBoardWillShow(notification:NSNotification) {
        
        
        var textField = UITextField()
        
        
        if fieldName == "IBPassword" {
            textField = IBPassword
        }
        else if fieldName == "IBUser" {
            textField = IBUser
        }
        
        if textField.isFirstResponder {
            keybordY = view.frame.size.height - getKeyBoardHeight(notification: notification)
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
        else if fieldName == "IBUser" {
            textField = IBUser
        }
        
        
        if textField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        fieldName = ""
        keybordY = 0
        
        
    }
    
    func getKeyBoardHeight(notification:NSNotification)->CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    
    
    //MARK: coreData function
    
    
    private func fetchAllUser() -> [User] {
        
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
            displayAlert(translate.error, mess: error.localizedDescription)
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
                loadFaceBook()
                IBUser.isHidden = true
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
    
    
    private func loginWithLogout() -> Bool {
        
        if (FBSDKAccessToken.current() != nil) {
            return false
        }
        
        if users.count > 0 {
            for aUser in users {
                if aUser.user_logout == false {
                    // User is already logged in
                    self.assignUser(aUser)
                    return true
                }
            }
        }
        
        IBUser.isHidden = false
        IBPassword.isHidden = false
        return false
        
    }
    
    @IBAction func actionAnonyme(_ sender: AnyObject) {
        IBUser.text = "anonymous"
        IBPassword.text = "anonymous"
        
        actionLogin(self)
        
    }
    
    
    @IBAction func actionLogin(_ sender: AnyObject) {
        
        if loginWithLogout() {
            return
        }
        
        if loginWithCurrentToken() {
            return
        }
        
        guard IBUser.text != "" else {
            
            displayAlert(translate.error, mess: translate.errorLogin!)
            return
        }
        
        guard IBPassword.text != "" else {
            
            displayAlert(translate.error, mess:  translate.errorPassword)
            return
        }
        
        setUIEnabled(false)
        
        var flgOK = false
        
        config.user_pass = IBPassword.text!
        config.user_pseudo = IBUser.text!
        
        if users.count > 0 {
            for aUser in users {
                
                if aUser.user_pseudo == IBUser.text!  {
                    
                    if aUser.user_pass == config.user_pass {
                        self.assignUser(aUser)
                        flgOK = true
                        return
                    }
                    
                    
                    if flgOK == false && aUser.user_pass != ""  {
                        
                        displayAlert(translate.error, mess:  translate.loginPassword)
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
        
        
        MDBUser.sharedInstance.Authentification(config) { (success, userArray, errorString) in
            
            if success {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    if self.users.count > 0 {
                        
                        self.sharedContext.delete(self.users[0])
                        self.users.removeLast()
                        // Save the context.
                        do {
                            try self.sharedContext.save()
                        } catch _ {}
                        
                    }
                    
                    self.users = self.fetchAllUser()
                    
                    
                    self.assignUser( User(dico: userArray![0], context: self.sharedContext))
                    
                }
                
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.displayAlert(self.translate.error, mess: errorString!)
                    
                }
            }
        }
        
        
    }
    
    
    private func loginWithCurrentToken() -> Bool {
        
        if (FBSDKAccessToken.current() != nil)
        {
            // User is already logged in
            
            loadFaceBook()
            
            return true
        }
        else {
            
            
            IBUser.isHidden = false
            IBPassword.isHidden = false
            return false
        }
        
    }
    
    private func loadFaceBook() {
        
        let parameters = ["fields":"email"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connexion, result, error) in
            
            let res = result as! [String:AnyObject]
            self.config.user_email = res["email"] as? String
            
            if self.users.count > 0 {
                for aUser in self.users {
                    if aUser.user_email == self.config.user_email  {
                        self.assignUser(aUser)
                        return
                        
                    }
                }
                
            }
            
            MDBUser.sharedInstance.AuthentiFacebook(self.config, completionHandlerOAuthFacebook: { (success, userArray, errorString) in
                
                
                if success {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        
                        if self.users.count > 0 {
                            
                            self.sharedContext.delete(self.users[0])
                            self.users.removeLast()
                            // Save the context.
                            do {
                                try self.sharedContext.save()
                            } catch _ {}
                            
                        }
                        
                        
                        self.users = self.fetchAllUser()
                        
                        self.assignUser(User(dico: userArray![0], context: self.sharedContext))
                        
                    }
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.displayAlert(self.translate.error, mess: errorString!)
                        
                    }
                }
                
                
            })
            
            
        })
        
        
    }
    
    
    private func assignUser(_ aUser:User) {
        
        
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
        config.level = aUser.user_level as Int!
        
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
