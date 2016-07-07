//
//  SettingsTableViewContr.swift
//  PressShare
//
//  Created by MacbookPRV on 22/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import UIKit
import Foundation

class SettingsTableViewContr : UITableViewController {

     let config = Config.sharedInstance
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config.previousView = "SettingsTableViewContr"
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "\(config.user_nom) \(config.user_prenom)"
    }

    
    
    @IBAction func ActionLogout(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    
    //MARK: Table View Controller Delegate
   
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 0:
            performSegueWithIdentifier("profil", sender: self)
            
        case 1:
            performSegueWithIdentifier("infoconnexion", sender: self)
            
        default:
            break
        }
        
    }
    

    
}


    