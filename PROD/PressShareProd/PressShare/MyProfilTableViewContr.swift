//
//  ViewController.swift
//  PressShare
//
//  Description : Update user profil except password.
//
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



//Todo: aide dans MyProfilTableViewContr


import UIKit

class MyProfilTableViewContr : UITableViewController ,UITextFieldDelegate,  UIAlertViewDelegate {
    
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBSave: UIBarButtonItem!
    @IBOutlet weak var IBPseudo: UITextField!
    @IBOutlet weak var IBPseudoLabel: UILabel!
    
    @IBOutlet weak var IBEmail: UITextField!
    @IBOutlet weak var IBEmailLabel: UILabel!

    @IBOutlet weak var IBNickName: UITextField!
    @IBOutlet weak var IBNickNameLabel: UILabel!
    @IBOutlet weak var IBSurname: UITextField!
    @IBOutlet weak var IBSurnameLabel: UILabel!
    @IBOutlet weak var IBAdresse: UITextField!
    @IBOutlet weak var IBAdresseLabel: UILabel!
    @IBOutlet weak var IBZipCode: UITextField!
    @IBOutlet weak var IBZipCodeLabel: UILabel!
    @IBOutlet weak var IBCity: UITextField!
    @IBOutlet weak var IBCityLabel: UILabel!
    @IBOutlet weak var IBCountry: UITextField!
    @IBOutlet weak var IBCountryLabel: UILabel!
 
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var timerBadge : Timer!


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
        
    
        for i in 0...7 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundColor  = UIColor.init(hexString: config.colorApp)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
       
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
        
        IBSave.title = translate.message("save")
        
        navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        
        IBPseudo.placeholder = translate.message("pseudo")
        IBPseudo.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBPseudo.frame))
        IBPseudoLabel.text = translate.message("pseudo")
        IBEmail.placeholder = translate.message("mail")
        IBEmail.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBEmail.frame))
        IBEmailLabel.text = translate.message("mail")
        IBNickName.placeholder = translate.message("nickName")
        IBNickName.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBNickName.frame))
        IBNickNameLabel.text = translate.message("nickName")
        IBSurname.placeholder = translate.message("surname")
        IBSurname.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBSurname.frame))
        IBSurnameLabel.text = translate.message("surname")
        IBAdresse.placeholder = translate.message("adresse")
        IBAdresse.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBAdresse.frame))
        IBAdresseLabel.text = translate.message("adresse")
        IBZipCode.placeholder = translate.message("zipCode")
        IBZipCode.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBZipCode.frame))
        IBZipCodeLabel.text = translate.message("zipCode")
        IBCity.placeholder = translate.message("city")
        IBCity.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBCity.frame))
        IBCityLabel.text = translate.message("city")
        IBCountry.placeholder = translate.message("country")
        IBCountry.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBCountry.frame))
        IBCountryLabel.text = translate.message("country")
        IBPseudo.text = config.user_pseudo
        IBEmail.text = config.user_email
        IBNickName.text = config.user_nom
        IBSurname.text = config.user_prenom
        IBAdresse.text = config.user_adresse
        IBZipCode.text = config.user_codepostal
        IBCity.text = config.user_ville
        IBCountry.text = config.user_pays
        
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
            
            BlackBox.sharedInstance.checkBadge(completionHdlerBadge: { (success, result) in
                
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
    
    
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            tableView.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        BlackBox.sharedInstance.showHelp("MyProfilTableViewContr", self)
        
    }
    
    
    @IBAction func actionDone(_ sender: AnyObject) {
        
        guard config.user_pseudo != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("errorLogin"))
            return
        }
        
        guard config.user_email != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("errorMail"))
            return
        }
        
        IBSave.isEnabled = false
        
        MDBUser.sharedInstance.setUpdateUser(config) { (success, errorString) in
            self.IBSave.isEnabled = true
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
            IBEmail.becomeFirstResponder()
        }
        else if textField.isEqual(IBEmail) {
            IBNickName.becomeFirstResponder()
        }
        else if textField.isEqual(IBNickName) {
            IBSurname.becomeFirstResponder()
        }
        else if textField.isEqual(IBSurname) {
            IBAdresse.becomeFirstResponder()
        }
        else if textField.isEqual(IBAdresse) {
            IBZipCode.becomeFirstResponder()
        }
        else if textField.isEqual(IBZipCode) {
            IBCity.becomeFirstResponder()
        }
        else if textField.isEqual(IBCity) {
            IBCountry.becomeFirstResponder()
        }
        else if textField.isEqual(IBCountry) {
            actionDone(self)
        }
        
        
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBPseudo) {
            config.user_pseudo = IBPseudo.text
        }
        else if textField.isEqual(IBEmail) {
            config.user_email = IBEmail.text
        }
        else if textField.isEqual(IBNickName) {
            config.user_nom = IBNickName.text
        }
        else if textField.isEqual(IBSurname) {
            config.user_prenom = IBSurname.text
        }
        else if textField.isEqual(IBAdresse) {
            config.user_adresse = IBAdresse.text
        }
        else if textField.isEqual(IBZipCode) {
            config.user_codepostal = IBZipCode.text
        }
        else if textField.isEqual(IBCity) {
            config.user_ville = IBCity.text
        }
        else if textField.isEqual(IBCountry) {
            config.user_pays = IBCountry.text
        }
        
        
    }
    
    
}



