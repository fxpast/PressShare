//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit

class Connexion : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var IBpassword: UITextField!
    @IBOutlet weak var IBuser: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.IBpassword.delegate=self
        self.IBuser.delegate=self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func ActionValider(sender: AnyObject) {
        
      
        
        if self.IBuser.text != "" && self.IBpassword != ""  {
            self.performSegueWithIdentifier("accueilnormal", sender: self)
        }
        
    }
    
    
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    
    
}

