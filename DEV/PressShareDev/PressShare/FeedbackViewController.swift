//
//  FeedbackViewController.swift
//  PressShare
//
//  Created by MacbookPRV on 21/03/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit


class FeedbackViewController: UIViewController {
    
    
    @IBOutlet weak var IBSend: UIBarButtonItem!
    @IBOutlet weak var IBTextView: UITextView!
    
    
    var helpTitre:String!
    
    let translate = TranslateMessage.sharedInstance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IBSend.title = translate.message("send")
        title = translate.message("feedback")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        IBTextView.becomeFirstResponder()
        
    }
    
    
    @IBAction func actionSend(_ sender: Any) {
        
        
        var feedback = Feedback(dico: [String : AnyObject]())
        
        feedback.comment = IBTextView.text!
        feedback.origin = helpTitre!
        MDBFeedback.sharedInstance.setAddFeedback(feedback) { (success, errorString) in
            
            if success {
        
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("feedback"), mess: self.translate.message("feedbackMess"))
                    self.IBTextView.text = ""
                }
                
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
        }
        
        
    }
    
    @IBAction func actionCancel(_ sender: Any) {

        dismiss(animated: true, completion: nil)
    
    }
}
