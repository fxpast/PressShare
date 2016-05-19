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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.IBemail.delegate=self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func ActionCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ActionValier(sender: AnyObject) {
        
        guard self.IBemail.text != "" else {
            displayAlert("Error", mess: "Email is empty")
            return
        }
        
        var user = User(dico: [String : AnyObject]())
        user.user_pass = randomAlphaNumericString(8)
        user.user_email = IBemail.text!
        
        setUpdatePass(user) { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.displayAlert("Mot de passe", mess: "Attention un mail a été envoyé dans votre boite aux lettes. \n Pensez à vérifier votre dossier spam si vous ne trouvez pas le mail.")
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

