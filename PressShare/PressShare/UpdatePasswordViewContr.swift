//
//  UpdatePasswordViewContr.swift
//  PressShare
//
//  Desciption : Update password from setting list or lost password from sign in view.
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import UIKit

class UpdatePasswordViewContr : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var IBDone: UIBarButtonItem!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBEmail: UITextField!
    @IBOutlet weak var IBCheckPass: UITextField!
    @IBOutlet weak var IBOldPass: UITextField!
    @IBOutlet weak var IBNewPass: UITextField!
    
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    
    var users = [User]()
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        users = fetchAllUser()
        
        if config.previousView == "LoginViewController" {
            
            navigationItem.title = translate.lostPassword
            if let nouvPass = config.user_newpassword {
                
                if nouvPass == true {
                    IBEmail.isHidden = false
                    IBEmail.text = config.user_email
                    
                    IBNewPass.isHidden = false
                    IBCheckPass.isHidden = false
                    
                    IBOldPass.isHidden = true
                    
                }
            }
            else {
                config.user_newpassword = false
            }
            
            if config.user_newpassword == false {
                
                IBEmail.isHidden = false
                IBEmail.text = config.user_email
                
                IBOldPass.isHidden = true
                IBNewPass.isHidden = true
                IBCheckPass.isHidden = true
                
            }
        }
        
        
        if config.previousView == "SettingsTableViewContr" {
            
            self.navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
            
            IBEmail.isHidden = false
            IBEmail.text = config.user_email
            
            IBOldPass.isHidden = false
            IBNewPass.isHidden = false
            IBCheckPass.isHidden = false
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscibeToKeyboardNotifications()
        
        IBDone.title = translate.done
        
        IBOldPass.placeholder = translate.oldPass
        IBNewPass.placeholder = translate.newPass
        IBCheckPass.placeholder = translate.checkPass
        IBEmail.placeholder = translate.enterEmail
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
    
    //MARK: Data User with update password
    
    @IBAction func actionDone(_ sender: AnyObject) {
        
        guard IBEmail.text != "" else {
            displayAlert(translate.error, mess: translate.errorMail)
            return
        }
        
        //--- Login View Controller
        if config.previousView == "LoginViewController" {
            
            if config.user_newpassword == true {
                
                guard IBNewPass.text != "" else {
                    displayAlert(translate.error, mess: translate.errorNewPassword)
                    return
                }
                
                guard IBCheckPass.text != "" else {
                    displayAlert(translate.error, mess: translate.errorCheckPassword)
                    return
                }
                
                guard IBNewPass.text == IBCheckPass.text else {
                    displayAlert(translate.error, mess: translate.loginPassword)
                    return
                }
                
                config.user_lastpass = IBNewPass.text!
                config.user_newpassword = false
            }
            else {
                
                config.user_lastpass = randomAlphaNumericString(8)
                config.user_email = IBEmail.text!
                config.user_newpassword = true
                
            }
            
        }
        
        //--- Settings Table View Controller
        
        if config.previousView == "SettingsTableViewContr" {
            
            guard IBOldPass.text != "" else {
                displayAlert(translate.error, mess: translate.errorOldPassword)
                return
            }
            
            guard IBNewPass.text != "" else {
                displayAlert(translate.error, mess: translate.errorNewPassword)
                return
            }
            
            guard IBCheckPass.text != "" else {
                displayAlert(translate.error, mess: translate.errorCheckPassword)
                return
            }
            
            guard IBNewPass.text == IBCheckPass.text else {
                displayAlert(translate.error, mess: translate.loginPassword)
                return
            }
            
            config.user_pass = IBOldPass.text
            config.user_lastpass = IBNewPass.text!
            config.user_newpassword = false
        }
        
        
        if users.count > 0 {
            
            sharedContext.delete(users[0])
            users.removeLast()
            
            // Save the context.
            do {
                try sharedContext.save()
            } catch let error as NSError {
                print(error.debugDescription)
                
            }
            
        }
        
        MDBUser.sharedInstance.setUpdatePass(config) { (success, errorString) in
            if success {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    if self.config.user_newpassword == true {
                        self.IBDone.isEnabled = false
                        self.displayAlert(self.translate.password, mess: self.translate.emailPassword)
                        
                    }
                    else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        }
        
    }
    
    
    private func randomAlphaNumericString(_ length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.characters.index(allowedChars.startIndex, offsetBy: randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    //MARK: textfield Delegate
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        let location = (event?.allTouches?.first?.location(in: self.view).y)! as CGFloat
        if (Double(location) < Double(keybordY)) {
            
            var textField = UITextField()
            
            
            if fieldName == "IBEmail" {
                textField = IBEmail
            }
            else if fieldName == "IBNewPass" {
                textField = IBNewPass
            }
            else if fieldName == "IBCheckPass" {
                textField = IBCheckPass
            }
            else if fieldName == "IBOldPass" {
                textField = IBOldPass
            }
            
            textField.endEditing(true)
            
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        if IBEmail.text != ""  &&  textField == IBEmail && config.previousView == "LoginViewController"  {
            
            actionDone(self)
            
        }
        
        
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBEmail) {
            fieldName = "IBEmail"
        }
        else if textField.isEqual(IBNewPass) {
            fieldName = "IBNewPass"
        }
        else if textField.isEqual(IBCheckPass) {
            fieldName = "IBCheckPass"
        }
        else if textField.isEqual(IBOldPass) {
            fieldName = "IBOldPass"
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
        
        if fieldName == "IBEmail" {
            textField = IBEmail
        }
        else if fieldName == "IBNewPass" {
            textField = IBNewPass
        }
        else if fieldName == "IBCheckPass" {
            textField = IBCheckPass
        }
        else if fieldName == "IBOldPass" {
            textField = IBOldPass
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
        
        if fieldName == "IBEmail" {
            textField = IBEmail
        }
        else if fieldName == "IBNewPass" {
            textField = IBNewPass
        }
        else if fieldName == "IBCheckPass" {
            textField = IBCheckPass
        }
        else if fieldName == "IBOldPass" {
            textField = IBOldPass
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
    
    
}

