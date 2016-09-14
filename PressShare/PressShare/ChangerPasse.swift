//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import UIKit

class ChangerPasse : UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBValider: UIBarButtonItem!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBemail: UITextField!
    @IBOutlet weak var IBPasswordVerif: UITextField!
    @IBOutlet weak var IBPassword: UITextField!
    
    
    let config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    
    
    var users = [User]()
    
    
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        users = fetchAllUser()
        
        
        if config.previousView == "LoginViewController" {
            setUIHidden(config.user_newpassword )
            navigationItem.title = traduction.oda4
            
            
        }
        
        if config.previousView == "SettingsTableViewContr" {
            
            self.navigationItem.title = "\(config.user_nom) \(config.user_prenom) (\(config.user_id))"
            IBemail.text = config.user_email
            config.user_newpassword = true
        }
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        IBCancel.title = traduction.pic1
        IBValider.title = traduction.pic2
        IBPassword.placeholder = traduction.pic3
        IBPasswordVerif.placeholder = traduction.pic4
        IBemail.placeholder = traduction.pic5
        
    }
    
    private func setUIHidden(hidden: Bool) {
        IBPassword.hidden = !hidden
        IBPasswordVerif.hidden = !hidden
        IBemail.hidden = hidden
        
    }
    
    
    private func fetchAllUser() -> [User] {
        
        
        users.removeAll()
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [User]
        } catch _ {
            return [User]()
        }
    }
    
    
    
    @IBAction func ActionCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ActionValier(sender: AnyObject) {
        
        var password:String
        
        
        if config.user_newpassword == true {
            
            guard IBPassword.text != "" else {
                displayAlert("Error", mess: "le mot de passe est incorrect")
                return
            }
            
            guard IBPasswordVerif.text != "" else {
                displayAlert("Error", mess: "le mot de passe est incorrect")
                return
            }
            
            guard IBPassword.text == IBPasswordVerif.text else {
                displayAlert("Error", mess: "le mot de passe est incorrect")
                return
            }
            
            password = IBPassword.text!
            config.user_newpassword = false
        }
        else {
            guard IBemail.text != "" else {
                displayAlert("Error", mess: "Email is empty")
                return
            }
            
            password = randomAlphaNumericString(8)
            config.user_email = IBemail.text!
            config.user_newpassword = true
            
        }
        
        
        sharedContext.deleteObject(users[0])
        users.removeLast()
        
        // Save the context.
        do {
            try sharedContext.save()
        } catch let error as NSError {
            print(error.debugDescription)
            
        }
        
        
        config.user_pass = password
        
        
        setUpdatePass(config) { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    
                    if self.config.user_newpassword == true {
                        
                        
                        self.displayAlert("Mot de passe", mess: "Attention un mail a été envoyé dans votre boite aux lettes. \n Pensez à vérifier votre dossier spam si vous ne trouvez pas le mail.")
                        
                    }
                    else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
            else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
        }
        
        
    }
    
    
    private func randomAlphaNumericString(length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    
}

