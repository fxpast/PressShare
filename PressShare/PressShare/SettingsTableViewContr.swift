//
//  SettingsTableViewContr.swift
//  PressShare
//
//  Created by MacbookPRV on 22/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import UIKit
import Foundation

class SettingsTableViewContr : UITableViewController {
    
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    
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
        
        users = fetchAllUser()
        
        config.previousView = "SettingsTableViewContr"
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_id!))"
        
        
        navigationController?.tabBarItem.title = traduction.pam3
        IBLogout.title = traduction.pam4
        
        var cell:UITableViewCell
        
        cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0))!
        var label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp1
        
        cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp2
        
        cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp3
        
        cell = tableView.cellForRow(at: IndexPath(item: 3, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp4
        
        cell = tableView.cellForRow(at: IndexPath(item: 4, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp5
        
        cell = tableView.cellForRow(at: IndexPath(item: 5, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp6
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    
    @IBAction func ActionLogout(_ sender: AnyObject) {
        
        //logout
        if users.count > 0 {
            for aUser in users {
                if aUser.user_pseudo == config.user_pseudo {
                    aUser.user_logout = true
                    
                    // Save the context.
                    do {
                        try sharedContext.save()
                    } catch _ {}
                    
                    break
                }
            }
            
            users = fetchAllUser()
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    //MARK: Table View Controller Delegate
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            performSegue(withIdentifier: "profil", sender: self)
            
        case 1:
            performSegue(withIdentifier: "infoconnexion", sender: self)
            
        case 2:
            
            self.displayAlert("info", mess: "Under construction...")
            
        case 3:
            
            performSegue(withIdentifier: "carte", sender: self)
            
        case 4:
            
            self.displayAlert("info", mess: "Under construction...")
            
        case 5:
            
            self.displayAlert("info", mess: "Under construction...")
            
            
        default:
            break
        }
        
    }
    
    
    
}


    
