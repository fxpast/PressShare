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

//Todo : improve view fields


import CoreData
import UIKit

class UpdateUserTableViewContr : UITableViewController ,UITextFieldDelegate,  UIAlertViewDelegate {
    
    
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBSave: UIBarButtonItem!
    
    
    var ligne:Int = -1
    
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    
    var users = [User]()
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
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
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        users = fetchAllUser()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        subscibeToKeyboardNotifications()
        
        
        IBCancel.title = translate.cancel
        IBSave.title = translate.save
        
        navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        
        var cell:UITableViewCell
        
        cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0))!
        var label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.pseudo
        
        cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.mail
        
        cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.nickName
        
        cell = tableView.cellForRow(at: IndexPath(item: 3, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.surname
        
        cell = tableView.cellForRow(at: IndexPath(item: 4, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.adresse
        
        cell = tableView.cellForRow(at: IndexPath(item: 5, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.zipCode
        
        cell = tableView.cellForRow(at: IndexPath(item: 6, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.city
        
        cell = tableView.cellForRow(at: IndexPath(item: 7, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.country
        
        
        
        
        setUIHidden(false, indexpath: IndexPath(row: 0, section: 0))
        setUIHidden(false, indexpath: IndexPath(row: 1, section: 0))
        setUIHidden(false, indexpath: IndexPath(row: 2, section: 0))
        setUIHidden(false, indexpath: IndexPath(row: 3, section: 0))
        setUIHidden(false, indexpath: IndexPath(row: 4, section: 0))
        setUIHidden(false, indexpath: IndexPath(row: 5, section: 0))
        setUIHidden(false, indexpath: IndexPath(row: 6, section: 0))
        setUIHidden(false, indexpath: IndexPath(row: 7, section: 0))
        
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setUIHidden(_ hidden: Bool, indexpath:IndexPath) {
        
        
        
        let cell = tableView.cellForRow(at: indexpath)
        let etiquette =  cell!.contentView.subviews[0] as! UILabel
        let valeur =  cell!.contentView.subviews[1] as! UITextField
        
        etiquette.isHidden = hidden
        valeur.isHidden = hidden
        
        switch  cell?.reuseIdentifier {
        case "Pseudo"?:
            valeur.text = config.user_pseudo
            
        case  "Mail"?:
            valeur.text = config.user_email
            
        case  "Nom"?:
            valeur.text = config.user_nom
            
        case  "Prenom"?:
            valeur.text = config.user_prenom
            
        case  "Adresse"?:
            valeur.text = config.user_adresse
            
        case "Code postal"?:
            valeur.text = config.user_codepostal
            
        case "Ville"?:
            valeur.text = config.user_ville
            
        case "Pays"?:
            valeur.text = config.user_pays
            
        default: break
        }
        
    }
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
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
            self.displayAlert(self.translate.error, mess: translate.errorLogin)
            return
        }
        
        guard config.user_email != "" else {
            self.displayAlert(self.translate.error, mess: translate.errorMail)
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
                    self.displayAlert(self.translate.error, mess: errorString!)
                    
                }
            }
            
        }
        
    }
    
    private func assignValue (_ nom: String, valeur: String) {
        
        
        switch nom {
        case "Pseudo":
            config.user_pseudo = valeur
        case "Mail":
            config.user_email = valeur
        case "Nom":
            config.user_nom = valeur
        case "Prenom":
            config.user_prenom = valeur
        case "Adresse":
            config.user_adresse = valeur
        case "Code postal":
            config.user_codepostal = valeur
        case "Ville":
            config.user_ville = valeur
        case "Pays":
            config.user_pays = valeur
            
        default:
            break
            
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
        
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var i = -1
        while i < 9 {
            i += 1
            if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) {
                let valeur =  cell.contentView.subviews[1] as! UITextField
                if textField.isEqual(valeur) {
                    assignValue(cell.reuseIdentifier!, valeur: valeur.text!)
                    break
                }
            }
        }
        
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        ligne = -1
        
        var i = -1
        while i < 9 {
            i += 1
            if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) {
                let valeur =  cell.contentView.subviews[1] as! UITextField
                if textField.isEqual(valeur) {
                    ligne = i
                    return true
                }
            }
            
            
        }
        
        return false
        
    }
    
    
    //MARK: keyboard function
    
    func  subscibeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    
    func keyboardWillShow(notification:NSNotification) {
        
        IBSave.isEnabled = false
        let cell = tableView.cellForRow(at: IndexPath(item: ligne, section: 0))!
        let valeur =  cell.contentView.subviews[1] as! UITextField
        
        if valeur.isFirstResponder {
            let keybordY = view.frame.size.height - getkeyboardHeight(notification: notification)
            if keybordY < valeur.frame.origin.y {
                view.frame.origin.y = keybordY - valeur.frame.origin.y - valeur.frame.size.height
            }
            
            
        }
        
        
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
        
        IBSave.isEnabled = true
        let cell = tableView.cellForRow(at: IndexPath(item: ligne, section: 0))!
        let textField =  cell.contentView.subviews[1] as! UITextField
        
        
        if textField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        textField.endEditing(true)
        
    }
    
    func getkeyboardHeight(notification:NSNotification)->CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    
    //MARK: delegate table view controller
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard ligne >= 0 else {
            return
        }
        
        let cell = tableView.cellForRow(at: IndexPath(item: ligne, section: 0))!
        let valeur =  cell.contentView.subviews[1] as! UITextField
        
        valeur.endEditing(true)
    }
    
    
}



