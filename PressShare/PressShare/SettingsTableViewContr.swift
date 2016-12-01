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
        //IBLogout.title = traduction.pam4
        IBLogout.image = #imageLiteral(resourceName: "eteindre")
        IBLogout.title = ""
        
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
        
        if config.mess_badge > 0 {
            let badge = BadgeLabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
            badge.setup()
            badge.badgeValue = "\(config.mess_badge!)"
            if cell.contentView.subviews.count > 1 {
                cell.contentView.subviews[1].removeFromSuperview()
                label.frame = CGRect(origin: CGPoint.init(x: label.frame.origin.x - 10.0, y: 0) , size: label.frame.size)
            }
            cell.contentView.addSubview(badge)
            label.frame = CGRect(origin: CGPoint.init(x: label.frame.origin.x + 10.0, y: 0) , size: label.frame.size)
            
            tabBarController?.tabBar.items![2].badgeValue = "\(config.mess_badge!)"
        }
        else if tabBarController?.tabBar.items![2].badgeValue == "1" {
      
            cell.contentView.subviews[1].removeFromSuperview()
            label.frame = CGRect(origin: CGPoint.init(x: label.frame.origin.x - 10, y: 0) , size: label.frame.size)
            tabBarController?.tabBar.items![2].badgeValue  = nil
        }
        
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
            
            performSegue(withIdentifier: "abonner", sender: self)
            
        case 3:
            
            performSegue(withIdentifier: "carte", sender: self)
            
        case 4:
            
            performSegue(withIdentifier: "alerte", sender: self)
            
        case 5:
            
             performSegue(withIdentifier: "tutoriel", sender: self)
            
            
        default:
            break
        }
        
    }
    
    
    
}


    
