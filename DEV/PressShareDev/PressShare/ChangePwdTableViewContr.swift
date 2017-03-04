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

class ChangePwdTableViewContr : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var IBDone: UIBarButtonItem!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBEmail: UITextField!
    @IBOutlet weak var IBEmailLabel: UILabel!
    @IBOutlet weak var IBCheckPass: UITextField!
    @IBOutlet weak var IBCheckPassLabel: UILabel!
    @IBOutlet weak var IBOldPass: UITextField!
    @IBOutlet weak var IBOldPassLabel: UILabel!
    @IBOutlet weak var IBNewPass: UITextField!
    @IBOutlet weak var IBNewPassLabel: UILabel!
    
    
    
    var fieldName = ""
    
    
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
        
        tableView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0...3 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
      
        if config.previousView == "LoginViewController" {
            
            navigationItem.title = translate.message("lostPassword")
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
                
                IBOldPassLabel.isHidden = true
                IBNewPassLabel.isHidden = true
                IBCheckPassLabel.isHidden = true
                
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
        
        
      
        IBDone.title = translate.message("done")
        
        IBOldPass.placeholder = translate.message("oldPass")
        IBOldPassLabel.text = translate.message("oldPass")
        IBOldPass.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBOldPass.frame))

        IBNewPass.placeholder = translate.message("newPass")
        IBNewPassLabel.text = translate.message("newPass")
        IBNewPass.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBNewPass.frame))

        IBCheckPass.placeholder = translate.message("checkPass")
        IBCheckPassLabel.text = translate.message("checkPass")
        IBCheckPass.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBCheckPass.frame))

        IBEmail.placeholder = translate.message("enterEmail")
        IBEmailLabel.text = translate.message("enterEmail")
        IBEmail.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBEmail.frame))

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            tableView.endEditing(true)
        }
        sender.cancelsTouchesInView = false
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
            displayAlert(translate.message("error"), mess: translate.message("errorMail"))
            return
        }
        
        //--- Login View Controller
        if config.previousView == "LoginViewController" {
            
            if config.user_newpassword == true {
                
                guard IBNewPass.text != "" else {
                    displayAlert(translate.message("error"), mess: translate.message("errorNewPassword"))
                    return
                }
                
                guard IBCheckPass.text != "" else {
                    displayAlert(translate.message("error"), mess: translate.message("errorCheckPassword"))
                    return
                }
                
                guard IBNewPass.text == IBCheckPass.text else {
                    displayAlert(translate.message("error"), mess: translate.message("loginPassword"))
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
                displayAlert(translate.message("error"), mess: translate.message("errorOldPassword"))
                return
            }
            
            guard IBNewPass.text != "" else {
                displayAlert(translate.message("error"), mess: translate.message("errorNewPassword"))
                return
            }
            
            guard IBCheckPass.text != "" else {
                displayAlert(translate.message("error"), mess: translate.message("errorCheckPassword"))
                return
            }
            
            guard IBNewPass.text == IBCheckPass.text else {
                displayAlert(translate.message("error"), mess: translate.message("loginPassword"))
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
                        self.displayAlert(self.translate.message("password"), mess: self.translate.message("emailPassword"))
                        
                    }
                    else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
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
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if textField.isEqual(IBEmail) {
            if IBEmail.text != ""  &&  config.previousView == "LoginViewController"  {                
                actionDone(self)
            }
            else {
                IBOldPass.becomeFirstResponder()
            }
            
        }
        else if textField.isEqual(IBOldPass) {
            IBNewPass.becomeFirstResponder()
        }
        else if textField.isEqual(IBNewPass) {
            IBCheckPass.becomeFirstResponder()
        }
        else if textField.isEqual(IBCheckPass) {
            actionDone(self)
        }
        
        textField.endEditing(true)
        
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
    
    
    
}

