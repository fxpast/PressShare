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
    @IBOutlet weak var IBVerifPass: UITextField!
    @IBOutlet weak var IBAncienPass: UITextField!
    @IBOutlet weak var IBNouvPass: UITextField!
    
    
    
    let config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    
    var users = [User]()
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        users = fetchAllUser()
        
        if config.previousView == "LoginViewController" {
            
            navigationItem.title = traduction.oda4
            if let nouvPass = config.user_newpassword {
                
                if nouvPass == true {
                    IBemail.isHidden = false
                    IBemail.text = config.user_email
                    
                    IBNouvPass.isHidden = false
                    IBVerifPass.isHidden = false
                    
                    IBAncienPass.isHidden = true
                    
                }
            }
            else {
                config.user_newpassword = false
            }
            
            if config.user_newpassword == false {
                
                IBemail.isHidden = false
                IBemail.text = config.user_email
                
                IBAncienPass.isHidden = true
                IBNouvPass.isHidden = true
                IBVerifPass.isHidden = true
                
            }
        }
        
        
        if config.previousView == "SettingsTableViewContr" {
            
            self.navigationItem.title = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_id!))"
            
            IBemail.isHidden = false
            IBemail.text = config.user_email
            
            IBAncienPass.isHidden = false
            IBNouvPass.isHidden = false
            IBVerifPass.isHidden = false
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IBCancel.title = traduction.pic1
        IBValider.title = traduction.pic2
        
        IBAncienPass.placeholder = traduction.pic3
        IBNouvPass.placeholder = traduction.pic6
        IBVerifPass.placeholder = traduction.pic4
        IBemail.placeholder = traduction.pic5
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
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
    
    
    @IBAction func ActionCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func ActionValider(_ sender: AnyObject) {
        
        
        guard IBemail.text != "" else {
            displayAlert("Error", mess: "Email is empty")
            return
        }
        
        //--- Login View Controller
        if config.previousView == "LoginViewController" {
            
            if config.user_newpassword == true {
                
                guard IBNouvPass.text != "" else {
                    displayAlert("Error", mess: "nouveau mot de passe incorrect")
                    return
                }
                
                guard IBVerifPass.text != "" else {
                    displayAlert("Error", mess: "verification mot de passe incorrect")
                    return
                }
                
                guard IBNouvPass.text == IBVerifPass.text else {
                    displayAlert("Error", mess: "nouveau et verification mot de passe differents")
                    return
                }
                
                config.user_lastpass = IBNouvPass.text!
                config.user_newpassword = false
            }
            else {
                
                config.user_lastpass = randomAlphaNumericString(8)
                config.user_email = IBemail.text!
                config.user_newpassword = true
                
            }
            
        }
        
        //--- Settings Table View Controller
        
        if config.previousView == "SettingsTableViewContr" {
            
            guard IBAncienPass.text != "" else {
                displayAlert("Error", mess: "ancien mot de passe incorrect")
                return
            }
            
            guard IBNouvPass.text != "" else {
                displayAlert("Error", mess: "nouveau mot de passe incorrect")
                return
            }
            
            guard IBVerifPass.text != "" else {
                displayAlert("Error", mess: "verification mot de passe incorrect")
                return
            }
            
            guard IBNouvPass.text == IBVerifPass.text else {
                displayAlert("Error", mess: "nouveau et verification mot de passe differents")
                return
            }
            
            config.user_pass = IBAncienPass.text
            config.user_lastpass = IBNouvPass.text!
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
        
        
        setUpdatePass(config) { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    
                    if self.config.user_newpassword == true {
                        
                        
                        self.displayAlert("Mot de passe", mess: "Attention un mail a été envoyé dans votre boite aux lettes. \n Pensez à vérifier votre dossier spam si vous ne trouvez pas le mail.")
                        
                    }
                    else {
                        self.dismiss(animated: true, completion: nil)
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
    
    
    fileprivate func randomAlphaNumericString(_ length: Int) -> String {
        
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
        textField.endEditing(true)
        return true
        
    }
    
    
}

