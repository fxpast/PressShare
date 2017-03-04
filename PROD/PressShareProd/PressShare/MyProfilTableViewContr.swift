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


import CoreData
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
    
    var users = [User]()
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
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
        
        users = fetchAllUser()
        
        tableView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
        for i in 0...7 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
       
        
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
    
    
    //MARK: coreData function
    
    private func fetchAllUser() -> [User] {
        
        users.removeAll()
        
        // Create the Fetch Request
        
        
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(request) as! [User]
        } catch _ {
            return [User]()
        }
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
                    
                    if self.users.count > 0 {
                        self.assignUser(self.users[0])
                    }
                    
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
    

    private func assignUser(_ aUser:User) {
        
        aUser.user_pseudo = config.user_pseudo
        aUser.user_email = config.user_email
        aUser.user_nom = config.user_nom
        aUser.user_prenom = config.user_prenom
        aUser.user_pays = config.user_pays
        aUser.user_ville = config.user_ville
        aUser.user_adresse = config.user_adresse
        aUser.user_codepostal = config.user_codepostal
        aUser.user_pass = config.user_pass
        aUser.user_level = config.level as NSNumber?
        
        // Save the context.
        do {
            try sharedContext.save()
        } catch _ {}
        
        
        users = fetchAllUser()
        
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


