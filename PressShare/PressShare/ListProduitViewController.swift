//
//  ListProduitViewController
//  On the Map
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import Foundation
import UIKit
import MapKit

class ListProduitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBSearch: UISearchBar!
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBAddProduct: UIBarButtonItem!
    
    
    
    
    var users = [User]()
    var produits = [Produit]()
    var config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    var aindex:Int!
    var lat:CLLocationDegrees?
    var lon:CLLocationDegrees?
    var flgUser=false
    
    
    //Constants
    let SearchBBoxHalfWidth = 1.0
    let SearchBBoxHalfHeight = 1.0
    let SearchLatRange = (-90.0, 90.0)
    let SearchLonRange = (-180.0, 180.0)
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if config.user_pseudo == "anonymous" {
            IBAddProduct.isEnabled = false
        }
        
        users = fetchAllUser()
        
        //IBSearch.text = traduction.titre
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        
        self.navigationItem.title = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_id!))"
        
        navigationController?.tabBarItem.title = traduction.pam2
        if let _ = lat, let _ = lon {
            IBLogout.title = traduction.pmp1
            
        }
        else if flgUser == false {
            IBLogout.title = traduction.pam4
            
        }
        else {
            IBLogout.title = traduction.pmp1
        }
        
        
        chargerData()
        
        IBTableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    
        //IBSearch.becomeFirstResponder()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromtable" {
            
            if (aindex != 999) {
                
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! ProduitViewController
                
                controller.aproduit = produits[aindex]
                
            }
            
        }
        
    }
    
    
    
    @IBAction func ActionEpingle(_ sender: AnyObject) {
        
        aindex = 999
        performSegue(withIdentifier: "fromtable", sender: self)
    }
    
    
    
    @IBAction func ActionLogout(_ sender: AnyObject) {
        
        
        if let _ = lat, let _ = lon {
            //Cancel list product
        }
        else if flgUser == false {
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
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func ActionRefresh(_ sender: AnyObject) {
        
        
        getAllProduits(config.user_id) { (success, produitArray, errorString) in
            
            if success {
                
                Produits.sharedInstance.produitsArray = produitArray
                self.chargerData()
                
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
    
    
    // MARK: - Search Bar Delegate
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the text is empty we are done
        if searchText == "" {
            
            performUIUpdatesOnMain {
                self.chargerData()
                self.IBTableView.reloadData()
            }
            
        }
        else {
            
            performUIUpdatesOnMain {
                self.searchData(searchText)
                self.IBTableView.reloadData()
            }
            
        }
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: Data Produit
    
    fileprivate func searchData(_ str:String) {
        
        produits.removeAll()
        for prod in Produits.sharedInstance.produitsArray {
            let produ = Produit(dico: prod)
            let nom = produ.prod_nom.capitalized
            if nom.contains(str.capitalized) {
                produits.append(produ)
            }
        }
        
    }
    
    //MARK: coreData function
    
    
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
    
    
    fileprivate func chargerData() {
        
        var minimumLon = Double()
        var maximumLon = Double()
        var minimumLat = Double()
        var maximumLat = Double()
        
        if let _ = lat, let _ = lon {
            
            minimumLon = max(Double(lon!) - SearchBBoxHalfWidth, SearchLonRange.0)
            minimumLat = max(Double(lat!) - SearchBBoxHalfHeight, SearchLatRange.0)
            maximumLon = min(Double(lon!) + SearchBBoxHalfWidth, SearchLonRange.1)
            maximumLat = min(Double(lat!) + SearchBBoxHalfHeight, SearchLatRange.1)
            
        }
        
        
        produits.removeAll()
        for prod in Produits.sharedInstance.produitsArray {
            let produ = Produit(dico: prod)
            if let _ = lat, let _ = lon {
                if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon) {
                    produits.append(produ)
                }
            }
            else if flgUser {
                
                if produ.prod_by_user == config.user_id {
                    produits.append(produ)
                }
            }
            else {
                produits.append(produ)
            }
            
        }
        
        
    }
    
    //MARK: Table View Controller data source
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let produit =  produits[(indexPath as NSIndexPath).row]
        
        for view in (cell?.contentView.subviews)! {
            
            if view.tag == 99 {
                let firstlastname = view as! UILabel
                firstlastname.text =  "\(produit.prod_nom) (user:\(produit.prod_by_user))"
            }
            
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return produits.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        aindex = (indexPath as NSIndexPath).row
        performSegue(withIdentifier: "fromtable", sender: self)
        
        
    }
    
    
}
