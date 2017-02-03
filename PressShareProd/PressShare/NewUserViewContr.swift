//
//  NewUserViewContr.swift
//  PressShare
//
//  Description : Sign up
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import UIKit

class NewUserViewContr : UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBDone: UIBarButtonItem!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBemail: UITextField!
    @IBOutlet weak var IBPseudo: UITextField!
    @IBOutlet weak var IBVerifPass: UITextField!
    @IBOutlet weak var IBAncienPass: UITextField!
    
    
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscibeToKeyboardNotifications()
        
        IBDone.title = translate.done
        
        IBAncienPass.placeholder = translate.oldPass
        IBVerifPass.placeholder = translate.checkPass
        IBemail.placeholder = translate.enterEmail
        
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
    
    
    //MARK: Data User with Sign up
    
    @IBAction func actionDone(_ sender: AnyObject) {
        
        guard IBPseudo.text != "" else {
            self.displayAlert(self.translate.error, mess: translate.errorLogin)
            return
        }
        
        guard IBemail.text != "" else {
            self.displayAlert(self.translate.error, mess: translate.errorMail)
            return
        }
        
        guard IBAncienPass.text != "" else {
            self.displayAlert(self.translate.error, mess: translate.errorPassword)
            return
        }
        
        guard IBAncienPass.text == IBVerifPass.text else {
            self.displayAlert(self.translate.error, mess: translate.errorPassword)
            return
        }
        
        
        IBDone.isEnabled = false
        
        config.user_pseudo = IBPseudo.text
        config.user_email = IBemail.text
        config.user_pass = IBAncienPass.text
        
        MDBUser.sharedInstance.setAddUser(config) { (success, errorString) in
            
            self.IBDone.isEnabled = true
            
            if success {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    if self.users.count > 0 {
                        self.sharedContext.delete(self.users[0])
                        self.users.removeLast()
                        // Save the context.
                        do {
                            try self.sharedContext.save()
                        } catch let error as NSError {
                            print(error.debugDescription)
                            
                        }
                        
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: errorString!)
                    
                }
            }
            
        }
        
        
    }
    
    
    
    
    //MARK: textfield Delegate
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        let location = (event?.allTouches?.first?.location(in: self.view).y)! as CGFloat
        if (Double(location) < Double(keybordY)) {
            
            var textField = UITextField()
            
            
            if fieldName == "IBemail" {
                textField = IBemail
            }
            else if fieldName == "IBPseudo" {
                textField = IBPseudo
            }
            else if fieldName == "IBVerifPass" {
                textField = IBVerifPass
            }
            else if fieldName == "IBAncienPass" {
                textField = IBAncienPass
            }
            
            textField.endEditing(true)
            
        }
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBemail) {
            fieldName = "IBemail"
        }
        else if textField.isEqual(IBPseudo) {
            fieldName = "IBPseudo"
        }
        else if textField.isEqual(IBVerifPass) {
            fieldName = "IBVerifPass"
        }
        else if textField.isEqual(IBAncienPass) {
            fieldName = "IBAncienPass"
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
        
        
        if fieldName == "IBemail" {
            textField = IBemail
        }
        else if fieldName == "IBPseudo" {
            textField = IBPseudo
        }
        else if fieldName == "IBVerifPass" {
            textField = IBVerifPass
        }
        else if fieldName == "IBAncienPass" {
            textField = IBAncienPass
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
        
        
        if fieldName == "IBemail" {
            textField = IBemail
        }
        else if fieldName == "IBPseudo" {
            textField = IBPseudo
        }
        else if fieldName == "IBVerifPass" {
            textField = IBVerifPass
        }
        else if fieldName == "IBAncienPass" {
            textField = IBAncienPass
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

