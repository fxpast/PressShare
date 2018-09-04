//
//  UpdatePasswordViewContr.swift
//  GoOtoor
//
//  Desciption : Update password from setting list or lost password from sign in view.
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit

class ChangePwdTableViewContr : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var IBDone: UIBarButtonItem!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBEmail: UITextField!
    @IBOutlet weak var IBEmailLabel: UILabel!
    @IBOutlet weak var IBCheckPass: UITextField!
    @IBOutlet weak var IBCheckPassLabel: UILabel!
    @IBOutlet weak var IBOldPass: UITextField!
    @IBOutlet weak var IBOldPassLabel: UILabel!
    @IBOutlet weak var IBNewPass: UITextField!
    @IBOutlet weak var IBNewPassLabel: UILabel!
    
    
    
    var fieldName = ""
    
    var timerBadge : Timer!

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
        
        
     
        IBEmail.textColor = UIColor.init(hexString: config.colorAppText)
        
        if config.previousView == "LoginViewController" {
            
            navigationItem.title = translate.message("lostPassword")
            if config.user_newpassword == true {
                
                IBEmail.isHidden = false
                IBEmail.text = config.user_email
                    
                IBNewPass.isHidden = false
                IBCheckPass.isHidden = false
                    
                IBOldPass.isHidden = true
            }
            else {
                IBEmail.isHidden = false
                IBEmail.text = config.user_email
                
                IBOldPass.isHidden = true
                IBNewPass.isHidden = true
                IBCheckPass.isHidden = true
                
                IBOldPassLabel.isHidden = true
                IBNewPassLabel.isHidden = true
                IBCheckPassLabel.isHidden = true
                
            }
        }
        
        if config.previousView == "SettingsTableViewContr" {
            
            self.navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
            
            IBEmail.isHidden = false
            IBEmail.text = config.user_email
            
            IBOldPass.isHidden = false
            IBNewPass.isHidden = false
            IBCheckPass.isHidden = false
            
        }
        
        
      
        
        IBDone.title = translate.message("done")
        
        IBOldPass.attributedPlaceholder = NSAttributedString.init(string: translate.message("oldPass"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBOldPassLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBOldPassLabel.text = translate.message("oldPass")
        IBOldPass.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBOldPass.frame))

        
        IBNewPass.attributedPlaceholder = NSAttributedString.init(string: translate.message("newPass"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBNewPassLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBNewPassLabel.text = translate.message("newPass")
        IBNewPass.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBNewPass.frame))

        
        
        IBCheckPass.attributedPlaceholder = NSAttributedString.init(string: translate.message("checkPass"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        IBCheckPassLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBCheckPassLabel.text = translate.message("checkPass")
        IBCheckPass.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBCheckPass.frame))

        
        IBEmail.attributedPlaceholder = NSAttributedString.init(string: translate.message("enterEmail"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])        
        IBEmailLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBEmailLabel.text = translate.message("enterEmail")
        IBEmail.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBEmail.frame))

        
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
    
    
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        MyTools.sharedInstance.showHelp("ChangePwdTableViewContr", self)
        
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
  
    //MARK: Data User with update password
    
    @IBAction func actionDone(_ sender: AnyObject) {
        
        guard IBEmail.text != "" else {
            displayAlert(translate.message("error"), mess: translate.message("errorMail"))
            return
        }
        
        //--- Login View Controller
        if config.previousView == "LoginViewController" {
            
            if config.user_newpassword == true {
                
                guard IBNewPass.text != "" else {
                    displayAlert(translate.message("error"), mess: translate.message("errorNewPassword"))
                    return
                }
                
                guard IBCheckPass.text != "" else {
                    displayAlert(translate.message("error"), mess: translate.message("errorCheckPassword"))
                    return
                }
                
                guard IBNewPass.text == IBCheckPass.text else {
                    displayAlert(translate.message("error"), mess: translate.message("loginPassword"))
                    return
                }
                
                config.user_lastpass = IBNewPass.text!
                config.user_newpassword = false
            }
            else {
                
                config.user_lastpass = randomAlphaNumericString(8)
                config.user_email = IBEmail.text!
                config.user_newpassword = true
                
            }
            
        }
        
        //--- Settings Table View Controller
        
        if config.previousView == "SettingsTableViewContr" {
            
            guard IBOldPass.text != "" else {
                displayAlert(translate.message("error"), mess: translate.message("errorOldPassword"))
                return
            }
            
            guard IBNewPass.text != "" else {
                displayAlert(translate.message("error"), mess: translate.message("errorNewPassword"))
                return
            }
            
            guard IBCheckPass.text != "" else {
                displayAlert(translate.message("error"), mess: translate.message("errorCheckPassword"))
                return
            }
            
            guard IBNewPass.text == IBCheckPass.text else {
                displayAlert(translate.message("error"), mess: translate.message("loginPassword"))
                return
            }
            
            config.user_pass = IBOldPass.text
            config.user_lastpass = IBNewPass.text!
            config.user_newpassword = false
        }
        
        
        MDBUser.sharedInstance.setUpdatePass(config) { (success, errorString) in
            if success {
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    
                    if self.config.user_newpassword == true {
                        self.IBDone.isEnabled = false
                        
                        let alertController = UIAlertController(title: self.translate.message("password"), message: self.translate.message("emailPassword"), preferredStyle: .alert)
        
                        let actionOk = UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                             self.dismiss(animated: true, completion: nil)
                        })
                        
                        alertController.addAction(actionOk)
                        self.present(alertController, animated: true) {
                            //ok
                        }
                        
                    }
                    else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else {
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        }
        
    }
    
  
    
    private func randomAlphaNumericString(_ length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.characters.index(allowedChars.startIndex, offsetBy: randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    //MARK: textfield Delegate
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if textField.isEqual(IBEmail) {
            if IBEmail.text != ""  &&  config.previousView == "LoginViewController"  {                
                actionDone(self)
            }
            else {
                IBOldPass.becomeFirstResponder()
            }
            
        }
        else if textField.isEqual(IBOldPass) {
            IBNewPass.becomeFirstResponder()
        }
        else if textField.isEqual(IBNewPass) {
            IBCheckPass.becomeFirstResponder()
        }
        else if textField.isEqual(IBCheckPass) {
            actionDone(self)
        }
        
        textField.endEditing(true)
        
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBEmail) {
            fieldName = "IBEmail"
        }
        else if textField.isEqual(IBNewPass) {
            fieldName = "IBNewPass"
        }
        else if textField.isEqual(IBCheckPass) {
            fieldName = "IBCheckPass"
        }
        else if textField.isEqual(IBOldPass) {
            fieldName = "IBOldPass"
        }
    }
    
    
    
}

