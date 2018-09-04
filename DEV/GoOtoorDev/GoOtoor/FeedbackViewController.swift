//
//  FeedbackViewController.swift
//  GoOtoor
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
    let config = Config.sharedInstance
    var timerBadge : Timer!

    let translate = TranslateMessage.sharedInstance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor =  UIColor.init(hexString: config.colorApp)
        
        IBSend.title = translate.message("send")
        title = translate.message("feedback")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        IBTextView.becomeFirstResponder()
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        config.isTimer = false
        timerBadge.invalidate()
        timerBadge = nil
        IBTextView.textColor = UIColor.init(hexString: config.colorAppText)
        
        
    }
    
    @objc private func routineTimer() {
        
        if config.isTimer == false {
            
            MyTools.sharedInstance.checkBadge(completionHdlerBadge: { (success, result) in
                
                if success == true {
                    
                    if result == "mess_badge" {
                        self.displayAlert(self.translate.message("myNotif"), mess: self.translate.message("newMessage"))
                    }
                    else if result == "trans_badge" {
                        self.displayAlert(self.translate.message("myNotif"), mess: self.translate.message("newTransaction"))
                    }
                    
                }
                else {
                    
                }
                
            })
        }
        
    }
    
    
    @IBAction func actionSend(_ sender: Any) {
        
        
        var feedback = Feedback(dico: [String : AnyObject]())
        
        feedback.comment = IBTextView.text!
        feedback.origin = helpTitre!
        MDBFeedback.sharedInstance.setAddFeedback(feedback) { (success, errorString) in
            
            if success {
        
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("feedback"), mess: self.translate.message("feedbackMess"))
                    self.IBTextView.text = ""
                }
                
            }
            else {
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
        }
        
        
    }
    
    @IBAction func actionCancel(_ sender: Any) {

        dismiss(animated: true, completion: nil)
    
    }
}
