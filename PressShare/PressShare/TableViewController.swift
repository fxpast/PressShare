//
//  tableViewController.swift
//  On the Map
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit


class TableViewController: UITableViewController {
    
    var users:Users!
    var config:Config!
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        users = Users.sharedInstance
        config = Config.sharedInstance
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "\(config.user_nom) \(config.user_prenom)"
    }
    
    
    //MARK: Data Networking
    private  func RefreshData()  {
        
        getAllUsers(config.user_id) { (success, usersArray, errorString) in
            
            if success {
                self.users.usersArray = usersArray
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
            else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
        }
        
    }
    
    
    @IBAction func ActionRefresh(sender: AnyObject) {
        
        RefreshData()
    }
    
    @IBAction func ActionLogout(sender: AnyObject) {
      
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Table View Controller Delegate
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellReuseId = "Cell"
        let location =  users.usersArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as UITableViewCell!
        let user = User(dico: location)
        
        for view in cell.contentView.subviews {
            
            if view.tag == 99 {
                let firstlastname = view as! UILabel
                firstlastname.text =  "\(user.user_nom)  \(user.user_prenom)"
            }
            
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.usersArray.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        //let location = users.usersArray[indexPath.row]
        
    }
    
    
}
