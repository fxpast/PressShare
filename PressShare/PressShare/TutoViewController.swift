//
//  TutoViewController.swift
//  PressShare
//
//  Description : Tutorial on how app works.
//
//  Created by MacbookPRV on 28/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



//Todo :Ajouter le contenu recu de Arnaud


import Foundation

class TutoViewController: UIViewController  {
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    let translate = TranslateMessage.sharedInstance
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IBCancel.title = translate.cancel
    }
    //MARK: Locked landscapee
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            return .portrait
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    open override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
