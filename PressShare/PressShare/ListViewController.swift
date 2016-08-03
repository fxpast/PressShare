//
//  tableViewController.swift
//  On the Map
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit


class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBSearch: UISearchBar!
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    
    var users = Users.sharedInstance
    var config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
   
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        //IBSearch.text = traduction.titre
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "\(config.user_nom) \(config.user_prenom)"
        IBTableView.reloadData()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.tabBarItem.title = traduction.pam2
        IBLogout.title = traduction.pam4
        //IBSearch.becomeFirstResponder()
        
    }
    
    
    
    // MARK: - Search Bar Delegate
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the text is empty we are done
        if searchText == "" {
            IBTableView.reloadData()
            return
        }
    
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: Data Networking
    private  func RefreshData()  {
        
        getAllUsers(config.user_id) { (success, usersArray, errorString) in
            
            if success {
                self.users.usersArray = usersArray
                performUIUpdatesOnMain {
                    self.IBTableView.reloadData()
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
    
    
    //MARK: Table View Controller data source

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.usersArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        //let location = users.usersArray[indexPath.row]
        
    }
    
    
}
