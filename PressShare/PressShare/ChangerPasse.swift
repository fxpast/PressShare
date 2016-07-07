//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit

class ChangerPasse : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var IBemail: UITextField!
    @IBOutlet weak var IBPasswordVerif: UITextField!
    @IBOutlet weak var IBPassword: UITextField!
    
    let config = Config.sharedInstance
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.IBemail.delegate = self
        self.IBPasswordVerif.delegate = self
        self.IBPassword.delegate = self
        
        if config.previousView == "LoginViewController" {
            setUIHidden(config.user_newpassword )
            
        }
        
        if config.previousView == "SettingsTableViewContr" {
            navigationItem.title = "\(config.user_nom) \(config.user_prenom)"
            IBemail.text = config.user_email
            config.user_newpassword = true
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setUIHidden(hidden: Bool) {
        IBPassword.hidden = !hidden
        IBPasswordVerif.hidden = !hidden
        IBemail.hidden = hidden
        
    }
    
    
    
    
    @IBAction func ActionCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ActionValier(sender: AnyObject) {
        
        var password:String
        
        var user = User(dico: [String : AnyObject]())
        
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
            user.user_email = config.user_email
            user.user_newpassword = false
        }
        else {
            guard IBemail.text != "" else {
                displayAlert("Error", mess: "Email is empty")
                return
            }
            
            password = randomAlphaNumericString(8)
            user.user_email = IBemail.text!
            user.user_newpassword = true
            
        }
        
        
        user.user_pass = password
        
        
        setUpdatePass(user) { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    
                    if user.user_newpassword == true {
                        
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

