//
//  ListProductViewController
// PressShare
//
// Description : List of products
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import CoreData
import Foundation
import UIKit
import MapKit

class ListProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBSearch: UISearchBar!
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBAddProduct: UIBarButtonItem!
    @IBOutlet weak var IBDelete: UIBarButtonItem!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBRefresh: UIBarButtonItem!
    
    var users = [User]()
    var products = [Product]()
    var productsTmp = [Product]()
    var aProduct:Product!
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var lat:CLLocationDegrees?
    var lon:CLLocationDegrees?
    var flgUser=false //touch on blue user pin
    var flgFirst=false
    
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    var countProduct = 0
    var searchText = ""
    
    var frameTableView:CGRect!
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if config.level <= 0 {
            IBAddProduct.isEnabled = false
            IBDelete.isEnabled = false
        }
        
        users = fetchAllUser()
        
  
        NotificationCenter.default.addObserver(self, selector: #selector(pushProduct), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        IBSearch.placeholder = translate.product
        
        navigationController?.tabBarItem.title = translate.list
        if let _ = lat, let _ = lon {
            IBLogout.title = translate.cancel
            IBLogout.image = nil
            IBRefresh.isEnabled = false
            IBDelete.isEnabled = false
            IBAddProduct.isEnabled = false
            Products.sharedInstance.productsUserArray = Products.sharedInstance.productsArray
        }
        else if flgUser == false {
            IBLogout.image = #imageLiteral(resourceName: "eteindre")
            IBLogout.title = ""
            IBRefresh.isEnabled = true
            
        }
        else {
            IBLogout.title = translate.cancel
            IBLogout.image = nil
            IBRefresh.isEnabled = false
            IBDelete.isEnabled = false
            IBAddProduct.isEnabled = false
            
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        pushProduct()
        
        
        if  IBTableView == nil {
            
            IBActivity.startAnimating()
            myQueue.cancelAllOperations()
            myQueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                       
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            self.IBTableView = UITableView()
                            self.IBTableView.frame = self.frameTableView
                            self.IBTableView.dataSource = self
                            self.IBTableView.delegate = self
                            self.IBTableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
                            self.view.addSubview(self.IBTableView)
                            
                            self.IBActivity.stopAnimating()
                        }
                        
                    }
                }
                
                self.customOpeation.start()
                
            }
            
 
        }

        
        if config.mess_badge > 0 {
            
            tabBarController?.tabBar.items![1].badgeValue = "\(config.mess_badge!)"
            UIApplication.shared.applicationIconBadgeNumber = config.mess_badge
        }
        else {
            tabBarController?.tabBar.items![1].badgeValue = nil
             UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        if config.product_maj == true || config.product_add == true || Products.sharedInstance.productsUserArray == nil {
            refreshData()
            config.product_maj = false
            config.product_add = false
        }
        
        if flgFirst == false {
            frameTableView = IBTableView.frame
            flgFirst = true
            IBActivity.startAnimating()
            myQueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        self.chargeData()
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.IBActivity.stopAnimating()
                        }
                        
                    }
                }
                
                self.customOpeation.start()
                
            }
            
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let _ = lat, let _ = lon {
            Products.sharedInstance.productsUserArray = nil
        }
        
        IBTableView.dataSource = nil
        IBTableView.delegate = nil
        IBTableView.removeFromSuperview()
        IBTableView = nil
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromtable" {
            
            if let thisProduct = aProduct {
                
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! ProductViewController
                
                controller.aProduct = thisProduct
                controller.aProduct?.prod_imageData = UIImageJPEGRepresentation(BlackBox.sharedInstance.restoreImageArchive(prod_imageUrl: (controller.aProduct!.prod_imageUrl)), 1)!
                
            }
            
        }
        
    }
    
    
    @IBAction func actionEpingle(_ sender: AnyObject) {
        
        aProduct = nil
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
    
    
    @IBAction func actionDelete(_ sender: AnyObject)  {
        
        IBTableView.isEditing = !IBTableView.isEditing
        
    }
    
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
        
    }
    
    
    
    @objc private func pushProduct() {
        
        
        IBActivity.startAnimating()
        BlackBox.sharedInstance.pushProduct(menuBar: tabBarController) { (success, product, errorStr) in
            
            if success {
            
                self.aProduct = product
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.performSegue(withIdentifier: "fromtable", sender: self)
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    if errorStr != "" {
                        self.displayAlert(self.translate.error, mess: errorStr!)
                    }
                }
            }
            
        }
        
    }
    
    
    // MARK: - Search Bar Delegate
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        productsTmp.removeAll()
        countProduct = 0
        self.searchText = searchText
        IBActivity.startAnimating()
        
        myQueue.cancelAllOperations()
        
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        myQueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    if searchText == "" {
                        
                        self.countProduct = self.products.count
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            searchBar.endEditing(true)
                            self.IBActivity.stopAnimating()
                            self.IBTableView.reloadData()
                        }
                        
                    }
                    else {
                        self.searchData(searchText)
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            self.IBActivity.stopAnimating()
                        }
                    }
                    
                }
            }
            
            self.customOpeation.start()
        }
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: Data Product
    

    @objc private func chargeData() {
        
        
        guard let theProducts = Products.sharedInstance.productsUserArray else {
            return
        }
        
        
        var minimumLon = Double()
        var maximumLon = Double()
        var minimumLat = Double()
        var maximumLat = Double()
        
        if let _ = lat, let _ = lon {
            
            //Setting search Area
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, config.distanceProduct, config.distanceProduct)
            
            minimumLon = coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta
            maximumLon = coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta
            minimumLat = coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta
            maximumLat = coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta
            
        }
        else {
            
        }
        
        
        for prod in theProducts {
            
            if customOpeation.isCancelled {
                break
            }
            
            var produ = Product(dico: prod)
            if let _ = lat, let _ = lon {
                if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon && produ.prod_hidden == false) {
                    produ.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: produ.prod_imageUrl)
                    products.append(produ)
                    
                }
            }
            else {
                
                produ.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: produ.prod_imageUrl)
                products.append(produ)
                
            }
            
            countProduct = products.count
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                self.IBTableView.reloadData()
            }
            
        }
        
    }
    
    
    private func refreshData()  {
        
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            IBTableView.reloadData()
            return
        }
        
        IBActivity.startAnimating()
        
        MDBMessage.sharedInstance.getAllMessages(config.user_id) {(success, messageArray, errorString) in
            
            if success {
                
                Messages.sharedInstance.MessagesArray = messageArray
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    var i = 0
                    for mess in Messages.sharedInstance.MessagesArray {
                        
                        let message = Message(dico: mess)
                        
                        if message.destinataire == self.config.user_id && message.deja_lu_dest == false {
                            i+=1
                        }
                        
                    }
                    
                    if i > 0 {
                        self.config.mess_badge = i
                        
                        self.tabBarController?.tabBar.items![1].badgeValue = "\(i)"
                         UIApplication.shared.applicationIconBadgeNumber = i
                        
                    }
                    else {
                        
                        self.tabBarController?.tabBar.items![1].badgeValue = nil
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                    
                    self.IBActivity.stopAnimating()
                    
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        }
        
        
        if config.product_maj == true {
            
            MDBProduct.sharedInstance.getProduct(aProduct.prod_id, completionHandlerProduct: { (success, productArray, errorString) in
                
                if success {
                    
                    for prod in productArray! {
                        
                        var produ = Product(dico: prod)
                        produ.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: produ.prod_imageUrl)
                        self.aProduct.prod_id = produ.prod_id
                        self.aProduct.prod_by_cat = produ.prod_by_cat
                        self.aProduct.prod_by_user = produ.prod_by_user
                        self.aProduct.prod_comment = produ.prod_comment
                        self.aProduct.prod_date = produ.prod_date
                        self.aProduct.prod_etat = produ.prod_etat
                        self.aProduct.prod_hidden = produ.prod_hidden
                        self.aProduct.prod_imageUrl = produ.prod_imageUrl
                        self.aProduct.prod_latitude = produ.prod_latitude
                        self.aProduct.prod_longitude = produ.prod_longitude
                        self.aProduct.prod_mapString = produ.prod_mapString
                        self.aProduct.prod_nom = produ.prod_nom
                        self.aProduct.prod_prix = produ.prod_prix
                        self.aProduct.prod_tempsDispo = produ.prod_tempsDispo
                        self.aProduct.prodImageOld = produ.prodImageOld
                        
                        break
                        
                    }
                    
                    self.countProduct = self.products.count
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBTableView.reloadData()
                        self.IBActivity.stopAnimating()
                    }
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
                
            })
            
        }
        else {
            
            products.removeAll()
            
            
            IBTableView.reloadData()
            
            MDBProduct.sharedInstance.getAllProducts(config.user_id) { (success, productArray, errorString) in
                
                if success {
                    
                    Products.sharedInstance.productsUserArray = productArray
                    self.chargeData()
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
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
        
        
    }
    
    private func searchData(_ str:String) {
        
        
        for prod in products {
            
            if customOpeation.isCancelled {
                break
            }
            
            let nom = prod.prod_nom.lowercased()
            
            if nom.contains(str.lowercased()) {
                productsTmp.append(prod)
                countProduct += 1
            }
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                self.IBTableView.reloadData()
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
            displayAlert(translate.error, mess: translate.deletionFor)
            return
        }
        MDBProduct.sharedInstance.setDeleteProduct(product) { (success, errorString) in
            
            if success {
                
                let prod1 =  self.products[indexPath.row]
                var i = 0
                
                for produ in Products.sharedInstance.productsUserArray {
                    i+=1
                    let prod2 = Product(dico: produ)
                    if (prod2.prod_id == prod1.prod_id) {
                        self.products.remove(at: indexPath.row)
                        
                        Products.sharedInstance.productsUserArray.remove(at: i-1)
                        break
                    }
                }
                
                self.countProduct = self.products.count
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    if self.products.count == 0 {
                        self.IBDelete.isEnabled=false
                        self.IBTableView.isEditing = false
                    }
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.IBTableView.reloadData()
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        }
        
    }
    
    
    private func chargeBadge(_ cell:UITableViewCell, badgeValue:Int) -> UITableViewCell  {
        
        
        if cell.contentView.subviews.count > 2 {
            
            for view in (cell.contentView.subviews) {
                
                if view.tag == 77 {
                    view.removeFromSuperview() //badge
                }
                else if view.tag == 88 {
                    view.frame = CGRect(origin: CGPoint.init(x: view.frame.origin.x - 10, y: 0) , size: view.frame.size) //image
                }
                else if view.tag == 99 {
                    view.frame = CGRect(origin: CGPoint.init(x: view.frame.origin.x - 10, y: 0) , size: view.frame.size) //product name
                }
            }
            
        }
        
        if badgeValue > 0 {
            let badge = BadgeLabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
            badge.setup()
            badge.badgeValue = ""
            badge.badgeValue = "\(badgeValue)"
            badge.tag = 77
            cell.contentView.addSubview(badge)
            
            for view in (cell.contentView.subviews) {
                
                if view.tag == 88 {
                    view.frame = CGRect(origin: CGPoint.init(x: view.frame.origin.x + 10.0, y: 0) , size: view.frame.size) //image
                }
                else if view.tag == 99 {
                    view.frame = CGRect(origin: CGPoint.init(x: view.frame.origin.x + 10.0, y: 0) , size: view.frame.size) //product name
                }
                
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        var product:Product
        
        if searchText == "" {
            product =  products[(indexPath as NSIndexPath).row]
        }
        else {
            product =  productsTmp[(indexPath as NSIndexPath).row]
        }
        
        
        for view in (cell?.contentView.subviews)! {
            
            if view.tag == 99 {
                let firstlastname = view as! UILabel
                firstlastname.text =  "\(product.prod_nom) (user:\(product.prod_by_user))"
            }
            else if view.tag == 88 {
                let photo = view as! UIImageView
                if product.prod_imageUrl == "" {
                    photo.image = #imageLiteral(resourceName: "noimage")
                }
                else {
                    photo.image = BlackBox.sharedInstance.restoreImageArchive(prod_imageUrl: product.prod_imageUrl)
                }
                
            }
            
        }
        
        var i = 0
        for mess in Messages.sharedInstance.MessagesArray {
            
            let message = Message(dico: mess)
            
            if message.product_id == product.prod_id  && message.destinataire == self.config.user_id && message.deja_lu_dest == false {
                i+=1
            }
            
        }
        
        cell = chargeBadge(cell!, badgeValue: i)
        
        return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchText == "" {
            return products.count
            
        }
        else {
            return countProduct
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        aProduct = products[indexPath.row]
        performSegue(withIdentifier: "fromtable", sender: self)
        
        
    }
    
    
}
