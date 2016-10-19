//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import UIKit

class NewUserTableViewContr : UITableViewController ,UITextFieldDelegate,  UIAlertViewDelegate {
    
    
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBSave: UIBarButtonItem!
    
    
    var ligne:Int = -1
    
    let config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    
    var users = [User]()
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
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
        
        
        IBCancel.title = traduction.pmp1
        IBSave.title = traduction.pmp2
        
        
        var cell:UITableViewCell
        
        cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0))!
        var label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp3
        
        cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp4
        
        cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp5
        
        cell = tableView.cellForRow(at: IndexPath(item: 3, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp5
        
        cell = tableView.cellForRow(at: IndexPath(item: 4, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp6
        
        cell = tableView.cellForRow(at: IndexPath(item: 5, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp7
        
        cell = tableView.cellForRow(at: IndexPath(item: 6, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp8
        
        cell = tableView.cellForRow(at: IndexPath(item: 7, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp9
        
        cell = tableView.cellForRow(at: IndexPath(item: 8, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp10
        
        cell = tableView.cellForRow(at: IndexPath(item: 9, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp11
        
        
        
        if config.previousView == "LoginViewController" {
            
            config.cleaner()
            config.previousView = "LoginViewController"
            navigationItem.title = traduction.pmp12
            
            setUIHidden(false, indexpath: IndexPath(row: 0, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 1, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 2, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 3, section: 0))
            setUIHidden(true, indexpath: IndexPath(row: 4, section: 0))
            setUIHidden(true, indexpath: IndexPath(row: 5, section: 0))
            setUIHidden(true, indexpath: IndexPath(row: 6, section: 0))
            setUIHidden(true, indexpath: IndexPath(row: 7, section: 0))
            setUIHidden(true, indexpath: IndexPath(row: 8, section: 0))
            setUIHidden(true, indexpath: IndexPath(row: 9, section: 0))
            
        }
        
        
        if config.previousView == "SettingsTableViewContr" {
            
            self.navigationItem.title = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_id!))"
            
            
            setUIHidden(false, indexpath: IndexPath(row: 0, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 1, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 2, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 3, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 4, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 5, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 6, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 7, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 8, section: 0))
            setUIHidden(false, indexpath: IndexPath(row: 9, section: 0))
            
            
        }
        
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    
    @IBAction func ActionCancel(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    fileprivate func fetchAllUser() -> [User] {
        
        
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
    
    
    
    
    
    @IBAction func ActionValider(_ sender: AnyObject) {
        
        guard config.user_pseudo != "" else {
            self.displayAlert("Error", mess: "Pseudo incorrect")
            return
        }
        
        guard config.user_email != "" else {
            self.displayAlert("Error", mess: "mail incorrect")
            return
        }
        
        guard config.user_pass != "" else {
            self.displayAlert("Error", mess: "mot de passe incorrect")
            return
        }
        
        guard config.user_pass == config.verifpassword else {
            self.displayAlert("Error", mess: "mot de passe incorrect")
            return
        }
        
        IBSave.isEnabled = false
        
        
        if config.previousView == "LoginViewController" {
            
            
            
            setAddUser(config) { (success, errorString) in
                self.IBSave.isEnabled = true
                
                if success {
                    performUIUpdatesOnMain {
                        
                        if self.users.count > 0 {
                            self.sharedContext.delete(self.users[0])
                            self.users.removeLast()
                            // Save the context.
                            do {
                                try self.sharedContext.save()
                            } catch let error as NSError {
                                print(error.debugDescription)
                                
                            }
                            
                            
                            self.users = self.fetchAllUser()
                            
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    performUIUpdatesOnMain {
                        self.displayAlert("Error", mess: errorString!)
                        
                    }
                }
                
            }
            
            
        }
        
        if config.previousView == "SettingsTableViewContr" {
            
            
            
            setUpdateUser(config) { (success, errorString) in
                self.IBSave.isEnabled = true
                if success {
                    performUIUpdatesOnMain {
                        
                        if self.users.count > 0 {
                            self.AffecterUser(self.users[0])
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    performUIUpdatesOnMain {
                        self.displayAlert("Error", mess: errorString!)
                        
                    }
                }
                
            }
            
            
        }
        
        
    }
    
    
    
    fileprivate func AffecterValeur (_ nom: String, valeur: String) {
        
        
        switch nom {
        case "Pseudo":
            config.user_pseudo = valeur
        case "Mail":
            config.user_email = valeur
        case "Mot de passe":
            config.user_pass = valeur
        case "Verifier mot de passe":
            config.verifpassword = valeur
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
    
    
    
    fileprivate func AffecterUser(_ aUser:User) {
        
        aUser.user_pseudo = config.user_pseudo
        aUser.user_email = config.user_email
        aUser.user_nom = config.user_nom
        aUser.user_prenom = config.user_prenom
        aUser.user_pays = config.user_pays
        aUser.user_ville = config.user_ville
        aUser.user_adresse = config.user_adresse
        aUser.user_codepostal = config.user_codepostal
        aUser.user_pass = config.user_pass
        
        // Save the context.
        do {
            try sharedContext.save()
        } catch _ {}
        
        
        users = fetchAllUser()
        
        
    }
    
    fileprivate func setUIHidden(_ hidden: Bool, indexpath:IndexPath) {
        
        
        
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
    

    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        var i = -1
        while i < 9 {
            i += 1
            if let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0)) {
                let valeur =  cell.contentView.subviews[1] as! UITextField
                if textField.isEqual(valeur) {
                    ligne = i
                    break
                }
            }
        
            
        }
      
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
        
        let cell = tableView.cellForRow(at: IndexPath(item: ligne, section: 0))!
        let valeur =  cell.contentView.subviews[1] as! UITextField
        
        if valeur.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        ligne = -1
        
    }
    
    func getkeyboardHeight(notification:NSNotification)->CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    
    //MARK: delegate table view controller
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard ligne > 0 else {
            return
        }
        
        let cell = tableView.cellForRow(at: IndexPath(item: ligne, section: 0))!
        let valeur =  cell.contentView.subviews[1] as! UITextField
        valeur.endEditing(true)
    }
    
    
    
    
}



