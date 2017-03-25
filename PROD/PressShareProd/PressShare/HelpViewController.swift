//
//  helpViewController.swift
//  PressShare
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
    
    
    override func viewDidLoad() {
        
        let url = URL(string: "\(CommunRequest.sharedInstance.urlServer)/Tuto_PressShare/\(helpTitre!).pdf")
        if let _ = url {
            IBWebview.loadRequest(URLRequest.init(url: url!))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        IBFeedback.title = translate.message("feedback")
        
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
