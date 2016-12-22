//
//  ListProductViewController
// PressShare
//
// Description : List of products
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo: Tous les produits d'un utilisateur resilié sont masqués
//Todo :Les produits avec transaction ne doivent plus apparaitre dans la liste
//Todo :Les produits avec transaction ne peuvent plus être échangés ou commercés.
//Todo :Le raffraichissement de la liste est fonction de la zone affichée sur la carte.
//Todo :Comment reduire la lenteur de chargement? les photos sont en cause.



import CoreData
import Foundation
import UIKit
import MapKit

class ListProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBSearch: UISearchBar!
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBAddProduct: UIBarButtonItem!
    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    var users = [User]()
    var products = [Product]()
    var config = Config.sharedInstance
    let translate = InternationalIHM.sharedInstance
    var aindex:Int!
    var lat:CLLocationDegrees?
    var lon:CLLocationDegrees?
    var flgUser=false
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    
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
        
        
        if config.level == 0 {
            IBAddProduct.isEnabled = false
            buttonEdit.isEnabled = false
        }
        
        users = fetchAllUser()
        
        IBActivity.startAnimating()
        myQueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    self.chargeData()
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
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
        
        navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        IBSearch.placeholder = translate.product
        
        navigationController?.tabBarItem.title = translate.list
        if let _ = lat, let _ = lon {
            IBLogout.title = translate.cancel
            IBLogout.image = nil
            
        }
        else if flgUser == false {
            //IBLogout.title = traduction.pam4
            IBLogout.image = #imageLiteral(resourceName: "eteindre")
            IBLogout.title = ""
            
        }
        else {
            IBLogout.title = translate.cancel
            IBLogout.image = nil
        }
        
        if config.product_maj == true {
            config.product_maj = false
            refreshData()
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromtable" {
            
            if (aindex != 999) {
                
                
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! ProductViewController
                
                controller.aProduct = products[aindex]
                
                
            }
            
        }
        
    }
    
    
    
    @IBAction func actionEpingle(_ sender: AnyObject) {
        
        aindex = 999
        performSegue(withIdentifier: "fromtable", sender: self)
    }
    
    
    
    @IBAction func actionLogout(_ sender: AnyObject) {
        
        
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
    
    
    
    
    @IBAction func actionEdit(_ sender: AnyObject)  {
        
        
        
        if buttonEdit.title == "Edit" {
            IBTableView.isEditing=true
            buttonEdit.title="Done"
        }
        else {
            IBTableView.isEditing=false
            buttonEdit.title="Edit"
        }
        
    }
    
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
        
    }
    
    
    // MARK: - Search Bar Delegate
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        
        IBActivity.startAnimating()
        
        myQueue.cancelAllOperations()
        
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        products.removeAll()
        
        myQueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    if searchBar.text == "" {
                        
                        self.chargeData()
                    }
                    else {
                        self.searchData(searchBar.text!)
                    }
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
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
    
    
    
    
    //MARK: Data Product
    
    
    private func chargeData() {
        
        
        guard let theProducts = Products.sharedInstance.productsArray else {
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
        
        for prod in theProducts {
            
            if customOpeation.isCancelled {
                break
            }
            
            let produ = Product(dico: prod)
            if let _ = lat, let _ = lon {
                if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon) {
                    products.append(produ)
                }
            }
            else if flgUser {
                
                if produ.prod_by_user == config.user_id {
                    products.append(produ)
                }
            }
            else {
                products.append(produ)
            }
            
        }
        
        
    }
    
    
    private func refreshData()  {
        
        IBSearch.isHidden = true
        
        IBActivity.startAnimating()
        
        products.removeAll()
        IBTableView.reloadData()
        
        MDBProduct.sharedInstance.getAllProducts(config.user_id) { (success, productArray, errorString) in
            
            if success {
                
                Products.sharedInstance.productsArray = productArray
                self.chargeData()
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBSearch.isHidden = false
                    self.IBActivity.stopAnimating()
                    self.IBTableView.reloadData()
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBSearch.isHidden = false
                    self.IBActivity.stopAnimating()
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
            
            
        }
        
    }
    
    private func searchData(_ str:String) {
        
        products.removeAll()
        for prod in Products.sharedInstance.productsArray {
            
            if customOpeation.isCancelled {
                break
            }
            
            let produ = Product(dico: prod)
            let nom = produ.prod_nom.capitalized
            if nom.contains(str.capitalized) {
                products.append(produ)
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
    
    
    
    //MARK: Table View Controller data source
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete row
        let product =  products[indexPath.row]
        
        guard config.user_id == product.prod_by_user else {
            displayAlert("Error", mess: "Suppression impossible")
            return
        }
        MDBProduct.sharedInstance.setDeleteProduct(product) { (success, errorString) in
            
            if success {
                
                let prod1 =  self.products[indexPath.row]
                var i = 0
                for produ in Products.sharedInstance.productsArray {
                    i+=1
                    let prod2 = Product(dico: produ)
                    if (prod2.prod_id == prod1.prod_id) {
                        self.products.remove(at: indexPath.row)
                        Products.sharedInstance.productsArray.remove(at: i-1)
                        break
                    }
                }
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    if self.products.count == 0 {
                        self.buttonEdit.title="Edit"
                        self.buttonEdit.isEnabled=false
                        self.IBTableView.isEditing = false
                    }
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.IBTableView.reloadData()
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
            
            
        }
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let product =  products[(indexPath as NSIndexPath).row]
        
        for view in (cell?.contentView.subviews)! {
            
            if view.tag == 99 {
                let firstlastname = view as! UILabel
                firstlastname.text =  "\(product.prod_nom) (user:\(product.prod_by_user))"
            }
            else if view.tag == 88 {
                let photo = view as! UIImageView
                if product.prod_image == "" {
                    photo.image = #imageLiteral(resourceName: "noimage")
                }
                else {
                    photo.image =   UIImage(data:product.prod_imageData)
                }
                
            }
            
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        aindex = (indexPath as NSIndexPath).row
        performSegue(withIdentifier: "fromtable", sender: self)
        
        
    }
    
    
}
