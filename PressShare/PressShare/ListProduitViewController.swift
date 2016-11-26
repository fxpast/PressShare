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
    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    var users = [User]()
    var produits = [Produit]()
    var config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    var aindex:Int!
    var lat:CLLocationDegrees?
    var lon:CLLocationDegrees?
    var flgUser=false
    var customOpeation = BlockOperation()
    let myqueue = OperationQueue()
    
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
            buttonEdit.isEnabled = false
        }
        
        users = fetchAllUser()
        
        IBActivity.startAnimating()
        myqueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    self.chargerData()
                    performUIUpdatesOnMain {
                        
                        self.IBTableView.reloadData()
                        self.IBActivity.stopAnimating()
                        
                    }
                    
                }
            }
            
            self.customOpeation.start()
            
        }

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_id!))"
        
        navigationController?.tabBarItem.title = traduction.pam2
        if let _ = lat, let _ = lon {
            IBLogout.title = traduction.pmp1
            IBLogout.image = nil
            
        }
        else if flgUser == false {
            //IBLogout.title = traduction.pam4
            IBLogout.image = #imageLiteral(resourceName: "eteindre")
            IBLogout.title = ""
            
        }
        else {
            IBLogout.title = traduction.pmp1
            IBLogout.image = nil
        }
        
        if config.produit_maj == true {
            config.produit_maj = false
            RefreshData()
        }
       
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
    
    


    @IBAction func ActionEdit(_ sender: AnyObject)  {
        
        
        
        if buttonEdit.title == "Edit" {
           IBTableView.isEditing=true
            buttonEdit.title="Done"
        }
        else {
            IBTableView.isEditing=false
            buttonEdit.title="Edit"
        }
        
    }

    private func RefreshData()  {
        
        IBSearch.isHidden = true
        
        IBActivity.startAnimating()
        
        produits.removeAll()
        IBTableView.reloadData()
        
        getAllProduits(config.user_id) { (success, produitArray, errorString) in
            
            if success {
                
                Produits.sharedInstance.produitsArray = produitArray
                self.chargerData()
                
                performUIUpdatesOnMain {
                    self.IBSearch.isHidden = false
                    self.IBActivity.stopAnimating()
                    self.IBTableView.reloadData()
                }
            }
            else {
                performUIUpdatesOnMain {
                    self.IBSearch.isHidden = false
                    self.IBActivity.stopAnimating()
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
            
            
        }

    }
    
    @IBAction func ActionRefresh(_ sender: AnyObject) {
        
        RefreshData()
        
    }
    
    
    // MARK: - Search Bar Delegate
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        
        IBActivity.startAnimating()
        
        myqueue.cancelAllOperations()
        
        guard myqueue.operationCount == 0 else {
            
            return
        }
        
        produits.removeAll()
        
        myqueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    if searchBar.text == "" {
                        
                        self.chargerData()
                    }
                    else {
                        self.searchData(searchBar.text!)
                    }
                    
                    performUIUpdatesOnMain {
                        
                        self.IBTableView.reloadData()
                        self.IBActivity.stopAnimating()
                        
                    }
                    
                }
            }
            
            self.customOpeation.start()
            
        }

        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
        
            searchBar.endEditing(true)
        }
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    
    
    //MARK: Data Produit
    

    private func searchData(_ str:String) {
        
        produits.removeAll()
        for prod in Produits.sharedInstance.produitsArray {
         
            if customOpeation.isCancelled {
                break
            }
            
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
    
    
    private func chargerData() {
        
        
        guard let lesProduits = Produits.sharedInstance.produitsArray else {
            return
        }
        
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
        
        for prod in lesProduits {
         
            if customOpeation.isCancelled {
                break
            }
            
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
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete row
        let produit =  produits[indexPath.row]
        setDeleteProduit(produit) { (success, errorString) in
            
            if success {
                
                let prod1 =  self.produits[indexPath.row]
                var i = 0
                for produ in Produits.sharedInstance.produitsArray {
                    i+=1
                    let prod2 = Produit(dico: produ)
                    if (prod2.prod_id == prod1.prod_id) {
                        self.produits.remove(at: indexPath.row)
                        Produits.sharedInstance.produitsArray.remove(at: i-1)
                        break
                    }
                }

                performUIUpdatesOnMain {
                    if self.produits.count == 0 {
                        self.buttonEdit.title="Edit"
                        self.buttonEdit.isEnabled=false
                        self.IBTableView.isEditing = false
                    }
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
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
    

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let produit =  produits[(indexPath as NSIndexPath).row]
        
        for view in (cell?.contentView.subviews)! {
            
            if view.tag == 99 {
                let firstlastname = view as! UILabel
                firstlastname.text =  "\(produit.prod_nom) (user:\(produit.prod_by_user))"
            }
            else if view.tag == 88 {
                let photo = view as! UIImageView                
                if produit.prod_image == "" {
                  photo.image = #imageLiteral(resourceName: "noimage")
                }
                else {
                  photo.image =   UIImage(data:produit.prod_imageData)
                }
               
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
