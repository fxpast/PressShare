//
//  Accueil.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit

class Accueil : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let zTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.tapped(_:)))
        zTapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(zTapRecognizer)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tapped(zUigr:UITapGestureRecognizer) -> Void {
        
        if zUigr.state != UIGestureRecognizerState.Recognized {
            return
            
        }
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
    
}

