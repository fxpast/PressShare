//
//  CBViewController.swift
//  PressShare
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit

class CBViewController: UIViewController {
    
    
    @IBAction func ActionDone(_ sender: AnyObject) {
        
    
        getAllCard(userId: 1) { (success, cardArray, errorString) in
            
            if success {
                
                performUIUpdatesOnMain {
                    
                    print(cardArray!)
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
            }
            else {
                performUIUpdatesOnMain {
                    
                    self.displayAlert("Error", mess: errorString!)
                    
                }
            }
            
        }
        
        
        
    }
    
    
    @IBAction func ActionCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    
}
