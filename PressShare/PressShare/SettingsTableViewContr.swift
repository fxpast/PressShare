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
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = fetchAllUser()
        
        config.previousView = "SettingsTableViewContr"
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "\(config.user_nom) \(config.user_prenom) (\(config.user_id))"
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.tabBarItem.title = traduction.pam3
        IBLogout.title = traduction.pam4
        
        var cell:UITableViewCell
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))!
        var label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp1
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp2
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp3
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp4
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 4, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp5
        
        cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 5, inSection: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = traduction.psp6
        
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
    
    
    @IBAction func ActionLogout(sender: AnyObject) {
        
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
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    
    //MARK: Table View Controller Delegate
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 0:
            performSegueWithIdentifier("profil", sender: self)
            
        case 1:
            performSegueWithIdentifier("infoconnexion", sender: self)
            
        case 2:
            
            self.displayAlert("info", mess: "Under construction...")
            
        case 3:
            
            self.displayAlert("info", mess: "Under construction...")
        case 4:
            
            self.displayAlert("info", mess: "Under construction...")
            
        case 5:
            
            self.displayAlert("info", mess: "Under construction...")
            
            
        default:
            break
        }
        
    }
    
    
    
}


    