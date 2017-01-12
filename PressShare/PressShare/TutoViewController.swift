//
//  TutoViewController.swift
//  PressShare
//
//  Description : Tutorial on how app works.
//
//  Created by MacbookPRV on 28/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation

class TutoViewController: UIViewController  {
    
    @IBOutlet weak var IBWebView: UIWebView!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    let translate = TranslateMessage.sharedInstance
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Locked landscapeLeft
     open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            return .landscapeLeft
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .landscapeLeft
        }
    }
 
    open override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let url = URL(string: String(format: "http://pressshare.fxpast.com/Tuto_PressShare/index.html"))
        
        let request = URLRequest.init(url: url!)
        IBWebView.loadRequest(request)

        
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
