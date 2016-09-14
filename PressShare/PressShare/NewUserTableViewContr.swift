//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import UIKit

class NewUserTableViewContr : UITableViewController , UIAlertViewDelegate {
    
    
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBSave: UIBarButtonItem!
    
    let config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    
    var users = [User]()
    
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        users = fetchAllUser()
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        IBCancel.title = traduction.pmp1
        IBSave.title = traduction.pmp2
        
        
        var cell:UITableViewCell
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))!
        var label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp3
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp4
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp5
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp5
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 4, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp6
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 5, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp7
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 6, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp8
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 7, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp9
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 8, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp10
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 9, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.pmp11
        
        
        
        if config.previousView == "LoginViewController" {
            navigationItem.title = traduction.pmp12
            
        }
        
        if config.previousView == "SettingsTableViewContr" {
            
            self.navigationItem.title = "\(config.user_nom) \(config.user_prenom) (\(config.user_id))"
            
            afficherData(NSIndexPath(forRow: 0, inSection: 0))
            afficherData(NSIndexPath(forRow: 1, inSection: 0))
            afficherData(NSIndexPath(forRow: 4, inSection: 0))
            afficherData(NSIndexPath(forRow: 5, inSection: 0))
            afficherData(NSIndexPath(forRow: 6, inSection: 0))
            afficherData(NSIndexPath(forRow: 7, inSection: 0))
            afficherData(NSIndexPath(forRow: 8, inSection: 0))
            afficherData(NSIndexPath(forRow: 9, inSection: 0))
            
            
            
        }
        
        
        
        
    }
    
    private func afficherData (indexpath:NSIndexPath)  {
        
        
        let cell = tableView.cellForRowAtIndexPath(indexpath)
        
        
        switch  cell?.reuseIdentifier {
        case "Pseudo"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_pseudo
            config.user_pseudo = config.user_pseudo
            
        case  "Mail"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_email
            config.user_email = config.user_email
            
        case  "Nom"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_nom
            config.user_nom = config.user_nom
            
        case  "Prenom"?:
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_prenom
            config.user_prenom = config.user_prenom
            
        case  "Adresse"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_adresse
            config.user_adresse = config.user_adresse
            
        case "Code postal"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_codepostal
            config.user_codepostal = config.user_codepostal
            
        case "Ville"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_ville
            config.user_ville = config.user_ville
            
            
        case "Pays"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_pays
            config.user_pays = config.user_pays
            
            
        default: break
        }
        
        
    }
    
    
    @IBAction func ActionCancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    private func fetchAllUser() -> [User] {
        
        
        users.removeAll()
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [User]
        } catch _ {
            return [User]()
        }
    }
    
    
    
    
    
    @IBAction func ActionValier(sender: AnyObject) {
        
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
        
        
        
        
        if config.previousView == "LoginViewController" {
            
            
            
            setAddUser(config) { (success, errorString) in
                if success {
                    performUIUpdatesOnMain {
                        
                        self.sharedContext.deleteObject(self.users[0])
                        self.users.removeLast()
                        // Save the context.
                        do {
                            try self.sharedContext.save()
                        } catch let error as NSError {
                            print(error.debugDescription)
                            
                        }
                        
                        
                        self.users = self.fetchAllUser()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
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
                if success {
                    performUIUpdatesOnMain {
                        
                        if self.users.count > 0 {
                            self.AffecterUser(self.users[0])
                        }
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    
    
    private func AffecterValeur (nom: String, valeur: String) {
        
        
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
    
    
    
    private func AffecterUser(aUser:User) {
        
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
    
    
    
    //MARK: Table View Controller Delegate
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        let alertController = UIAlertController(title: cell.reuseIdentifier, message: "Entrer la valeur :", preferredStyle: .Alert)
        
        let actionValider = UIAlertAction(title: "Valider", style: .Destructive, handler: { (action) in
            performUIUpdatesOnMain {
                let valeur =  cell.contentView.subviews[1] as! UILabel
                valeur.text = (alertController.textFields![0]).text
                self.AffecterValeur(cell.reuseIdentifier!, valeur: valeur.text!)
                
            }
            
        })
        
        let actionCancel = UIAlertAction(title: "Annuler", style: .Destructive, handler: { (action) in
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        alertController.addTextFieldWithConfigurationHandler({ (zoneTexte) in
            performUIUpdatesOnMain {
                zoneTexte.placeholder = cell.reuseIdentifier
                let valeur =  cell.contentView.subviews[1] as! UILabel
                if valeur.text != "" {
                    zoneTexte.text = valeur.text
                }
                
            }
        })
        
        
        self.presentViewController(alertController, animated: true) {
            
        }
        
        
    }
    
    
    
}



