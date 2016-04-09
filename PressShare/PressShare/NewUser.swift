//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit

class NewUser : UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var IBpays: UITextField!
    @IBOutlet weak var IBville: UITextField!
    @IBOutlet weak var IBcodepostal: UITextField!
    @IBOutlet weak var IBadresse: UITextField!
    @IBOutlet weak var IBpasseVerif: UITextField!
    @IBOutlet weak var IBpasse: UITextField!
    @IBOutlet weak var IBemail: UITextField!
    @IBOutlet weak var IBpseudo: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.IBville.delegate=self
        self.IBpays.delegate=self
        self.IBcodepostal.delegate=self
        self.IBadresse.delegate=self
        self.IBpasseVerif.delegate=self
        self.IBpasse.delegate=self
        self.IBemail.delegate=self
        self.IBpseudo.delegate=self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
    
    @IBAction func ActionValier(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    
}

