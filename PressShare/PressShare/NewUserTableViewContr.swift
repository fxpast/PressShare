//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit

class NewUserTableViewContr : UITableViewController , UIAlertViewDelegate {
    
    var user = User(dico: [String : AnyObject]())

    
    let config = Config.sharedInstance
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        if config.previousView == "LoginViewController" {
            
            
        }
        
        if config.previousView == "SettingsTableViewContr" {
            navigationItem.title = "\(config.user_nom) \(config.user_prenom)"
            
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        var indexpath:NSIndexPath
        
        user.user_id = config.user_id
        indexpath = NSIndexPath(forRow: 0, inSection: 0)
        afficherData(indexpath)
        indexpath = NSIndexPath(forRow: 1, inSection: 0)
        afficherData(indexpath)
        indexpath = NSIndexPath(forRow: 4, inSection: 0)
        afficherData(indexpath)
        indexpath = NSIndexPath(forRow: 5, inSection: 0)
        afficherData(indexpath)
        indexpath = NSIndexPath(forRow: 6, inSection: 0)
        afficherData(indexpath)
        indexpath = NSIndexPath(forRow: 7, inSection: 0)
        afficherData(indexpath)
        indexpath = NSIndexPath(forRow: 8, inSection: 0)
        afficherData(indexpath)
        indexpath = NSIndexPath(forRow: 9, inSection: 0)
        afficherData(indexpath)
        
        
       
        
        
    }
    
    private func afficherData (indexpath:NSIndexPath)  {
        
        
        let cell = tableView.cellForRowAtIndexPath(indexpath)
        
        
        switch  cell?.reuseIdentifier {
        case "Pseudo"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_pseudo
            user.user_pseudo = config.user_pseudo
            
        case  "Mail"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_email
            user.user_email = config.user_email
            
        case  "Nom"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_nom
            user.user_nom = config.user_nom
            
        case  "Prenom"?:
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_prenom
            user.user_prenom = config.user_prenom
            
        case  "Adresse"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_adresse
            user.user_adresse = config.user_adresse
            
        case "Code postal"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_codepostal
            user.user_codepostal = config.user_codepostal
            
        case "Ville"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_ville
            user.user_ville = config.user_ville
            
            
        case "Pays"?:
            
            let valeur =  cell!.contentView.subviews[1] as! UILabel
            valeur.text = config.user_pays
            user.user_pays = config.user_pays
            
            
        default: break
        }
        
        
    }
    
    
    @IBAction func ActionCancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func ActionValier(sender: AnyObject) {
        
        guard user.user_pseudo != "" else {
            self.displayAlert("Error", mess: "Pseudo incorrect")
            return
        }
        
        guard user.user_email != "" else {
            self.displayAlert("Error", mess: "mail incorrect")
            return
        }
        
        guard user.user_pass != "" else {
            self.displayAlert("Error", mess: "mot de passe incorrect")
            return
        }
        
        guard user.user_pass == user.user_mapString else {
            self.displayAlert("Error", mess: "mot de passe incorrect")
            return
        }
        
        
        
        if config.previousView == "LoginViewController" {
            
            
            setAddUser(user) { (success, errorString) in
                if success {
                    performUIUpdatesOnMain {
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
            
            setUpdateUser(user) { (success, errorString) in
                if success {
                    performUIUpdatesOnMain {
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
            user.user_pseudo = valeur
        case "Mail":
            user.user_email = valeur
        case "Mot de passe":
            user.user_pass = valeur
        case "Verifier mot de passe":
            user.user_mapString = valeur
        case "Nom":
            user.user_nom = valeur
        case "Prenom":
            user.user_prenom = valeur
        case "Adresse":
            user.user_adresse = valeur
        case "Code postal":
            user.user_codepostal = valeur
        case "Ville":
            user.user_ville = valeur
        case "Pays":
            user.user_pays = valeur
            
        default:
            break
            
        }
        
        
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

