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
    
    
    
    
    @IBAction func ActionValier(sender: AnyObject) {
        
        if self.IBemail.text != "" {
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
       
    
    }
    
    
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    
}

