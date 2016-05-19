//
//  ViewController.swift
//  PresseEchange
//
//  Created by MacbookPRV on 05/03/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit

class NewUser : UITableViewController , UIAlertViewDelegate {
    
    var user = User(dico: [String : AnyObject]())

 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

