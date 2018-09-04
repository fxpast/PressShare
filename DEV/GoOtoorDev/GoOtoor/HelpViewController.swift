//
//  helpViewController.swift
//  GoOtoor
//
//  Created by MacbookPRV on 20/03/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit


class HelpViewController : UIViewController {
    
    
    @IBOutlet weak var IBWebview: UIWebView!
    @IBOutlet weak var IBFeedback: UIBarButtonItem!
    @IBOutlet weak var IBCondition: UIBarButtonItem!
    
    var helpTitre:String!
    let translate = TranslateMessage.sharedInstance
    let config = Config.sharedInstance
    var timerBadge : Timer!

    
    override func viewDidLoad() {
        
        let url = URL(string: "\(CommunRequest.sharedInstance.urlServer)/Tuto_GoOtoor/\(helpTitre!).pdf")
        if let _ = url {
            IBWebview.loadRequest(URLRequest.init(url: url!))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        IBFeedback.title = translate.message("feedback")
        view.backgroundColor =  UIColor.init(hexString: config.colorApp)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        config.isTimer = false
        timerBadge.invalidate()
        timerBadge = nil
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "feedback"  {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! FeedbackViewController
            
            controller.helpTitre = helpTitre
            
        }
        
    }
    
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionFeedback(_ sender: Any) {
        
        performSegue(withIdentifier: "feedback", sender: self)
    }
    
}
