//
//  LoginViewController.swift
//  PressShare
//
//  Description : Sign in and if you have forgotten you can ask a new one. Connection by user/password or by facebook
//
//  Created by MacbookPRV on 02/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo new : supprimer doublon proprieté user et config
//Todo new : login par pseudo ou email
//Todo bog : Connexion : orientation paysage


import Foundation
import UIKit
import SystemConfiguration

class LoginTableViewController : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var IBUserLabel: UILabel!
    @IBOutlet weak var IBUser: UITextField!
    @IBOutlet weak var IBPasswordLabel: UILabel!
    @IBOutlet weak var IBPassword: UITextField!
    @IBOutlet weak var IBLogin: UIButton!    
    @IBOutlet weak var IBInfo: UIImageView!
    @IBOutlet weak var IBPressConnect: UILabel!
    @IBOutlet weak var IBNewAccount: UIButton!
    @IBOutlet weak var IBLostPass: UIButton!
    @IBOutlet weak var IBAnonyme: UIButton!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    

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
        
        tableView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        config.cleaner()
        
        for i in 0...4 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundColor  = UIColor.init(hexString: config.colorApp)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        var filePath  = url.appendingPathComponent("tokenString")!.path
        config.tokenString = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! String!
        
     
        IBActivity.isHidden = true
        
        config.previousView = "LoginViewController"
        PressOperations.sharedInstance.operationArray = nil
        Messages.sharedInstance.MessagesArray = nil
        Transactions.sharedInstance.transactionArray = nil
        Capitals.sharedInstance.capitalsArray = nil
        Products.sharedInstance.productsArray = nil
        Products.sharedInstance.productsUserArray = nil
        Cards.sharedInstance.cardsArray = nil
        
        IBPressConnect.text = translate.message("connectToPress")
        IBPressConnect.textColor = UIColor.init(hexString: config.colorAppLabel)
        
        
        IBUser.attributedPlaceholder = NSAttributedString.init(string: translate.message("pseudo"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBUser.textColor = UIColor.init(hexString: config.colorAppText)
        
        IBUserLabel.text = translate.message("pseudo")
        IBUserLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        
        IBUser.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBUser.frame))
        
        IBPasswordLabel.text = translate.message("password")
        IBPasswordLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        
        IBPassword.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBPassword.frame))
        
        IBPassword.attributedPlaceholder = NSAttributedString.init(string: translate.message("password"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBPassword.textColor = UIColor.init(hexString: config.colorAppText)
        
        
        IBLogin.setTitle(translate.message("signin"), for: UIControlState())
        IBLogin.titleLabel?.textAlignment = NSTextAlignment.center
        IBLogin.setTitleColor(UIColor.init(hexString: config.colorAppBt), for: UIControlState())
        IBNewAccount.setTitle(translate.message("signup"), for: UIControlState())
        IBNewAccount.titleLabel?.textAlignment = NSTextAlignment.center
        IBNewAccount.setTitleColor(UIColor.init(hexString: config.colorAppBt), for: UIControlState())
        IBLostPass.setTitle(translate.message("lostPassword"), for: UIControlState())
        IBLostPass.titleLabel?.textAlignment = NSTextAlignment.center
        IBLostPass.setTitleColor(UIColor.init(hexString: config.colorAppBt), for: UIControlState())
        IBAnonyme.setTitle(translate.message("anonyme"), for: UIControlState())
        IBAnonyme.titleLabel?.textAlignment = NSTextAlignment.center
        IBAnonyme.setTitleColor(UIColor.init(hexString: config.colorAppBt), for: UIControlState())
        
        
        filePath  = url.appendingPathComponent("userDico")!.path
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [String:String]) != nil  {
            let userDico = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! [String:AnyObject]
            config.user_pseudo = userDico["user_pseudo"] as! String
            config.user_email = userDico["user_email"] as! String
            IBUser.text = config.user_pseudo
            
            IBUser.isHidden = false
            IBPassword.isHidden = false
            
        }
        else {
            IBUser.text = ""
        }
        
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("firstTime")!.path
        
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Bool) == nil  {
            NSKeyedArchiver.archiveRootObject(true, toFile: filePath)
            //action info
            
            BlackBox.sharedInstance.showHelp("Tuto_Presentation", self)
            
        }

    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        
        if textField.isEqual(IBUser) {
            IBPassword.becomeFirstResponder()
            
        }
        else if IBUser.text != "" && IBPassword.text != "" {
            
            actionLogin(self)
            
        }
        
        
        
        return true
        
    }
    
    
    private func setUIEnabled(_ enabled: Bool) {
        IBUser.isEnabled = enabled
        IBPassword.isEnabled = enabled
        IBLogin.isEnabled = enabled
        // adjust login button alpha
        if enabled {
            IBLogin.alpha = 1.0
        } else {
            IBLogin.alpha = 0.5
        }
        
        
    }
    
    //MARK: Sign in
    
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            
            let location = sender.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at:location)
            let zx = location.x
            let cell = tableView.cellForRow(at: indexPath!)
            let zy = location.y - (cell?.frame.origin.y)!
            
            if indexPath?.row == 0 && indexPath?.section == 0 {
                
                let xw1 = IBInfo.frame.origin.x + IBInfo.frame.size.width
                let yh1 = IBInfo.frame.origin.y + IBInfo.frame.size.height
                
                if zx <= xw1 && zx >= IBInfo.frame.origin.x && zy  <= yh1 && zy >= IBInfo.frame.origin.y {
                    
                    //action info
                    BlackBox.sharedInstance.showHelp("Tuto_Presentation", self)
                    
                    
                }
                else {
                    tableView.endEditing(true)
                }
                
                
            }
            else {
                tableView.endEditing(true)
            }
            
            
        }
        sender.cancelsTouchesInView = false
    }
    
    
    
    @IBAction func actionNewAccount(_ sender: Any) {
        
        performSegue(withIdentifier: "signup", sender: self)
        
    }
    
    
    @IBAction func actionPassword(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "chgpass", sender: self)
        
    }
    
    
    @IBAction func actionAnonyme(_ sender: AnyObject) {
        
        IBUser.text = "anonymous"
        IBPassword.text = "anonymous"
        
        actionLogin(self)
        
    }
    
    
    @IBAction func actionLogin(_ sender: AnyObject) {
     
        
        guard IBUser.text != "" else {
            
            displayAlert(translate.message("error"), mess: translate.message("errorLogin"))
            return
        }
        
        guard IBPassword.text != "" else {
            
            displayAlert(translate.message("error"), mess:  translate.message("errorPassword"))
            return
        }
        
        setUIEnabled(false)
        
        config.user_pass = IBPassword.text!
        config.user_pseudo = IBUser.text!
        
        MDBUser.sharedInstance.Authentification(config) { (success, userArray, errorString) in
            
            if success {
                
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
                let filePath  = url.appendingPathComponent("userDico")!.path
                
                let userDico = ["user_pseudo":userArray![0]["user_pseudo"],
                                "user_email":userArray![0]["user_email"]]
                
                NSKeyedArchiver.archiveRootObject(userDico, toFile: filePath)
                
                self.assignUser( User(dico: userArray![0]))
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.callMenu()
                }
                
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                    
                }
            }
        }
        
        
    }
    
    private func assignUser(_ aUser:User) {
        
        
        config.user_id = aUser.user_id
        config.user_pseudo = aUser.user_pseudo
        config.user_email = aUser.user_email
        config.user_nom = aUser.user_nom
        config.user_prenom = aUser.user_prenom
        config.user_newpassword = aUser.user_newpassword
        config.user_pays = aUser.user_pays
        config.user_ville = aUser.user_ville
        config.user_adresse = aUser.user_adresse
        config.user_codepostal = aUser.user_codepostal
        config.verifpassword = ""
        config.level = aUser.user_level as Int!
        config.user_countNote = aUser.user_countNote
        config.user_note = aUser.user_note
        
    }
    
    
    private func callMenu() {
        
        if config.user_pseudo != "" {
            
            IBPassword.text = ""
            setUIEnabled(true)
            
            
            if (config.user_newpassword == true) {
                
                config.previousView = "SettingsTableViewContr"
                performSegue(withIdentifier: "chgpass", sender: self)
            }
            else {
                if config.tokenString == nil {
                    self.performSegue(withIdentifier: "tabbar", sender: self)
                }
                else {
                    
                    MDBUser.sharedInstance.setUpdateUserToken(config, completionHandlerToken: { (success, errorString) in
                        
                        if success {
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
                                self.performSegue(withIdentifier: "tabbar", sender: self)
                                
                            }
                            
                        }
                        else {
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.setUIEnabled(true)
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                                
                            }
                        }
                        
                    })
                    
                }
                
            }
            
            
        }
        
        
    }
    
}
