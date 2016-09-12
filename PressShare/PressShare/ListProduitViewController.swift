//
//  ListProduitViewController
//  On the Map
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ListProduitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBSearch: UISearchBar!
    @IBOutlet weak var IBLogout: UIBarButtonItem!
   
    
    var produits = [Produit]()
    var config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    var aindex:Int!
    var lat:CLLocationDegrees?
    var lon:CLLocationDegrees?
    
    
    //Constants
    let SearchBBoxHalfWidth = 1.0
    let SearchBBoxHalfHeight = 1.0
    let SearchLatRange = (-90.0, 90.0)
    let SearchLonRange = (-180.0, 180.0)
    
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        //IBSearch.text = traduction.titre
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        self.navigationItem.title = "\(config.user_nom) \(config.user_prenom) (\(config.user_id))"
        
        chargerData()
        
        IBTableView.reloadData()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.tabBarItem.title = traduction.pam2
        IBLogout.title = traduction.pam4
        //IBSearch.becomeFirstResponder()
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
       
        if segue.identifier == "fromtable" {
          
            if (aindex != 999) {
                
                let nav = segue.destinationViewController as! UINavigationController
                let controller = nav.topViewController as! ProduitViewController
                
                controller.aproduit = produits[aindex]
                
            }
            
        }
        
    }
    
    
    
    @IBAction func ActionEpingle(sender: AnyObject) {
        
         aindex = 999
         performSegueWithIdentifier("fromtable", sender: self)
    }
    
  
    
    @IBAction func ActionLogout(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func ActionRefresh(sender: AnyObject) {
        
        
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
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: Data Produit
    
    private func searchData(str:String) {
        
        produits.removeAll()
        for prod in Produits.sharedInstance.produitsArray {
            let produ = Produit(dico: prod)
            let nom = produ.prod_nom.capitalizedString
            if nom.containsString(str.capitalizedString) {
                    produits.append(produ)
                }
        }
        
    }
    
    
    private func chargerData() {
        
        var minimumLon = Double()
        var maximumLon = Double()
        var minimumLat = Double()
        var maximumLat = Double()

        if let _ = lat, _ = lon {
            
            minimumLon = max(Double(lon!) - SearchBBoxHalfWidth, SearchLonRange.0)
            minimumLat = max(Double(lat!) - SearchBBoxHalfHeight, SearchLatRange.0)
            maximumLon = min(Double(lon!) + SearchBBoxHalfWidth, SearchLonRange.1)
            maximumLat = min(Double(lat!) + SearchBBoxHalfHeight, SearchLatRange.1)
            
        }
        
        
        produits.removeAll()
        for prod in Produits.sharedInstance.produitsArray {
            let produ = Produit(dico: prod)
            if let _ = lat, _ = lon {
                if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon) {
                    produits.append(produ)
                }
            }
            else {
                produits.append(produ)
            }
        }
        
    }
        
    //MARK: Table View Controller data source

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellReuseId = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as UITableViewCell!
        let produit =  produits[indexPath.row]
        
        for view in cell.contentView.subviews {
            
            if view.tag == 99 {
                let firstlastname = view as! UILabel
                firstlastname.text =  "\(produit.prod_nom) (user:\(produit.prod_by_user))"
            }
            
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return produits.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        aindex = indexPath.row
        performSegueWithIdentifier("fromtable", sender: self)
        
        
    }
    
    
}
