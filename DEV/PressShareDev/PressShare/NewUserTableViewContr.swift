//
//  NewUserViewContr.swift
//  PressShare
//
//  Description : Sign up
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import CoreData
import UIKit

class NewUserTableViewContr : UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBDone: UIBarButtonItem!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBemail: UITextField!
    @IBOutlet weak var IBemailLabel: UILabel!
    @IBOutlet weak var IBPseudo: UITextField!
    @IBOutlet weak var IBPseudoLabel: UILabel!
    @IBOutlet weak var IBVerifPass: UITextField!
    @IBOutlet weak var IBVerifPassLabel: UILabel!
    @IBOutlet weak var IBPassword: UITextField!
    @IBOutlet weak var IBPasswordLabel: UILabel!
    
    
    var fieldName = ""
    
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    

    //MARK: Locked portrait
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
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0...3 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundColor  = UIColor.init(hexString: config.colorApp)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
      
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
        
        IBDone.title = translate.message("done")
        
        
        IBPseudoLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBPseudoLabel.text = translate.message("pseudo")
        IBPseudo.attributedPlaceholder = NSAttributedString.init(string: translate.message("pseudo"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBPseudo.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBPseudo.frame))

        IBPasswordLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBPasswordLabel.text = translate.message("password")
        IBPassword.attributedPlaceholder = NSAttributedString.init(string: translate.message("password"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBPassword.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBPassword.frame))
       
        IBVerifPassLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBVerifPassLabel.text = translate.message("checkPass")
        IBVerifPass.attributedPlaceholder = NSAttributedString.init(string: translate.message("checkPass"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBVerifPass.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBVerifPass.frame))
        
        IBemailLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBemailLabel.text = translate.message("enterEmail")
        IBemail.attributedPlaceholder = NSAttributedString.init(string: translate.message("enterEmail"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBemail.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBemail.frame))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        BlackBox.sharedInstance.showHelp("NewUserTableViewContr", self)
        
    }
    
    
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            tableView.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
  
    //MARK: Data User with Sign up
    
    @IBAction func actionDone(_ sender: AnyObject) {
        
        guard IBPseudo.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("errorLogin"))
            return
        }
        
        guard IBemail.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("errorMail"))
            return
        }
        
        guard IBPassword.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("errorPassword"))
            return
        }
        
        guard IBPassword.text == IBVerifPass.text else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("errorPassword"))
            return
        }
        
        
        IBDone.isEnabled = false
        
        config.user_pseudo = IBPseudo.text
        config.user_email = IBemail.text
        config.user_pass = IBPassword.text
        
        MDBUser.sharedInstance.setAddUser(config) { (success, errorString) in
            
            self.IBDone.isEnabled = true
            
            if success {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                    
                }
            }
            
        }
        
        
    }
    
    
    //MARK: textfield Delegate
    
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isEqual(IBPseudo) {
          IBemail.becomeFirstResponder()
        }
        else if textField.isEqual(IBemail) {
          IBPassword.becomeFirstResponder()
        }
        else if textField.isEqual(IBPassword) {
            IBVerifPass.becomeFirstResponder()
        }
        else if textField.isEqual(IBVerifPass) {
            actionDone(self)
        }
        
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBemail) {
            fieldName = "IBemail"
        }
        else if textField.isEqual(IBPseudo) {
            fieldName = "IBPseudo"
        }
        else if textField.isEqual(IBVerifPass) {
            fieldName = "IBVerifPass"
        }
        else if textField.isEqual(IBPassword) {
            fieldName = "IBPassword"
        }
    }
    
    
    
    
    
    
}

