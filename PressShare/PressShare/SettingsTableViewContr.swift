//
//  SettingsTableViewContr.swift
//  PressShare
//
//  Description : List of setting functions
//
//  Created by MacbookPRV on 22/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import UIKit
import Foundation

class SettingsTableViewContr : UITableViewController {
    
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    
    var users = [User]()
    
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = fetchAllUser()
        IBActivity.isHidden = true
        config.previousView = "SettingsTableViewContr"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        
        navigationController?.tabBarItem.title = translate.settings
        IBLogout.image = #imageLiteral(resourceName: "eteindre")
        IBLogout.title = ""
        
        var cell:UITableViewCell
        var label:UILabel
        
        cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.editProfil
        
        cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.connectInfo
        
        cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.mySubscrit
        
        cell = tableView.cellForRow(at: IndexPath(item: 3, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.myCB
        
        chargeData(item: 4, labelText: translate.myNotif, badgeValue: config.mess_badge!)
        
        chargeData(item: 5, labelText: translate.runTransac, badgeValue: config.trans_badge!)
        
        
        cell = tableView.cellForRow(at: IndexPath(item: 6, section: 0))!
        label = cell.contentView.subviews[0] as! UILabel
        label.text = translate.ExplanTuto
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
        
    }
    
    @IBAction func actionLogout(_ sender: AnyObject) {
        
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
    
    private func refreshData()  {
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        
        MDBMessage.sharedInstance.getAllMessages(config.user_id, completionHandlerMessages: {(success, messageArray, errorString) in
            
            if success {
                
                Messages.sharedInstance.MessagesArray = messageArray
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    var i = 0
                    for mess in Messages.sharedInstance.MessagesArray {
                        
                        let mess1 = Message(dico: mess)
                        
                        if mess1.destinataire == self.config.user_id && mess1.deja_lu_dest == false {
                            i+=1
                        }
                        
                    }
                    if i > 0 {
                        self.config.mess_badge = i
                        
                    }
                    
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.chargeData(item: 4, labelText: self.translate.myNotif, badgeValue: self.config.mess_badge!)
                        
                        self.IBActivity.stopAnimating()
                        self.IBActivity.isHidden = true
                    }
                    
                    
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        })
        
        MDBTransact.sharedInstance.getAllTransactions(config.user_id) { (success, transactionArray, errorString) in
            
            if success {
                
                Transactions.sharedInstance.transactionArray = transactionArray
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    var i = 0
                    for tran in Transactions.sharedInstance.transactionArray  {
                        
                        let tran1 = Transaction(dico: tran)
                        
                        if (tran1.trans_valide != 1 && tran1.trans_valide != 2 )  {
                            i+=1
                        }
                        
                    }
                    if i > 0 {
                        self.config.trans_badge = i
                        
                    }
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.chargeData(item: 5, labelText: self.translate.runTransac, badgeValue: self.config.trans_badge!)
                        
                        self.IBActivity.stopAnimating()
                        self.IBActivity.isHidden = true
                    }
                    
                    
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        }
        
        
    }
    
    private func chargeData(item:Int, labelText:String, badgeValue:Int)  {
        
        var cell:UITableViewCell
        var label:UILabel
        
        cell = tableView.cellForRow(at: IndexPath(item: item, section: 0))!
        
        label = cell.contentView.subviews[0] as! UILabel
        label.text = labelText
        
        if cell.contentView.subviews.count > 1 {
            
            cell.contentView.subviews[1].removeFromSuperview()
            label.frame = CGRect(origin: CGPoint.init(x: label.frame.origin.x - 10, y: 0) , size: label.frame.size)
            if item == 4 {
                tabBarController?.tabBar.items![2].badgeValue  = nil
            }
            
        }
        
        if badgeValue > 0 {
            let badge = BadgeLabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
            badge.setup()
            badge.badgeValue = "\(badgeValue)"
            
            cell.contentView.addSubview(badge)
            label.frame = CGRect(origin: CGPoint.init(x: label.frame.origin.x + 10.0, y: 0) , size: label.frame.size)
            
            if item == 4 {
                tabBarController?.tabBar.items![2].badgeValue = "\(badgeValue)"
            }
            
        }
        
    }
    
    
    //MARK: Table View Controller Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            if config.level > -1 {
                performSegue(withIdentifier: "profil", sender: self)
            }
        case 1:
            
            if config.level > -1 {
                performSegue(withIdentifier: "infoconnexion", sender: self)
            }
            
            
        case 2:
            
            if config.level > -1 {
                performSegue(withIdentifier: "abonner", sender: self)
            }
            
        case 3:
            
            if config.level > -1 {
                performSegue(withIdentifier: "carte", sender: self)
            }
            
        case 4:
            
            if config.level > -1 {
                performSegue(withIdentifier: "alerte", sender: self)
            }
            
        case 5:
            
            if config.level > -1 {
                performSegue(withIdentifier: "transaction", sender: self)
            }
            
        case 6:
            
            performSegue(withIdentifier: "tutoriel", sender: self)
            
        default:
            break
        }
        
    }
    
    
}



