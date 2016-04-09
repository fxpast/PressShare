//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit

class AccueilNormal : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func ActionTrajet(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func ActionGare(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
   
    @IBAction func ActionAcheter(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}

